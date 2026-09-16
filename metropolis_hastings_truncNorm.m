%Metropolis Hastings practice  -   Random-walk Metropolis
% Russell Latterman 2022
% programmed to match a lesson given online
% no code is provided for the online example
% Search "Metropolis-Hastings algorithm" by Jarad Niemi
% https://www.youtube.com/watch?v=VGRVRjr0vyw
% lecture by

% Want to sample from a distribution with density f(x)
% Were f(x) is not known, but can be evaluated up to a normalizing constant
% If we can get f(x) up to a normalizing constant

% Assume current value x(j)
% Let q(x|x(j)) be a proposal dist

% Sample x* from q(x|x(j) )

% Caluclate the acceptance probability

n = 10000;
Xvalues = zeros(1,n+1);%Allows us to do n iterations after setting initial value
                        %stores the value we have at every step
Xaccepted = zeros(1,n+1);%stores only the accepted values
numAccepted = 1; %counts how many values we have accepted
x_zero = 5; %Initial value

alphaVals = zeros(1,n+1); %list of acceptance probabilities for each step
%f_density = zeros(2,n+1);
%p(x(j),x_current) = min(1, f(x_current)/f(x(j))*q(x(j)|x_current)/q(x*|x_current)
meanEstimate = zeros(1,n+1);

Xvalues(1) = x_zero;
Xaccepted(1) = x_zero;

meanEstimate(1) = x_zero;

%Truncated normal parameters
mu = 5;
sig = 3;


for j=1:n
    
    xj = Xvalues(j); %The mean of our proposal distribution
    
    %Proposal density: Normal( xj , 1)
    % sample from the proposal density, whose mean is the current value
    x_star = normrnd(xj,1);%proposed value
                %q~N(mean=xj,variance=1) Sample from proposal density
    %Then calculate the acceptance probability
    %f(x_star)/f(xj) * q(xj|x_star)/q(x_star|xj)
    %In this example, q(xj|x_star)/q(x_star|xj) = 1 because q is normal
    %Suppose X is a truncated Normal(5,9)*I_{1 <= x <=6) rv
    % 
    
    Indicator_star = 0; %If a value is outside of the support [1,6], then
                        %f will be zero
    Indicator_j = 0;
    if x_star >= 1 && x_star <= 6 %is the proposed x_star in the support of f(x)?
        Indicator_star = 1; 
    end
    
    if xj >= 1 && xj <= 6  %is the current xj in the support of f(x)?
        Indicator_j = 1;
    end

    f_x_star = exp(-(x_star-mu)^2/(2*sig^2)) * Indicator_star; %f(x_start) is target density evaluted at the proposed value
    
    f_xj = exp(-(xj-mu)^2/(2*sig^2)) * Indicator_j; %f(xj) is target density evaluated at the current value
    
    % q_ratio = q(xj|x_star)/q(x_star|xj) We don't need these because they will be
    % equal, given that q is normal
   
    if f_xj > 0 % need our density to take on non-negative values. This should not happen unless an
                %initial value is chosen outside of the support, or if
                %something is programmed incorrectly.
        alpha = min(1,f_x_star/f_xj); % * q_ratio; %Prob of moving from current value xj to proposed value x_star
    else
        disp('out of bounds');
        break
    end
    %q_xj = 1;% q(x|xj) if q is symmetric then we don't need to use it to
    %q_x_star = 1;
    
    %p(x(j),x_current) = min(1, f((x star))/f(x(j))*q(x(j)|x_current)/q(x*|x_current)
    %f(x proposed)/f(most recently accepted value) 
    alphaVals(j)=alpha;
 
    if rand() < alpha 
        Xvalues(j+1) = x_star;
        %f_density(1,numAccepted+1) = x_star;
        %f_density(numAccepted+1) = f_x_star;
        numAccepted = numAccepted + 1;
        Xaccepted(numAccepted) = x_star;% x_star is now our most recently
            %accepted value
    else
        Xvalues(j+1) = xj; %xj is still our most recently accepted value
    end

    meanEstimate(j+1) = (meanEstimate(j)*j + Xvalues(j+1) )/(j+1);
end

estimate = mean(Xvalues);

Xaccepted = Xaccepted(1:numAccepted);

%Compare this to the actual mean of a truncated normal
mu = 5; sigma = 3; a = 1; b = 6;
alpha = (a - mu)/sigma;
beta = (b - mu)/sigma;
capPhi_alpha = cdf('Normal',alpha,0,1); %CDF of standard normal distirution
capPhi_beta = cdf('Normal',beta,0,1);
Z = capPhi_beta - capPhi_alpha;
phi_alpha = 1/sqrt(2*pi()) * exp(-1/2 * alpha^2);
phi_beta  = 1/sqrt(2*pi()) * exp(-1/2 * beta^2);
meanTruncatedNormal = mu + (phi_alpha-phi_beta)*sigma/Z;
close all

tiledlayout(2,2)
nexttile %%%%%%%%%%%%


plot(Xvalues,'color','blue','Linewidth',0.25)
yline(mean(Xvalues),'color','black','Linewidth',2)
yline(meanTruncatedNormal,'color','red','Linewidth',2)
title({'Trace Plot','Actual mean (red)','and approximate mean (black)'})
xlim([0,n])

nexttile%%%%%%%%%%%%
yRange = abs(mean(Xvalues)-meanTruncatedNormal);
center =(mean(Xvalues)+meanTruncatedNormal)/2;
lower = center - yRange;
upper = center + yRange;
plot(Xvalues,'color','blue','Linewidth',0.25)

ylim([lower,upper])
xlim([ceil(n*0.9),n])
yline(mean(Xvalues),'color','black','Linewidth',3)
yline(meanTruncatedNormal,'color','red','Linewidth',3)

%title(['Zoomed in:','True mean is ',num2str(meanTruncatedNormal),' Estimate is ',num2str(mean(Xvalues))])
lowerTitle =  ['True mean (red)  ',num2str(meanTruncatedNormal)];
lowerTitle2 = ['Estimate (black) ',num2str(mean(Xvalues))];
title({'Zoomed in',lowerTitle,lowerTitle2})

nexttile%%%%%%%%%%%%%%%%
bins = 5;
histogram(Xvalues,bins,'Normalization','probability')
%histogram(Xvalues,bins)%,'Normalization','probability')
pd = makedist('Normal',5,3)
t = truncate(pd,1,6)
axis = [1,6,0,0.5];
title({'Frequency Histogram','Dashed line illustrates actual pdf'});

x = linspace(1,6,1000);
hold on

plot(x,pdf(t,x),'LineStyle','--','color','red','Linewidth',3)


nexttile%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plot(meanEstimate,'Linewidth',0.5)
title({'Mean estimate series','Horizontal line indicates true mean'})
hold on
xlim([ceil(0.025*n),n])
yline(meanTruncatedNormal,'Linewidth',1)
