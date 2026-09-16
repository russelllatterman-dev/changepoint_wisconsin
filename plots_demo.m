%% Plots
%global samples %number of iterations
global samples %nuber of iterations of gibbs sampler

%tracePlot_group_updates
%startPlotWindowFirst  is a variable in insertion_deletion_demo

%Discard some number of values for burn-in
if startPlotWindowFirst ~= 1 %This means we have not produced an initial window  at 
    %the start of the program

    close all
    tic
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
    f.Position = [xStartCP yStartCP widthCPwindow heightCPwindow];
    set(gca,'Color',[cl cl cl])
    
    %set(gcf,'menubar','none')
    %movegui(f,'northwest')
    
    
    tiledlayout(3,1)


    %% DATA PLOTS:  INITIAL GUESS
    nexttile
    %tic
    %for i = 1:length(S_initial)
    xline(S_initial,'--b','linewidth',2)
    %end
    %toc
    
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
    
        %xline(S_well,'lineWidth',2)
    
        xline(S_well,'lineWidth',2)
        for i = 1:length(C_well)
        
            %xline(S_well(i),'lineWidth',2)
        
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
        xline(Sactual,'--b','linewidth',2)
        %for i = 1:(length(Sactual))
        %    xline(Sactual(i),'--b','linewidth',2)
        %end
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
    
    
    
    
    estimateTitle = [num2str(length(S)-1),' Estimated Segments'];
    title(estimateTitle,'Interpreter','latex','FontSize',16)

    xline(S,'--b','linewidth',2)
    %for i = 1:(length(S))
    %    xline(S(i),'--b','linewidth',2)
    %end
    xticks(S)
    
    hold on
    %groupColor = ["magenta","red"];
    
    
    for i = 1:length(C)
        gColor = groupColor(G(i));
        plot([S(i),S(i+1)],[C(i),C(i)],'color',gColor,'LineWidth',1)
    end
    
    shg % This makes everything suddenly visible

else 
    %Everything else has already been run,
    title("Estimates",'Interpreter','latex','FontSize',16)
    xline(S,'--b','linewidth',1)
    %for i = 1:(length(S))
    %    xline(S(i),'--b','linewidth',2)
    %end
    xticks(S)
    
    hold on
    %groupColor = ["magenta","red"];
    for i = 1:length(C)
        gColor = groupColor(G(i));
        plot([S(i),S(i+1)],[C(i),C(i)],'color',gColor,'LineWidth',2)
    end

end
%% Animation 
if doAnimation == 1
    nexttile

    numLines = 0;
    for j = 1:size(Svector,1) %2 refers to rows
        %Go through each row and visually update
        a = 1;
        while a > 0
            numLines = numLines + 1;
            a = Svector(j,numLines);
        end
        %Snew_j = Svector(j,1:numLines);

        
        for k= 1:(numLines-1)
            xline(Svector(j,k),'linewidth',2,'color','blue')
        end
        xticks(Snew)

        drawnow 
        clf
        pause(.1)

        if j < size(Svector,1)
        for k= 1:(numLines-1)
            xline(Svector(j,k),'linewidth',3,'color','white')
        end
        xticks(Snew)
        end
        numLines = 0;
    %     length(Snew)
    %     for i=1:length(Snew_j)
    %         xline(Snew(i))
    %     end
    % 
    %     for i = 1:length(S)
    %         xline(Snew(i),'linewidth',2,'color','blue')
    %     end
    end

end 

%%
%%
%% FIGURE 2 TRACE PLOTS


%%PSI UPDATES
f2 = figure('visible','off','Color','white');
cl = 0.8;
wPsi = 500;
hPsi = floor(heightCPwindow/2);

x1Psi = widthCPwindow;
x2Psi = wPsi;
y1Psi = heightCPwindow + yStartCP - hPsi;
y2Psi = hPsi;

f2.Position = [x1Psi y1Psi x2Psi y2Psi ];

if updatePSI == 1

    

    %CASE  WE ARE NOT DOING TWO PSI ESTIMATES
    if psi_two_groups == 0 %
        %psiEstimatesGroups
        hold on
        psi_hat = mean(psiEstimates); %Based 

        psiTrue = psi_g_true(1);
       
        plot(psiEstimates,'color','blue')
    
        if excludeLowerData == 1
            plot(psiEstimates(lowerCutoff:length(psiEstimates)),'color','blue')
        else
            plot(psiEstimates,'color','blue')
        end
    
        hold on
        psi_hat_adjusted = mean(psiEstimates(lowerCutoff:length(psiEstimates)));
        actualPsiPlot = plot([0,length(psiEstimates)],[psiTrue,psiTrue],'linewidth',3,'color','green');
    
        estimatePsiPlot = plot([0,length(psiEstimates)],[psi_hat_adjusted,psi_hat_adjusted],'linewidth',2,'color','red');%],'linewidth',2,'color','red')
        %plot([0,length(psiEstimates)],[psi_hat_adjusted ,psi_hat_adjusted ],'-','linewidth',2,'color','black');%],'linewidth',2,'color','red')

        set(gca,'Color',[cl cl cl])
        grid(gca(), 'on')
        
        title('Trace Plot of $$ \psi $$',...
           'FontSize',16,'Interpreter','latex')
        % legend( [estimatePsiPlot, actualPsiPlot],...
        %         {'Mean','True $$ \psi $$'},...
        %         'location','northoutside',...
        %         'FontSize',12,...
        %         'Interpreter','latex')
        %set(gcf,'menubar','none')
        shg %Show figure for psi estimate
    end  %psi_two_groups == 0


    if  psi_two_groups == 1
        tiledlayout(2,1)
        if min(Gm) == 1 %Then we have a group 1 estimate. Even if we randomly generated two groups, we might end up with only a group 1 estimate
                        %Or just a group 2 estimate
            nexttile

            psi_hat = mean(psiEstimatesGroups(:,1));
            psiTrue = psi_g_true(1);     
            psi_hat_adjusted = mean(psiEstimates(lowerCutoff:length(psiEstimatesGroups(:,1))));
            
        
            if excludeLowerData == 1
                plot(psiEstimatesGroups(lowerCutoff:length(psiEstimates),1),'color','black')
            else

                plot(psiEstimatesGroups(:,1),'color','black')
            end
        
            hold on
            
            psi_hat_adjusted = mean(psiEstimatesGroups(   lowerCutoff:length(psiEstimatesGroups(:,1))   ,2  )  );
            actualPsiPlot = plot([0,length(psiEstimatesGroups(:,1))],[psiTrue,psiTrue],'linewidth',3,'color','red');
        
            set(gca,'Color',[cl cl cl])
            grid(gca(), 'on')
        
            title('Trace Plot of $$ \psi_{1} $$',...
            'FontSize',16,'Interpreter','latex')
           % set(gcf,'menubar','none')
        % legend( [estimatePsiPlot, actualPsiPlot],...
        %         {'Mean','True $$ \psi $$'},...
        %         'location','northoutside',...
        %         'FontSize',12,...
        %         'Interpreter','latex')

            %estimatePsiPlot = plot([0,length(psiEstimatesGroups(1,:))],[psi_hat_adjusted,psi_hat_adjusted],'linewidth',2,'color','black');%],'linewidth',2,'color','red')
            %plot([0,length(psiEstimates)],[psi_hat_adjusted ,psi_hat_adjusted ],'-','linewidth',2,'color','black');%],'linewidth',2,'color','red')
           shg %Show figure for psi estimate
        end



        if max(Gm) == 2 %Then we have a group 2 estimate
            nexttile
            psi_hat = mean(psiEstimatesGroups(:,2));
            psiTrue = psi_g_true(2);     
            plot(psiEstimatesGroups(:,2),'color','black')
        
            if excludeLowerData == 1
                plot(psiEstimatesGroups(lowerCutoff:length(psiEstimates),2),'color','black')
            else
                plot(psiEstimatesGroups(:,2),'color','black')
            end
        
            hold on
            
            psi_hat_adjusted = mean( psiEstimatesGroups(   lowerCutoff:length(psiEstimatesGroups(:,2))   ,2));
            actualPsiPlot = plot([0,length(psiEstimatesGroups(:,2))],[psiTrue,psiTrue],'linewidth',3,'color','red');
        
            %estimatePsiPlot = plot([0,length(psiEstimatesGroups(1,:))],[psi_hat_adjusted,psi_hat_adjusted],'linewidth',2,'color','black');%],'linewidth',2,'color','red')
            %plot([0,length(psiEstimates)],[psi_hat_adjusted ,psi_hat_adjusted ],'-','linewidth',2,'color','black');%],'linewidth',2,'color','red')
            set(gca,'Color',[cl cl cl])
            grid(gca(), 'on')
        
            title('Trace Plot of $$ \psi_{2} $$',...
            'FontSize',16,'Interpreter','latex')
            %set(gcf,'menubar','none')
            shg %Show figure for psi estimate
        end
        
        
        

    end

end


%% THETA ESTIMATE
if updateTheta == 1
    numTiles = 1;
    if theta_two_groups == 1
        numTiles = 2;
    end

    
    
    f3 = figure('visible','off','Color','white');
    tiledlayout(numTiles,1)
    cl = 0.8;
    
    hTheta = floor(hPsi*3/4);

    x1Theta = x1Psi;
    x2Theta = wPsi;
    y1Theta = y1Psi-hPsi;
    y2Theta = hTheta;
    
    f3.Position = [x1Theta y1Theta x2Theta y2Theta];
    
    

    %nexttile
    theta_hat = mean(thetaEstimatesGroups(:,1));

    theta_hat_adjusted = mean(thetaEstimatesGroups(lowerCutoff:length(thetaEstimates),1));


    nexttile

    if excludeLowerData == 1
        plot(thetaEstimatesGroups(lowerCutoff:length(thetaEstimates),1),'color','blue')
    else
        plot(thetaEstimatesGroups(:,1),'color','blue')
    end
    hold on

    actualThetaPlot = plot([0,length(thetaEstimates)],[thetaMA_0,thetaMA_0],'linewidth',3,'color','green');
    %estimateThetaPlot = plot([0,length(thetaEstimates)],[theta_hat,theta_hat],'linewidth',2,'color','black');%],'linewidth',2,'color','red')

    plot([0,length(thetaEstimates)],[theta_hat_adjusted,theta_hat_adjusted],'-','linewidth',2,'color','red');%],'linewidth',2,'color','red')
    
    hold on


    title('Trace Plot of $$ \theta $$',...
        'FontSize',16,'Interpreter','latex')

    if theta_two_groups == 1
        nexttile
        if excludeLowerData == 1    
            
            plot(thetaEstimatesGroups(lowerCutoff:length(thetaEstimates),2),'color','blue')
            
        else
            plot(thetaEstimatesGroups(:,2),'color','blue')
            theta_hat_adjusted2 = mean(thetaEstimatesGroups(lowerCutoff:length(thetaEstimates),2));
            hold on
            plot([0,length(thetaEstimates)],[theta_hat_adjusted2,theta_hat_adjusted2],'-','linewidth',2,'color','red');%],'linewidth',2,'color','red')
        end
    end

    shg

    %set(gcf,'menubar','none')
    % legend( [estimateThetaPlot, actualThetaPlot],...
    %     {'Mean','True $$ \theta $$'},...
    %     'location','northoutside',...
    %     'FontSize',12,...
    %     'Interpreter','latex')
end

if numUpdates == 2
    %set(gcf, 'Position',  [600, 100, 500, 1000])
end

if updatePHI == 1
    figure()
    hold on
    cl = 0.8;
    wPhi = 100;
    hPhi = 100;
    plot(phiEstimates)
    title('PHI estimates')
    
    actualPHI = (Ktrue-1)/T;
    plot([0,length(phiEstimates)],[actualPHI,actualPHI],'linewidth',3,'color','green')
    
    set(gcf, 'Position',  [1100, 600, 200, hPhi])
    %set(gcf,'menubar','none')
end


if updateSig2error == 1
    figure()
    hold on
    cl = 0.8;
    wPhi = 100;
    hPhi = 100;
    plot(sig2Estimates)
    title('Sigma squared estimates')
    
    %actualPHI = (Ktrue-1)/T;
    %plot([0,length(phiEstimates)],[actualPHI,actualPHI],'linewidth',3,'color','green')
    
    set(gcf, 'Position',  [1100, 600, 200, hPhi+100])
    %set(gcf,'menubar','none')
end

toc



