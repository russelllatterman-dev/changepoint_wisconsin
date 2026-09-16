%Here we generate some data from an AR(1) process. Assuming two groups

% if  do_AR1_zero_mean == 1     % This is what we are dealing with in the
%           basic10intervals  file
% 
%                 AR_mean0_groups2
%                 Ktrue = numARsegs; % True number of segments (#change points is K-1) 
%                 obs_per_seg = AR_obs_per_seg;
%             else
%                 Ktrue = 10; % True number of segments (#change points is K-1) 
%                 obs_per_seg = 100;
% end

fixedWidth = 1;

numARsegs = 2;      %Ktrue is set to this
AR_obs_per_seg = 500;  %obs_per_seg is set to this fixed number of obs per seg

% Xt = c + et + psi(x_tm1 - c) + theta*x_tm1    ARMA process
% AR(1) process

c1 = 0;  c2 = 0;
% Let et ~ N(0,1)
% Xt  = et + psi*x_tm1


thetaMA1 = 0;   thetaMA2 = 0; %If we want this to be a generalized ARMA model
psiAR1 = 0;     psiAR2 = .9;

psiAR_g = [psiAR1 , psiAR2];

nPoints = numARsegs*AR_obs_per_seg;
Xseries = zeros(nPoints,1);

actualGroups = zeros(numARsegs,1);



for i = 1:numARsegs
    if mod(i,2) == 0 %The evens will be assigned to group 2
        actualGroups(i) = 2;
    else
        actualGroups(i) = 1;
    end
end



error_terms = normrnd(0, 1, nPoints);

t = 0;
for i = 1:numARsegs %For now this just works for AR process
    psi_Gi = psiAR_g( actualGroups(i) );
    t = t + 1;
    Xseries(point_num) = error_terms(t);
    for j = 1:(AR_obs_per_seg-1) 
        t = t + 1;
        Xseries(t) = error_terms(t) + psi_Gi*Xseries(t-1);
    end
end



% 
% Xseries(1) = c + error_terms(1);
% for i = 2:ceil(nPoints/2)
%     Xseries(i) = c1 + error_terms(i) + psiAR1 * (Xseries(i-1) - c1) + thetaMA1*error_terms(i-1);
% end
% 
% for i = (ceil(nPoints/2)+1):nPoints
%     Xseries(i) = c2 + error_terms(i) + psiAR2 * (Xseries(i-1) - c2) + thetaMA2*error_terms(i-1);
% end

plot(Xseries)


