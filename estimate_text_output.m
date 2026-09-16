%Run this at the end of insertion_deletion_demo

%number of segments actually assigned to groups 1 and 2
numG1true = abs(sum(Gtrue-2));
numG2true = sum(Gtrue-1);

propG1true = sum(numG1true/(numG1true+numG2true));
propG2true = 1-propG1true;
%
%Number of estimated segments in groups 1 and 2
numG1 = abs(sum(Gm-2));
numG2 = sum(Gm-1);

propG1 = sum(numG1/(numG1+numG2));
propG2 = 1-propG1;

%%% Second half of data
totalEstimates = length(gk_groupMeans);
burnInStart = totalEstimates-floor(totalEstimates/2);

psiBurn1 = mean(psiEstimatesGroups(burnInStart:length(psiEstimatesGroups),1));
psiBurn2 = mean(psiEstimatesGroups(burnInStart:length(psiEstimatesGroups),2));

thetaBurn1 = mean(thetaEstimatesGroups(burnInStart:length(psiEstimatesGroups),1)); %THETA2
thetaBurn2 = mean(thetaEstimatesGroups(burnInStart:length(psiEstimatesGroups),2)); %THETA2

disp('')
disp('With a burn-in')
disp(['Total Estimates     ', ' ', num2str(totalEstimates) , '  burn-in   ', num2str(burnInStart)])
disp(' ')
disp(['gk_groupMeans          ', '   ', num2str( mean(gk_groupMeans(burnInStart:totalEstimates,:) ) ) ])
disp(['Actual m1_true m2_true ', '   ', num2str(m1_true)     , '           ' num2str(m2_true)])
disp(' ')
disp(['gk_groupVariances      ', '   ', num2str(mean(gk_groupVariances(burnInStart:totalEstimates,:)))])
disp(['Actual Group Variances ', '   ', num2str(tauG1_fixed) , '           ', num2str(tauG2_fixed)])
disp(' ')
disp(['gk_groupProbabilities  ', '   ', num2str(mean(gk_groupProbabilities(burnInStart:totalEstimates,:))) ])
disp(['pi1_true and pi2_true  ', '   ', num2str(pi1_true)    , '          ',   num2str(pi2_true) ] )
disp(' ')
disp(['Estimate in G1/G2 prop ', '   ', num2str(propG1)      , '          ', num2str(propG2) ])
disp(['Proportions (actual)   ', '   ', num2str(propG1true)  , '          ', num2str(propG2true) ])
disp(' ')
disp(['psiEstimatesGroups     ', '   ', num2str(psiBurn1) , '       ', num2str(psiBurn2) ])
disp(['PSI True               ', '    ', num2str(psi_g_true(1)),'          ', num2str(psi_g_true(2)) ])
disp(' ')
disp(['thetaEstimatesGroups   ', '   ', num2str(thetaBurn1) , '       ', num2str(thetaBurn2) ])
disp(['thetaTrue              ', '    ', num2str(num2str(theta_g_true(1))),'          ', num2str(theta_g_true(2)) ])

disp(' ')