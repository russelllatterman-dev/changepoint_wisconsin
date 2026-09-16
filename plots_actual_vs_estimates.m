%% Plots of data, true changepoint locations, and group means
close all

f = figure('visible','off','Color','white');
f.Position = [0 0 500 900];
%movegui(f,'northwest')
shg

if test_exact_paper == 1
    tiledlayout(1,1)
    nexttile
    hold on

    % figure legend and title

    grid on
    title(['True number of Segments : K= ', num2str(Ktrue),'~~~',...
        '    Obs Per Segment: ', num2str(obs_per_seg)],...
        'FontSize',14,...
        'Interpreter','latex')

    %%%%%%  Data scatter plot
    data_plot = plot(Xt,'black','LineWidth',1);
    ylow = -7.5;   yhigh = 10;
    xlim = [-obs_per_seg/5, T+obs_per_seg/5]; ylim = [ylow, yhigh];
    %axis([-obs_per_seg/5, T+obs_per_seg/5, ylow, yhigh])
    % yticks(( (-ceil(min(Xt)):(ceill(max(Xt)) );
    yticks((-15:20)/2);
    cl = .9;  set(gca,'Color',[cl cl cl]); %Gives us a grey plot background

    %%%%%% Red line segments for true segment means
    %means_plot = plot(actualMeans,'red','LineWidth',2);

    %ylabel('Simulated Data Series $X_{t}$','FontSize',14,'Interpreter','latex')
    %xlabel('Sample t','FontSize',14,'Interpreter','latex')

    % Line segments represent segment means
    for i = 1:(Ktrue)
       groupColor = ["red","magenta"];
       if gk_segGroups_0(i) == 1
           gColor = groupColor(1);  %Color indicator for group 1
       else
           gColor = groupColor(2);  %Color indicator for group 2
       end

       Spoints = [Strue,T];
       gPlot = plot([Spoints(i),(Spoints(i+1))],[ck_segMeans_0(i),ck_segMeans_0(i)],gColor,'LineWidth',2);

       %plot([Strue(i),Strue(i+1)],[Ctrue(i),Ctrue(i)])
       hold on
    end
    %%%%%  Vertical blue lines indicate start of new segment (changepoint)
    %%%%%  These are s2 through s_(K-1) where K is the number of segments
    for i=1:(Ktrue)
        xline(obs_per_seg*i,'--b','LineWidth',2.3)
    end
    location_plot = xline(obs_per_seg*i,'--b','LineWidth',2.3);

    legend( [location_plot, gPlot],...
            {'True Change-Point Location $s_{k}$','True Segment Mean $C_{k}$'},...
            'location','northoutside',...
            'FontSize',12,...
            'Interpreter','latex')
    hold off
    % Plots for estimated locations

    
else
    tiledlayout(3,1)
    

nexttile
hold on

% figure legend and title

grid on
title(['True number of Segments : K= ', num2str(Ktrue),'~~~',...
    '    Obs Per Segment: ', num2str(obs_per_seg)],...
    'FontSize',14,...
    'Interpreter','latex')

%%%%%%  Data scatter plot
data_plot = plot(Xt,'black','LineWidth',1);
ylow = min(min(Xt),6)+0.5;   yhigh = min(max(Xt),6)-0.5;
xlim = [-obs_per_seg/5, T+obs_per_seg/5]; ylim = [ylow, yhigh];
%axis([-obs_per_seg/5, T+obs_per_seg/5, ylow, yhigh])
% yticks(( (-ceil(min(Xt)):(ceill(max(Xt)) );
yticks((-5:5)*3);
cl = .9;  set(gca,'Color',[cl cl cl]); %Gives us a grey plot background

%%%%%% Red line segments for true segment means
%means_plot = plot(actualMeans,'red','LineWidth',2);

%ylabel('Simulated Data Series $X_{t}$','FontSize',14,'Interpreter','latex')
%xlabel('Sample t','FontSize',14,'Interpreter','latex')

% Line segments represent segment means
for i = 1:(Ktrue)
   groupColor = ["red","magenta"];
   if gk_segGroups_0(i) == 1
       gColor = groupColor(1);  %Color indicator for group 1
   else
       gColor = groupColor(2);  %Color indicator for group 2
   end
   
   Spoints = [Strue,T];
   gPlot = plot([Spoints(i),(Spoints(i+1))],[ck_segMeans_0(i),ck_segMeans_0(i)],gColor,'LineWidth',2);
   
   %plot([Strue(i),Strue(i+1)],[Ctrue(i),Ctrue(i)])
   hold on
end
%%%%%  Vertical blue lines indicate start of new segment (changepoint)
%%%%%  These are s2 through s_(K-1) where K is the number of segments
for i=1:(Ktrue)
    xline(obs_per_seg*i,'--b','LineWidth',2.3)
end
location_plot = xline(obs_per_seg*i,'--b','LineWidth',2.3);

legend( [location_plot, gPlot],...
        {'True Change-Point Location $s_{k}$','True Segment Mean $C_{k}$'},...
        'location','northoutside',...
        'FontSize',12,...
        'Interpreter','latex')
hold off
% Plots for estimated locations




nexttile
%%%%%%  Data scatter plot
data_plot2 = plot(Xt,'black','LineWidth',1);
ylow = min(min(Xt),6)+0.5;   yhigh = min(max(Xt),6)-0.5;
xlim = [-obs_per_seg/5, T+obs_per_seg/5]; ylim = [ylow, yhigh];
%axis([-obs_per_seg/5, T+obs_per_seg/5, ylow, yhigh])
% yticks(( (-ceil(min(Xt)):(ceill(max(Xt)) );
yticks((-5:5)*2);
cl = .9;  set(gca,'Color',[cl cl cl]); %Gives us a grey plot background

%%%%%% Red line segments for true segment means
% means_plot = plot(actualMeans,'red','LineWidth',2);
ylabel('Simulated Data Series $X_{t}$','FontSize',14,'Interpreter','latex')
xlabel('Sample t','FontSize',14,'Interpreter','latex')







%% Second plot with change point estimates
grid on

% title('Change Point Estimates, depicted with vertical lines.',...
%   'FontSize',14,'Interpreter','latex')
% title('Change Point Estimated Locations, depicted with vertical lines')%...
    %'FontSize',14,'Interpreter','latex')]

title({'Data viewed without knowing changepoints','(may not display all points)'},...
 'FontSize',14,'Interpreter','latex');

hold on


% % xline(Snew(2),'green','LineWidth',2.3)
% for i=2:(Kcurrent+1)
%     xline(Sk(currentSample-1,i),'blue','LineWidth',2.3)
% end
% 
% % line([0,ck1],[20,ck1])
% plot([1,zIndex],[ck1,ck1],'color','blue','linewidth',2)
% plot([zIndex+1,ceil(T/2)],[ck2,ck2],'color','blue','linewidth',2)
% % location_plot = xline(obs_per_seg*i,'blue','LineWidth',2.3);
% xline(zIndex+1,'color','blue','linewidth',2)
%     
% 
% 
% 
% %% Second plot with change point estimates
% grid on
% 
% % title('Change Point Estimates, depicted with vertical lines.',...
% %   'FontSize',14,'Interpreter','latex')
% % title('Change Point Estimated Locations, depicted with vertical lines')%...
%     %'FontSize',14,'Interpreter','latex')]
% 
% title({'Data viewed without knowing changepoints','(may not display all points)'},...
%  'FontSize',14,'Interpreter','latex');
% hold on
% 
% 
% % xline(Snew(2),'green','LineWidth',2.3)
% for i=2:(Kcurrent+1)
%     xline(Sk(currentSample-1,i),'blue','LineWidth',2.3)
% end
% 
% % line([0,ck1],[20,ck1])
% plot([1,zIndex],[ck1,ck1],'color','blue','linewidth',2)
% plot([zIndex+1,ceil(T/2)],[ck2,ck2],'color','blue','linewidth',2)
% % location_plot = xline(obs_per_seg*i,'blue','LineWidth',2.3);
% xline(zIndex+1,'color','blue','linewidth',2)
%     




%% Third plot
% 
nexttile
%%%%%%  Data scatter plot
data_plot2 = plot(Xt,'black','LineWidth',1);
ylow = min(min(Xt),6)+0.5;   yhigh = min(max(Xt),6)-0.5;
xlim = [-obs_per_seg/5, T+obs_per_seg/5]; ylim = [ylow, yhigh];
% axis([-obs_per_seg/5, T+obs_per_seg/5, ylow, yhigh])
% yticks(( (-ceil(min(Xt)):(ceill(max(Xt)) );
yticks((-5:5)*2);
cl = .9;  set(gca,'Color',[cl cl cl]); %Gives us a grey plot background

%%%%%% Red line segments for true segment means
% means_plot = plot(actualMeans,'red','LineWidth',2);
ylabel('Simulated Data Series $X_{t}$','FontSize',14,'Interpreter','latex')
xlabel('Sample t','FontSize',14,'Interpreter','latex')











%% Third plot with change point estimates
grid on

% title('Change Point Estimates, depicted with vertical lines.',...
%   'FontSize',14,'Interpreter','latex')
% title('Change Point Estimated Locations, depicted with vertical lines')%...
    %'FontSize',14,'Interpreter','latex')]

title({'Change Point Estimates, depicted with vertical lines.','(may not display all points)'},...
 'FontSize',14,'Interpreter','latex');

hold on


% xline(Snew(2),'green','LineWidth',2.3)
for i=2:(Kcurrent+1)
    xline(Sk(currentSample-1,i),'blue','LineWidth',2.3)
end

% line([0,ck1],[20,ck1])
% plot([1,zIndex],[ck1,ck1],'color','blue','linewidth',2)
% plot([zIndex+1,ceil(T/2)],[ck2,ck2],'color','blue','linewidth',2)
% location_plot = xline(obs_per_seg*i,'blue','LineWidth',2.3);
xline(zIndex+1,'color','green','linewidth',3)
    

end




