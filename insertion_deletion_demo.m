
% a_start_initialization    must be run at least once before this file can be run
%This file can be run over and over using the information from a_start_initialization
%  ----> plots_demo
%  ----> tracePlot_group_updates
%  outputs means for several parameters are given

%% Global variables
counter1 = 0;
%hi
global thetaEstimates
global psiEstimates
global theta_g
global theta
global thetaEstimatesGroups %THETA2
global psi_right
global psi_left
global theta_left
global theta_right
global psi_null %psiEstimatesGroups(g_null); %psi_null = psiEstimatesGroups(g_null);
global theta_null

global Ktrue        % Actual number of estimates
global obs_per_seg  %observations per segment
global Kguess       % Initial guess number of segments
global runDemoFile  % determines whether we run the demo file
global do_demo2_basic
global thetaMA_0
global phi_0
global Strue
global Kmax
global T

global Xt

global tauG1_fixed  %<----- March14 change
global tauG2_fixed
global muG1_fixed
global muG2_fixed
global psiAR_0paper 

global sig2_0paper

global gk_segGroups
global ck_segMeans

global gk_groupMeans            %< Group work
global gk_groupVariances        %< Group work
global gk_groupProbabilities    %< Group work
global gk_groupPsi              %< Group work

global psiEstimatesGroups %samples x groups
global psi_g    %[psi1, psi2]

global gk_groupTheta


global ck_segMeans_0
global gk_segGroups_0

global phiTrue
global Kmax
global pi_0

global whichUpdate %which segment mean to update
global errorAll

global samples

global psi

global CmeansVector
counter1 = 0;
%%
doNewUpdates = 1; % Runs posterior_mean
run_debug_meanCheck = 0;
debugMeanCheckTime = 0;
outputTextResults  =  0;


clc
%clf
close all
exceptions = 0;
problems_with_psi = 0;

adjacentPointCount = 0; %Counts how many times we end up having adjacent points
possibleInsertionSteps = 0; %Counts how many times we attempt to do an insertion step
insertionStepsPerformed = 0; %Counts how many times we can do the insertion step
                            %(we can't do the insertion step if we have
                            %adjacent points)
%% Startup options
tic

doRegressionTest = 0; %This fits a least squares regression line to every segment
%Every sinlge itteration. It is shown that this takes almost no extra
%computational time.

Xdata = Xt;
if do_imported_data == 1
   Xt    = Xwell;
   Xdata = Xwell;
end
excludeLowerData = 0; % Removes burn-in before doing trace plots


%psi_two_groups   = 1; This is determined in the "basic10intervals" file
%psi0_guess         = .22;

%psi0_guess = rand(); %Nov 18
 %Nov 18

%psi0_guess = psiAR_0paper;
%psi0_guessGroups = psi_g_true;  %% <---- AR(1) two groups
updatePSI        = 1; % AR PSI %%%%%%
updateTheta  =   1;  % MA  THETA%%%%%%

if updateTheta == 1
    theta0_guessGroups = [2*(rand()-1/2),2*(rand()-1/2)]; %%THETA2
    theta0_guess = theta0_guessGroups(1);
else
    theta0_guessGroups  =  [thetaMA_0,thetaMA_0]; %THETA2
    theta0_guess        =  theta0_guessGroups(1); %THETA2
end

%theta0_guess       =  -.6;
%theta0_guess = rand();
updatePHI           =   1;  % PHI  %%%%%%%%%
updateSig2error     =   1;  
updateGroupMeans    =   1;
updateGroupVariances =  1;
%muEstimates = zeros(2,samples);
%posterior_mu_groups
%updateGroupAssignments = 0;

doNewGroupUpdate        =  1; %<---- posterior_mean file, I changed this to update groups properly
doInsertionMeanUpdates  =  1; % Runs poserior_mean  file
doDeletionMeanUpdates   =  1;
plotEachInsertion       =  0;
plotEachDeletion        =  0;

                            %Acceted        %total        %Proportion
deletionCount  = zeros(length(Xdata),3);  %Which points were chosen and when were they deleted?
insertionCount = zeros(length(Xdata),3); %When did we attempt to insert points and when did result in an insertion?

%% Define vectors to store everything

%% muEstimates is probably no longer being used
muEstimates = zeros(2,samples); % estimates for group means: Row 1 is for group 1, column 2 is for group 2
psiEstimates = zeros(1,samples);
psiEstimatesGroups = zeros(samples,2); % <---- AR(1) two groups
            % Used for estimating psi when we consider a different value of psi for one of two groups

thetaEstimates      = zeros(1,samples);
thetaEstimatesGroups = zeros(samples,2); %THETA2

phiEstimates        = zeros(1,samples);

sig2Estimates       = zeros(1,samples);
sig2Estimates(1)    = sig2_0paper;

thetaMeans          = zeros(1,samples);  %We will analyze the mean and variance of the posterior dist for theta
adjustedThetaMeans  = zeros(1,samples);
thetaVariances      = zeros(1,samples);

kMaximum_estimate   =    Kmax;
groupMu_fixed       = [  muG1_fixed ,  muG2_fixed  ];
groupTau_fixed      = [ tauG1_fixed , tauG2_fixed  ];

gk_groupPsi         = zeros(samples,2);
gk_groupTheta       = zeros(samples,2);


%Insertion and Deletion code
%Used to provide evidence of a working insertion/deletion algorithm



numExceptions = 0; %%<----- Prob debug March 21 this counts how many times we get a problem where the program things both insertion and deletion probs are zero
 
demoCode = 2; %1 for basic demo, 2 for basic10intervals code, which is actually the main code

doAnimation = 0; %Set this to 1 to see animated demonstration
segmentMeans = [0];  %%%%% ---- %%%%% ---- %%%%% 



calculateInsertionProb = 1;

calculateDeletionProb = 1; %1 Calculate P1 and P0.  otherwise used fixed values
P_insert_fixed = 0;

P_delete_fixed = 0;

doRegularProb = 1;
doRegular_errorRepair = 2;
doProbCalc_markov = 3;
doProbCalc_logMarkov = 4;
probType = [doRegularProb , doRegular_errorRepair, doProbCalc_markov, doProbCalc_logMarkov];

pIn = zeros(samples,kMaximum_estimate);
pDel = zeros(samples,kMaximum_estimate);

tau2basic = 16; % needs to match the main program
muBasic = 0;

doSimpleMeans = 0; %simple

scaleFixedProbabilities = 0; %If we are going to fix them, we might want to scale the deletion relative
%reps = 100;
%to the fixed insertion
% 
% if do_imported_data == 1
%     Xdata2 = importdata('well_data');
%     Xdata = Xdata2(1:4000);
% else
%     Xdata = Xt; % CAUTION this is currently derived from another program
% end
insertedYet = 0;

%errorAll = et;

%% Demo code 2, includes initialization from bigger program
if demoCode == 2 
   
   insertionTrue = 0;
   %samples = reps; %From main code
   %obs_per_seg; %interval width for true segments
   probInsertion = zeros(samples,Kmax,2)-8.888;
   probDeletion  = zeros(samples,Kmax,2)-8.888;

   newInProb  = zeros(samples,length(Xdata),2); %Stores insertion and deletion probs and locations
   newDelProb = zeros(samples,length(Xdata),2);
   
   K = Kguess;  
   Kactual = Ktrue;
   Total = T;
   %T is from original file              
   %phi = .1;  % This is normally defined later in the code
   %phi = (Kactual-1)/T;  %This is supposed to represent the probability of a changepoint randomly occuring, but when set to the "correct" value, it overestimates change points
   %phi = phiTrue; %This is from the main program
   
   phi = phi_0; %%%% March 21 see if this matters
   phiEstimates(1) = phi;
   %phi = 0.9;
  
   Xdata = Xt; % CAUTION this is currently derived from another program

   %Xdata = Xt; %Xt is from other file    
   %Strue = [1,(1:(Ktrue-1))*obs_per_seg,Total];  %%%% <--------- needs to start off differently
   Sactual = [Strue,Total];   %Based on previous code, but we add the last data point in this file
   errorAll = zeros(1,Total); 
   Ctrue = ck_segMeans(1,1:Ktrue);
   Gtrue = gk_segGroups_0(1:(Ktrue));
   
   w = floor(Total/Kguess);
   
   %S_initial = [1,(1:(K-1))*guessSpacing,Total]; %We store a series of progressions of 
        %insertion and deletion for each step
        
   S_initial = [0,(1:(K-1))*guessSpacing]+1; %Not sure if we are using this 
   S_initial = [S_initial,Total];    
   S = S_initial;
   Sm = S; %<<<< changed
   Soriginal = S;
   
   kMaximum_estimate = Kmax; %we will have a long vector of possible change points
   Kmax_original = Kmax;
   
   Svector = zeros(samples,kMaximum_estimate);   
   Cvector = zeros(samples,kMaximum_estimate);
   Gvector = zeros(samples,kMaximum_estimate);
    
   Coriginal = ck_segMeans_0; %original generated data
   Goriginal = gk_segGroups_0; 
   
   %1 ... 20 ... 40 ... 60
   C_initial = zeros(1,K); %Initial guess values for segments means will be the means of the data on the initial segment guesses
   %Initial segment and group estimates
   G_initial = zeros(1,K); %By default, all groups are initially set to 1
   
   for i = 1:(K)
        if i < (K-1)
            C_initial(i) = mean( Xdata(S(i):(S(i+1)-1)) );
        else
            C_initial(i) = mean( Xdata(S(i):S(i+1)));
        end
        
       % avgGroupMeans = muG1_fixed + 
        %if C_initial(i) <= mean(Xdata)         %For now, group 2 has positive mean
        if C_initial(i) <= 0    
            G_initial(i) = 1;       % and group 1 has nevagive mean
        else
            G_initial(i) = 2;
        end
       
   end
   C = C_initial;
   Cm = C;

   debug_meanCheck %What is this?

   G = G_initial;
   Gm = G;
   
   %C_initial = Ctrue;
   %C = C_initial;
   
        %insertion and deletion for each step
   %C = C_initial;  %<<<<<<<<<<<<<<<<<
   %C(1,1) = 1;
   
   Svector(1,1:length(S)) = S; %Segment left endpoints (last element is right-most point)
   Cvector(1,1:length(C)) = C; %Segment means
   Gvector(1,1:length(G)) = G; %Groups corresponding to each segment
 
   accept = false;
   acceptDeletion = false; 
   
   %Strue = Strue; %Strue is the actual vector of points
end %Utilizes simulated data. Must run the basic10intervals code, first
%group means and variances  %< ----- CHECK THIS

g_left = 1;  %  <------ needs to match main code
g_right = 2; %  
mu_g_1   = muG1_fixed;      % <<< ----------- mu * NW * -- fixed
mu_g_2   = muG2_fixed;         %<----- March14 change
tau2_g_1 = tauG1_fixed;    % <<< assume left and right group vaiances are equal
tau2_g_2 = tauG2_fixed; % Based on figure 4 page 11
tau2_g   = tauG1_fixed;       %<----- March14 change %<----- March14 change %<----- March14 change


if do_random_generation == 1 %<--- work on this
    pi_group1 = pi1;
    mu_g_1   = m1;      % <<< ----------- mu * NW * -- fixed
    mu_g_2   = m2;         %<----- March14 change
    tau2_g_1 = t1;    % <<< assume left and right group vaiances are equal
    tau2_g_2 = t2; % Based on figure 4 page 11
    tau2_g   = [t1,t2];       
else
    pi_group1 = pi_0; %0.5; 
end

pi_group2 = 1 - pi_group1;%<----- March14 change
sig2error = sig2_0paper; % 0.96; % Value from paper 



%Initial Starting Values for psi and theta

if updatePSI == 1
    %psi = psiAR_0paper;
    psi0_guessGroups = [2*(rand()-1/2),2*(rand()-1/2)];
    psi0_guess = psi0_guessGroups(1);
    psi = psi0_guess;
    psi_g = [psi0_guessGroups(1), psi0_guessGroups(2)]; %% NOV27
    psiEstimates(1) = psi0_guess;
    psiEstimatesGroups(1,1) = psi0_guessGroups(1);  %% <---- AR(1) two groups;
    psiEstimatesGroups(1,2) = psi0_guessGroups(2);
else  
    psi = psiAR_0paper; %.22  % From paper: fixed values between -1 and 1
    psi_g = [psiAR_0paper,psiAR_0paper];
    psiEstimates(1) = psiAR_0paper;
    psiEstimatesGroups(1,1) = psiAR_0paper; % <---- AR(1) two groups;
    psiEstimatesGroups(1,2) = psiAR_0paper; % <---- March 21 change these 
    % to access actual variables
end

if updateTheta == 1
    %theta = thetaMA_0; 
    theta0_guessGroups = [2*(rand()-1/2),2*(rand()-1/2)]; %%THETA2
    theta0_guess = theta0_guessGroups(1);
    theta = theta0_guess;
    theta_g = [theta0_guessGroups(1),theta0_guessGroups(2)]; %THETA2 
else
    %theta = 0.90;
    theta0_guessGroups  =  [thetaMA_0,thetaMA_0]; %THETA2
    theta0_guess        =  theta0_guessGroups(1); %THETA2
    theta = thetaMA_0; % From paper: fixed values between -1 and 1
    theta_g = [thetaMA_0, thetaMA_0]; %THETA2
end
thetaEstimates(1) = theta;
thetaEstimatesGroups(1,1) = theta_g(1); %THETA2
thetaEstimatesGroups(1,2) = theta_g(2); %THETA2
    
if updateGroupMeans == 1  %We can decide on how to make our initial estimates later
    mu_g_1 = muG1_fixed;  %This needs to be randomized
    mu_g_2 = muG1_fixed;
else
%This code might not be needed
end
muEstimates(1,1) = mu_g_1; % X These probably won't be needed
muEstimates(2,1) = mu_g_1; % X These probably won't be needed

clc
   
%%                   Gibbs Sampler 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Svector(1,1:length(S)) = S;
startTime = datetime;

startPlotWindowFirst = 1;
if startPlotWindowFirst == 1
   plots_demo_beforeSim
   pause(0.01) %It wouldn't show up without running this pause funtion
end


errorAll = et;

for doubleRun = 1:1
    % if doubleRun == 1
    %     thisMany = samples;
    % else
    %     thisMany = samples;
    % end
            %2
    %error_update %Does this need to be here

for rep = 1:samples

    K = length(S)-1; % Our "S" vector contains the rightmost endpoint in this programming structure
    Snew = [1]; Cnew = C(1); Gnew = [1]; % List of new assignments for updating purposes
    
    if length(S) > 2    %<<<< possibly should change  to just evaluate Sm
        dLeft = S(1);  dPoint = S(2);  dRight = S(3);   
    end
    % TEXT RESULTS
    if outputTextResults == 1
        disp('.'); disp('.'); disp('.'); disp('.'); disp('.');
        
        disp(['Begin Sample: ' , num2str(rep),'    K estimate = ' , num2str(K) ])
        disp('.'); disp('.');
    end
    
    M = 0;
    Sm = S;
    Cm = C;   
    debug_meanCheck;
    Cindex = 1;
    
    for k = 1:(length(S)-1)
        possibleInsertionSteps = possibleInsertionSteps + 1;
        M = M+1; 
        if k == 1
            ileft = 1;
        else
            ileft = Snew(length(Snew)); %This is because we keep adding points to "Snew"
        end
        %% Output messages, each step
        % TEXT RESULTS    
        if outputTextResults == 1
            statement = ['            step k= ',num2str(k),'    of ', num2str(K),' for sample ',num2str(rep)];
            disp(['      ------- INSERTION ----------  ', statement])
            disp('');
            
            disp(['S  =  ',num2str(S)])
            disp(['Sm =  ',num2str(Sm)])
            disp(['C  =  ',num2str(C)])
            disp(['Cm  =  ',num2str(Cm)]) 
            
            disp(['G  =  ',num2str(G)])
            disp(['Gm  =  ',num2str(Gm)])
            
            disp(['Cindex:', num2str(Cindex)])
            disp(['M = ', num2str(M)])
            disp(['Snew =  ',num2str(Snew)])
            %disp(['Cnew =  ',num2str(Cnew)])
        end
        
        %% Accepance and Rejection Probabilities for insertion
        % must be calculated here.
        % Insertion step
        whichUpdate = 1; %If we do an update, 1 means insertion update

        %doInsertionStep = 1;
        doInsertionStep = 0; %If we do the insertion step, this will be set to 1
        if (S(k+1) - ileft) > 1 % If we don't have adjacent points then we will do the insertion step
             %1 means an insertion occurs when we run the posterior mean file
                            %2 means we are doing an update after a
                            %deletion
            doInsertionStep = 1;

            z = ileft + ceil(rand()*((S(k+1)-ileft)-1))-1;
            % TEXT RESULTS
            if outputTextResults == 1
                disp(['z+1 = ',num2str(z+1)])
            end
            
            %% Acceptance probability step
            % Calculate new left and right groups
            %pi_group1 = 0.5; defined above   % <<< ----------- pi_group1 * NW * - fixed
       %% Group calculations (at first we just have a framework    

            if do_demo2_basic == 1 %just do a fixed assignment
                c_left  = normrnd(muBasic,sqrt(tau2basic));
                c_right = normrnd(muBasic,sqrt(tau2basic));
                
            else %Group assigned means
                
                g_left = 1; g_right = 1;
                %pi_group1 = gk_groupProbabilities(rep,2); %Nov 20
                if rand() > pi_group1
                   g_left = 2;
                end
                
                if rand() > pi_group1
                   g_right = 2;
                end

                if rep > 1      
                    psi_left  = psiEstimatesGroups(rep,g_left); %Nov 18th 
                    psi_right = psiEstimatesGroups(rep,g_right); %Nov 18th
                    pi_group1 = gk_groupProbabilities(rep,1); %Dec 9 changed to 1 instead of 2
                else
                    psi_left  = psi_g(g_left);
                    psi_right = psi_g(g_right);
                end            
                
                mu_left  = gk_groupMeans(rep,g_left);
                mu_right = gk_groupMeans(rep,g_right);
                % 
                var_left  = gk_groupVariances(rep,g_left);
                var_right = gk_groupVariances(rep,g_right);
                % 
                c_left  = normrnd(mu_left , sqrt(var_left)  );
                c_right = normrnd(mu_right, sqrt(var_right) );
                
                
                theta_left = theta;  % THETA2
                theta_right = theta; % THETA2
                if doNewUpdates == 1
                    theta_left = theta_g(g_left);
                    theta_right = theta_g(g_right);
                end

                %c_left  = normrnd(groupMu_fixed(g_left),sqrt(groupTau_fixed(g_left)));
                %c_right = normrnd(groupMu_fixed(g_right),sqrt(groupTau_fixed(g_right)));
                
            end
  %% proposed/randomly chosen new left and right interval means
            
            % endpoints of intervals within which we perform our insertion
            % step       [S(k)   z] , [s2    S(k+1)-1] 
            s1 = ileft;  % |s1----z  , z+1------(s3-1) S3------...
            s2 = z+1;
            s3 = S(k+1);    % ************
            rightEndpoint = s3-1;                % ************
            if k == (length(S)-1)
                rightEndpoint = s3; %%At the very end we include the right endpoint
            end
            intervalData = Xdata(s1:(rightEndpoint));
 
            leftData = Xdata(s1:z); %left and right lists of data with which
                %we perform our calculations
            nLeft = length(leftData); %number of data in left interval
            errorLeft = zeros(nLeft,1); %accosiated error terms
            
            rightData = Xdata((z+1):(rightEndpoint)); %analagous for right side
            
            nRight = length(rightData);
            errorRight = zeros(nRight,1);
            
             if outputTextResults == 1
                disp(['insertion interval: ',       num2str(ileft), '           ',num2str(s3)]); 
                disp(['proposed insertion: ',       num2str(ileft), '    ',    num2str(z+1), '    ' num2str(s3)]);
                disp(['                  ','  C left','  C right']);
                
                disp(['  Proposed cL, cR : ',       num2str(c_left),'  ',num2str(c_right)]);
                %disp(['     Current Ck   :', '     ',num2str(Cnew(length(Cnew))) ]);
                disp(['Data Means        : ',       num2str(mean(leftData)),'  ',num2str(mean(rightData))]);
                disp(['Full interval mean: ','     ', num2str(mean(intervalData))]);
             end
            
            
            
            %%        % <<<<<<<< left insertion error calculation     
            errorLeft(1) = leftData(1) - c_left; %First does not involve previous data
            if nLeft > 1 
                for j = 2:nLeft % only goes to next to last value in the list
                           % <<<<<<<<<< make sure psi is calculated correctly
                    if doNewUpdates == 1      
                        lambda = c_left + psi_left*(leftData(j-1) - c_left) + theta_left*(errorLeft(j-1)); %Nov 18th
                    else
                        lambda = c_left + psi_left*(leftData(j-1) - c_left) + theta*(errorLeft(j-1)); %Nov 18th
                    end
                    %lambda = c_left + psi*(leftData(j-1) - c_left) + theta*(errorLeft(j-1));
                    errorLeft(j) = leftData(j) - lambda;
                end
            end
            
            %% % <<<<<<<< right insertion error calculation
            % <<<<<<<< make sure it works for adjacent point cases
            errorRight(1) = rightData(1) - c_right;
            if nRight > 1
                for j = 2:nRight
                    
                    if doNewUpdates == 1
                        lambda = c_right + psi_right*(rightData(j-1) - c_right) + theta_right*(errorRight(j-1));
                    else
                        lambda = c_right + psi_right*(rightData(j-1) - c_right) + theta*(errorRight(j-1));
                    end
                    %lambda = c_right + psi_g(2)*(rightData(j-1) - c_right) + theta*(errorRight(j-1));
                    
                    %lambda = c_right + psi*(rightData(j-1) - c_right) + theta*(errorRight(j-1));
                    errorRight(j) = rightData(j) - lambda;
                end
            end
            
            %% Full insertion error calc
            %c_null = Cnew(length(Cnew));     
            c_null = Cm(Cindex);                 %<----- March14 change %<----- March14 change %<----- March14 change
            g_null = Gm(Cindex);            % March 21
            
            psi_null = psiEstimatesGroups(rep,g_null); %Nov 18 %Could just do psi_g(g_null)
       
            theta_null = thetaEstimatesGroups(rep,g_null);
            
            %theta_null = theta;
            %theta_null = thetaEstimatesGroups(gnull); THETA2

            %c_null = mean(intervalData); % CAUTION <<<<<< This is NOT YET correct
            error_null = zeros(nLeft+nRight,1);
            error_null(1) = intervalData(1) - c_null; 
            %Null hypothesis is to reject the new change point
            for j = 2:(nLeft+nRight)

                if doNewUpdates == 1
                    lambda = c_null + psi_null*(intervalData(j-1)-c_null) + theta_null*error_null(j-1); %Nov 18
                else
                    lambda = c_null + psi_null*(intervalData(j-1)-c_null) + theta*error_null(j-1); %Nov 18
                end
                %lambda = c_null + psi*(intervalData(j-1)-c_null)     + theta*error_null(j-1);
                error_null(j) = intervalData(j) - lambda;
            end
           
            
            
            %% Insertion probabilities
            % N_groups = 2; %number of groups a = 1; % order of AR process m = 1; % order of MA process
            K_now = length(S) - 1; %number of currently estimated segments (number of moves)
            % T_of_X = 4*X - 1 + 2*N_groups + a + m + 3;
            T_of_K = 4*K_now + 8;      %%%%%%%% <---- CAUTION July 11
            T_of_K_plus_one = 4*(K_now + 1)  + 8;
            T_of_K_minus_one = 4*(K_now - 1) + 8; %To be used in the deletion step
            
            probTerms1 = normpdf(error_null,0,sqrt(sig2error))';
            logProb1 = log(1-phi) + log(1/(s3-1-s1)) + log(1/T_of_K) + sum(log(probTerms1));
            Prob1 = exp(logProb1);
            %Prob1 = (1-phi)*1/(s3-1-s1)*1/(T_of_K)*prod(normpdf(error_null,0,sqrt(sig2error))); 
            
            probTerms0 = normpdf([errorLeft',errorRight'],0,sqrt(sig2error));

            %----> could save time by doing direct calculations instead of
            %normal samples


            logProb0 = log(phi) + log(1/T_of_K_plus_one) + sum(log(probTerms0));    
            Prob0 = exp(logProb0); % a lot faster to calculate it this way
            
            %calculatedAcceptanceProb = Prob0/(Prob1+Prob0);

            log_calculatedAcceptanceProb = logProb0 - log(Prob1+Prob0); % Jul 1  This seems to finally make the non-markove way work
            calculatedAcceptanceProb = exp(log_calculatedAcceptanceProb);
            
            sortedProb1 = sort(probTerms1);
            sortedProb0 = sort(probTerms0);
      
            sortedP0_P1_ratio = sortedProb0./sortedProb1;
            logSorted = log(sortedP0_P1_ratio);
            
            gamma = phi/(1-phi)   *   T_of_K/T_of_K_plus_one   *    (nRight+nLeft - 1); %<--- March 28 minus 1 change 
            
            logP0_over_P1 = log(gamma) + 1/sqrt(2*pi*sig2error)*sum((error_null'.^2-[errorLeft',errorRight'].^2));
            
            %doRegularProb = 1;
            %doRegular_errorRepair = 2;
            %doProbCalc_markov = 3;
            %doProbCalc_logMarkov = 4;
            %probType = [doRegularProb , doRegular_errorRepair, doProbCalc_markov, doProbCalc_logMarkov];

            %pIn = zeros(reps,kMax);
            %pDel = zeros(reps,kMax);
        
           
            logAccept = min(0,logP0_over_P1);
            
            calcType = probType(4); %doProbCalc_logMarkov

            if calculateInsertionProb == 1
                if calcType == 4            %Set this to something other than 4 to test the non-markov way
                    acceptanceProb = logAccept;
                    randVal = log(rand());
                else
                    acceptanceProb = calculatedAcceptanceProb;
                    randVal = rand();
                end %<-------- calculate this based on data
                
            else 
                acceptanceProb = P_insert_fixed; % for debugging. Sets fixed prob of insertion
            end
            probInsertion(rep,k,1) = calculatedAcceptanceProb; %Stores insertion and deletion probabilities
            probInsertion(rep,k,2) = z+1; %Stores insertion and deletion probabilities
            
            newInProb(rep,z+1,1) = newInProb(rep,z+1,1) + calculatedAcceptanceProb;
            newInProb(rep,z+1,2) = newInProb(rep,z+1,2) + 1;

            pIn(rep,k) = calculatedAcceptanceProb;
           
            if outputTextResults == 1
                disp(['log( insertionProb ) ',num2str(acceptanceProb)])
            end
            
            LC = length(Cm);
            LG = length(Gm);
            Cm_previous = Cm;
            Gm_previous = Gm;
            
            if abs(LC - LG) > 0
                disp('error, lengths not equal')
            end
            
            originalC_index = Cindex;
            if randVal < acceptanceProb            %*****************      INSERTION OCCURRS   **********************

                insertionTrue = 1;
                Snew = [Snew,z+1];
                Sm_previous = Sm;
                Sm = sort([Sm,z+1]); %<<<< changed  %sort
                
                if outputTextResults == 1
                    statement = 'insertion occurs, Snew includes new z+1'; 
                    disp(statement);
                    disp(['Snew =  ',num2str(Snew)]);
                    disp(['Sm =  ',num2str(Sm)]); %<<<< changed
                    %disp(['C* =  ',num2str(Cnew)])
                end
   
                M = M+1;  %<<<< changed
                %Cnew(length(Cnew)+1) = z+1;              %%%%%%% )))))))))) %%%%%%%%% )))))))))))
                
                if LC == 1
                    
                    
                    if doInsertionMeanUpdates == 1 %1          %     CASE 1
                        posterior_mean %run this file to update means         posterior mean file

                        Cm = [leftMeanUpdate ,rightMeanUpdate];   
                        Gm = [leftGroupUpdate,rightGroupUpdate];
                        debug_meanCheck;

                        if leftMeanUpdate == 0 || rightMeanUpdate == 0
                            disp(['Insertion Zero Mean:  ',' rep ', num2str(rep)], 'code line 750ish of insertion_deletion_demo')
                            disp('   if LC == 1')
                            disp('        if leftMeanUpdate == 0 || rightMeanUpdate == 0')
                            pause
                        end

                    else

                        Cm = [c_left         ,c_right];   
                        Gm = [g_left         ,g_right];
                        debug_meanCheck;

                        if c_left == 0 || c_right == 0
                            disp(['Insertion Zero Mean:  ',' rep ',num2str(rep),' zero mean inserted'])
                        end
                    end   

                    if outputTextResults == 1
                        disp('Had only one segment. We will not do a deletion step')
                        disp(['Cm = ', num2str(Cm)]) 
                        disp(['Gm = ', num2str(Gm)])
                        disp(['Cindex not increased: ', num2str(Cindex)])
                    end
                end
                
                
                if LC > 1 && originalC_index == 1 %We are at the very left end of C
                      
                   if doInsertionMeanUpdates == 1 %2         %     CASE 2

                        posterior_mean %run this file to update means         posterior mean file
                        Cm = [leftMeanUpdate ,rightMeanUpdate ,Cm((Cindex+1):LC)];   
                        debug_meanCheck;
                        Gm = [leftGroupUpdate,rightGroupUpdate,Gm((Cindex+1):LC)];
                        if leftMeanUpdate == 0 || rightMeanUpdate == 0
                            disp(['Insertion Zero Mean:  ',' rep ', num2str(rep), 'code line 750ish of insertion_deletion_demo'])
                            pause
                        end

                        for i = 1:length(Cm)
                            if i == 0
                                disp(['Insertion Zero Mean:  ',' rep ', num2str(rep), 'code line 790ish of insertion_deletion_demo'])
                                disp('  LC > 1 && originalC_index == 1 %We are at the very left end of C')
                                disp('    ')
                                pause
                            end
                        end
                   else    
                        %rightMeanUpdate = g_left;
                        %leftMeanUpdate  = c_left;

                        Cm = [c_left         ,c_right         ,Cm((Cindex+1):LC)];   
                        debug_meanCheck;
                        Gm = [g_left         ,g_right         ,Gm((Cindex+1):LC)];
                        for i = 1:length(Cm)
                            if i == 0
                                    disp(['Insertion Zero Mean:  ',' rep ', num2str(rep), 'code line 790ish of insertion_deletion_demo'])
                                    disp('       ')
                                    disp('       if LC > 1 && originalC_index == 1 %We are at the very left end of C')
                                    disp('')
                                    pause
                            end
                        end
                   end
                   Cindex = Cindex+1;
                   
                   if outputTextResults == 1
                        disp('We were at the start of the list and had more than one segment')
                        disp(['Cm = ', num2str(Cm)])
                        disp(['Gm = ', num2str(Gm)])
                        disp(['Cindex = ', num2str(Cindex)])
                   end
                end
                    %s1      s2       s3
                    %|       |        |        
                    %c1      c2
                    %s1  z   s2       s3
                    %cL  cR  c2
                
                if LC > 1 && originalC_index > 1          %     CASE 3
                   if originalC_index == LC %run this file to update means         posterior mean file
     
                       if doInsertionMeanUpdates == 1
                            posterior_mean %3
                               %posterior_mean outputs leftMeanUpdate
                                                       %rightMean update
                            Cm = [ Cm(1:(Cindex-1)),leftMeanUpdate ,rightMeanUpdate ,Cm((Cindex+2):LC) ];   debug_meanCheck;
                            Gm = [ Gm(1:(Cindex-1)),leftGroupUpdate,rightGroupUpdate,Gm((Cindex+2):LC) ];
                       else  
                            Cm = [ Cm(1:(Cindex-1)),c_left         ,c_right         ,Cm((Cindex+2):LC) ];   debug_meanCheck;
                            Gm = [ Gm(1:(Cindex-1)),g_left         ,g_right         ,Gm((Cindex+2):LC) ];
                       end

                       for i = 1:length(Cm)
                            if Cm(i) == 0
                                    disp(['Insertion Zero Mean:  ',' rep ', num2str(rep), 'code line 790ish of insertion_deletion_demo'])
                                    disp('      if LC > 1 && originalC_index > 1          %     CASE 3 ')
                                    disp('')
                                    pause
                            end
                        end
                        
                        if outputTextResults == 1
                            disp('We are at the end of the list. We will not do a deletion step')
                            disp(['Cm = ', num2str(Cm)])
                            disp(['Gm = ', num2str(Gm)])
                            
                            disp(['Cindex not increased: ', num2str(Cindex)])
                        end
                   else
                       % Here we actually need to update c_left and c_right
                       % using the posterior dist

                       %    This was what we had before
                       %   %   %  Before  % % %
                       Cm = [ Cm(1:(Cindex-1)),c_left         ,c_right,Cm((Cindex+1):LC) ];               
                       Gm = [ Gm(1:(Cindex-1)),g_left         ,g_right,Gm((Cindex+1):LC) ]; 
                       
                       
                       
                       
                       %    After  %   %   %   %
                       % if doInsertionMeanUpdates == 1
                       %      posterior_mean %3
                       %         %posterior_mean outputs leftMeanUpdate
                                                       %rightMean update

                       %     Cm = [ Cm(1:(Cindex-1)),leftMeanUpdate ,rightMeanUpdate,Cm((Cindex+1):LC) ];   debug_meanCheck;
                       %     Gm = [ Gm(1:(Cindex-1)),leftGroupUpdate,rightGroupUpdate,Gm((Cindex+1):LC) ];
                       % else  
                       %      Cm = [ Cm(1:(Cindex-1)),c_left         ,c_right,Cm((Cindex+1):LC) ];   debug_meanCheck;
                       %      Gm = [ Gm(1:(Cindex-1)),g_left         ,g_right,Gm((Cindex+1):LC) ];
                       % end
                       % 
                       % 
                       % for i = 1:length(Cm)
                       %      if Cm(i) == 0
                       %              disp(['Insertion Zero Mean:  ',' rep ', num2str(rep), 'code line 790ish of insertion_deletion_demo'])
                       %              disp('      else part of LC > 1 && originalC_index > 1          %     CASE 3 ')
                       %              disp('')
                       %              pause
                       %      end
                       % end


                       Cindex = Cindex + 1;
                       %
                       
                       debug_meanCheck;
                       
                       if outputTextResults == 1
                           disp('We did an insertion and we were not at the end of the list. We will do a deletion step.')
                           disp(['Cm = ', num2str(Cm)])
                           disp(['Gm = ', num2str(Cm)])
                           disp(['Cindex: ', num2str(Cindex)])
                       end
                   end

                   
                   
                end
                
                %Cindex = 2
                %s1      s2   z    s3    s4
                %c1      c2        c3
                %c1      cL   CR   c3  

            else % We are not doing an insertion step, as a result of the probability step
                insertionTrue = 0;
                if outputTextResults == 1
                    statement = 'no new insertion, based on probability, Snew not updated'; 
                    disp(statement);
                    disp(['Snew =  ',num2str(Snew)])                   
                end
                
                if LC == 1
                    if outputTextResults == 1
                        disp('We had only one interval, so we will not do a deletion step')
                        disp(['Cm = ', num2str(Cm)])
                        disp(['Gm = ', num2str(Gm)])
                        disp(['Cindex not increased: ', num2str(Cindex)])
                    end
                end
                
                if LC > 1 && originalC_index == LC
                    if outputTextResults == 1
                        disp('We are at the end of the list so we will not do a deletion step')
                        disp(['Cm = ', num2str(Cm)])
                        disp(['Gm = ', num2str(Gm)])
                        disp(['Cindex not increated: ', num2str(Cindex)])
                    end
                end
                
                if LC > 1 && originalC_index < LC
                    if outputTextResults == 1
                        disp('We are not at the end of the list, so we will do a deletion step')
                        disp('Cindex was not increased because we did not do the insertion')
                        disp(['Cm = ', num2str(Cm)])
                        disp(['Gm = ', num2str(Gm)])
                        disp(['Cindex = ', num2str(Cindex)])
                    end
                end
                
                %s1      s2        s3    
                %c1      c2        
                if plotEachInsertion == 1
                    plots_demo
                    pause()
                end
                
            end
            
        else %If we have adjacents change points, we can't insert a point between them
            
            adjacentPoints = 1;
            insertionTrue = 0; %We did not do an insertion step

            %Counts how often we randomly chose a point z, such that z+1
            %was adjacent to a change point.
            adjacentPointCount = adjacentPointCount + 1;

            if outputTextResults == 1
                disp('adjacent points, Snew not updated');
   
            end
        end % mean updates
        dleft = Snew(length(Snew)); %determines the left endpoint of the interval used
        % to do the deletion step
    





      
        % Deletion step      
        %%%%%%%%%%%%           DELETION         %%%%%%%%%%%%
        %%%%%%%%%%%%                            %%%%%%%%%%%%
        %                      DELETION        
        %%%%%%%%%%%%                            %%%%%%%%%%%%
        %%%%%%%%%%%%                            %%%%%%%%%%%%  
        %%%%%%%%%%%%           DELETION         %%%%%%%%%%%%
        %%%%%%%%%%%%                            %%%%%%%%%%%%  






        doDeletionStep = 0; %If we do a deletion step, then this will be set to 1
        if k < (length(S)-1)  %If we are at the end of the list, we don't do a deletion step
            doDeletionStep = 1;
            whichUpdate = 2; %If we do an update, it will be a deletion update
            if insertionTrue == 1  %|-----   |-----------------|--------------------|  
                                   %sk       z+1              S(k+1)              S(k+2)
                                  %|-----   |------------------|--------------------|  
                                  %sk       Sm(M) = z+1       Sm(M) = S(k+1)      S(M+1 = S(k+2)
                                  
                                  
                 %dleft = z+1
                 dleft = Sm(M); %<<<< changed
                 
                 firstDeletionStatement = 'inserted point, z+1, is the left side of the deletion interval';
                 leftDeletionData = rightData; %Data from z+1 to S(k+1) from the insertion step
            else                   %|----------------|------------|
                 %dleft = S(k);     %sk              S(k+1)      S(k+2) 
                 dleft = Sm(M); %<<<< changed
                 firstDeletionStatement = 'left side of deletion interval is S(K), no insertion previously occured';
            end
            %s1 = dleft;    %left---------- S(k+1)-1   S(k+1)---------S(k+2)-1
                           %dleft--------- S(k+1)-1   S(k+1)---------S(k+2)-1
                                                      %Sm(k+1) same
            dleft = Sm(M); %<<<< changed
            ds1    = dleft;    %<<<< changed                      %     
            %s2 = S(k+1); %rather than choosing a z value, we use the value to the left of the point we are dealing with
            %s3 = S(k+2);
            
            ds2    = Sm(M+1); %<<<< changed
            
            ds3    = Sm(M+2); %<<<< changed <<<<<<<<<<<< Check on this
            
            %<<<< changed
            
                         %|----------------|           |------------|    

            %% <------------ deletion probability we be calculated here
                  
            % PROBABILITY OF DELETION
           
            %hypothetical new segment mean is supposed to be chosen, here
            %New group chosen
                                                                                              %<<<<     DC  Calc or Usage
            %%%%%%%%
            if rand < pi_group1           %< ---  March 21 group calc
                dg_null = 1;    %Nov 18 this needs to be consistent
            else
                dg_null = 2; 
            end


            psi_null_d   = psi_g(dg_null);
            theta_null_d = theta_g(dg_null);
            
            muNull  = gk_groupMeans(rep,dg_null);          %Nov 18
            tauNull = gk_groupMeans(rep,dg_null);      %Nov 18
            
            %muNull   = groupMu_fixed(dg_null);
            %tauNull  = groupTau_fixed(dg_null);

            dc_null = normrnd(muNull,sqrt(tauNull));   %<<<<<<<<<<<<<<<<<< Calculate a new interval mean
            
            %dc_left = Cnew(length(Cnew)); %Keep the previous left and right inverval values
            %dc_right = Cvector(k+1);

            dc_left  = Cm(Cindex);                                                             %<<<<     DC  Calc or Usage
            dc_right = Cm(Cindex+1);

            dg_left  = Gm(Cindex);                                                             %<<<<     DC  Calc or Usage
            dg_right = Gm(Cindex+1);

            psi_d_left = psi_g(dg_left);
            psi_d_right = psi_g(dg_right);
            
            theta_d_left = theta_g(dg_left);
            theta_d_right = theta_g(dg_right);


            %dc_right = normrnd(muBasic,sqrt(tau2basic)); %<< 3_7 12 pm
            dintervalData = Xdata(ds1:(ds3-1));
            
            %if s3 == Total
            %   intervalData = Xdata(s1:s3); %We include the last value in the list
            %end
            
         
            %full interval calculation
            %dc_null = mean(intervalData); % CAUTION <<<<<< This is NOT YET correct
            error_full = zeros((ds3-ds1),1);
            
            
            deletionInterval = [dleft,ds2,ds3];
            
            if outputTextResults == 1
                disp(['         ------------ Deletion step ',num2str(k)]); 
                 
                disp(firstDeletionStatement)
                                                                                              %<<<<     DC  Calc or Usage
                disp(['deletion interval = ', num2str(deletionInterval)])
                disp(['  Current cL, cR : ', num2str(dc_left),'  ', num2str(dc_right)]);
                disp(['New CL (Cr may be deleted)', num2str(dc_null)] );
                disp('');
                
                disp(['  Current GL, GR : ', num2str(dg_left),'  ', num2str(dg_right)]);
                disp(['New GL (GR may be deleted)', num2str(dg_null)] );       
            end
            %S1        %s2
            %            5 6 7 
            %1  2  3 4     
            %                   8 9 10 11 ...
            %                  %s3
            
            
            dErrorLeft = zeros(ds2-ds1,1);
            %dXdataLeft = Xdata(s2-s1,1); %<< 3_7 12 pm
            dXdataLeft = Xdata(ds1:(ds2-1),1);
            
            %s2---------------- ck+1
         
            %----------------------------------------
                                 %-------------------
                                 
            %s1                  s2                 s3
            dErrorRight = zeros(ds3 - ds2  ,1);
            dXdataRight = Xdata(ds2:(ds3-1),1);
            
            %psi_left  = psiEstimatesGroups(rep,dg_left);
            %psi_right = psiEstimatesGroups(rep,dg_right);
            %psi_null  = psiEstimatesGroups(rep,dg_null);      %Nov 18

            %length(dintervalData)
            if k == (length(S) - 2)
               dXdataRight = [dXdataRight',Xdata(ds3)]';
               dintervalData = [dintervalData',Xdata(ds3)]';
               dErrorRight = zeros(ds3-ds2+1,1);%On the last step, we include the last value in the list
            end
            
            %dErrorRight
            
            error_full(1) = dintervalData(1) - dc_null;

            if doNewUpdates == 1

            
                for j = 2:length(dintervalData)
                    %lambda = dc_null  + psi_null*(dintervalData(j-1)-dc_null) + theta * error_full(j-1); %Nov 18
                    lambda = dc_null   + psi_null_d*(dintervalData(j-1)-dc_null)        + theta_null_d * error_full(j-1);
                    error_full(j) = dintervalData(j) - lambda;
                end  
                
                dErrorLeft(1) = dXdataLeft(1) - dc_left;
                if length(dErrorLeft) > 1
                    for j = 2:length(dXdataLeft)
                        %lambda = dc_null  + psi_left*(dintervalData(j-1)-dc_null) + theta * error_full(j-1); %Nov 18
                        lambda = dc_left + psi_d_left*(dXdataLeft(j-1)-dc_left)           + theta_d_left*dErrorLeft(j-1);
                        dErrorLeft(j) = dXdataLeft(j) - lambda;
                    end
                end
                
                dErrorRight(1) = dXdataRight(1) - dc_right;
                if length(dErrorRight) > 1 
                    for j = 2:length(dXdataRight)
                        %lambda = dc_null  + psi_right*(dintervalData(j-1)-dc_null) + theta * error_full(j-1); %Nov 18
                        lambda = dc_right + psi_d_right*(dXdataRight(j-1)-dc_right) + theta_d_right*dErrorRight(j-1);
                        dErrorRight(j) = dXdataRight(j) - lambda;
                    end
                end

            else %%% Original code without updating group values
                for j = 2:length(dintervalData)
                    %lambda = dc_null  + psi_null*(dintervalData(j-1)-dc_null) + theta * error_full(j-1); %Nov 18
                    lambda = dc_null   + psi*(dintervalData(j-1)-dc_null)        + theta * error_full(j-1);
                    error_full(j) = dintervalData(j) - lambda;
                end  
                
                dErrorLeft(1) = dXdataLeft(1) - dc_left;
                if length(dErrorLeft) > 1
                    for j = 2:length(dXdataLeft)
                        %lambda = dc_null  + psi_left*(dintervalData(j-1)-dc_null) + theta * error_full(j-1); %Nov 18
                        lambda = dc_left + psi*(dXdataLeft(j-1)-dc_left)           + theta*dErrorLeft(j-1);
                        dErrorLeft(j) = dXdataLeft(j) - lambda;
                    end
                end
                
                dErrorRight(1) = dXdataRight(1) - dc_right;
                if length(dErrorRight) > 1 
                    for j = 2:length(dXdataRight)
                        %lambda = dc_null  + psi_right*(dintervalData(j-1)-dc_null) + theta * error_full(j-1); %Nov 18
                        lambda = dc_right + psi*(dXdataRight(j-1)-dc_right) + theta*dErrorRight(j-1);
                        dErrorRight(j) = dXdataRight(j) - lambda;
                    end
                end
            end
            

            %Need to update the K values because they change if a change
            %point happens to have occured.

            
            K_now = length(Sm) - 1; %number of currently estimated segments (number of moves)
            %T_of_X = 4*X - 1 + 2*N_groups + a + m + 3;
            T_of_K = 4*K_now + 8;      %%%%%%%% <---- CAUTION July 11
 
            T_of_K_minus_one = 4*(K_now - 1) + 8; %To be used in the deletion step

           
            
            dprobTerms1 = normpdf(error_full,0,sqrt(sig2error)); %E2
            
            
              
                            %<----- March14 change  s3-1-s1  is dk - sk
                            %except when we are on the last deletion step
                            
                            %when we are at the very last deletion step,
                            %it should be s3 - s2 because dk is s3
            
            dlogProb1 = log(1-phi) + log(1/(ds3-1-ds1)) + log(1/T_of_K_minus_one) + sum(log(dprobTerms1));
            
            dProb1 = exp(dlogProb1);
            
            
            %dgamma = (1-phi)/phi*T_of_K/T_of_K_minus_one*1/(length(dintervalData));
            dgamma = (1-phi)/phi*T_of_K/T_of_K_minus_one*1/(length(dintervalData) - 1); % <-- March 28 minus 1 change for dgamma
            
            
            
            logP1_over_P0 = log(dgamma) + 1/sqrt(2*pi*sig2error)*sum(([dErrorLeft',dErrorRight'].^2 - error_full'.^2));
          
            %logP1_over_P0 = log(gamma) + 1/sqrt(2*pi*sig2error)*sum(([dErrorLeft',dErrorRight'].^2 - error_full'.^2));
          
                  % <---- March 28  IT WAS SUPPOSED TO BE "D gamma"
                  % dgamma
            
            %Prob1 = (1-phi)*1/(s3-1-s1)*1/(T_of_K)*prod(normpdf(error_null,0,sqrt(sig2error)))

            %% PROBABILITY OF REJECTING THE DELETION
      
            dprobTerms0 = normpdf([dErrorLeft',dErrorRight'],0,sqrt(sig2error));
            dlogProb0 = log(phi) + log(1/T_of_K) + sum(log(dprobTerms0));
            
            dProb0 = exp(dlogProb0); % a lot faster to calculate it this way
            
            %dataCalculation = (mean(Xdata(s1:s2)) + mean(Xdata((s2+1):(s3-1))))/2; %<<<< changed
           
            
            calculatedDeletionAccept = dProb1/(dProb0+dProb1); %<----- March14 change BIG DISCOVERY somtimes results in 0/0 machine estimate
                                                               %due to
                                                               %sum(logprobs)
                                                               %being very
                                                               %large
                                                               %negative
                                                               
                                                              
                                                               
            
            if (dProb0+dProb1==0)     %<----- March14 change   we discoverd the zero %problem here
                numExceptions = numExceptions + 1;          %<----- Prob debug March 21 this counts how many times we get this problem
            end
            
            %dProb0 = 0.5; %
            
            %randVal = rand();            %<0000000
            randVal = log(rand());
            
            if calculateDeletionProb == 1
                
                %boundDeletion = calculatedDeletionAccept; %<-------- calculate this based on data
                boundDeletion = min(0,logP1_over_P0); %log markov     %<0000000
            else 
                boundDeletion = log(P_delete_fixed + 10^(-300));
            end
               
            if outputTextResults == 1
                disp(['log(Deletion Prob) ',num2str(boundDeletion)])
            end
            
            probDeletion(rep,k,1) = calculatedDeletionAccept;
            probDeletion(rep,k,2) = ds2; %Index of point proposed for deletion
            
         
            newDelProb(rep,ds2,1) = newDelProb(rep,ds2,1) + calculatedDeletionAccept;
            newDelProb(rep,ds2,2) = newDelProb(rep,ds2,2) + 1;


            pDel(rep,k) = boundDeletion;

            deletionOccurs = 0; %If deletion occurs, this will be 1
            if randVal < boundDeletion

                deletionOccurs = 1;
                
                 % We will do deletion updates (for posterior_mean file)
                 % RUN THE UPDATE FILE
                if outputTextResults == 1
                    statement = 'Deletion occurs, deleted point not added to Snew'; 
                    disp(statement);
                    disp(['Snew =  ', num2str(Snew)])
                end
               
                if doDeletionMeanUpdates == 1
                    posterior_mean
                    Cm(Cindex) = dmeanUpdate;   debug_meanCheck; %This was dc_left 
                    Gm(Cindex) = dgroupUpdate; 
                else
                    Cm(Cindex) = dc_null;      debug_meanCheck; %This was dc_left
                    Gm(Cindex) = dg_null; 
                end
                
                if (length(Cm)-Cindex) > 1
                    for j = (Cindex + 1):(length(Cm)-1)                                 %<<<<     DC  Calc or Usage
                        Cm(j) = Cm(j+1);     debug_meanCheck;
                        Gm(j) = Gm(j+1);
                    end
                end
                Cm = Cm(1:(length(Cm)-1));    debug_meanCheck;%Based on the way these were modified, we are left with the last term at the end, which we need to get rid of
                Gm = Gm(1:(length(Gm)-1));
                
                %     
                %Sm(M)   Sm(M+1) = z+1     Sm(M+2)     S(length(Sm)) 
                
                Smn = [Sm(1:M),Sm((M+2):length(Sm))   ]; %<<<< changed
                Sm = Smn; %<<<< changed
                M = M - 1; %<<<< changed
                
                %There must be at least two intervals for this to occur
                %if Cindex == 1
                
                
                %s1          s2           s3        s4
                %  dc_left      dc_right      c3 
                %s1                       s3        s4
                %c_null                      c3    
                
               
                 
                 
                %%%%% New mean has to be assigned to next interval
                %Cnew(length(Cnew)) = dc_null; %<<<<<<<<<<<<<<<<<<<<
                
                if plotEachDeletion == 1
                    plots_demo
                    pause()
                end
                
            else                
                Snew(length(Snew)+1) = S(k+1);
                
                %Cnew(length(Cnew)) = dc_left;  % Probably get rid of these calculations
                %Cnew = [Cnew,dc_right];         %<----------- why do we need to do this?
                
                
                if outputTextResults == 1
                    disp('No deletion, based on probability, Snew now contains non-deleted point'); 
                    disp(['Snew =  ', num2str(Snew)])
                    disp(['Sm = ', num2str(Sm)])
                    %disp(['C* =  '  , num2str(Cnew)])
                end
                
                if Cindex < length(Cm)
                    
                    Cindex = Cindex + 1; % <<<<<<<<<<<<< Cindex increases 
                    
                    if outputTextResults == 1
                        disp('We were not at the end of the list, so Cindex increases')
                        disp('deletion step did not result in a change in Cm')
                        disp(['Cindex = ', num2str(Cindex)])
                    end
                else
                    if outputTextResults == 1
                        disp('We were at the end of the list so Cm and Cindex do not change')
                        disp('!! ----->HOWEVER, THIS RESULT SHOULD NOT HAPPEN. IF WE WERE AT THE END OF THE LIST TO BEGIN WITH, WE SHOULD NOT DO A DELETION STEP')
                        disp('!! ----->IF THIS MESSAGE APPEARS, THERE IS AN ERROR IN THE DELETION STEP CODE')
                        
                        disp(['Cindex = ', num2str(Cindex)])
                    end
                end
                
                
                
            end
            
        else
            if outputTextResults == 1
                 disp('         ------------ END OF LIST. NO Deletion step ');
                 disp('         ------------ a final insertion step should have been done prior to this ');
            end
        end % DELETION STEP END

        %Each step we count how many insertions and deletions occured,
        %And where each was proposed to have occured
        %This gives us a ratio of acceted to rejected for each chosen point

        insertionDeletionCount %Count how many times a proposed insertion point is accepted
                       %Count how man times a deletion point is accepted
                       %insertionCount          deletionCount
       
            
    end% of deletion segment loop |--|--|--|--|
    
    %Snew = [Snew, Total];
    %Cnew = [Cnew, Total]; 
    %S = [Snew, Total]; %<<<< changed
%     if rep == 1
%         Svector(1,1:length(S)) = S;
%     end

    S = Sm; %<<<< changed
    %C = Cnew;
    C = Cm;
    
    G = Gm;
    %Svector((rep+1),1:length(S)) = S;
    Svector((rep+1),1:length(Sm)) = Sm; %<<<< changed  S to Sm
    Cvector((rep+1),1:length(C)) = C;
    Gvector((rep+1),1:length(G)) = G;       %<------ G and C should be the same length

    %This stores all of the segment sample means
    if rep == 1
        CmeansVector = zeros(size(Cvector));
    end

    if rep <= samples
        for t=1:(length(Sm)-1) % Calculates the sample means of each segment
            ind1 = Sm(t);
            if t == (length(Sm)-1)
                ind2 = Sm(t+1);
            else
                ind2 = Sm(t+1)-1;
            end
            CmeansVector(rep,t) = mean(Xdata(ind1:ind2));
        end
    end
    % This is what was being done, rather than calculating the posterior dist values,
    % originally
    if doSimpleMeans == 1
        if rep == 1
            Cvector(1,1:length(Cm)) = CmeansVector(1,length(Cm));
        end
        if rep < samples
            Cvector((rep+1),1:length(Cm)) = CmeansVector(rep+1,1:length(Cm));
            Cm = Cvector((rep+1),1:length(Cm));
        end
    end

    

    %errorAll is updated
    %update all error terms after segment menas are updated
                 %We use the update error terms to update the model
                 %parameters

    %%  Posterior Distribution parameter updatees     
    
    if  updateGroupAssignments == 1
        error_update;
        posterior_groups;
    end       

    Gvector((rep+1),1:length(G)) = Gm;

    if updateTheta == 1
       error_update    %RUN
       posterior_theta %RUN

       thetaEstimates(rep+1) = theta;
       thetaEstimatesGroups(rep+1,1) = theta_g(1);
       thetaEstimatesGroups(rep+1,2) = theta_g(2);
    else
       thetaEstimates(rep+1) = thetaEstimates(rep);
       thetaEstimatesGroups(rep+1,1) = thetaEstimatesGroups(rep,1);
       thetaEstimatesGroups(rep+1,2) = thetaEstimatesGroups(rep,2);
    end
    

    if updatePSI == 1
       error_update
       posterior_psi %Run this code. "psi" is calculated and it's value outputed
       psiEstimates(rep+1) = psi;

       psiEstimatesGroups(rep+1,1) = psi_g(1); %Whether we are doing group calculations
       %Or not, we store them in this vector as placeholders
       psiEstimatesGroups(rep+1,2) = psi_g(2);
       %thetaMeans will be updated. We will keep track of all values
       %thetaVariances will be updated
    else
       psiEstimates(rep+1) = psiEstimates(rep);
       psiEstimatesGroups(rep+1,1) = psiEstimatesGroups(rep,1); %Whether we are doing group calculations
       %Or not, we store them in this vector as placeholders
       psiEstimatesGroups(rep+1,2) = psiEstimatesGroups(rep,2);
    end

    if updatePHI == 1
       posterior_PHI; 
       phiEstimates(rep+1) = phi; 
    else
       phiEstimates(rep+1) = phi; %Just keps a vector of the same values
    end

    if updateSig2error == 1
        error_update
        posterior_sigma2
        sig2Estimates(rep+1) = sig2error;
    end
    

    posterior_mu_groups
    %gk_groupMeans(rep+1,1) = m1
    %gk_groupMeans(rep+1,2) = m2;
       %if updateMu == 1  
       %if updateTau == 1
            %if twoVariances == 1
       %if updatePi == 1
    
    %gk_groupVariances(rep+1,1) = t1;
    %gk_groupVariances(rep+1,2) = t2; 

    muEstimates(1,rep+1) = mu_g_1; %Might not be using these variables anymore
    muEstimates(2,rep+1) = mu_g_2;

    %error_update %We still need to update all the error at the end
    %yNow = polyfit([Sm(2):(Sm(2+1)-1)],Xdata(Sm(2):(Sm(2+1)-1)),1)
    if rep == 1
        polyFitTime = 0;
        otherTime = 0;  
    end

    if doRegressionTest == 1
        tic
        yFits = zeros((length(Sm)-1),2);
        for i = 1:(length(Sm)-1)
           if  (Sm(i+1)-Sm(i)) > 1
               indVar = [Sm(i):(Sm(i+1)-1)];
               depVar = [Xdata(Sm(i):(Sm(i+1)-1))];
               yFits(i,:) = polyfit(indVar,depVar,1);
           else
               yFits(i,:) = polyfit([Sm(i),Sm(i) + 1/2],[Xdata(Sm(i)),Xdata(Sm(i))],1);
           end
        end
        polyFitTime = polyFitTime + toc;
    end
    
    
    %disp(Svector);
end %End sample loop

end %Double run
samplerTime = datetime - startTime;

%%


numUpdates = 0;
if updatePSI == 1
    numUpdates = numUpdates + 1;
end

if updateTheta == 1
    numUpdates = numUpdates + 1;
end

%% Run plot code and output several means of interest

plots_demo  %Runs tracePlot_group_updates within this file

estimate_text_output

%data_analyzer_arma %Shows what we would get if an ARMA model funtion were
%to estimate the parameters

%% Regression fit test
if doRegressionTest == 1

    polyFitTime

    figure()
    plot(Xdata)
    hold on
    for i = 1:(length(Sm)-1)
        slope_i = yFits(i,1);
        int_i = yFits(i,2);
        
        deltaX = (Sm(i+1)-Sm(i));
        yZero = Xdata(Sm(i));
        yMean = mean(Xdata(Sm(i):(Sm(i+1)-1)));
    
        y0 = yMean - slope_i*deltaX/2;
        y1 = yMean + slope_i*deltaX/2;
    
        plot([Sm(i),(Sm(i+1)-1)],[y0,y1],'Color','red')
        hold on
    end

end