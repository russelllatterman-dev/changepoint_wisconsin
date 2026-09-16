%Posterior distribution for error terms

global psi;
global Xdata;
global theta;
global S;
global C;
global errorAll;
global psi_g;
global theta_g

errorNew = errorAll;
errorNew2 = errorAll;

Tend = length(Xdata); 
%We need this list for some of the posterior dist calculations
length_S = length(S);
for k = 1:(length_S-1)


    lower = S(k);
    
    if k == (length_S-1)
        upper = S(k+1); %We use the very last point in the list in this case
    else
        %upper = S(k+1) - 1;
        upper = S(k+1) - 1;
    end
       
    CK    = Cm(k);
    gr    = Gm(k);
    
    segLength   = upper - lower + 1;
    segError    = zeros(1,segLength);
    %segError2   = zeros(1,segLength);
    
    segData     = Xdata(lower:upper); 
    
    %CK = mean(segData);
    
    segData2    = Xdata(lower:upper)';%Data are organized 1 x T, so we transpose it to match the error vector dimension
    
    segError(1)  = segData(1) - CK;
    %segError2(1) = segData(1) - CK;
    
    if (upper - lower) > 0

        for j = 2:segLength %We reference psi_g whether we are dealing with one group or two groups
                
                lambda = CK + psi_g(gr)*(segData(j-1)-CK) + theta_g(gr)*segError(j-1);
                
                %lambda = CK + psi_g(gr)*(segData(j-1)-CK) + theta*segError(j-1);
                %lambda = CK + psi_g(gr)*(segData(j-1)-CK) + theta_g(gr)*segError(j-1); %THETA2
                segError(j) = segData(j) - lambda;
        end
          

        %Abbreviated way
        %segError2(2:segLength) = segData2(2:segLength) - ( CK + psi*( segData2(1:(segLength-1)) - CK) + theta*segError2( 1:(segLength-1)  )    );
    end
    
    %Lvect = CK + psi*(Xdata(lower:(upper-1))-CK) + theta*segError(j-1);
    %segError(2:(upper-lower)) = Xdata(lower:upper) - Lvect;

    errorAll(lower:upper)  = segError;
    %errorNew2(lower:upper) = segError2;
    %errorAll(lower:upper)  = segError2;
end

lambda = CK + psi_g(gr)*(Xdata(Tend-1)-CK) + theta_g(gr)*segError(length(segError)-1);%THETA2
errorAll(Tend) = Xdata(Tend) - lambda; %very last error value


%hold on
%plot(errorAll)
%hold on
