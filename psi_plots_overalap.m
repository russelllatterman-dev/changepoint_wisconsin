figure()
hold on
plot(psiEstimatesGroups(:,1))
plot(psiEstimatesGroups(:,2))
hold off

figure()
plot(psiEstimatesGroups(:,1))
plot(thetaEstimates)

hold off
figure()
hold on
plot(2*(psiEstimates-mean(psiEstimates))/std(psiEstimates))
plot(-(thetaEstimates-mean(thetaEstimates))/(std(thetaEstimates)))