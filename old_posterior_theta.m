
%%% Previous posterior theta

%Posterior distribution for theta  ARMA(1,1) with parameters psi and theta

%1 Try this with all error terms. This might make the mean of the truncated
%normal appropriately smaller

%2 Might need to do something so that we can get a legit update when we
%have adjacent change points (but we probably don't need to do this)

%Modify so that we include the very last value in the list
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

useNewCode = 1;

doRandomScatter = 0;

if useNewCode == 1
    
    if doRandomScatter == 1 %Just does a scatter of data around the actual value of theta
            %This allows us to determine whether the posterior for psi is
            %working when theta is flucutating. This is kind of like the
            %most ideal case we can get, asside from holding theta fixed at
            %the true value    
        theta = thetaMA_0 + normrnd(0,.0125);
        
    else %We are doing the actual calculations based on the derivated posterior distribution for theta
        
        for k = 1:(length(S)-1) 

            innerErrorSum = 0;
            innerNumeratorSum = 0;

            sk_upper = S(k+1) - 1; 
            sk_lower = S(k) + 1;
            
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
            
            if sk_upper - sk_lower > 0
               for t = sk_lower:sk_upper
                    et_m1 = errorAll(t-1);
                    et = errorAll(t);
                    innerErrorSum     = innerErrorSum + et_m1^2;
                    %innerErrorSum     = innerErrorSum + 1/et_m1^2;
                    %%April 6th 2:22 did not seem to work 
                    %innerNumeratorSum = innerNumeratorSum + et_m1*et; 
                    %Converges to something much lower than it should. Also results in psi converging
                    
                    %innerNumeratorSum = innerNumeratorSum + et_m1*( et - (psiCurrent*(Xdata(t-1)-CK)  +   Xdata(t) - CK) );
                    %innerNumeratorSum = innerNumeratorSum + et_m1*( psiCurrent*(Xdata(t-1)-CK)  +   Xdata(t) - CK - et );
                                                                                    
                    innerNumeratorSum = innerNumeratorSum + et_m1*( Xdata(t) - CK - psiCurrent*(Xdata(t-1)-CK));

                    
                    %innerNumeratorSum = innerNumeratorSum + et_m1*( psiCurrent*(Xdata(t-1)-CK)   - ( Xdata(t) - CK - et) ); %tried on April 15
               end

            end

            denominatorSum = denominatorSum + innerErrorSum;
            numeratorSum   = numeratorSum   + innerNumeratorSum;
        end

           VAR_THETA = (sig2error/denominatorSum);
           %VAR_THETA = (sig2error*denominatorSum);                                      %April 6th 2:22
                                %Might need the very last term
           thetaVariances(rep) = VAR_THETA;   %%%%%% Keeps track of variances
                                
        if VAR_THETA > 0 

            %MEAN_THETA = (numeratorSum/denominatorSum)^(-1); %This was
            %giving somewhat consistent convergence to about 0.9
            %when actual theta is 0.6 and psi is .22
            
            MEAN_THETA = (numeratorSum/denominatorSum);  %This was the
            %original formula from the handwritten sheet
            
            %MEAN_THETA = 0.6;
               
            %MEAN_THETA = (numeratorSum*denominatorSum); %The original corrected formula
                                                            %tried with the
                                                            %April 6th
                                                            %mods;
            
            thetaMeans(rep) = MEAN_THETA;  %%%%%% Keeps trakc of means
            
            if MEAN_THETA > 1
                %disp('mean estimate greanter than 1')
                counter1 = counter1 + 1;
            end

            %ORIGINAL DERIVED
            
            %dist_for_theta =
            %makedist('Normal',MEAN_THETA,max(sqrt(VAR_THETA),2*MEAN_THETA/12));
            
            
            %adjustedMean = min(abs(MEAN_THETA), .99); %The idea is that maybe we need to shift our estimate by 1/2, in general
            adjustedMean = MEAN_THETA; %The idea is that maybe we need to shift our estimate by 1/2, in general
            
            
            %adjustedVStandardDev = max(sqrt(VAR_THETA),2*abs(adjustedMean)/12); %tried april 15 to prevent "catastrophic rounding error"
            adjustedVStandardDev = VAR_THETA;
            
            adjustedThetaMeans(rep) = adjustedMean ;
            
            dist_for_theta = makedist('Normal',adjustedMean,adjustedVStandardDev); %tried april 15 to prevent "catastrophic rounding error"
                            %Prevents the error but results in all values
                            %of theta being estimated too high
                            
            try
                truncatedNormal_theta = truncate(dist_for_theta,-1,1);
                newTheta = random(truncatedNormal_theta);
                theta = newTheta;
            catch
                
               % disp('We might have defined this on a set of prob zero');
               % disp('The could be due to variance being too low');
                
                if abs(MEAN_THETA) >=1
                    disp('theta is set to + or -1 if abs(theta) >= 1')
                    dist_for_theta = makedist('Normal',MEAN_THETA/abs(MEAN_THETA),sqrt(VAR_THETA));
                    truncatedNormal_theta = truncate(dist_for_theta,-1,1);
                    newTheta = random(truncatedNormal_theta);
                    theta = newTheta;
                    %theta = MEAN_THETA/abs(MEAN_THETA);
                else
               %     disp('variance too small, theta set to fixed value')
                    theta = MEAN_THETA;
                end
                  
                 
               % disp(['rep ',num2str(rep)])
               % disp(['variance ', num2str(VAR_THETA)])
                
            end

            if previewHistogram == 1
                thetaSample = random(truncatedNormal_theta,10000,1);
                histogram(thetaSample,100)
            end

        else
            disp('Calculated variance for theta too samll, theta not updated')
        end
    
    end
    
else %Old code being used
    

    %old code
    for k = 1:(length(S)-1) %corrected code to include excluded points

        lower = S(k);    %%% Change 1
        %lower = S(k) + 1;
        upper = S(k+1) - 1; %We may need to remove the " - 1 "
                            %We also may need to include the very last endpoint
        CK = C(k);                                  %Change 2  switched from inside the loop                      


        innerSum = Xdata(lower) - CK - errorAll(lower);

        lower = lower+1; %We shift up since we already calculated the very first term
        if upper - lower > 0 %The algorithm only works for non-adjacent points      %Had to change to zero since we 
            %CK = C(k);
            %  %

            innerSum = innerSum + sum(    errorAll((lower-1):(upper-1))'.*(psi*Xdata((lower-1):(upper-1))-CK ) + Xdata(lower:upper) - CK - errorAll(lower:upper)' ) ; 

        end

        numeratorSum = numeratorSum + innerSum;

    end



    varTHETA = sig2error/error2Sum;

    muTHETA = numeratorSum/error2Sum;


    %muTHETA = (numeratorSum/error2Sum)^(-1);

    if abs(muTHETA) <= 1
        probDist = makedist('Normal',muTHETA,sqrt(varTHETA));

        truncatedNormal = truncate(probDist,-1,1);

        theta = random(truncatedNormal);
    else
        disp(['rep =', num2str(rep), 'mean out of bounds  ',num2str(muTHETA)]);
        disp('mean set to be 1 or -1');
        muTHETA = muTHETA/abs(muTHETA); 

        probDist = makedist('Normal',muTHETA,sqrt(varTHETA));

        truncatedNormal = truncate(probDist,-1,1);

        theta = random(truncatedNormal);

        %theta = theta*(0.001*(rand()-2) + 1);
    end


    if previewHistogram == 1

        thetaSample = random(truncatedNormal,10000,1);
        histogram(thetaSample,100)
    end
    
end
