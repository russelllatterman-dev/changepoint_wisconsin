tic
%%%% ARMA Segment Model 
% We generate data with this file
%
%
% Russell Latterman, October 1st 2022 to Nov 30th
% Parameters and plot appearance based on paper
%   Bayesian change-point modeling with segmented ARMA model
%   Farhana Sadia1, Sarah Boyd2, Jonathan M. KeithI  2018

%% Global variables
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

global psi_g        %This will be replaced by gk_grouPsi
%%
do_demo2_basic = 0; % Generates segment means based on a simple Normal(0,1) distribution
%Set to 1 to generate means based on a simple Normal(0,1) distribution,
%basically ignoring the concept of groups altogether
%Set to 2 to generate means based on two groups each with fixed mean and
%variance

global samples %how many times we run the gibbs sampler

%Set to 0 to generate data as similar to the paper as possible
clear all

%% Define which simulation to run
do_random_generation = 1;
test_exact_paper = 0;   %We will try to do a simulation based closely on the data from the paper
do_AR1_zero_mean = 0;   %Designed for a case in which we have just an AR1 process
                        %With all means equal to zero


do_well_data = 0;
psi_two_groups = 1;
theta_two_groups = 0;

samples = 10*10^3; 


% Tries to simulate as close to the exact data set from the paper as possible
if do_random_generation == 1
   do_even_groups = 1; %This means groups will be set systematically
   %Groups for odd segments will be group 1, group 2 for even segments

   test_exact_paper = 0;
   do_well_data = 0;

   simpleAR = 0;
   
   t1 = 4;%9/4;                        %%%%%%%%%% <--------- Changed to match data
   t2 = 4;
   m1 = 5;    
   m2 = -5;

   Ktrue       = 3;    % True number of segments (#change points is K-1) 
   obs_per_seg = 50;
   Kguess = 12;
   
   psi_g = [.18, .47];
   psi_g_true = psi_g;

   psiAR_0paper = psi_g(1);
   thetaMA_0 = 0;


   T = Ktrue * obs_per_seg; %Total number of observations, equal obs per sequent
   Kmax = 3*max(2*(Ktrue+1),2*(Kguess+1)); %allocate space for estimated segments
   
   numSamples = T;
   ck_segMeans   = zeros(numSamples,Kmax);  %segment means. Columns can increase
   gk_segGroups  = zeros(numSamples,Kmax);  %corresponding group
   
   %Suggestion
   % Make means far away and variances relatively small to get highly
   % disparate group means

   Strue    =  0:(Ktrue - 1); %Left endpoints ex: [0,1,2,3, ... (Ktrue-1)] 
   Strue    =  Strue * obs_per_seg; %Ex Strue*50 = [0,50,100,150]
   Strue(1) =  1; % [1,50,100,150]; %Always start with 1        

end

if test_exact_paper == 1    %CAUTION: MAKE SURE fixWide_manually = 0
    do_even_groups = 0;
    do_random_generation = 0;
    do_well_data = 0;
    do_AR1_zero_mean = 0; 
    
    exact_paper_1   %%%%%%%% RUN THIS FILE
    
end

if do_AR1_zero_mean == 1 %CAUTION: MAKE SURE fixWide_manually = 0
   do_even_groups = 0;
   do_well_data = 0;
   test_exact_paper = 0;  
   t1 = 1;      t2 = t1;
   m1 = 0;      m2 = 0;

   psi_g = [.22, .22]; %Used only if we think of this with groups with differing
   psi_g_true = psi_g;  %Used only if we think of this with groups with differing
   
   %variances
   

   psiAR_0paper = psi_g(1);
   thetaMA_0 = 0;

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

if do_well_data == 1    %CAUTION: MAKE SURE fixWide_manually = 0
                            % RUN THIS FILE
   do_even_groups = 0;                         
   test_exact_paper = 0;    % We will try to do a simulation based closely on the data from the paper
   do_random_generation = 0;
   do_AR1_zero_mean = 0;    % Designed for a case in which we have just an AR1 process
                            % With all means equal to zero
   well_data_practice       % We import the well data used by the authors in the paper
                            % generates g1_var g1_mean; etc
   
   numSamples = length(S_well);
   
   Kmax = 100;

   ck_segMeans   = zeros(numSamples,Kmax);  %segment means. Columns can increase
   gk_segGroups  = zeros(numSamples,Kmax);  %corresponding group  
   
   %psi_g = [.22, .22]; %CAUTION, this is a place holder but is not currently relevant
   psi_g        = [-0.6396, - 0.6396];
   psi_g_true = psi_g;
   psiAR_0paper = psi_g(1);
   thetaMA_0    = 0.7761;
   
   sig2_0paper = 4;

   t1 = g1_var;      t2 = g2_var;
   m1 = g1_mean;     m2 = g2_mean;  

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

view_hist = 0;

doGui = 1; % set to 1 for input window
if doGui == 1
    reps = 10;
else
    reps = 1;
end
%%

Ngroups = 2; %number of groups

%for repeat = 1:reps% Repeats, but with a GUI window
   
for n = 1:1%This just hides multiple comment sections for now 

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

%% Set number segs and number obs
            % Xcurrent = Xt;
if doGui == 1 % See the GUI file for these variables
        guiLoop   % File that runs a GUI window 
end    


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
%psiAR_0paper = 2*(rand()-1);% Unif(-1,1)
%thetaMA_0 = 2*(rand()-1);%Unif(0,1) 
%Fixed values of psi and theta from the paper
        %gk_segGroups(1) = 2 means that segment 1 data comes from group 2
        %gk_segGroups(n) = j means that segment n data comes from group j
        %etc
tauSquared = zeros(numSamples,Ngroups); %Group variances
    aa = 3; bb = 3; %scale for Inv-gamma
    %Inverse gamma is 1/gamma. Matalb does (shape, rate) rate = 1/scale
    tauSquared(1,1:Ngroups) = 1./gamrnd(aa,1/bb,1,Ngroups);
    mu_N  = zeros(numSamples,Ngroups); %Group means
    mu_N(1,1:Ngroups) = normrnd(0,1,1,Ngroups);
   
mu_k_groupMeans = zeros(numSamples,Ngroups);                        %<----- March14 change doesn't seem to assign any initial group means in this program

sigmaSquared    = zeros(numSamples,1); %Error variance
    %sigmaSquared(1,1:Ngroups) = 1./gamrnd(aa,1/bb,1,Ngroups); %see page 10
    sig2_0paper = 0.96;  sigmaSquared(1)= 1;
    sig2true = .96;
    
    %In the paper, these initial terms were pre-defined.
pi_N            =  zeros(numSamples,Ngroups); %prob group assignments
   % pi_N(1,1:Ngroups) = randperm(Ngroups)/sum(1:Ngroups);
    pi_N(1,1:Ngroups) = zeros(1,Ngroups)+1/Ngroups;
    pi_0 = pi_N(1); %We are just going to have the pi values set to be 1/2, for now
piEstimates = zeros(numSamples,Ngroups);
    piEstimates(1,1:Ngroups) = pi_N(1,1:Ngroups);
  
thetaMA  =  zeros(numSamples,1); %MA stands for moving average
    %thetaMA(1) = (rand()-1/2)*2; % Based on prior dist Unif(-1,1)
    %thetaMA_0 = 0.6; %If this is seet to zero, we just have an AR process
    %thetaMA_0 = 0.6;  This needs to be defined elsewhere  
    thetaMA(1) = thetaMA_0; %from paper, page 10
    
psiAR    =  zeros(numSamples,1); %AR stands for auto-regressive
    %psiAR(1) = (rand()-1/2)*2; %Based on prior dist Unif(-1,1)
    %psiAR_0paper = 0.22; %based on startingh value from paperchangepoints/observations
    
    psiAR(1) = psiAR_0paper;
     %Designed for case in which we might have different psi values
   
phiProbNewSeg   =  zeros(numSamples,1); %prob of change point at any time
    %phi_0 = rand();
    %Phi~       What if this were changed to 0.5?
    %phi_0 = (Ktrue-1)/T; %changepoints/observations
    %phi_0 = 0.05;
    %phiTrue = 0.5;  %We are told that the algorithm is invariant to the starting value of phi
            %if we set phi to be 1/2, it makes the calculations a little
            %easier.
    phi_0 = Ktrue/T;  %The algorithm will converge, regardless of this value
    
    %phi_0 = 1/2;
    %phi_0 = (Kguess-1)/(Kguess*obs_per_seg); %P(change point) ~= (changepoints)/(data points)
    phiProbNewSeg(1) = phi_0; %This is based on how we have initialized our data
    
    %We weren't told anything about what they did to get a starting
    %Value.
%% Assign segments to groups
% to group twos
% This is currently designed for a two group process
% Segments means will be drawn from a normal distribution with
% mean and variance based of of group mean and variance


gk_segGroups_0 = gk_segGroups(1,:); %creates something with same length

if test_exact_paper == 1
    %Don't do anything new. This part was already taken care of earlier in
    %the code. This is only here as a reminder
else

    for i = 1:Ktrue%Eventually this will be generalized to account for
        %all of the different groups

        if do_even_groups == 1 %Defines groups systematically. Odd intervals are group 1
            %even intervals are group 2
            if mod(i,2) == 0
               mu_i = muG1_fixed;                                                                        %<----- March14 change
               tau2_i = tauG1_fixed;
               gk_segGroups(1,i) = 1;
            else
               mu_i = muG2_fixed;                                                                        %<----- March14 change
               tau2_i = tauG2_fixed;
               gk_segGroups(1,i) = 2;
            end

        else
    
            if rand() < pi_0 %Group 1 mean and variance
               %mu_i = mu_N(1,1);    
               mu_i = muG1_fixed;                                                                        %<----- March14 change
               %tau2_i = tauSquared(1,1);
               tau2_i = tauG1_fixed;
               gk_segGroups(1,i) = 1; %Assigns each segment to one of N groups
                %in this case N is just assumed to be 2.
            else
               %mu_i = mu_N(1,2);
               %tau2_i = tauSquared(1,2);
               mu_i = muG2_fixed;                                                                        %<----- March14 change
               %tau2_i = tauSquared(1,1);
               tau2_i = tauG2_fixed;
               gk_segGroups(1,i) = 2;
              
            end

        end
        % Then draw sample means based on group assignments
           
           
        if do_demo2_basic == 1
           ck_segMeans(1,i) = normrnd(0,sqrt(tau2basic) );  %<<<<<<<<<<<<<< This highly simplifies everything
                    %for the purpose of testing out this method
           gk_segGroups(1,:) = 1; %all are default set to group 1                               %<---------- March 21 Need to fix this so that we don't have to 
           gk_segGroups_0(i) = 1;                                               % deal with
           
        else
           ck_segMeans(1,i) = normrnd(mu_i,sqrt(tau2_i)); %matlab passes in standard dev
        end
    end

end




ck_segMeans_0 = ck_segMeans(1,:); %Separately stores initial groups
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









%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      GENERATE DATA RANDOMLY

%%  1 (b) Generate X(t) (ARMA PROCESS) data
k = 1;
%Xt(1) = ck_segMeans(1) + et(1);

et = normrnd(0,sqrt(sig2_0paper),T,1); %Random noise
% 1 20 30 40
% 1 2  3  4
nextPoint = 1;
for i=1:T
    %if( mod(i,obs_per_seg) == 1)%We are at a change point or the first point
                            %in a segment
     if i == nextPoint 
        

        c = ck_segMeans(1,k);
        gr = gk_segGroups(1,k);

        psiParam = psi_g(gr);


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

        lambda_t = c + psiParam*(Xt(i-1)-c) + thetaMA_0*et(i-1);
        % Xt(i)    = c + et(i) + psiAR_0paper*(Xt(i-1)-c) + 
        % thetaMA_0*et(i-1); 
        Xt(i) = et(i) + lambda_t;
        % Xt(i) = c + 4*rand()-2;
        % Xt(i) = c + normrnd(0,1);
        % Re eq 5, page 4
    end
end


% Run Gibbs sampler file
insertion_deletion_demo


%% OLD CODE, Eventually we won't use this or run this
% Part 2: Gibbs Sampler
    % Explanations: Insertion and Deletion steps

% We start off assuming that we have some number of intervals, K 
% We will assume N fixed groups (N = 2 for our initial work based on the
% paper
%
%       Suppose we currectly have K intervals
% |----------]  |--------] ... |-----]...|-------|-------|---------|
%s1=1       d1  s2      d2    sj    dj  s_(K-1) d_(K-1) sK       dK=T
% 
% The actual chainge points are s2 through sK
% Given a segment [sj , dj ]
% We decide whether to insert a change point at any one of the points
% within the segment
%
% We decide whether to delete the next changepoint s_(j+1)
% We repeat this for all segments
%  % We will look at the current segment and the next segment
%  [sj , dj],[s_(j+1) ... d_(j+1)]
% 
% Suppose we insert a changepoint within [sj , dj ]
% then the segment becomes two segments  [sj ,pt],[pt+1 , dj*]
% And the two segments we were looking at are now three segments
%                                  [sj , dj],[s_(j+1) ... d_(j+1)]
%                             [sj ,pt],[pt+1 , dj*],[s_(j+1) ... d_(j+1)]
% Now we decide whether to delete the original change point s_(j+1)
% If we do delete changepoint s_(j+1), we then merge the second and third
% segments that we see, above  [sj ,pt],[pt+1 , dj*],[s_(j+1) ... d_(j+1)]
%                              [sj ,pt],[pt+1 , d_(j+1)]
% 
% *Suppose we then decide to delete the changepoint s_(j+1)
% Then we merge segments
%     [sj , dj ]
% [sj ,
% [s_j , pt],[pt+1 , d_j]
%
%   ... | - - - - - 
%          sk
%           5
% We go across the data set 
% We take interval (s1 = 1, d1) and decide if we should insert a point
% somewhere between s2 and d1, inclusive)
% then we go from (s2 to d2) We decide if we should delete 
%Explanations: Insertion and deletion algorithm
% Insertion. We propose new segment right-endpoints, z. This implies that
% new proposed changepoints are z+1
%
%Strue = 1:(K-1);  Strue = S*obs_per_seg;%K left endpoints
%Strue = [1,Strue]; % right endpoints
%Dtrue = 1:(K-1); Dtrue = Dtrue*obs_per_seg; Dtrue = Dtrue-1; Dtrue = [Dtrue,T];
%S_original = Strue 
%series = Xt;

%S_New = Strue; 
%L = Dtrue-Strue;  %length of segments
%for k = Strue %Each segment [s2,s3,...,sK]
    % Explanations: Insertion step code explanation
    % Length of segmentk is Sk-S_(k-1)
    % This is the approach we take based on the paper by 
    % Farhana Sadiaet al 2018
    % For non-singleton sets, we do the following
    % example, if the segment is [Sk=3,4,6,8,9,12=Dk] 
    % then we choose z in           [3,4,6,8,9] (from Sk to, (Dk) - 1) 
    % z is a proposed new right end-point, and we have two new segments
    %                            [Sk, ... z],[z+1, ... Dk]
    % z is the new right endpoint, z+1 is the new changepoint
    % Suppose z = 6
    % Then we have segments      [Sk = 3,4,6=z],[z=8,9,12]
    %                               [3,4,6],[8,9,12]
    %    Z CANNOT BE THE RIGHT ENDPOINT because then z+1 would be outside
    %    of the current segment
    %           We need to decide if we are going keep these two new
    %           segments or keep the original segment. Se before we even do
    %           this, we do temporary parameter updates on the left and
    %           rightintervals
    %               group left    gl    group right  gr
    %           segment mean left cl    mean right   cr
    % (for some reason we don't choose new segments vairances
    %    gl and gr Groups are chosen from a uniform dist 
    %    now we reference the group means and group standard devations
    %    mu_l and mu_r   tau_l  and tau_r
    %        choose cl from ~N(mu_l, and tau_l^2)
    %        choose cr from ~N(mu_r, and tau_r^2)
    %        At this point we finally have all the new group means and
    %        group variances
    %
    %       FINALLY: We decide wheter to accept or reject this insertion of
    %       a new endpoint z (i.e. decide whether to insert a new
    %       changepoint at z+1]
    %       Accept the new segment separation [3,4,6],[8,9,12]
    %           in addition to accepting the new assigned group and segment
    %           means
    %       Reject this new changepoint and keep [Sk=3,4,6,8,9,12=Dk] 
    %           while also keeping the current segment group and means
    %
    %        
    %
    %       If we do keep the new changepoint, we keep the new left and
    %       right groups and left and right segment means
    %       otherwise we go back to having the same group and segment
    %       mean for the single segment that we started with
    %
    %       See equations 10 and 11 for details on calculating the
    %       acceptance probability
    %    
    %   "Segments" with only one element? Possible, but very rare
    %
    %       In the case where we have a singleton set for our segment, it
    %       means we have a changepoint followed by another change point
    %       in this case we don't do the insertion step because we don't
    %       insert a new changepoint when there is already a changepoint
    %       Example
    %       Sk = {10} for example, means we have a changepoint at 10, but
    %       only one data point at t = 10 before the next changepoint at
    %       t=11.
%end
    % Explanations: Deletion steps code explanation
    % See paper or see other program script regarding this.
% 
end 
%%


% 
% % Insertion Step code
% Kcurrent = Kguess; %Current estimate for number of segments
% Dnew = zeros(1,Kcurrent);
% Snew = zeros(1,Kcurrent);
% 
% Dnew = Dtrue(2:length(Dtrue)); %will be used to store updated segment
% Snew = [Strue(1),Strue(3:length(Strue))]; %endpoints
% % Number of repetitions used to make our estimate
%  % Originally defined at the start of the program
%         % We can re-define it here for code-testing purposes
% newEstimates = zeros(numSamples,2);
% segments2use = 1; %We analyze the numberof segments shown here
% 
% % Acceptance and Rejection Probabilities for insertion  
% 
% r = 1;
% nSegments = Kguess;
% rng(randomSeedChange)
% 
% for sample = 1:1%1:numSamples %how many times we update parameters
%     currentSample = r+1; %%%%%%%%%%%%%%%%%%%%
% 
%     %Dnew = Dtrue(2:length(Dtrue)); %will be used to store updated segment
%     %Snew = [Strue(1),Strue(3:length(Strue))];
%     k = 0;
%     while k <= 0%To test out the code, this will first be run on firt seg
%         k=k+1;
%         if k > nSegments
%             break
%         end
%         dk = Dk(sample,k); 
%         sk = Sk(sample,k); %right and left interval endpoints   
%         numPoints = 3; % number of candidate points (number of 
%         if numPoints > 1 %We have an interval, rather than a single point
% 
% % P1 Rejection probability (proportional to the following)
%             % Calculate a list of errors
%             % We want to update group using Ck, then update gk
%             % Then calculate our acceptance/rejection prob
% 
%             % Product p(et|0,sig2)   *1/(dk-sk)*1/T(K)
%             % How do we calculate 
%             %        p(et|0,sig2)? (which is Normal(0,sig2) )
%             %
%             %        We need to figre out
% 
%             err = zeros(dk-sk,1);
%             ck = ck_segMeans(sample,k); 
%             %ck = mean(Xt(sk:dk));
%             psi = psiAR(sample);
%             theta = thetaMA(sample);
% 
%             % group update for current segment
%             % Group probability
%             gk     =  gk_segGroups(sample,k); %group number corresponding to segment 
%             tau2gk =  tauSquared(sample,k);
%             mu_gk = mu_N(gk,k);
% 
%             err(1) = Xt(sk) - ck; %At the left endpoint
%             %We only have one data point and the segment mean to deal with
%             %kt = Kt(sk);
%             j = 1;
%             for t = (sk+1):dk %from the second point, onward
%                 j = j+1; %index for the set of error terms
%                 lambda_t = ck + psi*(Xt(t-1)-ck) +theta*err(j-1);
%                 err(j) = Xt(t) - lambda_t;    
%             end
% 
%             sig2 = sigmaSquared(sample);
%             phi  = phiProbNewSeg(sample); %1-PHI is prob a 
%                 %changepoint occurs when randomly sampling original data
%             TofK = 4*(Kcurrent)-2*Ngroups+1+1+3;
%                     %*~ %%%%%%% Eventually we will have to change this
% 
%             prob_rej = zeros(dk-sk+1,1); %~<--- changed to + 1 to correctly match length
%             %~products temporary to compare loops
% 
%             for t = 1:(dk-sk+1) %~<--- changed to + 1 to correctly match length
%                 prob_rej(t) = 1/sqrt(sig2)*exp(-1/(2*sig2)*(err(t)^2) );
%             end
%             product = prod(prob_rej);
%             P1 = (1-phi)*product * 1/(dk-sk)*1/(TofK);         
% % P0 Acceptance Probability initialization
% %          %Randomly chooses a left endpoint z from
%             %[sk,sk+1, ... , dk - 1]
%             %Then z+1 will be our new right endpoint if we accept the new
%             %point (that is z+1 is a new change point) 
%             Ik = sk:dk; %Current interval time values
%             segmentLength = length(Ik);
% 
%             zIndex = ceil(rand()*(segmentLength - 1 ) ); %candidate left          
%             %~Zindex set to see if we get high acceptance probability at the first change point
%             %zIndex = obs_per_seg-1; %<-- ~ zIndex change
%             z   = Ik(zIndex); %New left endpoint
%             Ik1 = Ik(1:zIndex);
%             Ik2 = Ik((zIndex+1):segmentLength);
%             sk1 = sk;   dk1 = Ik(zIndex);
%             sk2 = Ik(zIndex+1); dk2 = dk;
% 
%             %Randomly assign new groups
%             %Randomly calculate new segment means for each
%             %segment
% 
%             % NEW GROUPS for the proposed two new segments
%             %Suppose we are updating groups before we update segment means
% 
%             %probG1 = normpdf(ck,mu_N(sample,1),tauSquared(sample,1));
%             %probG2 = normpdf(ck,mu_N(sample,2),tauSquared(sample,2));
% 
%             g1 = ceil(rand()*(Ngroups)); %New groups
%             g2 = ceil(rand()*(Ngroups));
% 
%             pG1 = 1/2;
%             pG2 = 1/2;
%             tau2gk =  tauSquared(sample,k);
%             tauGk  =  sqrt(tau2gk);
%             mu_gk  =  mu_N(gk,k);
% 
%             num = normpdf(ck,mu_gk,tauGk)*0.5;
%             den = normpdf(ck,mu_gk,tauGk)*0.5 + normpdf(ck,mu_gk,tauGk)*0.5;
% 
%             groupConstant = num/den;
% 
%             tauSquared1 = tauSquared(sample,g1); %New group variances
%             tauSquared2 = tauSquared(sample,g2);
% 
%             mu1 = mu_N(sample,g1); %New group means
%             mu2 = mu_N(sample,g2);
% %            
%             %New random group means
%             %Ik1
%             %Ik2
%             %Xt(Ik1)
%             %prod(1:3)
%             %Xt(Ik2)
%             prodcutX1 = prod(normpdf(Xt(Ik1),0,1));
%             productX2 = prod(normpdf(Xt(Ik2),0,1));
%             %ck1 = normrnd(mu1,sqrt(tauSquared1));
%             %ck2 = normrnd(mu2,sqrt(tauSquared2));
%             ck1 = mean(Xt(Ik1));
%             ck2 = mean(Xt(Ik2));
%             %ck1 = ck_segMeans(sample,1); %<--~ck changed to match actual means
%             %ck2 = ck_segMeans(sample,2); %<--~ck changed to match actual means
% %         
%             err1 = zeros(dk1-sk1+1,1);%~2<--- changed to + 1 in correctly match length
%             err2 = zeros(dk2-sk2+1,1);%~2<--- changed to + 1 in correctly match length
%             err1(1) = Xt(sk1) - ck1;
%             err2(1) = Xt(sk2) - ck2;
% %            
%             i = 1;
%             for t = (sk1+1):dk1 % from the second point, onward
%                 i = i+1; % index for the set of error terms
%                 lambda_t = ck1 + psi*(Xt(t-1)-ck1) +theta*err1(i-1);
%                          % = ck*(1-psi) +psi*(Xt(t-1)) +theta*err(t-1)
%                 err1(i) = Xt(t) - lambda_t;
%             end
% 
%             i = 1;
%             for t = (sk2+1):dk2 %from the second point, onward
%                 i = i+1; %index for the set of error terms
%                 lambda_t = ck2 + psi*(Xt(t-1)-ck2) +theta*err2(i-1);
%                         % = ck*(1-psi) +psi*(Xt(t-1)) +theta*err(t-1)
%                 err2(i) = Xt(t) - lambda_t;
%             end
% 
%             prob_rej1 = zeros(dk1-sk1+1,1); % ~1 <--- changed to + 1 in correctly match length
%             for t = 1:(dk1-sk1+1) % ~1 <--- changed to + 1 in correctly match length        
%                 prob_rej1(t) = 1/sqrt(sig2)*exp(-1/(2*sig2)*(err1(t)^2) );
%             end
% 
%             %~ correct number of terms?
%             prob_rej2 = zeros(dk2-sk2,1); %~1<--- changed to + 1 in correctly match length
%             for t = 1:(dk2-sk2+1) %~1<--- changed to + 1 in correctly match length
%                 prob_rej2(t) = 1/sqrt(sig2)*exp(-1/(2*sig2)*(err2(t)^2) );
%             end
%             product1 = prod(prob_rej1);
%             product2 = prod(prob_rej2);
%             %*~2 We will have to use "Kcurrent + 1" for now
%             TofKplus1 = 4*(Kcurrent+1)-2*Ngroups+1+1+3;
% 
%             P0 = phi*product1*product2*1/(TofKplus1);
% 
%             a_P0_accept = P0; %Labels for viewing in workspace
%             a_P1_reject = P1;
%             acceptanceProb = P0/(P0+P1);
%             acceptanceMetrop = min(1,P0/P1); %metropolis hastings way
% 
%             % sig2 already defined
%             % psi already defined
%             % theta already defined
% 
% 
% % Acceptance decision step
%             choiceVal = rand();
%             %if choiceVal < acceptanceProb %acceptanceProb %Keep the new change point
%             %~ Dk needs work
%             if acceptanceProb > 0 %set to zero for now so that we see what happnens if we accept the insertion 
%                Kcurrent = Kcurrent + 1; %Current estimate increases by 1
%                if k == 1
%                   Dnew = [z,Dk(r,1:Kcurrent)]; 
%                else
%                   Dnew = [Dk(r,1:k),z  ,Dk(r,k:(Kcurrent))];
%                end
%                Snew = [Sk(r,1:k),z+1,Sk(r,(k+1):(Kcurrent))];
%                Sk(currentSample,1:(Kcurrent+1)) = Snew;
%                Dk(currentSample,1:(Kcurrent+1)) = Dnew;
%                r = r+1;
%                accepted = 1;
%             else
%                accepted = 0;
%                %do not keep the changepoint
%                %Run the deletion step based on not keeping it
%             end
% 
%             % f = msgbox(["Operation";"Completed"],"Changepoint",'FontSize',14); ...
%             % 'FontSize',14,...
%             % 'Interpreter','latex')
%         else
%             %We don't do anything here because we have a singleton set.
%             %We don't try to insert a new changepoint on intervals of length 1
%         end
% 
% % Deletion Step: 
%         if accepted == 1
%             sk = dk1;
%             dk = dk2;
%             %k = k+1; %Index increases to account for this
%         else
% 
%         end
% %Acceptance probabilities for deletion
%     end
% 
% end

%% Plots called from separate scripts. Original code commented out

%plots_actual_vs_estimates


%% plots_trace
% Original plot code Plots of data, true changepoint locations, and group means
% 
% %clf
% %close all
% 
% f = figure('visible','off','Color','white');
% movegui(f,'northwest')
% shg
% tiledlayout(2,1)
% nexttile
% hold on
% 
% %figure legend and title
% grid on
% title(['Segments: K= ', num2str(Ktrue),'~~~',...
%     '    Groups: ',num2str(Ngroups),'~~~',...
%     '    Observations Per Segment: ', num2str(obs_per_seg)],...
%     'FontSize',14,...
%     'Interpreter','latex')
% 
% 
% %%%%%%  Data scatter plot
% data_plot = plot(Xt,'black','LineWidth',1);
% ylow = min(min(Xt),6)+0.5;   yhigh = min(max(Xt),6)-0.5;
% axis([-obs_per_seg/5, T+obs_per_seg/5, ylow, yhigh])
% %yticks(( (-ceil(min(Xt)):(ceill(max(Xt)) );
% yticks(-10:10);
% cl = .9;  set(gca,'Color',[cl cl cl]); %Gives us a grey plot background
% 
% %%%%%% Red line segments for true segment means
% means_plot = plot(actualMeans,'red','LineWidth',2);
% ylabel('Simulated Data Series $X_{t}$','FontSize',14,'Interpreter','latex')
% xlabel('Sample t','FontSize',14,'Interpreter','latex')
% 
% %%%%%% Vertical blue lines indicate start of new segment (changepoint)
% %%%%%  These are s2 through s_(K-1) where K is the number of segments
% for i=1:(Ktrue-1)
%     xline(obs_per_seg*i,'blue','LineWidth',2.3)
% end
% location_plot = xline(obs_per_seg*i,'blue','LineWidth',2.3);
% 
% legend([location_plot,means_plot],...
%     {'True Change-Point Location $s_{k}$','True Segment Mean $C_{k}$'},...
%     'location','northoutside',...
%     'FontSize',12,...
%     'Interpreter','latex')
% hold off
% % Plots for estimated locations
% 
% nexttile
% %%%%%%  Data scatter plot
% data_plot2 = plot(Xt,'black','LineWidth',1);
% ylow = min(min(Xt),6)+0.5;   yhigh = min(max(Xt),6)-0.5;
% axis([-obs_per_seg/5, T+obs_per_seg/5, ylow, yhigh])
% %yticks(( (-ceil(min(Xt)):(ceill(max(Xt)) );
% yticks(-10:10);
% cl = .9;  set(gca,'Color',[cl cl cl]); %Gives us a grey plot background
% 
% %%%%%% Red line segments for true segment means
% %means_plot = plot(actualMeans,'red','LineWidth',2);
% ylabel('Simulated Data Series $X_{t}$','FontSize',14,'Interpreter','latex')
% xlabel('Sample t','FontSize',14,'Interpreter','latex')
% 
% 
% 
% %% Second plot with change point estimates
% grid on
% 
% %title('Change Point Estimates, depicted with vertical lines.',...
% %   'FontSize',14,'Interpreter','latex')
% %title('Change Point Estimated Locations, depicted with vertical lines')%...
%     %'FontSize',14,'Interpreter','latex')]
%     
% %title('Change Point Estimates, depicted with vertical lines.',...
% %   'FontSize',14,'Interpreter','latex')
% hold on
% 
% %xline(Snew(2),'green','LineWidth',2.3)
% 
% for i=2:(Kcurrent+1)
%     xline(Sk(currentSample,i),'blue','LineWidth',2.3)
% end
% 
% %line([0,ck1],[20,ck1])
% yline(ck1)
% yline(ck2)
% %location_plot = xline(obs_per_seg*i,'blue','LineWidth',2.3);
%     
% Trace Plots Example (What trance plot should look like)
% f = figure();
% 
% startX = 600;
% startY = 300;
% wid = 250;
% len = wid*1.5;
% 
% tiledlayout(2,1)
% f.Position = [startX startY len  wid];
% 
% nexttile
% 
% numSamples = 4000;
% 
% thetaValsExample = normrnd(thetaMA_0,.025,1,numSamples);
% %yticks((-5:5)/5);
% plot(thetaValsExample ,'color','black')
% title('Example(not actual) Trace Plot of $$ \theta $$',...
%    'FontSize',14,'Interpreter','latex')
% hold on
% yline(thetaMA_0,'linewidth',2,'color','red')
% ylim = [.45, .75];
% 
% nexttile
% psiValsExample = normrnd(psiAR_0paper+.008,.035,1,numSamples);
% title('Example (not actual) Trace Plot of $$ \psi $$',...
%    'FontSize',14,'Interpreter','latex')
% hold on
% plot(psiValsExample,'color','black')
% 
% yline(psiAR_0paper,'linewidth',2,'color','red')
% %yline(psiSecondHalf,'linewidth',2,'color','red')
% ylim = [0, .5];
% hold on
% 
% 

% Input window

 
 

%end
