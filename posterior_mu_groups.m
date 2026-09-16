%We want to estimate group means.
%We will go through all k segments

%Let m1 be number of segments from group 1
%Let m2 be number of segments from group 2


%% global variables
global Gm
global Cm

global t1
global t2
global m1
global m2

global gk_groupVariances
global gk_groupMeans
global gk_groupProbabilities

global updateTau
global updateGroupMeans
global updateMu 

%% Group Means

if updateGroupMeans == 1
    mu1_sum = 0;
    mu2_sum = 0;
    numG1 = 0;
    numG2 = 0;

    for i = 1:length(Gm)
        if Gm(i) == 1
            mu1_sum = mu1_sum + Cm(i);
            numG1 = numG1 + 1;
        else
            mu2_sum = mu2_sum + Cm(i);
            numG2 = numG2 + 1;
        end
    end
    %end 
    if updateMu == 1   
        if numG1 > 0
            muG1 = mu1_sum/numG1;
            varG1 = t1/numG1;
            m1 = normrnd(muG1, sqrt(varG1));
        end
        
        if numG2 > 0
           muG2 = mu2_sum/numG2;
           varG2 = t2/numG2;
           m2 = normrnd(muG2, sqrt(varG2));
        end
    end   
else
     m1 = muG1_fixed;
     m2 = muG2_fixed;
end

%If we are not updating mu, then we are assigning these fixed values,
%instead
gk_groupMeans(rep+1,1) = m1;
gk_groupMeans(rep+1,2) = m2;

%% Tau
if updateTau == 1

    %error_update
    %%% We have to update the "prior" parameters
    

    alphaPrior1 = 3; %Rate
    betaPrior1  = 3; %
    
    alphaPrior2 = 3;
    betaPrior2  = 3;
    
    alpha1 = alphaPrior1 + numG1/2;
    alpha2 = alphaPrior2 + numG2/2;
    
    beta1 = betaPrior1;
    beta2 = betaPrior2;
    
    sumSquare1 = 0;
    sumSquare2 = 0;
    
    if twoVariances == 1

        for i = 1:length(Gm)
            gr = Gm(i);
            ck = Cm(i);
            if gr == 1
                sumSquare1 = sumSquare1 + (ck - m1)^2;
            end
        
            if gr == 2
               sumSquare2 = sumSquare2 + (ck - m2)^2;
            end
        end
    
        beta1 = betaPrior1 + 1/2*sumSquare1; % The bigger the squared sum, the more variation we seem to get
        beta2 = betaPrior2 + 1/2*sumSquare2; %
        
        if numG1 > 0
           t1 = 1/gamrnd(alpha1,1/beta1);  %(shape, scale)  where scale is 1/rate
        end
        
        if numG2 > 0
           t2 = 1/gamrnd(alpha2,1/beta2);
        end

    else %We are considering group variances to be equal

        alphaPrior1 = 3; %Rate
        betaPrior1  = 3; %
        
        alpha1 = alphaPrior1 + length(Gm)/2;     
        
        beta1 = betaPrior1;
        
        sumSquare1 = 0;

        for i = 1:length(Gm)
            gr = Gm(i);
            ck = Cm(i);
            if gr == 1
                sumSquare1 = sumSquare1 + (ck - m1)^2;
            end
        
            if gr == 2
               sumSquare1 = sumSquare1 + (ck - m2)^2;
            end
        end
        
        beta1 = betaPrior1 + 1/2*sumSquare1; % The bigger the squared sum, the more variation we seem to get
        %beta2 = betaPrior2 + 1/2*sumSquare2; %
        
        t1 = 1/gamrnd(alpha1,1/beta1);  %(shape, scale)  where scale is 1/rate
        t2 = t1; %We are storing this here as a placeholder

    end
else
    t1 = tauG1_fixed;
    t2 = tauG2_fixed; 
end%When we have the code set to twovariances == 0, group variance will
    %be the same for each group
gk_groupVariances(rep+1,1) = t1;
gk_groupVariances(rep+1,2) = t2; 


%% PI
if updatePi == 1
    
    %error_update
    numG1 = abs(sum(Gm-2));
    numG2 = sum(Gm-1);

    %%General Dirichlet 
    %a = [numG1+1,numG2+2];
    a = [numG1+1,numG2+1];

    n = 1;

    p = length(a);
    r = gamrnd(repmat(a,n,1),1,n,p);
    r = r ./ repmat(sum(r,2),1,p);

    %pi ~ dirichlet(pi|numG1+1,numG2+2)
    pi1 = r(1);
    pi2 = r(2);
else
    pi1 = pi1_true;
    pi2 = pi2_true;
end

gk_groupProbabilities(rep+1,1) = pi1;
gk_groupProbabilities(rep+1,2) = pi2;







