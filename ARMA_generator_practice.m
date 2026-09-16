% Xt = c + et + psi(x_tm1 - c) + theta*x_tm1    ARMA process

close all
% AR(1) process

c1 = 0;
c2 = 10;
% Let et ~ N(0,1)
% Xt  = et + psi*x_tm1
thetaMA1 = 0;   
thetaMA2 = 0;
psiAR1 = .5;
psiAR2 = -.5;
sig2_err = .3;

phi_now = 0.01;

psiGroup   = [psiAR1,psiAR2];
thetaGroup = [thetaMA1, thetaMA2];

nPoints = 1000;
Xseries = zeros(nPoints,1);

XseriesManual = zeros(nPoints,1);

error_terms = normrnd(0,sqrt(sig2_err),nPoints);

manualPoints = [1, 50, 200, 500, 600, 800, nPoints];
manualMeans  = [-1,   1,  -1,  1,  -1,  1]*5;
manualGroups = [1,    2,   1,  2,   1,  2];

Xseries(1) = c1 + error_terms(1);
for i = 2:ceil(nPoints/2)
    Xseries(i) = c1 + error_terms(i) + psiAR1 * (Xseries(i-1) - c1) + thetaMA1*error_terms(i-1);
end

sampleVar1 = std(Xseries(1:ceil(nPoints/2)) )^2 
Var1 = (1+2*psiAR1*thetaMA1+thetaMA1^2)*sig2_err/(1-psiAR1^2)


for i = (ceil(nPoints/2)+1):nPoints
    Xseries(i) = c2 + error_terms(i) + psiAR2 * (Xseries(i-1) - c2) + thetaMA2*error_terms(i-1);
end

seriesDifferences = Xseries(1:(nPoints-1)) - Xseries(2:(nPoints));

differences1 = seriesDifferences(1:ceil(nPoints/2));
differences2 = seriesDifferences(ceil(nPoints/2):(nPoints-1));

varDiff1 = std(differences1)^2



sampleVar2 = std(Xseries( (ceil(nPoints/2)+1):nPoints) )^2 
Var2 = (1+2*psiAR2*thetaMA2+thetaMA2^2)*sig2_err/(1-psiAR2^2)
varDiff2 = std(differences2)^2


for i = 1:(length(manualPoints)-1)
    
    p1 = manualPoints(i);
    p2 = manualPoints(i+1)-1;
    group_i = manualGroups(i);
    mean_i = manualMeans(i);

    psi_i = psiGroup(group_i);
    theta_i = thetaGroup(group_i);


    XseriesManual(p1) = mean_i + error_terms(p1);
    for j = (p1+1):p2
        XseriesManual(j) = mean_i + error_terms(j) + psi_i * (XseriesManual(j-1) - c1) + theta_i*error_terms(j-1);
    end
end
j = p2+1;
XseriesManual(j+1)       = mean_i + error_terms(j+1) + psi_i * (XseriesManual(j) - c1) + theta_i*error_terms(j);

XseriesManual

figure()
plot(Xseries)

figure()
plot(XseriesManual)
hold on
for i = 1:(length(manualPoints)-1)
    xline(manualPoints(i),'LineWidth',2)
end
hold off

figure()
plot(XseriesManual)




