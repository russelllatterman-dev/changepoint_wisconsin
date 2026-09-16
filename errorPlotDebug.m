%error_update
figure()
plot(errorAll,'Color','red','Linewidth',2)
hold on
for k = 1:(length(C))
    SK1 = S(k);
    SK2 = S(k+1);
    CK = C(k);
    plot([SK1,SK2-1],[CK,CK],"Color","black")
    
end

XatS     = zeros(1,length(S));
XatS_m_1 = zeros(1,length(S));
XatS_p_1 = zeros(1,length(S));

XatS(1) = Xdata(1);
XatS_m_1(1) = Xdata(1);
XatS_p_1(1) = Xdata(1)+1;

XatS(length(S)) = Xdata(T);
XatS_m_1(length(S)) = Xdata(T-1);
XatS_p_1(length(S)) = Xdata(T);

for k = 2:length(S)
    
    XatS(k) = Xdata(S(k));
    XatS_m_1(k) = Xdata(S(k)-1);
    
    if k < length(S)
        XatS_p_1(k) = Xdata(S(k)+1);
    else
        XatS_p_1(k) = Xdata(S(k));
    end
end

plot(Xdata,".")
hold on
plot(S,XatS,"*")

for k = 1:(length(C))
    SK1 = S(k);
    SK2 = S(k+1);
    CK = C(k);
    plot([SK1,SK2-1],[CK,CK],"Color","black")
    
end
plot([SK1,SK2],[CK,CK],"Color","black")%Very last point

%errorAt_S = XatS - [C,C(length(C))]


%errorAtChangePoints = S(1:(length(S)-1)) - C;