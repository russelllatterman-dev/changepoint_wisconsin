%plots_demo_initialData

global samples %nuber of iterations of gibbs sampler
close all

%Discard some number of values for burn-in

lowerCutoff = floor(length(psiEstimates)/2); %Used for estimation based on last half of data
excludeLowerData = 0;

groupColor = ["blue","yellow"];

%%%% FIRST WINDOW DATA PLOTS
f = figure('Name','Red is "true" when we already know psi', 'visible','off','Color','white');
cl = 0.8; 

xStartCP = 0;
yStartCP = 500;
widthCPwindow = 600;
heightCPwindow = 700;
set(gca,'Color',[cl cl cl])
f.Position = [xStartCP yStartCP widthCPwindow heightCPwindow];
%set(gcf,'menubar','none')
%movegui(f,'northwest')
shg
tiledlayout(3,1)



%% DATA PLOTS:  INITIAL GUESS
nexttile
for i = 1:length(S_initial)
    xline(S_initial(i),'--b','linewidth',2)
end
set(gca,'Color',[cl cl cl])
grid(gca(), 'on') 
hold on

%groupColor = ["magenta","red"];
plot(Xdata,'.','color','black')
for i = 1:length(C_initial)
    gColor = groupColor(G_initial(i));
    plot([S_initial(i),S_initial(i+1)],[C_initial(i),C_initial(i)],'color',gColor,'LineWidth',1)
end

title([num2str(samples), '  samples ', num2str(Kguess),' Initial guess segments', '   phi = ', num2str(phi)],'Interpreter','latex','FontSize',16)
%subtitle([num2str(samples),' iterations'],'Interpreter','latex','FontSize',14)
xticks(S_initial)

%  DATA PLOTS ACTUAL
nexttile 
set(gca,'Color',[cl cl cl])
if do_imported_data == 1
    f.Position = [0 0 1000 900];
    %Manual Entry of Change points
    hold on
    plot(Xwell,'.')
    xticks(S_well)
    grid(gca(), 'on') 
    for i = 1:length(C_well)
    
        xline(S_well(i),'lineWidth',2)
    
        if G_well(i) == 1
            groupColor = 'magenta';
        else
            groupColor = 'red';
        end
    
       plot([S_well(i),S_well(i+1)],[C_well(i),C_well(i)],'Color',groupColor,'LineWidth',3)
    end
    yline(g1_mean,'Color','magenta','LineWidth',2)
    
    
    yline(g2_mean,'Color','red','LineWidth',1)
    title([num2str(Ktrue),' Actual Segments'], 'Interpreter','latex','FontSize',16)
    hold off
else

    for i = 1:(length(Sactual))
        xline(Sactual(i),'--b','linewidth',2)
    end
    hold on
    plot(Xdata,'Color','black')
    title([num2str(Ktrue),' Actual Segments'], 'Interpreter','latex','FontSize',16)
    xticks(Sactual)
    grid(gca(), 'on') 
    
    
    for i = 1:(length(Ctrue))
       gr = Gtrue(i);
       gColor = groupColor(gr);
    
       plot([Sactual(i),Sactual(i+1)],[Ctrue(i),Ctrue(i)],gColor,'LineWidth',2)
    
       %plot([Strue(i),Strue(i+1)],[Ctrue(i),Ctrue(i)])
       hold on
    end

end



%% (1)  DATA PLOTS:  ESTIMATIONS
nexttile
hold on

set(gca,'Color',[cl cl cl])
grid(gca(), 'on') 
plot(Xdata,'.','color','black')
title("Estimates to appear here",'Interpreter','latex','FontSize',16)