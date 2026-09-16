
doRight = 0;
%%Sm(16:18) = [1400        1493        1500]
%% Brief Change Point results in something that isn't very important
%% Notice when we calculate the posterior mean on smaller intervals, we get results that
%% are way off compared to what we get if we just take the segment mean
ind = 2;

if doRight == 1
    ind = ind+1;
end

leftEndShift = 99;
rightEndShift = 0;
l1 = Sm(ind)  + leftEndShift;
l2 = Sm(ind+1)-1-rightEndShift;
leftData = Xdata(l1:l2);
g_left = Gm(1);

errorLeft = errorAll(l1:l2);

%True group values
psiVal   = psi_g_true(g_left);
thetaVal = theta_g_true(g_left);
tau2gk = t1_true; %tau2gk = t2_true;
%Values corresponding to estimates
psiVal   = psi_g(g_left);
thetaVal = theta_g(g_left);
tau2gk = 10;

mu_gk = mean(leftData);
%tau2gk   = gk_groupVariances(rep,g_left);

%mu_gk    = gk_groupMeans(rep,g_left)

% if g_left == 1
%     mu_gk = -10;
% else
%     mu_gk = 10;
% end


QK = length(leftData) - 1; %qk = dk - sk
lambda_star = leftData;

% if doNewUpdates == 1
%     psiVal   = psi_g(g_left);
%     thetaVal = theta_g(g_left);
%     tau2gk   = gk_groupVariances(rep,g_left);
%     mu_gk    = gk_groupMeans(rep,g_left);
% else
%     psiVal = psi;
%     thetaVal = theta;
%     tau2gk = groupTau_fixed(g_left); %Calculated during the deletion step
%     mu_gk  = groupMu_fixed(g_left); 
% end


%lambda_star(1) = leftData(1) - errorLeft(1);
%lambda_star(1) = leftData(1);
lambda_star(1) = 0;
if length(lambda_star) > 1
    lambda_star(2:(QK+1)) = lambda_star(2:(QK+1)) - psiVal*lambda_star(1:(QK)) - thetaVal*errorLeft(1:QK)';
end

PHI_1 = ( (QK *(1-psiVal)^2+1)/sig2error + 1/tau2gk)^(-1);

x_sk = leftData(1);

THETA_1 = PHI_1*(   (x_sk + (1-psiVal)*sum(lambda_star))/sig2error + mu_gk/tau2gk  );
%THETA_1 = PHI_1*(x_sk + (1-psiVal)*sum(lambda_star))/sig2error +
%mu_gk/tau2gk;  <---- March 28 parentheses
%CK_draw = normrnd(PHI_1  , sqrt(THETA_1));

CK_draw = normrnd(THETA_1, sqrt(PHI_1  ) );
leftMeanUpdate = CK_draw;





drawData = zeros(1,10000);
for i = 1:10000
    drawData(i) = normrnd(THETA_1, sqrt(PHI_1  ) );
end

figure()
histogram(drawData)
hold on
xline(mean(drawData),'LineWidth',2)
mean(drawData)
mean(leftData)
hold on
xline(mean(leftData),'LineWidth',2,'Color','yellow')
Cm(ind)