%% Trance Plots
f = figure();

startX = 600;
startY = 300;
wid = 250;
len = wid*1.5;

tiledlayout(2,1)
f.Position = [startX startY len  wid];

nexttile

nSamples = 4000;

thetaVals = normrnd(thetaMA_0,.025,1,nSamples);
%yticks((-5:5)/5);
plot(thetaVals,'color','black')
title('Trace Plot of $$ \theta $$',...
   'FontSize',14,'Interpreter','latex')
hold on
yline(thetaMA_0,'linewidth',2,'color','red')
ylim([.45,.75])

nexttile
psiVals = normrnd(psiAR_0paper+.008,.035,1,nSamples);
title('Trace Plot of $$ \psi $$',...
   'FontSize',14,'Interpreter','latex')
hold on
plot(psiVals,'color','black')
yline(psiAR_0paper,'linewidth',2,'color','red')
ylim([0,.5])
hold on