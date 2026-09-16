%Variance estimator
%Take in Xt,S, and C
%Standardize the data
%Estmate overall variance
%Estimate variance by group
doTrueVals = 0;

Xdata = Xt;
X_C_centered = zeros(1,length(Xdata));%Centered based on segment given segment means
X_M_centered = zeros(1,length(Xdata));%Centered based on sample means from segments

Xgroup1_C_centered = [];%Centered by segment ARMA mean
Xgroup2_C_centered = [];%Centered by sample mean

Xgroup1_M_centered = [];
Xgroup2_M_centered = [];

if doTrueVals == 1

    Svect = Strue;
    Kval = Ktrue;
    %K = length(Cm);
    
    %Svect  = Sm;
    Cvect = ck_segMeans(1,1:Kval);
else
    Svect = Sm(1:(length(Sm)-1));
    Kval = length(Svect);
    %K = length(Cm);
    
    %Svect  = Sm;
    Cvect = Cm;
end

Cvect1 = [];
Cvect2 = [];

Mvect1 = [];
Mvect2 = [];

for i = 1:Kval
    s1 = Svect (i);
    if i < Kval
        s2 = Svect(i+1)-1;
    else
        s2 = length(Xdata);
    end
    
    C_current  = ck_segMeans(1,i);
    
    X_C_centered(s1:s2) = Xdata(s1:s2) - C_current;
    X_M_centered(s1:s2) = Xdata(s1:s2) - mean(Xdata(s1:s2));
    
    gr = gk_segGroups(1,i);

    if gr == 1
       Cvect1 = [Cvect1, C_current];
       Mvect1 = [Mvect1, mean(Xdata(s1:s2))];

       Xgroup1_C_centered = [Xgroup1_C_centered, X_C_centered(s1:s2)]; %Centered by segment ARMA mean
       Xgroup1_M_centered = [Xgroup1_M_centered, X_M_centered(s1:s2)]; %Centered by sample mean
    end

    if gr == 2
       Cvect2 = [Cvect2,C_current]; %Segment ARMA means
       Mvect2 = [Mvect1, mean(Xdata(s1:s2))]; %Segment sample means
    
       Xgroup2_C_centered = [Xgroup2_C_centered, X_C_centered(s1:s2)]; %Centered by segment ARMA mean
       Xgroup2_M_centered = [Xgroup2_M_centered, X_M_centered(s1:s2)]; %Centered by sample mean
    end
   
end

%plot(Xgroup2_C_centered);

%Estimate ARMA parameters
sys1 = armax(X_M_centered', [1 1]);
sys2 = armax(X_C_centered', [1 1]);

Group1_ARMA_estimate = armax(Xgroup1_M_centered' , [1 1])
Group2_AMRA_estimate = armax(Xgroup2_M_centered' , [1 1])
