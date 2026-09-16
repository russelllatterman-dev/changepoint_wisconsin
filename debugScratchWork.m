
howManyTimes = zeros(length(insertionCount),1);
for i = 1:length(insertionCount)
    insertionCount(i,3) = insertionCount(i,1)./(insertionCount(i,1)+insertionCount(i,2));
    howManyTimes(i) = sum(insertionCount(i,1:2));
end
figure()
plot(insertionCount(:,3))
figure()
plot(howManyTimes,'.')
hold on
for i=2:(Kcurrent+1)
    xline(Sk(currentSample-1,i),'blue','LineWidth',2.3)
end



ck_segMeans(1:50,1:10)