%Insertion and Deletion counts and proportions
global insertionCount
global deletionCount
close all
%Column 3 is accaptance versus deletions that occured at the point of
%interest

for i = 1:length(insertionCount)
    insertDenom = insertionCount(i,2);
    deleteDenom = deletionCount(i,1);

    if insertDenom > 0   
        insertionCount(i,3) = insertionCount(i,1)/insertDenom;
    else
        insertionCount(i,3) = 0;
    end
    
    if deleteDenom > 0
        deletionCount(i,3) = deletionCount(i,1)/deleteDenom;
    else
        deletionCount(i,3) = 0;
    end
end

tiledlayout(1,2)
nexttile
title("deletion proportions")
hold on
plot(deletionCount(:,3),'.')



nexttile
title("insertion proportions")
hold on
plot(insertionCount(:,3),'.')

