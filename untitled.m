x = linspace(-ceil(max(Xvalues)),ceil(max(Xvalues)),1000);
y = normpdf(x,-2,var1) + normpdf(x,2,2*var2);
hold on
plot(x,y,'color','red','LineStyle','--','Linewidth',3)
