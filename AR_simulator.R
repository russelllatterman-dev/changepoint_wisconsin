install.packages("aTSA")
 library("aTSA")

## might want to install TSA before installing forecast
install.packages("TSA")
install.packages("tseries")
library("forecast")
setwd("/Users/russelljlatterman/Desktop/Dissertation/Bayesian Online ARMA using Gen Gibbs (GGS)")



casesPerWeek = read.delim("wi7day.txt")
cases = casesPerWeek[,1]
plot(cases)
N = length(cases)
arima(cases,c(1,0,0))

y = arima.sim(model = list(ar = 0.9918), n = 700)
par(new=TRUE)
plot(y)


endPoints = c(1,100,150,200,250,300,350,400,500,600,650,700)

left = 1;
right = 100;
cases2 = casesPerWeek[left:right,1]

plot(cases2)
N = length(cases2)
arima(cases2,c(1,0,0))

y = arima.sim(model = list(ar = 0.997), n = 700)+285
par(new=TRUE)
plot(y)


seriesCases2 = as.ts(cases2)  






