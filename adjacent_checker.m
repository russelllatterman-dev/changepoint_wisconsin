%checks for adjacent points
Sx = [1,2,3,4,7,9,14,15,18,20,25,40,41,42,50,55,60,61,62]

Sx = Sm;
Sn = 1:length(Sx)

diff = Sx(2:length(Sx)) - Sx(1:(length(Sx)-1));
diff = diff.^-1;
diff = [floor(diff),0]

diff2 = Sx(1:(length(Sx)-1)) - Sx(2:length(Sx)); 
diff2 = diff2.^-1;
diff2 = [0,floor(abs(diff2))]

diff3 = (diff+diff2);
diff4 = diff3+.01;



diff6 = zeros(length(Sx),1);
diff6(1,1) = 1;
diff6(1,2) = 1;
diff6(1,3) = 1;

for i = 2:length(Sx)
    if Sx(i)-Sx(i-1) == 1
        diff6(i,1) = 1
    end
end
diff6'

%./(diff+diff2)