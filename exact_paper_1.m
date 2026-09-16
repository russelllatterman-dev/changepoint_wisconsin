%These are observed segment means from the paper produced by the author
%They did not give their parameters, so these were precicely infered based
%on their given graphical output.

%We first define the observed segment means.
%We then standardize everything to that we have these data centered about
%zero.

%We then get an estimate for the overal group means and overal group
%variances

%We assume group variances are equal, and group means are identical in
%magnitude and opposite in sign, which is apparent based on the wording of
%the paper.

global Ktrue        % Actual number of estimates
global Kmax %length of vector to store estimate
global obs_per_seg  %observations per segment
global Kguess       % Initial guess number of segments

global T
global ck_segMeans
global gk_segGroups
global gk_segGroups_0
global ck_segMeans_0
global tauG1_fixed % = 16;  %<----- March14 change
global tauG2_fixed % = 16;

global muG1_fixed % = -10;
global muG2_fixed % = 10;
global sig2_0paper % Matches what we are given in the paper
global Xt
global t1   %Group variance
global t2
global m1   %Group mean
global m2

global psi_g

global thetaMA_0
global psiAR_0paper

Ktrue       = 20;    % True number of segments (#change points is K-1) 
obs_per_seg = 100;
Kguess = 5;
    
psi_g = [.22, .22]; %Used only if we think of this with groups with differing
psi_g_true = psi_g;
%variances

psiAR_0paper = psi_g(1);

thetaMA_0 = 0.6;

T = Ktrue * obs_per_seg;
Kmax = 3*max(2*(Ktrue+1),2*(Kguess+1)); %allocate space for estimated segments
   
Strue    =  0:(Ktrue - 1); %Left endpoints ex: [0,1,2,3, ... (Ktrue-1)] 
Strue    =  Strue * obs_per_seg; %Ex Strue*50 = [0,50,100,150]
Strue(1) =  1; % [1,50,100,150]; %Always start with 1  

sig2_0paper = 0.96;


%The following are based on observations from the graph given in the paper
ck_segMeans = [  4.6875	, ... 
                     1.875	,	...
                    -1.875	,	...
                    -1.25	,	...
                     1.25	,	...
                    -3.90625	,	...
                     5.3125	,	...
                    -3.75	,	...
                    -1.40625	,	...
                     2.03125	,	...
                    -3.4375	,	...
                    -0.3125	,	...
                     1.25	,	...
                    -1.875	,	...
                     5.625  ,   ...
                     1.875	,	...
                    -0.78125	,	...
                     2.65625	,	...
                    -1.875	,	...
                     2.65625	,	...
                ];

   %Let's shift the data down to center it all at zero
   ck_segMeans      = ck_segMeans - mean(ck_segMeans);

   ck_meansCentered = ck_segMeans - mean(ck_segMeans); %We assume that 
   %The authors intended everything to be centered about zero.

   %ck_segMeansCentered = ck_segMeans - mean(ck_segMeans);

   total1 = 0;
   total2 = 0;
   num1 = 0;
   num2 = 0;

   ck_group1 = [];
   ck_group2 = [];

   gk_group1 = [];
   gk_group2 = [];

  

   for i = 1:length(ck_meansCentered)

       ck = ck_meansCentered(i);
       if ck < 0 %Since this is centered about zero and we are going to guess the groups
           %based on this. We assume the author generated data based on
           %having it separated such that segments generated from one group
           %will have means that are very far from segments generated from
           %a separate group.
            num1 = num1+1;
            total1 = total1 + ck;
            ck_group1(num1) = ck;
            gk_segGroups(1,i) = 1;
       else
            total2 = total2 + ck;
            num2 = num2+1;
            ck_group2(num2) = ck;
            gk_segGroups(1,i) = 2;
       end
   end
   
   paperMean1 = total1/num1; %Estimated means defined from paper based on data
   paperMean2 = total2/num2;
 
   %t1 = var(ck_meansCentered);
   %t2 = t1;

   ck_all_centered = [ck_group2-mean(ck_group2), ck_group1-mean(ck_group1)];
   avgVar = var(ck_all_centered);

   t1 = var(ck_group1); %These are estimates based on what we find in the data
   t2 = var(ck_group2);

   %t1 = avgVar;
   %t2 = t1;

   %m1 = paperMean1;
   %m2 = paperMean2;

   %Apparent exact intended values
   %t1 = 2; t2 = t1; m1 = -2.5; m2 = 2.5;


