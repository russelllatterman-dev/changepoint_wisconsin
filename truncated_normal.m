pd = makedist('Normal',5,3)
t = truncate(pd,1,6)

x = linspace(1,6,1000);
figure
plot(x,pdf(pd,x))
hold on
plot(x,pdf(t,x),'LineStyle','--')
%legend('Normal','Truncated')
hold off


testData = randn(10000,1); %# test data
[counts,bins] = hist(testData); %# get counts and bin locations
barh(bins,counts) 

