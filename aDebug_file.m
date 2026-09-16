

smallExtra  = 0
smallExtra2 = 0
probStorage_time = smallExtra - smallExtra2

chosenPoints = zeros(1,10000);
for m = 1:10000
    chosenPoints(m) = ileft + ceil(rand()*((S(k+1)-ileft)-1))-1;
end

%0.03 to 0.06 

% In insertion_deletion_demo

%probInsertion(rep,k) = acceptanceProb;
%pIn(rep,k) = acceptanceProb;

% 0.007 compared to 14 sec