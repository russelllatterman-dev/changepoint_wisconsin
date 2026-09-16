% Metropolis Hastings practice - Random-walk Metropolis
% Russell Latterman 2022
% We will attempt to estimate the mean of a chi-squared distribution
% We are using an exponential distribution (non-symmetric) proposal density

% Look for "burnInPoint" this is where changes have been made

%%
n = 100000;
burnInPoint = 30000;
Xvalues = zeros(1,n+1);  %Allows us to do n iterations after setting initial value
                         %stores the value we have at every step
Xaccepted = zeros(1,n+1); %a list of the accepted values
numAccepted = 1;  %counts how many values we have accepted
x_zero = 0;  %Initial value

alphaVals   = zeros(1,n+1); %list of acceptance probabilities for each step
meanEstimate = zeros(1,n+1);

Xvalues(1) = x_zero;
Xaccepted(1) = x_zero;

meanEstimate(1) = x_zero;

mu1 = -2; mu2 = 2; stDev1 = 1; stDev2 = 2;
 
stDev0 = 4;
meanTrueDist  = mu1 + mu2;

%%
for j=1:n
    
    xj = Xvalues(j); %The mean of our proposal distribution
    
    %x_star = lambda*exp(-lambda*xj);
    %Proposal Densities
    %1 Normal Dist
    %2 Uniform Dist
    
    %1 Normal centered at xj
    %x_star = normrnd(xj,1);%proposed value
    %2 Uniform Centered at xj
    %x_star = 5*(rand()-0.5)+xj;
    
    x_star = normrnd(xj,stDev0);
    %x_star = lambda * exp(1)^(-lambda*xj);
   
    %q~N(mean=xj,variance=1) Sample from proposal density
    %Then calculate the acceptance probability
    %f(x_star)/f(xj) * q(xj|x_star)/q(x_star|xj)
    %In this example, q(xj|x_star)/q(x_star|xj) = 1 because q is normal
    %Suppose X is a truncated Normal(5,9)*I_{1 <= x <=6) rv
    
    %Indicator_star = 0; %If a value is outside of the support 
                         %The indicator is set to zero.
    %Indicator_j = 0;
%%  Indicators
Indicator_star = 1;
Indicator_j = 1;

%     if x_star > 0
%         Indicator_star = 1;
%     else
%         Indicator_star = 0;
%     end
%     
%     if xj > 0
%         Indicator_j = 1;
%     else
%         Indicator_j = 0;
%     end
%%  
    
    %f_x_star   = exp(-(x_star-mu)^2/(2*sig^2)) * Indicator_star; %f(x_start) is target density evaluted at the proposed value
    %1/(2^(k/2) * gammaFunction(k/2)) * x_star^(k/2-1)*exp(-x_star/2)
    %f_x_star   = 1/(2^(k/2))*1/factorial(k-1)*x_star^(k/2-1)*exp(-x_star/2)* Indicator_star;
    %f_xj       = 1/(2^(k/2))*1/factorial(k-1)*xj^(k/2-1)*exp(-xj/2)* Indicator_j;
    
   
    f_x_star = normpdf(x_star,mu1,stDev1) + normpdf(x_star,mu2,stDev2);
    f_xj     = normpdf(xj,mu1,stDev1) + normpdf(xj,mu2,stDev2);
               
    q_x_star = normpdf(x_star,xj,stDev0);
    q_xj     = normpdf(xj,x_star,stDev0);
               
    % f_xj = exp(-(xj-mu)^2/(2*sig^2)) * Indicator_j; %f(xj) is target density evaluated at the current value
    % q_ratio = q(xj|x_star)/q(x_star|xj) We don't need these because they will be
    % equal, given that q is normal
   
    
%%%%%%%%%%% !!!!!!!!!!!!!!!!!
%%%%%%%%%%% !!!!!!!!!!!!!!!!!
%%%%%%%%%%% !!!!!!!!!!!!!!!!!
%%%%%%%%%%% !!!!!!!!!!!!!!!!!
%%%%%%%%%%% !!!!!!!!!!!!!!!!!
%%%%%%%%%%% !!!!!!!!!!!!!!!!!

    if f_xj > 0 %need our density to take on non-negative values. This should not happen unless an
                %initial value is chosen outside of the support, or if
                %something is programmed incorrectly.
        alpha = min(1,f_x_star/f_xj * q_xj/q_x_star ); 
        % * q_ratio; %Prob of moving from current value xj
        % to proposed value x_star
    else
        disp('out of bounds');
        break
    end
    
    alphaVals(j)=alpha;
 
    if rand() < alpha 
        Xvalues(j+1) = x_star;
        numAccepted = numAccepted + 1;
        Xaccepted(numAccepted) = x_star;% x_star is now our most recently
            % accepted value
    else
        Xvalues(j+1) = xj; % xj is still our most recently accepted value
    end

    if j == 20000
        meanEstimate(j) = xj;
    end
    if j > burnInPoint
        meanEstimate(j+1) = (meanEstimate(j)*j + Xvalues(j+1) )/(j+1);
    
    end
end
Xaccepted = Xaccepted(1:numAccepted);

estimate = mean(Xvalues(burnInPoint:n));

acceptanceRate = numAccepted/n;

%% Plots

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
tiledlayout(2,2)
%%%%%%%%%%%%%   Trace Plot with approximate and true means
nexttile
plot(Xvalues,'color','blue','Linewidth',0.25)

yline(mean(Xvalues),'color','black','Linewidth',2)
yline(meanTrueDist,'color','red','Linewidth',2)
xlim([0,n])

title({'Trace Plot','Actual mean (red)','and approximate mean (black)'})



%%%%%%%%%%%%%%%%%   Zoomed in on approximate mean and true mean
nexttile
plot(Xvalues,'color','blue','Linewidth',0.25)

lowerTitle =  ['True mean (red)  ',num2str(meanTrueDist)];
lowerTitle2 = ['Estimate (black) ',num2str(mean(Xvalues))];
yRange = max(abs(0.02*meanTrueDist),1.1*abs(mean(Xvalues)-meanTrueDist));
center = meanTrueDist;
lower = center - yRange;
upper = center + yRange;
ylim([lower,upper]);    xlim([ceil(n*.9),n])
yline(mean(Xvalues),'color','black','Linewidth',3)
yline(meanTrueDist,'color','red','Linewidth',3)

title({'Zoomed in',lowerTitle,lowerTitle2})


%%%%%%%%%%%%%%%%%%%%    Histogram with Distribution overlap
nexttile
bins = 50;
histogram(Xvalues,bins,'Normalization','probability')
x = linspace(-ceil(max(Xvalues)),ceil(max(Xvalues)),1000);
y = (normpdf(x,mu1,stDev1) + normpdf(x,mu2,stDev2))/8;
hold on
plot(x,y,'color','red','LineStyle','--','Linewidth',3)
title({'Frequency Histogram','Dashed line illustrates actual pdf'});


%%%%%%%%%%%%%%%%%%%%%%%%    Mean Estimate and true mean horizontal line
nexttile
plot(meanEstimate,'Linewidth',0.5)
hold on
yline(meanTrueDist,'Linewidth',1)
xlim([100,n])
title({'Mean estimate series','Horizontal line indicates true mean'})


meanEstimate = mean(Xvalues(50000:n))


