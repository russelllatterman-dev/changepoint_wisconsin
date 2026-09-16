% If an insertion occurs, we will update the left and right segments 
global whichUpdate

global psi
global theta
global psi_g
global theta_g
global doNewUpdates

global gk_groupMeans

%Look for lambda_star(1)

updateType = 2; %Priviously we have a simpler update procedure that was used, whereby we would 
%Take the mean of the segment, rather than doing these calculations. That
%was only for initial debugging purposes

if updateType == 2 %We are doing an insertion update

    if whichUpdate == 1 %We are doing an insertion update

        %Left mean update, given that an insertion just occured
        
        %leftMeanUpdate = mean(leftData);
        QK = length(leftData) - 1; %qk = dk - sk
        lambda_star = leftData;
        lambda_star(1) = 0;

        if doNewUpdates == 1
            psiVal   = psi_g(g_left);
            thetaVal = theta_g(g_left);
            tau2gk   = gk_groupVariances(rep,g_left);
            mu_gk    = gk_groupMeans(rep,g_left);
        else
            psiVal = psi;
            thetaVal = theta;
            tau2gk = groupTau_fixed(g_left); %Calculated during the deletion step
            mu_gk  = groupMu_fixed(g_left); 
        end

        if length(lambda_star) > 1
            lambda_star(2:(QK+1)) = lambda_star(2:(QK+1)) - psiVal*lambda_star(1:(QK)) - thetaVal*errorLeft(1:QK);
        end
   
        PHI_1 = ( (QK *(1-psiVal)^2+1)/sig2error + 1/tau2gk)^(-1);
        
        x_sk = leftData(1);
        
        THETA_1 = PHI_1*(   (x_sk + (1-psiVal)*sum(lambda_star))/sig2error + mu_gk/tau2gk  );
        %THETA_1 = PHI_1*(x_sk + (1-psiVal)*sum(lambda_star))/sig2error +
        %mu_gk/tau2gk;  <---- March 28 parentheses
        %CK_draw = normrnd(PHI_1  , sqrt(THETA_1));
        
        CK_draw = normrnd(THETA_1, sqrt(PHI_1  ) );
        leftMeanUpdate = CK_draw;

        if doNewUpdates == 1 %debug

            if leftMeanUpdate == 0
               disp('ERROR: Insertion mean update 0, LEFT')
                rep
                THETA_1
                PHI_1
                psiVal 
                thetaVal 
                tau2gk 
                mu_gk 
            end

        end
    
        
        %%%%%%%%%%%      Right update

        if doNewUpdates == 1
            psiVal = psi_g(g_right);
            thetaVal = theta_g(g_right);
            tau2gk = gk_groupVariances(rep,g_right);
            mu_gk =  gk_groupMeans(rep,g_right);
        else
            psiVal = psi;
            thetaVal = theta;
            tau2gk = groupTau_fixed(g_right); %Calculated during the deletion step
            mu_gk  = groupMu_fixed(g_right); 
        end

        QK = length(rightData) - 1; %qk = dk - sk
        lambda_star = rightData;
        lambda_star(1) = 0;
        if length(lambda_star) > 1
            lambda_star(2:(QK+1)) = lambda_star(2:(QK+1)) - psiVal*lambda_star(1:(QK)) - thetaVal*errorRight(1:QK);
        end
        
        PHI_1 = ( (QK *(1-psiVal)^2+1)/sig2error + 1/tau2gk)^(-1);
        
        x_sk = rightData(1);
        
        THETA_1 = PHI_1*( (x_sk + (1-psiVal)*sum(lambda_star))/sig2error + mu_gk/tau2gk);
        %THETA_1 = PHI_1*(x_sk + (1-psiVal)*sum(lambda_star))/sig2error + mu_gk/tau2gk; <---- March 28 parentheses
        
        %CK_draw = normrnd(PHI_1  , sqrt(THETA_1));
        
        CK_draw = normrnd(THETA_1, sqrt(PHI_1) );
            
        rightMeanUpdate = CK_draw; 
        
        if doNewGroupUpdate == 1
            leftGroupUpdate = g_left;
            rightGroupUpdate = g_right;
        else
            if leftMeanUpdate <= 0
                leftGroupUpdate = 1; %A very basic way to update groups
            else
                leftGroupUpdate = 2;
            end
    
            if rightMeanUpdate <= 0
                rightGroupUpdate = 1; %A very basic way to update groups
            else
                rightGroupUpdate = 2;
            end
        end

        if doNewUpdates == 1 %debug

            if rightMeanUpdate == 0

                disp('ERROR: Insertion mean update 0, RIGHT')
                rep
                THETA_1
                PHI_1
                psiVal
                thetaVal
                tau2gk
                mu_gk
            end

        end
    end
    
    if whichUpdate == 2 %When a deletion occurs, we do this
        %dmeanUpdate = mean(dintervalData); 
        nullGroup = 1;
        if doNewUpdates == 1
            psiVal   = psi_g(dg_null);
            thetaVal = theta_g(dg_null);
            tau2gk = gk_groupVariances(rep, dg_null);
            mu_gk  = gk_groupMeans(rep, dg_null);
        else
            psiVal   = psi;
            thetaVal = theta;   
            tau2gk   = tauNull; %Calculated during the deletion step
            mu_gk    = muNull; 
        end
        QK = length(dintervalData) - 1; %qk = dk - sk    
        lambda_star = dintervalData;
        lambda_star(1) = 0;
        lambda_star(2:(QK+1)) = lambda_star(2:(QK+1)) - psiVal*lambda_star(1:(QK)) - thetaVal*error_full(1:QK);
     
        PHI_1 = ( (QK *(1-psiVal)^2+1)/sig2error + 1/tau2gk)^(-1);
        x_sk  = dintervalData(1);
        
        THETA_1 = PHI_1*( (x_sk + (1-psiVal)*sum(lambda_star))/sig2error + mu_gk/tau2gk ) ;
        %THETA_1 = PHI_1* (x_sk + (1-psiVal)*sum(lambda_star))/sig2error +
        %mu_gk/tau2gk  ; <---march 28 missing outer parentheses 
        %CK_draw = normrnd(PHI_1  , sqrt(THETA_1));
        
        CK_draw = normrnd(THETA_1, sqrt(PHI_1  ) );  
        dmeanUpdate = CK_draw;
        
        %Full conditional density: Ck ~ N(PHI_1, sqrt(THETA_1))
        

        if dmeanUpdate == 0 %debug
           disp('ERROR: mean update 0 in deletion step:')
           rep
           THETA_1
           PHI_1
           psiVal
           thetaVal
           tau2gk
           mu_gk
        end

        if doNewGroupUpdate == 1
            dgroupUpdate = dg_null;
        else
            if  dmeanUpdate <= 0
                dgroupUpdate = 1; %A very basic way to update groups
            else
                dgroupUpdate = 2;
            end
        end
        
    end
 
end

if updateType == 1


end