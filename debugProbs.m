sample = 1;
k = 1;
Kcurrent = 3;
    dk = Dk(sample,k); 
            sk = Sk(sample,k); %right and left interval endpoints
            
%% Acceptance and Rejection Probabilities for insertion

     %% P1 Rejection probability (proportional to the following)
            %Calculate a list of errors
            
            err = zeros(dk-sk,1);
            ck = ck_segMeans(sample,k); 
            psi = psiAR(sample);
            theta = thetaMA(sample);
            
            err(1) = Xt(sk) - ck; %At the left endpoint
            %We only have one data point and the segment mean to deal with
            %kt = Kt(sk);
            i = 1;
            for t = (sk+1):dk %from the second point, onward
                i = i+1; %index for the set of error terms
                lambda_t = ck + psi*(Xt(t-1)-ck) +theta*err(i-1);
                        % = ck*(1-psi) +psi*(Xt(t-1)) +theta*err(t-1)
                err(i) = Xt(t) - lambda_t;
                
            end
            
            sig2 = sigmaSquared(sample);
            phi  = phiProbNewSeg(sample); %1-PHI is prob a 
                %changepoint occurs when randomly sampling original data
            %err = Xt(sk:dk) - mean(Xt(sk:dk));
            
            prob_rej = zeros(dk-sk,1);
            for t = 1:(dk-sk)
                prob_rej(t) = 1/sqrt(sig2)*exp(-1/(2*sig2)*(err(t)^2) );
            end
            product = prod(prob_rej);
            TofK = 4*(Kcurrent)-2*Ngroups+1+1+3;
            P1 = (1-phi)*product * 1/(dk-sk)*1/(TofK);
            
            
 %%           
            %P2 Acceptance Probability
            %Randomly chooses a left endpoint z from
            %[sk,sk+1, ... , dk - 1]
            %Then z+1 will be our new right endpoint if we accept the new
            %point (that is z+1 is a new change point)
            
            Ik = sk:dk; %Current interval time values
            segmentLength = length(Ik);
            zIndex = ceil(rand()*(segmentLength-1 ) ); %candidate left
            z = Ik(zIndex); %New left endpoint

            Ik1 = Ik(1:zIndex);
            Ik2 = Ik((zIndex+1):segmentLength);

            sk1 = sk;   dk1 = Ik(zIndex);
            sk2 = Ik(zIndex+1); dk2 = dk;
            
            %Randomly assign new groups
            %Randomly calculate new segment means for each
            %segment
            g1 = ceil(rand()*(Ngroups)); %New groups
            g2 = ceil(rand()*(Ngroups));
            
            tauSquared1 = tauSquared(sample,g1); %New group variances
            tauSquared2 = tauSquared(sample,g2);
            mu1 = mu_N(sample,g1); %New group means
            mu2 = mu_N(sample,g2);
            
            ck1 = normrnd(mu1,sqrt(tauSquared1));
            ck2 = normrnd(mu2,sqrt(tauSquared2));
           
            err1 = zeros(dk1-sk1,1);
            err2 = zeros(dk2-sk2,1);
            
            err1(1) = Xt(sk1) - ck1;
            err2(1) = Xt(sk2) - ck2;
            
            i = 1;
            for t = (sk1+1):dk1 %from the second point, onward
                i = i+1; %index for the set of error terms
                lambda_t = ck1 + psi*(Xt(t-1)-ck1) +theta*err1(i-1);
                        % = ck*(1-psi) +psi*(Xt(t-1)) +theta*err(t-1)
                err1(i) = Xt(t) - lambda_t;
                
            end
            
            i = 1;
            for t = (sk2+1):dk2 %from the second point, onward
                i = i+1; %index for the set of error terms
                lambda_t = ck2 + psi*(Xt(t-1)-ck2) +theta*err2(i-1);
                        % = ck*(1-psi) +psi*(Xt(t-1)) +theta*err(t-1)
                err2(i) = Xt(t) - lambda_t;
            end
            
            prob_rej1 = zeros(dk1-sk1,1);
            for t = 1:(dk1-sk1)
                prob_rej1(t) = 1/sqrt(sig2)*exp(-1/(2*sig2)*(err1(t)^2) );
            end
            
            prob_rej2 = zeros(dk2-sk2,1);
            for t = 1:(dk2-sk2)
                prob_rej2(t) = 1/sqrt(sig2)*exp(-1/(2*sig2)*(err2(t)^2) );
            end
            product1 = prod(prob_rej1);
            product2 = prod(prob_rej2);
            
            TofKplus1 = 4*(Kcurrent+1)-2*Ngroups+1+1+3;
            
            P0 = phi*product1*product2*1/(TofKplus1);
 %%           
             %In the future, this 
            
            acceptanceProb = P0/(P0+P1)
            

