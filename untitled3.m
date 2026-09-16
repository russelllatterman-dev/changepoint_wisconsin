%Group posterior distribution
% Group assignments

%p_1(ck) ~ N(tau2_1, mu_1)*PI_1
%p_2(ck) ~ N(tau2_2, mu_2)*PI_2


%log_p1 = -1/(2*t1^2)*(ck - m1)^2-log(pi1);

%log_p2 = -1/(2*t1^2)*(ck - m1)^2-log(pi2);


%% Update group variances

%% Update group means

%% Update group probabilities

%% Update groups

for i = 1:length(Cm)
    gr = group(i);
    p1 = exp(-1/(2*t1^2)*(ck - m1)^2)*log(pi_1);
    p2 = exp(-1/(2*t2^2)*(ck - m2)^2)*log(pi_2);
end

close all
figure()
hold on

nList = length(psiEstimatesGroups(:,1));

burnIn = length(psiEstimatesGroups)/1.5;

mean1 = mean(psiEstimatesGroups(burnIn:nList,1) )
mean2 = mean(psiEstimatesGroups(burnIn:nList,2) )


x = [0,nList]

y1 = [mean1,mean1]
y2 = [mean2,mean2]

plot(psiEstimatesGroups(:,1),'Color','black')
plot(x,y1,'Color','black','LineWidth',2)

plot(psiEstimatesGroups(:,2),'Color','blue')
plot(x,y2,'color','blue','LineWidth',2)


