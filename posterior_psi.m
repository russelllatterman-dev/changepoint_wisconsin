
global errorAll
global psi_g
global psi
global psi_two_groups

global theta

global theta_two_groups
global thetaCurrent
global theta_g

%% Check on the " - 1 " possible issue
% check on whether we need to include the last endpoint
% maybe do a log sum to eliminate the error due to squaring terms?

tryCorrectedCode = 0;
previewHistogram = 0;
phiSum = 0;
thetaSum = 0;
thetaSum_rightSide = 0;


%%
%errorSum2 = sum(errorAll.^2); % <------- approximation
%PHI_1 = sig2error/errorSum2; % <------- approximation


% if  psi_two_groups == 0
%     if rep > 1
%         THETA_1_Previous = psi;    %Not sure if we are using this code
%     else
%         THETA_1_Previous = 0;
%     end
% 
%     PHI_denominator = 0;
%     PHI_denominator_inner_sum = 0;
% 
%     THETA_numerator_inner_sum = 0;
%     THETA_numerator = 0;
% 
%     for k = 1:(length(S)-1)
%         CK = C(k);      %If we are at a change point, this particular term won't add anything to the sum
%         lower = S(  k  ) + 1;   %1  2  3
%         upper = S(k + 1) - 1;   %   2 
% 
%         %if k == length(S)-1
%         %    upper = S(k + 1);
%         %end
% 
%         PHI_denominator_inner_sum = 0;
%         THETA_numerator_inner_sum = 0;
% 
%         if upper - lower >= 0
%             for t = lower:upper
%                 X_T = Xdata(t);
%                 X_T_minus_one = Xdata(t-1);
% 
%                 innerSumTerm = (X_T_minus_one - CK) * (X_T -CK - theta * errorAll(t-1) );
% 
%                 squaredSum_PHI   = (X_T_minus_one - CK)^2; %Original ARMA includes CK
% 
%                 PHI_denominator_inner_sum = PHI_denominator_inner_sum + squaredSum_PHI; 
% 
%                 THETA_numerator_inner_sum = THETA_numerator_inner_sum + innerSumTerm;
%                                                                      %    +   (X_T_minus_one - CK) * (X_T-CK-theta * errorAll(t-1) );
%             end
% 
%         end
% 
%         THETA_numerator = THETA_numerator + THETA_numerator_inner_sum;
% 
%         PHI_denominator = PHI_denominator + PHI_denominator_inner_sum;
%     end
% 
% 
%                              % Might need the very last term  
% 
%     % PHI_denominator = PHI_denominator  + (Xdata(T) - CK)^2; %Very last term
%     THETA_denominator = PHI_denominator; %The are the same
% 
%     PHI_1_psi = sig2error/PHI_denominator; %Variance
% 
%     THETA_1_psi = (THETA_numerator/THETA_denominator);
% 
%     % We have this set up just in case we have a mean with magnitude greater
%     % than 1 along with a variance that is too small
%          try
%             probDist_for_psi = makedist('Normal',THETA_1_psi,sqrt(PHI_1_psi));
%             truncatedNormal_psi = truncate(probDist_for_psi,-1,1);
%             psi = random(truncatedNormal_psi);
%             psi_g(1) = psi; %Just placeholders
%             psi_g(2) = psi;
% 
%             %psi = normrnd(THETA_1_psi,sqrt(PHI_1_psi));
%          catch
%             disp('WARNING: psi posterior dist defined on set of prob zero')
%             signTerm = THETA_1_psi/abs(THETA_1_psi);
%             if sqrt(PHI_1_psi) == 0
%                disp('WARNING: dist has zero variance')
%             end
%             %psi = THETA_1_psi/abs(THETA_1_psi) - rand()/100*signTerm ;
%             if THETA_1_psi > 1
%                THETA_1_psi = 1;
%             end
% 
%             if THETA_1_psi < -1
%                THETA_1_psi = -1;
%             end
% 
%             psi = THETA_1_psi;
%             psi_g(1) = psi; %Just placeholders
%             psi_g(2) = psi;
%             %psi_g(2) = psi;
%          end   
%          %Need to have code for different group PSI values
% 
%     if previewHistogram == 1
% 
%         psiSample = random(truncatedNormal_psi,10000,1);
%         histogram(psiSample,100)
%     end
% 
% 
%     %RETURN psi
% 
% 
% end %IF ps_two_groups == 0



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%psi_G = [psiEstimatesGroups(rep,1) , psiEstimatesGroups(rep,2)]; 
    %By defualt, we keep the original estimates for psi 1 and psi 2
    %Then if we happen to update them, we will do so, as follows

%%

%if psi_two_groups == 1  % <---- AR(1) two groups June 20th
    
    groupPSI_calc = [0,0]; %We use this to locally store estimates

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

    %numG1segs = abs(sum(Gm-2));     %Simple way to calculate group vals
    %numG2segs = abs(sum(Gm-1));

    % Case in which we are doing just AR(1) with constant means CK = 0 for all
    
    tryCorrectedCode = 0;
    previewHistogram = 0;
    
    %errorSum2 =  sum(errorAll.^2);     %  <-------  approximation
    %PHI_1     =  sig2error/errorSum2;  %  <-------  approximation
    
    numGroups = 1;
    if psi_two_groups == 1
        numGroups = 2;
    end

    for groupNumber = 1:numGroups %We will repeat the sampling process for each group
        if groupNumber == 1
            numGroupSegs = numG1segs;
        end
        if groupNumber == 2
           numGroupSegs = numG2segs;
        end 
        %****  
        %If we are only doing one psi param (numGroups == 1)
        %Then we don't need to calculate psi based on the segment group
        if numGroupSegs > 0 || numGroups == 1%We only do calculation
                
            if rep > 1
                THETA_1_Previous = psi; %not sure if we will use this code
            else
                THETA_1_Previous = 0;
            end
            
            PHI_denominator = 0;
            PHI_denominator_inner_sum = 0;
            
            THETA_numerator_inner_sum = 0;
            THETA_numerator = 0;
            THETA_denominator = 0;
            
            for k = 1:(length(S)-1)
                if Gm(k) == groupNumber || numGroups == 1
                    CK = C(k);      %If we are at a change point, this particular term won't add anything to the sum
                    gr = Gm(k);
                    
                    %CK = 0; % Assuming we are just dealing with a fixed mean of zero
                    lower = S(k)   + 1;   %1  2  3
                    upper = S(k+1) - 1;   %   2 
                    
                    PHI_denominator_inner_sum = 0;
                    THETA_numerator_inner_sum = 0;

                    %if k == length(S)-1  %At the very last step, we need
                    %to include the very last point in our list of values
                        sk_upper = S(k + 1);
                    %end

                    if  theta_two_groups == 1
                        thetaCurrent = theta_g(gr);
                    else
                        thetaCurrent = theta;
                    end

                    
                    if upper - lower >= 0
                    %if upper - lower >= 0 % If zero then we have adjacent change points, and so we do not update our parameter
                        for t = lower:upper
                            X_T = Xdata(t);
                            X_T_minus_one = Xdata(t-1);
         
                            innerSumTerm = (X_T_minus_one - CK) * (X_T - CK - thetaCurrent * errorAll(t-1) );
                            
                            %innerSumTerm = (X_T_minus_one - CK) * (X_T - CK - theta * errorAll(t-1) );
                                 % X_T_minus_one*X_T
                            squaredSum_PHI   = (X_T_minus_one - CK)^2; %Original ARMA includes CK
                
                            PHI_denominator_inner_sum = PHI_denominator_inner_sum + squaredSum_PHI;                                                                               
                            THETA_numerator_inner_sum = THETA_numerator_inner_sum + innerSumTerm;   
                        end

                    else
                        disp(  ['psiEst: Adjacent Chng Pts ','k= ',num2str(k), ' rep ',num2str(rep),  ' points: ', num2str(S(k)),',',num2str(S(k+1))] )
                    end
                    
                    THETA_numerator   = THETA_numerator + THETA_numerator_inner_sum;
                    PHI_denominator = PHI_denominator + PHI_denominator_inner_sum;
                end    % Segment if Group Gm(k) == groupNumber loop
            end % segment k loop
                % Might need the very last term
            

                %%%%%%% !!!!!!!!!! %%%%%%%% !!!!!!!!!   THIS DOESN'T SOLVE
                %%%%%%% ALL THE PROBLEMS


            if PHI_denominator == 0
                disp('In posterior_psi: PHI_denominator == 0 Variance for Psi estimate is sig2error/zero')
                disp(['  Mean for Psi estimate is', num2str(THETA_numerator), 'over zero'])
                VAR_PSI = 1;
                MEAN_PSI = 0;
                disp('   temporary fix is implemented here VAR_PSI = 1, MEAN_PSI = 0')
                disp('      this needs to be worked on')
                
            else
                if isnan(PHI_denominator)
                    disp('In posterior_psi: PHI_denominator = NaN which means variance is NaN sig2error/PHI_denominator')
                    disp(['  rep ',num2str(rep), ' k ',num2str(k)])
                    disp(['  Current seg mean CK = ', num2str(CK)])
                    disp(['  Current calculated error errorAll(t-1) = ', num2str(errorAll(t-1))] )

                else
                    THETA_denominator = PHI_denominator; %They are the same
                    % THETA_numerator = THETA_numerator + (Xdata(T-1) - CK)*(Xdata(T)-CK-theta*errorAll(T-1) ); 
                    PHI_1_psi   = sig2error/PHI_denominator;
                    THETA_1_psi = (THETA_numerator/THETA_denominator);
        
                    VAR_PSI = PHI_1_psi;
                    MEAN_PSI = THETA_1_psi;
                end
            end
            
            if VAR_PSI == 0
                if abs(MEAN_PSI) > 1
                   %counter1 = counter1 + 1;
                   adjustedMean = 1*sign(MEAN_PSI);
                   psi_g(groupNumber) = adjustedMean;
                   disp('*PSI VAR = 0   AND  PSI MAG > 1. PSI Set to +/- 1')
                else
                   disp(['*PSI VAR = 0   PSI fixed to ', num2str(MEAN_PSI)])
                end
            else %Variance calculation is non-zero
                if abs(MEAN_PSI) > 1 %Non-stationarity in this case, so we set the value to 1 or -1
                   %counter1 = counter1 + 1;
                   adjustedMean = 1*sign(MEAN_PSI);
                   psi_g(groupNumber) = adjustedMean;
                   disp('*PSI MAG > 1. PSI Set to +/- 1')
                else
                   %dist_for_theta = makedist('Normal',MEAN_PSI, VAR_PSI ); %tried april 15 to prevent "catastrophic rounding error"
                   dist_for_psi = makedist('Normal',MEAN_PSI,sqrt(VAR_PSI)); %tried april 15 to prevent "catastrophic rounding error"
                   truncatedNormal_psi = truncate(dist_for_psi,-1,1);
                   newPsi = random(truncatedNormal_psi);
                   psi_g(groupNumber) = newPsi;
                end  
            end
        end %Calculation loop if numGroups > 0

        if groupNumber == 1
            psi = psi_g(1);
            psi_g(2) = psi; %Placeholder until we do the calculation for the second group
            %If we only do one psi calculation, then psi_g(2) will just be
            %the same as psi_g(1)
        end
    end% Group loop
            
        
    %%
    % 
    % 
    %         if abs(THETA_1_psi) > 1
    %             disp('WARNING: dist psi mean magnitude is greater than 1 ')
    %         end
    %         % We have this set up just in case we have a mean with magnitude greater
    %         % than 1 along with a variance that is too small
    % 
    % 
    %          try
    %             probDist_for_psi = makedist('Normal',THETA_1_psi,sqrt(PHI_1_psi));
    %             truncatedNormal_psi = truncate(probDist_for_psi,-1,1);
    %             %psi = random(truncatedNormal_psi);
    %             psi_g(groupNumber) = random(truncatedNormal_psi);
    %          catch
    %             disp('WARNING: psi posterior dist defined on set of prob zero')
    %             if sqrt(PHI_1_psi) == 0
    %                 disp('WARNING: psi posterior dist defined on set of prob zero')
    %             end
    % 
    %             signTerm = THETA_1_psi/abs(THETA_1_psi);
    %             %psi = THETA_1_psi/abs(THETA_1_psi) - rand()/100*signTerm ;
    % 
    %             %psi_G(groupNumber) = THETA_1_psi/abs(THETA_1_psi) - rand()/100*signTerm ;
    %             %psi_g(groupNumber) = THETA_1_psi/abs(THETA_1_psi) - rand()/100*signTerm ;
    %             if THETA_1_psi > 1
    %                THETA_1_psi = 1;
    %             end
    % 
    %             if THETA_1_psi < -1
    %                THETA_1_psi = -1;
    %             end
    % 
    %             psi_g(groupNumber) = THETA_1_psi;
    %          end   
    %          %Need to have code for different group PSI values
    % 
    %      end   
    %         if previewHistogram == 1
    %             psiSample = random(truncatedNormal_psi,10000,1);
    %             histogram(psiSample,100)
    %         end
    % 
    % end %Calculations loop only done if we have non-zero number of groups
    % 
    %%
    %psi = psi_g(1); %Place-holder

 %end %if psitwogroups == 1

 
 


