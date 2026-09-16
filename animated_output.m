mean_t = zeros(1,n);
yLow = 6;
yHigh = 8;
close all
anim = 1;

for t = 1:n
    mean_t(t) = mean(Xvalues(1:t));
end

if anim == 1
    for t = (50*(1:(n/50)))
      figure(1)
      tiledlayout(2,1)
      nexttile
      plot(1:t,mean_t(1:t))
      yline(mean(Xvalues));
      xlim([0,n]); ylim([5,8]);
      nexttile
      plot(1:t,mean_t(1:t))
      yline(mean(Xvalues));
      xlim([0,n]); ylim([5,8]);
      drawnow
    end
end

if anim == 2    
    for t = 9000:10000 %(10*(1:(n/10)))   
      plot(t,mean_t(t))
      xlim([9000,10000]); ylim([5,8]);
      hold on
    end
end

if anim == 3
    
    meant2 = mean_t;
    for i = 1:100000
         meant2 = meant2 + ((rand(1,n)-0.5)/100);
         plot(meant2)
         xlim([0,n]); ylim([5,8]);
         drawnow
    end
    
end

if anim == 4
    randWalk = zeros(1,n);
    randWalk2 = zeros(1,n);

    randMiddle = zeros(1,n);
    for k=1:1000
        
        for i = 2:n
            randWalk(i)  = randWalk(i-1)+(rand()-0.5)/5;
            if i<n
                randWalk2(n-i) = randWalk2(n-i+1)+(rand()-0.5)/5;
            end
        end
        
        randMiddle(1:(n/2)) = randWalk(1:(n/2));
        randMiddle((n/2+1):n) = randWalk2((n/2+1):n);
        
        plot((randWalk+randWalk2)/2); 
        xlim([0,n]); ylim([-10,10]);
        drawnow
        pause(0.05)
        
    end
end

if anim == 5
    w  = 1;
    x0 = 1;
    y0 = 8;
    max_x = 10;
    max_y = 10;
    figure()
    %line([x0-w,x0+2*w],[y0+2*w,y0+2*w])
    xlim([0,windowSize]); ylim([0,windowSize]);
    line([x0,x0+w],[y0,y0],'LineWidth',4) %bottom left
    line([x0+w,x0+w],[y0,y0+w],'LineWidth',4)
    line([x0,x0],[y0,y0+w],'LineWidth',4)
    line([x0,x0+w],[y0+w,y0+w],'LineWidth',4)
    
    nMoves = 10000;
    dX = 0.8;
    dY = 0.5;
    for i=1:nMoves
        
%         xlim([0,windowSize]); ylim([0,windowSize]);
%         line([x0,x0+w],[y0,y0],'LineWidth',4,'color','white') %bottom left
%         line([x0+w,x0+w],[y0,y0+w],'LineWidth',4,'color','white')
%         line([x0,x0],[y0,y0+w],'LineWidth',4,'color','white')
%         line([x0,x0+w],[y0+w,y0+w],'LineWidth',4,'color','white')
        
        x0 = x0+dX;
        y0 = y0+dY;
        
        if x0 < 0 || (x0+w) > max_x
            dX = -dX;
            x0 = x0+2*dX;
        end
        
        if y0 < 0 || (y0+w) > max_y
            dY = -dY;
            y0 = y0 + 2*dY;
        end
        
       
        clf
        
        xlim([0,windowSize]); ylim([0,windowSize]);
        line([x0,x0+w],[y0,y0],'LineWidth',4) %bottom left
        line([x0+w,x0+w],[y0,y0+w],'LineWidth',4)
        line([x0,x0],[y0,y0+w],'LineWidth',4)
        line([x0,x0+w],[y0+w,y0+w],'LineWidth',4)
        drawnow
        
        %pause(0.01)
        
    end
    
    
    %hold on
    %line([x0-w,x0+2*w],[y0-2*w,y0-2*w])
end

% plot(mean_t)
% hold on
% 
% 
% close all
% 
% g=sin([1:0.1:10*pi]);
% for i = 1:length(g)
%   figure(1)    
%     if i ~=length(g)        
%         plot(1:i,g(1,1:i),'-b');      
%     else
%         plot(1:i,g(1,1:i),'-b*')
%     end
%     if i>=50
%         axis([i-50 i+50 min(g(1,:)) max(g(1,:))])
%     else
%         axis([0 i+50 min(g(1,:)) max(g(1,:))])
%     end
%  %pause(0.1)
%     drawnow
% end