
%Posterior distribution for theta  ARMA(1,1) with parameters psi and theta

%1 Try this with all error terms. This might make the mean of the truncated
%normal appropriately smaller

%2 Might need to do something so that we can get a legit update when we
%have adjacent change points (but we probably don't need to do this)

%Modify so that we include the very last value in the list
global theta_g
global theta
global errorAll
global psi_g
global psi
global psi_two_groups
global theta_two_groups

global psi_g                          
global psi   

previewHistogram = 0;
error2Sum = sum(errorAll.^2);
innerSum = 0;

%new code (less advanced, but easier to read for debugging
denominatorSum = 0;
innerErrorSum = 0;
numeratorSum = 0;
innerNumeratorSum = 0;


psiCurrent = psi;

%useNewCode = 1;

doRandomScatter = 0;

%if useNewCode == 1

%if doRandomScatter == 1 %Just does a scatter of data around the actual value of theta
    %This allows us to determine whether the posterior for psi is
    %working when theta is flucutating. This is kind of like the
    %most ideal case we can get, asside from holding theta fixed at
    %the true value

%theta = thetaMA_0 + normrnd(0,.0125);

groupTHETA_calc = [0,0]; %We use this to locally store estimates

numG1segs = 0; %We only update parameter estimates for a group  i
numG2segs = 0; %if we have at least one segment attributed to group i

%We assume two groups
for k = 1:(length(S)-1)
    if Gm(k) == 1
        numG1segs = numG1segs + 1;
    end

    if Gm(k) == 2
        numG2segs = numG2segs + 1;
    end
end

numGroups = 1; %This is the case if number of theta terms is 1
%else %We are doing the actual calculations based on the derivated posterior distribution for theta
if theta_two_groups == 1
    numGroups = 2;

    for groupNumber = 1:numGroups
        if groupNumber == 1
            numGroupSegs = numG1segs;
        end
        if groupNumber == 2
           numGroupSegs = numG2segs;
        end
        %****
        %If we are only doing one THETA param (numGroups == 1)
        %Then we don't need to calculate psi based on the segment group
        if numGroupSegs > 0 || numGroups == 1 %Then we will do a calculation

            denominatorSum = 0;
            numeratorSum = 0;

            for k = 1:(length(S)-1) 
    
                if Gm(k) == groupNumber || numGroups == 1
                    CK = C(k);
                    gr = Gm(k);

                    sk_lower = S(k)   + 1;
                    sk_upper = S(k+1) - 1; 

                    innerErrorSum = 0;
                    innerNumeratorSum = 0;
                   
                    if k == length(S)-1      %At the very last step, we need
                    % to include the very last point in our list of values
                        sk_upper = S(k + 1);
                    end
                
                    if psi_two_groups == 1
                        psiCurrent = psi_g(gr);
                    else
                        psiCurrent = psi;
                    end
                    
                    if sk_upper - sk_lower >= 0 % If it's 0, then we are dealing with just one point
                       for t = sk_lower:sk_upper
                            et_m1 = errorAll(t-1);
                            et    = errorAll(t);
                            innerErrorSum     = innerErrorSum + et_m1^2;                                                                    
                            innerNumeratorSum = innerNumeratorSum + et_m1*( Xdata(t) - CK - psiCurrent*(Xdata(t-1)-CK));
                       end
                    end
                
                    denominatorSum = denominatorSum + innerErrorSum;
                    numeratorSum   = numeratorSum   + innerNumeratorSum;
                end %if Gm(k) == groupNumber || numGroups == 1
            end %for k = 1:(length(S)-1)
        

            VAR_THETA = (sig2error/denominatorSum);
            MEAN_THETA = (numeratorSum/denominatorSum);  %This was the
            
            thetaVariances(rep) = VAR_THETA;   %%%%%% Keeps track of variances          
            thetaMeans(rep)     = MEAN_THETA;  %%%%%% Keeps trakc of means
            
            %adjustedVStandardDev = max(sqrt(VAR_THETA),2*abs(adjustedMean)/12); %tried april 15 to prevent "catastrophic rounding error"
            adjustedVStandardDev = sqrt(VAR_THETA); %%%%% we input standard deviation
            adjustedThetaMeans(rep) = MEAN_THETA ;
        
            %dist_for_theta = makedist('Normal',adjustedMean,adjustedVStandardDev); %tried april 15 to prevent "catastrophic rounding error"
                            %Prevents the error but results in all values
                            %of theta being estimated too high
            
            %Check to make sure we don't have a case in which 
            %We have undefined estimates

            %Error checking

            if isnan(VAR_THETA) || isnan(MEAN_THETA) || isinf(abs(VAR_THETA)) || isinf(abs(MEAN_THETA))
               disp(['NaN or +/1 inf Theta:',' mean = ', num2str(MEAN_THETA) , ' VAR_THETA = ', num2str(VAR_THETA)])
               disp(['numeratorSum ',num2str(numeratorSum)])
               disp(['denominatorSum ',num2str(denominatorSum)])
               break %We don't update theta
            end
    
    
            if VAR_THETA == 0
                if abs(MEAN_THETA) > 1
                   counter1 = counter1 + 1;
                   adjustedMean = 1*sign(MEAN_THETA);
                   theta_g(gr) = adjustedMean;
                   theta = theta_g(1);
                   disp('THETA VAR = 0   AND  MAG > 1. Theta Set to +/- 1')
                else
                   disp(['THETA VAR = 0   Theta fixed to ', num2str(MEAN_THETA)])
                end
            else %Variance calculation is non-zero
                if abs(MEAN_THETA) > 1 %Non-stationarity in this case, so we set the value to 1 or -1
                   counter1 = counter1 + 1;
                   adjustedMean = 1*sign(MEAN_THETA);
                   theta_g(gr) = adjustedMean;
                   theta = theta_g(1);
                   disp('THETA MAG > 1. Theta Set to +/- 1')
                else
                   %dist_for_theta = makedist('Normal',MEAN_THETA, VAR_THETA ); %tried april 15 to prevent "catastrophic rounding error"
                   dist_for_theta = makedist('Normal',MEAN_THETA,sqrt(VAR_THETA)); %tried april 15 to prevent "catastrophic rounding error"
                   truncatedNormal_theta = truncate(dist_for_theta,-1,1);
                   newTheta = random(truncatedNormal_theta);
                   theta_g(gr) = newTheta;
                   theta = theta_g(1);  
                end  
            end

        end %If numGroupSegs > 0 || numGroups == 1


    end %For groupNumber = 1:numGroups

else %(if theta_two_groups == 1) is false

    for k = 1:(length(S)-1) 
        innerErrorSum = 0;
        innerNumeratorSum = 0;
    
        
        sk_lower = S(k)   + 1;
        sk_upper = S(k+1) - 1; 
        
        if k == length(S)-1
            sk_upper = S(k + 1);
        end
        CK = C(k);
        gr = Gm(k);
    
        if psi_two_groups == 1
            psiCurrent = psi_g(gr);
        else
            psiCurrent = psi;
        end
        
        if sk_upper - sk_lower > 0 % If it's 0, then we are dealing with just one point
           for t = sk_lower:sk_upper
                et_m1 = errorAll(t-1);
                et    = errorAll(t);
                innerErrorSum     = innerErrorSum + et_m1^2;                                                                    
                innerNumeratorSum = innerNumeratorSum + et_m1*( Xdata(t) - CK - psiCurrent*(Xdata(t-1)-CK));
           end
        end
    
        denominatorSum = denominatorSum + innerErrorSum;
        numeratorSum   = numeratorSum   + innerNumeratorSum;
    end
    
    VAR_THETA = (sig2error/denominatorSum);
    MEAN_THETA = (numeratorSum/denominatorSum);  %This was the
    
    thetaVariances(rep) = VAR_THETA;   %%%%%% Keeps track of variances          
    thetaMeans(rep)     = MEAN_THETA;  %%%%%% Keeps trakc of means
    
    %adjustedVStandardDev = max(sqrt(VAR_THETA),2*abs(adjustedMean)/12); %tried april 15 to prevent "catastrophic rounding error"
    adjustedVStandardDev = sqrt(VAR_THETA); %%%%% we input standard deviation
    adjustedThetaMeans(rep) = MEAN_THETA ;
    %dist_for_theta = makedist('Normal',adjustedMean,adjustedVStandardDev); %tried april 15 to prevent "catastrophic rounding error"
                    %Prevents the error but results in all values
                    %of theta being estimated too high
    
    if isnan(VAR_THETA) || isnan(MEAN_THETA) || isinf(abs(VAR_THETA)) || isinf(abs(MEAN_THETA))
       disp(['NaN or +/1 inf Theta:',' mean = ', num2str(MEAN_THETA) , ' VAR_THETA = ', num2str(VAR_THETA)])
       disp(['numeratorSum ',num2str(numeratorSum)])
       disp(['denominatorSum ',num2str(denominatorSum)])
       return %We don't update theta
    end

    if VAR_THETA == 0               
        if abs(MEAN_THETA) > 1
           counter1 = counter1 + 1;
           adjustedMean = 1*sign(MEAN_THETA);
           theta = adjustedMean;
           theta_g(1) = theta;
           theta_g(2) = theta;
           disp('THETA VAR = 0   AND  MAG > 1. Theta Set to +/- 1')
        else
           disp(['THETA VAR = 0   Theta fixed to ', num2str(MEAN_THETA)])
        end
    else
        if abs(MEAN_THETA) > 1 %Non-stationarity in this case, so we set the value to 1 or -1
           counter1 = counter1 + 1;
           adjustedMean = 1*sign(MEAN_THETA);
           theta = adjustedMean;
           theta_g(1) = theta; %place holders
           theta_g(2) = theta;
           disp('THETA MAG > 1. Theta Set to +/- 1')
        else
           %dist_for_theta = makedist('Normal',MEAN_THETA, VAR_THETA ); %tried april 15 to prevent "catastrophic rounding error"
           dist_for_theta = makedist('Normal',MEAN_THETA,sqrt(VAR_THETA)); %tried april 15 to prevent "catastrophic rounding error"
           truncatedNormal_theta = truncate(dist_for_theta,-1,1);
           newTheta = random(truncatedNormal_theta);
           theta = newTheta;
           theta_g(1) = theta;
           theta_g(2) = theta;
        end  
    end
end %if theta_two_groups == 1, else, end


%%
% else %Old code being used
%     %old code
%     for k = 1:(length(S)-1) %corrected code to include excluded points
% 
%         lower = S(k);    %%% Change 1
%         %lower = S(k) + 1;
%         upper = S(k+1) - 1; %We may need to remove the " - 1 "
%                             %We also may need to include the very last endpoint
%         CK = C(k);                                  %Change 2  switched from inside the loop                      
% 
% 
%         innerSum = Xdata(lower) - CK - errorAll(lower);
% 
%         lower = lower+1; %We shift up since we already calculated the very first term
%         if upper - lower > 0 %The algorithm only works for non-adjacent points      %Had to change to zero since we 
%             %CK = C(k);
%             %  %
% 
%             innerSum = innerSum + sum(    errorAll((lower-1):(upper-1))'.*(psi*Xdata((lower-1):(upper-1))-CK ) + Xdata(lower:upper) - CK - errorAll(lower:upper)' ) ; 
% 
%         end
% 
%         numeratorSum = numeratorSum + innerSum;
% 
%     end
% 
% 
% 
%     varTHETA = sig2error/error2Sum;
% 
%     muTHETA = numeratorSum/error2Sum;
% 
% 
%     %muTHETA = (numeratorSum/error2Sum)^(-1);
% 
%     if abs(muTHETA) <= 1
%         probDist = makedist('Normal',muTHETA,sqrt(varTHETA));
% 
%         truncatedNormal = truncate(probDist,-1,1);
% 
%         theta = random(truncatedNormal);
%     else
%         disp(['rep =', num2str(rep), 'mean out of bounds  ',num2str(muTHETA)]);
%         disp('mean set to be 1 or -1');
%         muTHETA = muTHETA/abs(muTHETA); 
% 
%         probDist = makedist('Normal',muTHETA,sqrt(varTHETA));
% 
%         truncatedNormal = truncate(probDist,-1,1);
% 
%         theta = random(truncatedNormal);
% 
%         %theta = theta*(0.001*(rand()-2) + 1);
%     end
% 
% 
%     if previewHistogram == 1
% 
%         thetaSample = random(truncatedNormal,10000,1);
%         histogram(thetaSample,100)
%     end
    
%end
