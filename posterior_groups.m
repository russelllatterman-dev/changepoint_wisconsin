% We might consider there to be two distinct groups. We are then supposed to
% use this idea to estimate which group data may be coming from.

% N(ck|mu_gk, var_gk) * pi_gk
global t1
global t2
global m1
global m2
global pi1
global pi2
global gk_segGroups
global Gm
global Cm
global rep


for k = 1:length(Gm)
    Ck = Cm(k);
    %gP1 = 1/sqrt(t1)*exp(-1/(2*t1^2)*(Ck-m1)^2)*pi1;

    %gP2 = 1/sqrt(t2)*exp(-1/(2*t2^2)*(Ck-m2)^2)*pi2;

    gP1 = 1/sqrt(t1)*exp(-1/(2*t1)*(Ck-m1)^2)*pi1; %t1 and t1 actually stand for 
    %variances tau1 squared and tau2 squared
    gP2 = 1/sqrt(t2)*exp(-1/(2*t2)*(Ck-m2)^2)*pi2;

    if rand() < gP1/(gP1+gP2)
        gk_segGroups(rep+1,k) = 1;
        Gm(k) = 1;
    else
        gk_segGroups(rep+1,k) = 2;
        Gm(k) = 2;
    end

end