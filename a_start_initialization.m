
%%%% ARMA Segment Model data and initialization 
%% We generate data with this file
% Russell Latterman, October 1st 2022 to Dec 9th
% Updated as of August 8th - Dec 9th
% Parameters and plot appearance based on paper Bayesian change-point modeling with segmented ARMA model
%   Farhana Sadia1, Sarah Boyd2, Jonathan M. KeithI  2018

%       At the end of this file
%           begins ----> | insertion_deletion_demo
%                        |  %   ----> plots_demo
%                        |  %   ----> tracePlot_group_updates
%                        |  % outputs means for parameters

%% Global variables
global psi_two_groups
global theta_two_groups
global theta_g_true
global psi_g_true
global theta_g
global psi_g        %This will be replaced by gk_grouPsiglobal psi_g        %This will be replaced by gk_grouPsi

global sig2_g

global sig2_two_groups

global Ktrue        % Actual number of estimates
global Kmax %length of vector to store estimate
global obs_per_seg  %observations per segment
global Kguess       % Initial guess number of segments
global runDemoFile  % determines whether we run the demo file
global do_demo2_basic
global thetaMA_0
global psiAR_0paper
global phi_0
global T
global pi_0
global ck_segMeans
global gk_segGroups
global gk_segGroups_0
global ck_segMeans_0
global tauG1_fixed % = 16;  %<----- March14 change
global tauG2_fixed % = 16;

global gk_groupMeans            %< Group work
global gk_groupVariances        %< Group work
global gk_groupProbabilities    %< Group work
global gk_groupPsi              %< Group work
global gk_groupTheta

global muG1_fixed % = -10;
global muG2_fixed % = 10;
global sig2_0paper % Matches what we are given in the paper
global Xt
global t1   %Group variance
global t2
global m1   %Group mean
global m2

global pi1  %Group probabilities
global pi2
global pi1_true 
global pi2_true


%%
do_demo2_basic = 0; % Generates segment means based on a simple Normal(0,1) distribution
%Set to 1 to generate means based on a simple Normal(0,1) distribution,
%basically ignoring the concept of groups altogether
%Set to 2 to generate means based on two groups each with fixed mean and
%variance

global samples %how many times we run the gibbs sampler

clear all
  
    %          %%%%%%% 
    %        %%%%%%%
    %    %%%%%
    %    %%%
    %      %%%
    %       %%%%%%
    %          %%%%%
    %       %%%%%%
    %    %%%%%%
   
samples = 10^4; %We will use this unless we explicitly state a different number
%of samples 

interfaceReps = 1; %We do this if we want to use the GUI to define values
doGui = 0;      % set to 1 for input window
Ngroups = 2;    % number of groups

%for repeat = 1:reps% Repeats, but with a GUI window
%Set to 0 to generate data as similar to the paper as possible
%%
for n = 1:interfaceReps %This just hides multiple comment sections for now 

%% Define which simulation to runs
psi_two_groups = 1;     %Default set to this value
theta_two_groups = 1;
sig2_two_groups = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%
do_random_generation = 1; %<---- heavily affects what goes on
%%%%%%%%%%%%%%%%%%%%%%%%%
test_exact_paper = 0;   %Simulates as closely to the paper as possible
do_AR1_zero_mean = 0;   %Designed for a case in which we have just an AR1 process                        
                        %With all means equal to zero
do_imported_data = 0;

% Tries to simulate as close to the exact data set from the paper as possible
%% do_random_generation == 1
if do_random_generation == 1    
    %currentSeed = rng;
    %rng(currentSeed);
    samples = 3*10^3;  %%% Defined at the start of this file as default unless we change it
                       % for various cases like the do_random_generation
                       % case
    Ktrue       = 20; % Number of segments
    obs_per_seg = 100; % Observations per segment
    Kguess      = 40; % Initial estimated number of segments
    psi_g_true  = [.22 , -.22];

    m1 =  -10;        
    m2 =   10; %Group means   
    t1 =  1;        
    t2 =  1;  %Group variances
    %m1 = -10;   m2 =  20; %Group means               
    %t1 =  16;   t2 =  24;  %Group variances
      
    m1_true = m1;       m2_true = m2;
    t1_true = t1;       t2_true = t2;

    sig2_0paper = 0.96; %Random noise. In the paper it was originally 0.96
    sig2true = 0.96; %This may or may not end up being used

    if psi_two_groups == 0 %If we are only estimating one psi value, then we just use the first one in the list given
       psi_g_true(2) = psi_g_true(1);
    end
    psi_g = psi_g_true; %This should be randomized
    psiAR_0paper = psi_g(1);
    psi = psi_g(1);

    %The "true" theta
    thetaMA_0 =   .6; %Group 1 "true" parameter
    if theta_two_groups == 1
        thetaMA_0_1 =   thetaMA_0;
        thetaMA_0_2 =   -.6;
        theta_g_true = [thetaMA_0_1 , thetaMA_0_2]; %THETA2
    else
        theta_g_true = [thetaMA_0 , thetaMA_0];   
    end
    theta_g = theta_g_true;
    theta = theta_g(1);

    %if sig2_two_groups == 1
    %else
    %end
   
    updateTau = 1;      
    updatePi  = 1;
    updateMu  = 1;
    updateGroupAssignments = 1;
    
    twoVariances = 1;   
    do_even_groups = 1; 
     
    if do_even_groups == 1 %Assigns groups pack and forth group1, group2... etc
                    %systematically
        pi1 = 1/2;      pi2 = 1-pi1;% And so group probs should be the same
    else
        pi1 = 2/3;      pi2 = 1-pi1;%Group probabilities
    end
    pi1_true = pi1;     pi2_true = pi2;
    alphaPrior1 = 3;    betaPrior1 = 3;  %Shape and Rate  
    %(Matlab gamrnd(shape, scale = 1/rate)

    alphaPrior2 = 3;    betaPrior2 = 3; 
    alpha1 = 3;         alpha2 = 3;
    beta1 = 3;          beta2 = 3;
   
    muG1_fixed      = m1;    muG2_fixed      = m2; 
    tauG1_fixed     = t1;    tauG2_fixed     = t2; %The true values 

    %Ktrue       = 2; % Number of segments
    %obs_per_seg = 500; % Observations per segment
    %Kguess      = 1; % Initial estimated number of segments
  
    T = Ktrue * obs_per_seg; %Total number of observations, equal obs per sequent
    Kmax = 3*max(2*(Ktrue+1),2*(Kguess+1)); %allocate space for estimated segments
    
    numSamples = T;

    Strue    =  0:(Ktrue - 1); %Left endpoints ex: [0,1,2,3, ... (Ktrue-1)] 
    Strue    =  Strue * obs_per_seg; %Ex Strue*50 = [0,50,100,150]
    Strue(1) =  1; % [1,50,100,150]; %Always start with 1     


    ck_segMeans   = zeros(samples,Kmax);  %segment means. Columns can increase
    
    gk_segGroups  = zeros(samples,Kmax);  %corresponding group
    gk_groupMeans           = zeros(samples,2);  % m1 m2
    gk_groupVariances       = zeros(samples,2);  % 
    gk_groupProbabilities   = zeros(samples,2);  % pi
    
    %%%%%%% All new
    gk_groupMeans(1,1)     = m1;        gk_groupMeans(1,2)     = m2;
    gk_groupVariances(1,1) = t1;        gk_groupVariances(1,2) = t2;
    gk_groupProbabilities(1,1) = pi1;   gk_groupProbabilities(1,2) = pi2;
    %Suggestion
    % Make means far away and variances relatively small to get highly
    % disparate group means
       

end %%%%%%%   This is the original random data generation loop


%% Exact Paper
%%%%%%      test_exact_paper == 1      %%%     Does well-data
%%%%%%      test_exact_paper == 1      %%%  or Covid Data
%%%%%%      test_exact_paper == 1      %%%  or uses random generation file

%%%%%%%%%%%   Well   Data   %%%%%%%%%     
        %%%%%%%%%%%   Well   Data   %%%%%%%%%  
                            %%%%%%%%%%%   Well   Data   %%%%%%%%%  
                           
%%%%%%%%%%%   Well   Data   %%%%%%%%%  
                    %%%%%%%%%%%   Well   Data   %%%%%%%%%  \
if test_exact_paper == 1    %CAUTION: MAKE SURE fixWide_manually = 0
    
    updateTau = 1;      
    updatePi  = 1;
    updateMu  = 1;
    updateGroupAssignments = 1;
    twoVariances = 1;

    psi_two_groups = 0;
    do_even_groups = 0;
    do_random_generation = 0; %<--this could be a problem
    do_imported_data = 0;
    do_AR1_zero_mean = 0; 
    
    exact_paper_1   %%%%%%%% RUN THIS FILE
    
end


%%
if do_AR1_zero_mean == 1 %CAUTION: MAKE SURE fixWide_manually = 0
   
   psi_two_groups = 0;
   do_even_groups = 0;
   do_imported_data = 0;
   test_exact_paper = 0;  
   t1 = 1;      t2 = t1;
   m1 = 0;      m2 = 0;
 

   psi_g = [.22, .22]; %Used only if we think of this with groups with differing
   psi_g_true = psi_g;  %Used only if we think of this with groups with differing
   
   %variances
   

   psiAR_0paper = psi_g(1);
   thetaMA_0 = 0;
   theta_g = [thetaMA_0, thetaMA_0]; %THETA2

   AR_mean0_groups2 %Run this file
   Ktrue = numARsegs; % True number of segments (#change points is K-1) 
   obs_per_seg = AR_obs_per_seg;
   Kguess = 10;

   Kmax = 3*max(2*(Ktrue+1),2*(Kguess+1)); %allocate space for estimated segments
   
   ck_segMeans   = zeros(numSamples,Kmax);  %segment means. Columns can increase
   gk_segGroups  = zeros(numSamples,Kmax);  %corresponding group
   
   % Ktrue       = 20;    % True number of segments (#change points is K-1) 
   % obs_per_seg = 100;
end
%%

if do_imported_data == 1    %CAUTION: MAKE SURE fixWide_manually = 0
   
   %options
   updateTau = 1;      
   updatePi  = 1;
   updateMu  = 1;
   updateGroupAssignments = 1;
   twoVariances = 1;  

   psi_two_groups = 1;  %RUN THIS FILE
   do_even_groups = 0;                         
   test_exact_paper = 0;    % We will try to do a simulation based closely on the data from the paper
   do_random_generation = 0;%<---- This could be a problem
   do_AR1_zero_mean = 0;    % Designed for a case in which we have just an AR1 process
                            % With all means equal to zero

   %RUN                         
   well_data_practice       % We import the well data used by the authors in the paper
                            % generates g1_var g1_mean; etc
   
   numSamples = length(S_well);
   
   Kmax = 100;

   ck_segMeans   = zeros(numSamples,Kmax);  %segment means. Columns can increase
   gk_segGroups  = zeros(numSamples,Kmax);  %corresponding group  

   
   %psi_g = [.22, .22]; %CAUTION, this is a place holder but is not currently relevant
   %psi_g        = [-0.6396, - 0.6396];

   psi_g        = [0,0];
   theta_g      = [0,0]; %THETA2

   psi_g_true = psi_g;
   psiAR_0paper = psi_g(1);

   thetaMA_0 = -.6;
   theta_g = [-0.6,-0.6]; %THETA2
   %thetaMA_0    = 0.7761;
   

   %sig2_0paper = 4;

   t1 = g1_var;      t2 = g2_var;
   m1 = g1_mean;     m2 = g2_mean;  

   sig2_0paper = g1_var;

   Ktrue = length(C_well);
   obs_per_seg = 100; 
   Kguess = floor(length(Xwell)/obs_per_seg);

   T = length(Xwell); %%%%%%% This is defined in the well data practice file

   Strue         = S_well(1:(length(S_well)-1) ); %
    %
end



Dtrue         = [(Strue(2:Ktrue) - 1),T];
% Now we store t1 and t2 as FIXED VALUES so that, if we so choose, we can keep them
% fixed instead of estimating them via updates
%% Defined fixed group means and variances based on which simulation we do
tauG1_fixed     = t1;  %<----- March14 change
tauG2_fixed     = t2;
muG1_fixed      = m1;
muG2_fixed      = m2;
%%

%% Part 1 Description: Generate Data

% We generate a random sample of data based on an ARMA(1,1) process
% Xt(i) = Ck + et(i) + psi*(Xt(i-1)-c) +theta*et(i-1);
% We assume error terms are all N(0,sigma^2)
% psi,theta, and sigma squared fixed ahead of time (page 11 of paper)
% We assume 2 groups and 20 segments are known
% We then randomly assign each segment to either group 1 or group 2 using 
% a Un(0,1) dist  (parameter Pi1 represents prob of assignment to group 1
% We get a random sample for group means mui1 and mui2 from a N(0,1) dist
% We get a random sample for group variances tau squared from Inv - Gam(3,3)
% Segment means are distributed Ck ~ N(mui_gk,tau_gk^2), where gk
% stands for the group associated with the kth segment.
% We get a sample for all 20 group means
% 
% Now that we have 20 segments, each of which has its own mean, Ck
% We do a random sample of 100 observations on each segment based on the
% ARMA model mentioned, above.
%
% Afte getting this random sample, we will move on and attempt to use a
% generalized gibbs sampler to try to detect where the change points occur
% Can we successfully discover how many segments there actually are?
% Can we accurately estimate group and segment means?
% Can we accurately estimate the ARMA model parameters?
% Sections 1 (a), (b) and (c) all have to do with the data generation and
% the plot of the generated data.
 
%% Part 1: Generate Data. Sections are given, below
% 1 (a) Initialization, set rand seed and GUI operator on or off
% We are dealing with an ARMA(1,1) process on each of K intervals
% Xt(i) = Ck + et(i) + psi*(Xt(i-1)-c) +theta*et(i-1);
%Several segments with equal number of observations per segment

genNewData = 1; %We just use the data we generated previously
%seedToSet = 9; %9,15,18 %Good example seeds for 5,50 (#segments,#data per group)
randomSeedChange = 1;
%seedToSet = 18; %seedToSet+1; %This fixes the data to something we might want to use
%rng(seedToSet); % Set seed   FIXED RANDOM SEED
%18, 5,  50
do_demo2_basic = 0;

%We have this set so that we don't get the same values
%over and over. If the workspace is empty, we define a starting value,
%otherrwise we use the value of the variable.

if exist('randomSeedChange','var') == 0
   randomSeedChange = 1;
else
   randomSeedChange = randomSeedChange + 1; 
end%Later in the code we have
%this set to change every time the code is run




%% Initialization, continued
Kcurrent = Kguess; %Current estiamted number of segments
                            
Dtrue = [(Strue(2:Ktrue) - 1), T]; % ex [49,99,149,T]
Segments_true = [Strue, Dtrue]'; % Shows a column of intervals

guessSpacing = floor(T/Kguess); % if we guess two segments, we have
guess_shift  = floor(guessSpacing/2);

numSamples = 3; % How many times we run the sampler

Sk = zeros(numSamples+10,Kmax);
Sk(1,1:Kguess) = (0:(Kguess-1))*guessSpacing; 
Sk(1,1) = 1;  % Left endpoint is always 1
currentSample = 1; % We start off at 1 and continue on until we get to n
% Sk(1,2:(Kguess+1)) = Sk(1,1:Kguess); Sk(1,1) =1; %First is always 1 

Dk = zeros(numSamples+10,Kmax);
Dk(1,1:(Kguess-1)) = Sk(1,2:Kguess)-1;
Dk(1,Kguess) = T; % Right endpoint is always T
%% data generation

Xt = zeros(T,1); % Data to be generated and analyzed

sigmaSquared    = zeros(numSamples,1); %Error variance
    %sigmaSquared(1,1:Ngroups) = 1./gamrnd(aa,1/bb,1,Ngroups); %see page 10  
    sigmaSquared(1)= sig2_0paper; %This needs to be defined in any of the data generation set-ups
    sig2true = sig2_0paper;

tauSquared = zeros(numSamples,Ngroups); %Group variances
    aa = 3; bb = 3; %scale for Inv-gamma
    %Inverse gamma is 1/gamma. Matalb does (shape, rate) rate = 1/scale
    tauSquared(1,1:Ngroups) = 1./gamrnd(aa,1/bb,1,Ngroups);
    mu_N  = zeros(numSamples,Ngroups); %Group means
    mu_N(1,1:Ngroups) = normrnd(0,1,1,Ngroups);
   
mu_k_groupMeans = zeros(numSamples,Ngroups);                        %<----- March14 change doesn't seem to assign any initial group means in this program
    
    %In the paper, these initial terms were pre-defined.
pi_N            =  zeros(numSamples,Ngroups); %prob group assignments
   % pi_N(1,1:Ngroups) = randperm(Ngroups)/sum(1:Ngroups);
    pi_N(1,1:Ngroups) = zeros(1,Ngroups)+1/Ngroups;
    pi_0 = pi_N(1); %We are just going to have the pi values set to be 1/2, for now
piEstimates = zeros(numSamples,Ngroups);
    piEstimates(1,1:Ngroups) = pi_N(1,1:Ngroups);
  
thetaMA  =  zeros(numSamples,1); %MA stands for moving average
    %thetaMA(1) = (rand()-1/2)*2; % Based on prior dist Unif(-1,1)
    thetaMA(1) = thetaMA_0; %from paper, page 10
    
psiAR    =  zeros(numSamples,1); %AR stands for auto-regressive
    %psiAR(1) = (rand()-1/2)*2; %Based on prior dist Unif(-1,1)
    %psiAR_0paper = 0.22; %based on startingh value from paperchangepoints/observations
    psiAR(1) = psiAR_0paper;
     %Designed for case in which we might have different psi values
   
phiProbNewSeg   =  zeros(numSamples,1); %prob of change point at any time
    
    %phi_0 = (Ktrue-1)/T; %changepoints/observations
    %phi_0 = 0.05;

    phi_0 = Ktrue/T;  %The algorithm will converge, regardless of this value
    phiProbNewSeg(1) = phi_0; %This is based on how we have initialized our data

%% Segment Means and Groups

if do_random_generation == 1
                pi_0 = pi1;
end

gk_segGroups_0 = gk_segGroups(1,:); %creates something with same length

if test_exact_paper == 1
    %Don't do anything new. This part was already taken care of earlier in
    %the code. This is only here as a reminder
else

    for i = 1:Ktrue%Eventually this will be generalized to account for
        %all of the different groups

        if do_even_groups == 1 %Defines groups systematically. Odd intervals are group 1
            %even intervals are group 2
            if mod(i,2) == 1    %Starts off with group 1
               mu_i   = muG1_fixed;                                                                        %<----- March14 change
               tau2_i = tauG1_fixed;
               gk_segGroups(1,i) = 1;
            else %Then goes to group 2
               mu_i   = muG2_fixed;                                                                        %<----- March14 change
               tau2_i = tauG2_fixed;
               gk_segGroups(1,i) = 2;
            end
        else  
            if rand() < pi_0 %Group 1 mean and variance    
               mu_i = muG1_fixed;                                                                        %<----- March14 change
               tau2_i = tauG1_fixed;
               gk_segGroups(1,i) = 1; 
            else
               mu_i = muG2_fixed;                                                                        %<----- March14 change
               tau2_i = tauG2_fixed;
               gk_segGroups(1,i) = 2; 
            end

        end
        % Then draw sample means based on group assignments
        ck_segMeans(1,i) = normrnd(mu_i,sqrt(tau2_i)); %matlab passes in standard dev
        
    end

end

ck_segMeans_0  = ck_segMeans(1,:); %Separately stores initial groups
gk_segGroups_0 = gk_segGroups(1,:); %Stores initial segment means

%Segment means
means = ck_segMeans(1,:); %segment means
index = 0;
actualMeans = zeros(T,1); %For every point t = 1, ..., T, this stores 
    %the information about the segment mean
for i=1:T %Stores the information about the segment means for each time t in the series
    if(mod(i,obs_per_seg)==1)
        index = index+1;
    end
    %actualMeans(i) = means(index); % Not really necessary to do this
end


%% Data Generation

%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      GENERATE DATA RANDOMLY

%%  1 (b) Generate X(t) (ARMA PROCESS) data
k = 1;
%Xt(1) = ck_segMeans(1) + et(1);
et = normrnd(0,sqrt(sig2_0paper),T,1); %Random noise

%et = normrnd(0,sqrt(4),T,1); %Random noise

% 1 20 30 40
% 1 2  3  4
nextPoint = 1;
for i=1:T
    %if( mod(i,obs_per_seg) == 1)%We are at a change point or the first point
                            %in a segment
     if i == nextPoint 
        
        c  = ck_segMeans(1,k);
        gr = gk_segGroups(1,k);
        
        psiParam   = psi_g(gr);  %psi_g_true  
        thetaParam = theta_g(gr); %theta_g_true
        %thetaParam = theta_g(gr); THETA2

        % current segment mean
        % Xt(i) = c +psiAR_0paper*(-c) + et(i);
        % We don't include the ARMA terms for the first
        % Xt(i) = c*(1-psiAR_0paper) + et(i)
        % point in a segment
        lambda_t = c; 
        % Xt(i) = normrnd(lambda_t,sqrt(sig2_0paper)); % Ref eq 5, page 4
        Xt(i) = et(i) + lambda_t;
        % Xt(i) = c + 4*rand()-2;
        % Xt(i) = c + normrnd(0,1);

        if k < length(Strue)
            k = k+1;
            nextPoint = Strue(k);
        end
  
    else % if we are not at the first point in an a=1 m=1 segment, 
        % then we have the AR and MA terms

        lambda_t = c + psiParam*(Xt(i-1)-c) + theta_g(gr)*et(i-1);
        %lambda_t = c + psiParam*(Xt(i-1)-c) + thetaParam*et(i-1); THETA2
        
        % Xt(i)    = c + et(i) + psiAR_0paper*(Xt(i-1)-c) + 
        % thetaMA_0*et(i-1); 
        Xt(i) = et(i) + lambda_t;
        % Xt(i) = c + 4*rand()-2;
        % Xt(i) = c + normrnd(0,1);
        % Re eq 5, page 4
    end
end


%Run Gibbs sampler file
%for i = 1:2
    insertion_deletion_demo 
%end

end 
