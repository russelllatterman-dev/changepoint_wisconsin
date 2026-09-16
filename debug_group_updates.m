%Debug
close all
figure()
tiledlayout(3,2)

nexttile
%plot(Xt)
plot(gk_groupMeans(:,1))


nexttile
plot(gk_groupMeans(:,2))


nexttile
plot(gk_groupVariances(:,1))


nexttile
plot(gk_groupVariances(:,2))


nexttile
plot(gk_groupProbabilities(:,1))

nexttile
plot(gk_groupProbabilities(:,2))