% We keep track of insertions and delations
% When an insertion is proposed, is it accepted?

% When a deletion is proposed, is it accepted?


if doInsertionStep == 1
    %rep
    %k
    if insertionTrue == 1
        insertionCount(z,1) = insertionCount(z,1) + 1; %Keeps track of how many times insertion occured at z
    else
        insertionCount(z,2) = insertionCount(z,1) + 1; %Keeps track of how many times insertion was rejected at z
    end

end

if doDeletionStep == 1
    %rep
    %k
    if deletionOccurs == 1
        deletionCount(ds2,1) = deletionCount(ds2,1) + 1;
        
    else
        deletionCount(ds2,2) = deletionCount(ds2,1) + 1;
    end
end
