%% Plots of data, true changepoint locations, and group means
%%% Makes a tiled layout(2,1)

%clf
%close all

f = figure('visible','off','Color','white');
movegui(f,'northeast')
shg
tiledlayout(2,1)
nexttile
hold on

%figure legend and title
grid on
title(['Segments: K= ', num2str(Ksegments),'~~~',...
    '    Groups: ',num2str(Ngroups),'~~~',...
    '    Observations Per Segment: ', num2str(obs_per_seg)],...
    'FontSize',14,...
    'Interpreter','latex')


%%%%%%  Data scatter plot
data_plot = plot(Xt,'black','LineWidth',1);
ylow = min(min(Xt),6)+0.5;   yhigh = min(max(Xt),6)-0.5;
axis([-obs_per_seg/5, T+obs_per_seg/5, ylow, yhigh])
%yticks(( (-ceil(min(Xt)):(ceill(max(Xt)) );
yticks(-10:10);
cl = .9;  set(gca,'Color',[cl cl cl]); %Gives us a grey plot background

%%%%%% Red line segments for true segment means
means_plot = plot(actualMeans,'red','LineWidth',2);
ylabel('Simulated Data Series $X_{t}$','FontSize',14,'Interpreter','latex')
xlabel('Sample t','FontSize',14,'Interpreter','latex')

%%%%%% Vertical blue lines indicate start of new segment (changepoint)
%%%%%  These are s2 through s_(K-1) where K is the number of segments
for i=1:(Ksegments-1)
    xline(obs_per_seg*i,'blue','LineWidth',2.3)
end
location_plot = xline(obs_per_seg*i,'blue','LineWidth',2.3);

legend([location_plot,means_plot],...
    {'True Change-Point Location $s_{k}$','True Segment Mean $C_{k}$'},...
    'location','northoutside',...
    'FontSize',12,...
    'Interpreter','latex')
hold off

%% Plots for estimation process

nexttile
%%%%%%  Data scatter plot
data_plot2 = plot(Xt,'black','LineWidth',1);
ylow = min(min(Xt),6)+0.5;   yhigh = min(max(Xt),6)-0.5;
axis([-obs_per_seg/5, T+obs_per_seg/5, ylow, yhigh])
%yticks(( (-ceil(min(Xt)):(ceill(max(Xt)) );
yticks(-10:10);
cl = .9;  set(gca,'Color',[cl cl cl]); %Gives us a grey plot background

%%%%%% Red line segments for true segment means
%means_plot = plot(actualMeans,'red','LineWidth',2);
ylabel('Simulated Data Series $X_{t}$','FontSize',14,'Interpreter','latex')
xlabel('Sample t','FontSize',14,'Interpreter','latex')



%%%%%%% Second plot with change point estimates
grid on

title('Change Point Estimates, depicted with vertical lines.',...
   'FontSize',14,'Interpreter','latex')
%title('Change Point Estimated Locations, depicted with vertical lines')%...
    %'FontSize',14,'Interpreter','latex')]
hold on

xline(Snew(2),'green','LineWidth',2.3)
for i=3:(length(Snew))
    xline(Snew(i),'blue','LineWidth',2.3)
end


%location_plot = xline(obs_per_seg*i,'blue','LineWidth',2.3);
    



