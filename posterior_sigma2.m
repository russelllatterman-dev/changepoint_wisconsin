%Error terms are distributed Normal with mean 0 and variance sigma2
%We use this to update our estimate of sigma2

%PI
%Uniform(b1+1,b2+1)
%Where b1 is number of segments in group 1
% and b2 is the number of segments in group 2

%PHI - see other file

%MU
%Mu for group n Does not update if there are no segments in group n
%Normal: Mean sum(Ck for group 1 segments)/m   variance tau2groupe1/m

%Where m = number of groups? check on this

%PHI Beta(K,T-K)

%Sigma squared
%Inverse gamma u v
% u = u0 + T/2
% v = (2v_0 + sum(all errors squared)) / 2
% Where u0 and v0 are prior parameters  (Where do we get these priors?)


% u0_prior = 3; %These priors are defined in the main program
% v0_prior = 1/3;
% 
% uParam = u0_prior + T/2
% 
% vParam = v0_prior   +    sum(errorAll.^2)/2
% 
% vParam/(uParam-1)
% 
% sig2error = 1/gamrnd(uParam,1/vParam);
% 
% sig2Estimates(rep+1) = sig2error;


u = 3 + T/2;

v = 3 + sum(errorAll.^2)/2;

sig2error = 1/gamrnd(u,1/v);

%Tau2

%Inverse gamma
% a0 and b0 are priors
% a = a0 + abs(number of segments in group 1)/2    b = b0 + 1/2*sum( (ck - meanGroup1)^2 )

%Do the same thing for group 2

%Why do we have an absolute value here? We won't ever estimate something
%less than zero

%Only update if we have a non-zero number of segments



%Group. On each segment, k
% Discrete distribution with parameters
% N(ck|mu_gk, tau2_gk) * pi_gk

% Looks like it will be another truncated normal.
% We might only need to do an update for group 1. However, what if we
% update for group 1 and then update for group 2.
% We would have sampled two values, and they won't sum to 1. We could take
% a weighted average of the two.