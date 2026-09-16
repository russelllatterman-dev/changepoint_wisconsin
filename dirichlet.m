
%Dirichlet script
close all
nG1 = 0;
nG2 = 0;
for i = 1:length(Gm)
    if Gm(i) == 1

        nG1 = nG1 + 1;
    else
        nG2 = nG2 + 1;
    end

end

a = [nG1,nG2];
n = 1000;%

p = length(a);
r = gamrnd(repmat(a,n,1),1,n,p);
r = r ./ repmat(sum(r,2),1,p);

figure()
histogram(r(:,1))
figure()
histogram(r(:,2))

mean(r)



