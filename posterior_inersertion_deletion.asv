
%utilizes
%newInProb  from insertion_deletion_demo
%NewDelProb from insertion_deletion_demo
numInAttempts = zeros(length(Xdata),1);
postProbs = zeros(length(Xdata));

for i = 1:length(numInAttempts)
    numInAttempts(i) = sum(newInProb(:,i,2));
    if numInAttempts(i) > 0
        postProbs(i) = sum(newInProb(:,i,1))/numInAttempts(i);
    else
        postProbs(i) = 0;
    end

end

figure()
plot(numInAttempts,'.')

figure()
plot(postProbs,'.')


numDelAttempts = zeros(length(Xdata),1);
postDelProbs = zeros(length(Xdata));

for i = 1:length(numInAttempts)
    numDelAttempts(i) = sum(newDelProb(:,i,2));
    if numDelAttempts(i) > 0
        postDelProbs(i) = sum(newDelProb(:,i,1))/numDelAttempts(i);
    else
        postDelProbs(i) = 0;
    end

end

figure()
plot(numDelAttempts,'.')

figure()
plot(1-postDelProbs,'.')

figure()
plot(Sm,numDelAttempts(Sm),'.')
%xticks(Sm)

histogram(newDelProb(:,52,2))