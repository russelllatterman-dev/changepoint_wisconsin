%Insertion and Deletion code
%Used to provide evidence of a working insertion/deletion algorithm
clc
clf
demoCode = 2; %1 for basic demo, 2 for basic10intervals code
doAnimation = 0; %Set this to 1 to see animated demonstration
segmentMeans = [0];  %%%%% ---- %%%%% ---- %%%%% 

calculateInsertionProb = 1;

calculateDeletionProb = 1; %1 Calculate P1 and P0.  otherwise used fixed values


scaleFixedProbabilities = 0; %If we are going to fix them, we might want to scale the deletion relative

outputTextResults = 0;

%to the fixed insertion

P_insert_fixed = 1;
%P_insert_fixed = 1/175;
scaleConstant = 1;

if scaleFixedProbabilities == 1
   P_delete_fixed = scaleConstant*P_insert_fixed;
else
   P_delete_fixed = 1;
   %_delete_fixed = 1-P_insert_fixed; %Can only do this if the program has already been run
end
scaled = 0.9;
Xdata = Xt; % CAUTION this is currently derived from another program

%% Original Demo code 1
if demoCode == 1 
    w = 10; %interval width
    K = 4; %number of intervals to start with (num changepoints + 1)
    Kactual = 5; %true number of intervals
    Total = w*K; %total data
    phi = Kactual/Total;
     %First starting point S1 = S(1) = 1. Last endpoint
                           % is DK = T. The S vector thus includes all
                           % changepoints, and the last right endpoint.
    samples = 10;
    S_initial = [1,(1:(K-1))*w,Total]; %We store a series of progressions of 
    C_initial = zeros(1,K+1)-99; 
        %insertion and deletion for each step
    S = S_initial;
    C = C_initial;  %<<<<<<<<<<<<<<<<<
    C(1,1) = 1;
   % C = S_initial;
    
    kMax = 15;
    Svector = zeros(samples,kMax);
    Cvector = zeros(samples,kMax);

    Soriginal = S;
    Svector(1,1:length(S)) = S;  
    Cvector(1,1:length(C)) = C;
    %Cvector(1,1:length(C)) = S;   % <<<<<<< Temporarily has same values

    acceptanceProb = .5;
    boundDeletion  = .5;

    accept = false;
    acceptDeletion = false; 
    %We start off assuming there is at least one changepoint, and thus three
    %endpoints to deal with.
end %designed for a very basic demonstration

%% Demo code 2, includes initialization from bigger program
if demoCode == 2 
   samples = reps;
   %obs_per_seg; %interval width for true segments
   probInsertion = zeros(samples,Kmax)-8.888;
   probDeletion  = zeros(samples,Kmax)-8.888;
   
   K = Kguess;  Kactual = Ktrue;
   Total = T;
   %T is from original file
   phi = Kactual/T;
   Xdata = Xt; %Xt is from other file    
   Strue = [1,(1:(Ktrue-1))*obs_per_seg,Total];  %%%% <--------- needs to start off differently
   Ctrue = ck_segMeans(1,1:Ktrue);
   w = floor(Total/Kguess);
   
   S_initial = [1,(1:(K-1))*guessSpacing,Total]; %We store a series of progressions of 
        %insertion and deletion for each step
   S = S_initial;
   Sm = S; %<<<< changed
   Soriginal = S;
   
   
   G_initial = zeros(1,K+1) + 1; %By default, all groups are initially set to 1
   G = G_initial;
   
   kMax = 3*Kmax; %we will have a long vector of possible change points
   Kmax_original = Kmax;
   
   Svector = zeros(samples,kMax);
   Cvector = zeros(samples,kMax);
   Gvector = zeros(samples,kMax);
    
   Coriginal = ck_segMeans_0; %original generated data
   Goriginal = gk_segGroups_0; 
   
   %1 ... 20 ... 40 ... 60
   C_initial = zeros(1,K+1)-99;
   for i=1:(K-1)
        if i < (K-1)
            C(i) = mean(Xdata(S(i):S(i+1)-1));
        else
            C(i) = mean(Xdata(S(i):S(i+1)-1));
        end
   end
        %insertion and deletion for each step
   C = C_initial;  %<<<<<<<<<<<<<<<<<
   C(1,1) = 1;
   
   Svector(1,1:length(S)) = S; %Segment left endpoints (last element is right-most point)
   Cvector(1,1:length(C)) = C; %Segment means
   Gvector(1,1:length(G)) = G; %Groups corresponding to each segment
 
   accept = false;
   acceptDeletion = false; 
   
   %Strue = Strue; %Strue is the actual vector of points
end %Utilizes simulated data. Must run the basic10intervals code, first
    g_left = 1;
    g_right = 2;
    mu_g_1 = 0;      % <<< ----------- mu * NW * -- fixed
    mu_g_2 = 0;
    tau2_g_left = 4;    % <<< assume left and right group vaiances are equal
    tau2_g_right= 4; % Based on figure 4 page 11
    tau2_g = 4;
    pi_group1 = 0.5; 
    
    sig2error = 0.96; % Value from paper 
    psi = 0.22;  % From paper: fixed values between -1 and 1
    theta = 0.6; % From paper: fixed values between -1 and 1
    clc
   
%% Gibbs Sampler
Svector(1,1:length(S)) = S;
for rep = 1:samples
    K = length(S); % Our "S" vector contains the rightmost endpoint in this programming structure
    Snew = [1]; Cnew = C(1); Gnew = [1]; % List of new assignments for updating purposes
    
    if length(S) > 2    %<<<< possibly should change  to just evaluate Sm
        dLeft = S(1);  dPoint = S(2);  dRight = S(3);   
    end
    
    % TEXT RESULTS
    if outputTextResults == 1
        disp('.'); disp('.');
        disp(['Begin Sample: ' , num2str(rep)] ); disp(['K estimate = ' , num2str(K) ])
    end
    
    M = 0;
    Sm = S;
    for k = 1:(length(S)-1)
        M = M+1;
        %% Output messages, each step
        % TEXT RESULTS
        
        if k == 1
            ileft= 1;
        else
            ileft= Snew(length(Snew)); %This is because we keep adding points to "Snew"
        end
            
        if outputTextResults == 1
            disp('------')
            statement = ['insertion step k=',num2str(k),' of sample ',num2str(rep)]; disp(statement)
            
            disp(['S  =  ',num2str(S)])
            disp(['Sm =  ',num2str(Sm)])
            disp(['M = ', num2str(M)])
            disp(['Snew =  ',num2str(Snew)])
            disp(['C* =  ',num2str(Cnew)])
        end
        
        %% Accepance and Rejection Probabilities for insertion
        % must be calculated here.
        
        % Insertion step       
        if (S(k+1) - ileft) > 1 % If we don't have adjacent points then we will do the insertion step
            
            z = ileft+ ceil(rand()*((S(k+1)-ileft)-1))-1;
            
            % TEXT RESULTS
            if outputTextResults == 1
                disp(['z+1 = ',num2str(z+1)])
            end
            
            %% Acceptance probability step
            % Calculate new left and right groups
            %pi_group1 = 0.5; defined above   % <<< ----------- pi_group1 * NW * - fixed
       %% Group calculations (at first we just have a framework    
            if rand() < pi_group1   % <<< ------- pi_group1 NW * - fixed
                g_left = 1;
                mu_g_left = 0;      % <<< ----------- mu  * NW * - fixed
                tau2_g_left = 1;
            else
                g_left = 2;
                mu_g_left = 0;
                tau2_g_left = 1;
            end

            if rand() < pi_group1 
                g_right = 1; % % <<<<<<<< Sample using correct dist
                mu_g_right = 1;
                tau2_g_right = 1;
            else  %with only two groups, we only consider < pi_group1, or
                  % greater than
                g_right = 2;
                mu_g_right = 2;
                tau2_g_right = 2;
            end %group assignments
            
  %% proposed/randomly chosen new left and right interval means
            c_left  = normrnd(mu_g_left,sqrt(tau2_g_left));
            c_right = normrnd(mu_g_right,sqrt(tau2_g_right));
            
            % endpoints of intervals within which we perform our insertion
            % step       [S(k)   z] , [s2    S(k+1)-1] 
            s1 = ileft ;  % |s1----z  , z+1------(s3-1) S3------...
            s2 = z+1;
            s3 = S(k+1);    %************
                            %************
            intervalData = Xdata(s1:(s3-1));
            if outputTextResults == 1
                disp(['insertion interval: ',num2str(ileft),' ',num2str(s3)])  
            end
            leftData = Xdata(s1:z); %left and right lists of data with which
                %we perform our calculations
            nLeft = length(leftData); %number of data in left interval
            errorLeft = zeros(nLeft,1); %accosiated error terms
            
            rightData = Xdata((z+1):(s3-1)); %analagous for right side
            nRight = length(rightData);
            errorRight = zeros(nRight,1);
            
            %%        % <<<<<<<< left insertion error calculation     
            errorLeft(1) = leftData(1) - c_left; %First does not involve previous data
            if nLeft > 1 
                for j = 2:nLeft % only goes to next to last value in the list
                           % <<<<<<<<<< make sure psi is calculated correctly
                    lambda = c_left + psi*(leftData(j-1) - c_left) + theta*(errorLeft(j-1));
                    errorLeft(j) = leftData(j) - lambda;
                end
            end
            
            %% % <<<<<<<< right insertion error calculation
            % <<<<<<<< make sure it works for adjacent point cases
            errorRight(1) = rightData(1) - c_right;
            if nRight > 1
                for j = 2:nRight
                    lambda = c_right + psi*(rightData(j-1) - c_right) + theta*(errorRight(j-1));
                    errorRight(j) = rightData(j) - lambda;
                end
            end
            
            %% Full insertion error calc
            c_null = Cnew(length(Cnew));
            %c_null = mean(intervalData); % CAUTION <<<<<< This is NOT YET correct
            error_null = zeros(nLeft+nRight,1);
            error_null(1) = intervalData(1) - c_null; 
            %Null hypothesis is to reject the new change point
            for j = 2:(nLeft+nRight)
                lambda = c_null + psi*(intervalData(j-1)-c_null) + theta*error_null(j-1);
                error_null(j) = intervalData(j) - lambda;
            end
            
            %% Insertion probabilities
            % N_groups = 2; %number of groups a = 1; % order of AR process m = 1; % order of MA process
            K_now = length(S) - 1; %number of currently estimated segments (number of moves)
            % T_of_X = 4*X - 1 + 2*N_groups + a + m + 3;
            T_of_K = 4*K_now + 8;
            T_of_K_plus_one = 4*(K_now + 1) + 8;
            T_of_K_minus_one = 4*(K_now - 1) + 8; %To be used in the deletion step
            
            probTerms1 = normpdf(error_null,0,sqrt(sig2error));
            logProb1 = log(1-phi) + log(1/(s3-1-s1)) + log(1/T_of_K) + sum(log(probTerms1));
            %Prob1 = exp(logProb1);
            Prob1 = (1-phi)*1/(s3-1-s1)*1/(T_of_K)*prod(normpdf(error_null,0,sqrt(sig2error))); 
            
            probTerms0 = normpdf([errorLeft',errorRight'],0,sqrt(sig2error));
            logProb0 = log(phi) + log(1/T_of_K_plus_one) + sum(log(probTerms0));    
            Prob0 = exp(logProb0); % a lot faster to calculate it this way
            calculatedAcceptanceProb = Prob0/(Prob1+Prob0);
            
            if calculateInsertionProb == 1
                acceptanceProb = calculatedAcceptanceProb; %<-------- calculate this based on data
            else 
                acceptanceProb = P_insert_fixed;
            end
            
            probInsertion(rep,k) = calculatedAcceptanceProb;
            %% Insertion decision rule
            
            if outputTextResults == 1
                disp(['insertionProb ',num2str(acceptanceProb)])
            end
            
            if rand() < acceptanceProb
                insertionTrue = 1;
                
                Snew = [Snew,z+1];
                Sm = sort([Sm,z+1]); %<<<< changed
                M = M+1;  %<<<< changed
                %Cnew(length(Cnew)+1) = z+1;              %%%%%%% )))))))))) %%%%%%%%% )))))))))))
                Cnew(length(Cnew)) = c_left;
                Cnew = [Cnew,c_right];    
                
                if outputTextResults == 1
                    statement = 'insertion occurs, Snew includes new z+1'; 
                    disp(statement);
                    disp(['Snew =  ',num2str(Snew)])
                    disp(['Sm =  ',num2str(Sm)]) %<<<< changed
                    disp(['C* =  ',num2str(Cnew)])
                end

            else
                insertionTrue = 0;
                if outputTextResults == 1
                    statement = 'no new insertion, Snew not updated'; disp(statement);
                    disp(['Snew =  ',num2str(Snew)])
                end
            end
            
        else %If we have adjacents points, we can't insert a point between them
            adjacentPoints = 1;
            if outputTextResults == 1
                statement = 'adjacent points, Snew not updated'; 
                disp(statement);  
            end
        end % mean updates
        dleft = Snew(length(Snew)); %determines the left endpoint of the interval used
        % to do the deletion step
        
        
        %% Deletion step      
        %%%%%%%%%%%%           DELETION         %%%%%%%%%%%%
        %%%%%%%%%%%%                            %%%%%%%%%%%%
        %                      DELETION        
        %%%%%%%%%%%%                            %%%%%%%%%%%%
        %%%%%%%%%%%%                            %%%%%%%%%%%%  
        %%%%%%%%%%%%           DELETION         %%%%%%%%%%%%
        %%%%%%%%%%%%                            %%%%%%%%%%%%  
        if k < (length(S)-1)  
            if insertionTrue == 1  %|-----   |---------|------------|  
                                  %sk       z+1       S(k+1)      S(k+2)
                                  %|-----   |---------|------------|  
                                  %sk       Sm(M=k+1)       Sm(M+1=k+2)      S(k+2)
                 dleft = z+1;
                 dleft = Sm(M); %<<<< changed
                 firstDeletionStatement = 'interted point z+1, is the left side of the deletion interval';
                 leftDeletionData = rightData; %Data from z+1 to S(k+1) from the insertion step
            else                   %|----------------|------------|
                 %dleft = S(k);     %sk              S(k+1)      S(k+2) 
                 dleft = Sm(M); %<<<< changed
                 firstDeletionStatement = 'left side of deletion interval is S(K), no insertion occured';
            end
            %s1 = dleft;    %left---------- S(k+1)-1   S(k+1)---------S(k+2)-1
                           %dleft--------- S(k+1)-1   S(k+1)---------S(k+2)-1
                                                      %Sm(k+1) same
            dleft = Sm(M); %<<<< changed
            s1 = dleft;    %<<<< changed                      %     
            %s2 = S(k+1); %rather than choosing a z value, we use the value to the left of the point we are dealing with
            %s3 = S(k+2);
            
            s2 = Sm(M+1); %<<<< changed
            s3 = Sm(M+2); %<<<< changed
            
            %<<<< changed
            deletionInterval = [dleft,s2,s3];
            if outputTextResults == 1
                statement = ['Deletion step ',num2str(k)]; disp(statement); 
                disp(firstDeletionStatement)
                
                disp(['deletion interval = ',num2str(deletionInterval)])
            end
                         %|----------------|           |------------|    

            %% <------------ deletion probability we be calculated here
                  
            % PROBABILITY OF DELETION
           
            %hypothetical new segment mean is supposed to be chosen, here
            %New group chosen
           
            dc_null = 1;   %<<<<<<<<<<<<<<<<<< Calculate a new interval mean
            dc_left = 1;
            dc_right = 1;
            intervalData = Xdata(s1:(s3-1));
            %full interval calculation
            dc_null = mean(intervalData); % CAUTION <<<<<< This is NOT YET correct
            error_full = zeros((s3-s1),1);
            
            dErrorLeft = zeros(s2-s1,1);
            dXdataLeft = Xdata(s2-s1,1);
            
            dErrorRight = zeros(s3-s2,1);
            dXdataRight = Xdata(s3-s2,1);
            %dErrorRight
            error_full(1) = intervalData(1) - dc_null;
            for j = 2:length(intervalData)
                lambda = c_null + psi*(intervalData(j-1)-c_null) + theta*error_full(j-1);
                error_full(j) = intervalData(j) - lambda;
            end  
            
            dErrorLeft(1) = dXdataLeft(1) - dc_left;
            if length(dErrorLeft) > 1
                for j = 2:length(dXdataLeft)
                    lambda = dc_left + psi*(dXdataLeft(j-1)-dc_left) + theta*dErrorLeft(j-1);
                    dErrorLeft(j) = dXdataLeft(j) - lambda;
                end
            end
            
            dErrorRight(1) = dXdataRight(1) - dc_right;
            if length(dErrorRight) > 1
                for j = 2:length(dXdataRight)
                    lambda = dc_right + psi*(dXdataRight(j-1)-dc_right) + theta*dErrorRight(j-1);
                    dErrorRight(j) = dXdataRight(j) - lambda;
                end
            end

            T_of_K_minus_one = 4*(K_now-1) + 8; %Used in the deletion step
            
            probTerms1 = normpdf(error_full,0,sqrt(sig2error));
            dlogProb1 = log(1-phi) + log(1/(s3-1-s1)) + log(1/T_of_K_minus_one) + sum(log(probTerms1));
            dProb1 = exp(dlogProb1);
            %Prob1 = (1-phi)*1/(s3-1-s1)*1/(T_of_K)*prod(normpdf(error_null,0,sqrt(sig2error)))

            %% PROBABILITY OF REJECTING THE DELETION
      
            probTerms0 = normpdf([dErrorLeft',dErrorRight'],0,sqrt(sig2error));
            logProb0 = log(phi) + log(1/T_of_K) + sum(log(probTerms0));
            
            dProb0 = exp(logProb0); % a lot faster to calculate it this way
     
            %dataCalculation = (mean(Xdata(s1:s2)) + mean(Xdata((s2+1):(s3-1))))/2; %<<<< changed
           
            calculatedDeletionAccept = dProb1/(dProb0+dProb1);
            %dProb0 = 0.5; %
            
            if calculateDeletionProb == 1
                boundDeletion = calculatedDeletionAccept; %<-------- calculate this based on data
            else 
                boundDeletion = P_delete_fixed;
            end
               
            if outputTextResults == 1
                disp(['Deletion Prob ',num2str(boundDeletion)])
            end
            
            probDeletion(rep,k) = calculatedDeletionAccept;
            if rand() < boundDeletion
                
                if outputTextResults == 1
                    statement = 'Deletion occurs, deleted point not added to Snew'; 
                    disp(statement);
                    disp(['Snew =  ',num2str(Snew)])
                end
                
                %     
                %Sm(M)   Sm(M+1) = z+1     Sm(M+2)     S(length(Sm)) 
                
                Smn = [Sm(1:M),Sm((M+2):length(Sm))   ]; %<<<< changed
                Sm = Smn; %<<<< changed
                M = M - 1; %<<<< changed
                 
                %%%%% New mean has to be assigned to next interval
                Cnew(length(Cnew)) = dc_null; %<<<<<<<<<<<<<<<<<<<<
            else
                
                Snew(length(Snew)+1) = S(k+1);
                
                Cnew(length(Cnew)) = dc_left;
                Cnew = [Cnew,dc_right];
                
                if outputTextResults == 1
                    statement = 'No deletion, Snew now contains non-deleted point'; 
                    disp(statement);
                    disp(['Snew =  ', num2str(Snew)])
                    disp(['Sm = ', num2str(Sm)])
                    disp(['C* =  '  , num2str(Cnew)])
                end
                
            end
        end
            
    end% of segment loop |--|--|--|--|
    
    %Snew = [Snew, Total];
    %Cnew = [Cnew, Total]; 
    %S = [Snew, Total]; %<<<< changed
%     if rep == 1
%         Svector(1,1:length(S)) = S;
%     end
    S = Sm; %<<<< changed
    C = [Cnew, Total];
    %Svector((rep+1),1:length(S)) = S;
    Svector((rep+1),1:length(Sm)) = Sm; %<<<< changed  S to Sm
    Cvector((rep+1),1:length(C)) = C;
    %disp(Svector);
end %End sample loop


%% Plots
%disp(Svector)

sum(Svector(1:samples,kMax));
close all
f = figure('visible','off','Color','white');
f.Position = [0 200 550 600];
%movegui(f,'northwest')
shg
tiledlayout(3,1)

nexttile

for i = 1:length(Soriginal)
    xline(Soriginal(i),'linewidth',2,'color','blue')
end
title([num2str(Kguess - 1),' Initial guess locations'],'Interpreter','latex','FontSize',16)
xline(Soriginal(length(Soriginal)))



nexttile

for i = 1:(length(S))
    xline(S(i),'linewidth',2,'color','blue')
end
estimateTitle = [num2str(length(S)-1),' Estimated Segments'];
title(estimateTitle,'Interpreter','latex','FontSize',16)
xticks(S) 
nexttile 
for i = 1:(length(Strue))
    xline(Strue(i),'linewidth',2,'color','blue')
end
title([num2str(Ktrue),' Actual Segments'], 'Interpreter','latex','FontSize',16)
xticks(Strue)
hold on
plot(Xdata)
means_plot = plot(actualMeans,'red','LineWidth',2);

%% Animation 
if doAnimation == 1
    nexttile

    numLines = 0;
    for j = 1:size(Svector,1) %2 refers to rows
        %Go through each row and visually update


        a = 1;
        while a > 0
            numLines = numLines + 1;
            a = Svector(j,numLines);
        end
        %Snew_j = Svector(j,1:numLines);

        for k= 1:(numLines-1)
            xline(Svector(j,k),'linewidth',2,'color','blue')
        end
        xticks(Snew)

        drawnow 
        clf

        pause(.1)

        if j < size(Svector,1)
        for k= 1:(numLines-1)
            xline(Svector(j,k),'linewidth',3,'color','white')
        end
        xticks(Snew)
        end
        numLines = 0;
    %     length(Snew)
    %     for i=1:length(Snew_j)
    %         xline(Snew(i))
    %     end
    % 
    %     for i = 1:length(S)
    %         xline(Snew(i),'linewidth',2,'color','blue')
    %     end
    end

end 


mean(Sm)
median(Sm)