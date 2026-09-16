%renWellData

%%%This was originally done to analyze well data

%% Temporarily this is being used to analyze other data sets
%These need to be defined for the tracePlot_group_updates file

global m1_true
global m2_true
global t1_true
global t2_true
global pi1_true
global pi2_true

useWellData = 1;
useCovidData1 = 0;
useLinearized = 1;
    useARMAgenerator = 0;

plotAtStart = 1; %Plots data labeled at the starting point
                 %Otherwise lower data range just gets labeled as 1 on the
                 %graph
%addNoise = 1;



%Guess Data
%Need to improve the moving average part
modifyOutliers = 0; %Reduces the bias from big spikes

%%%Data range for well data
useRefinedData = 1;
if useWellData == 1
    if useRefinedData == 1
        dataRange = [1,3960]; 
    else
        dataRange = [1,4050];
    end
end



movingAverage   = 0;
movingAverageSteps  = 2;

signedRoot      = 0;
rtPower             = 8; % 2 is square root, 3 is cubed root, etc

logData = 0; %Does a log transformation instead of root

movingAverageFirst      = 1; %Does moving avg transformation, then root

differences    = 0;
differenceStep = 1;

useMediansForCk = 0;

addNoise = 0;
shiftData = 0;

noiseVar = 0.25;
dataWidthFactor = 4; %Increases magnitude of data
dataLengthFactor =10; %Shifts data away from zero by the ammount


%Xwell_afterShift   Before we do any signed root or moving average
%Xwell_Moving_thenRoot       After Moving Average
%Xwell_Root_thenMoving   After Signed Root
%Xwell_Root
%Xwell_Moving

%% Manually entered change points
%% We will definitely do this differently later on


if useRefinedData == 1
    S_well =[1	,   ...
    300	,	...		
    554	,	...		#### was 500
    715	,	...
    821	,	...		
    1008 ,	...     %% was 1038
    1040 ,	...	    %% was 1071
    1325 ,	...     %% Was 1370
    1481 ,	...     %% Was 1527
    1637	,	... %% Was 1680		
    1819	,	...	%% Was 1887	
    2000	,	...	%% Was 2049	
    2360	,	... %% Was 2410
    2418	,	... %% 2470
    2478	,	... %% 2532
    2539	,	... %% 2592
    2719	,	... %% 2772
    2953	,	...	%% 2953
    3082	,	...	%% 3082
    3324    ,   ... %% 3324
    3525	,	... %% 3525
    3582    ,   ... %% 3610
    3684    ,   ... %% 3720
    3760    ,   ... %% 3850
    3776    ,   ...
    3943    ,   ...
    3960    ,   ...
    ];         %% 4050
else
    S_well =[1	,   ...
    320	,	...		
    580	,	...		#### was 500
    715	,	...
    821	,	...		
    1038 ,	...     %% was 1038
    1071 ,	...	    %% was 1071
    1370 ,	...     %% Was 1370
    1527 ,	...     %% Was 1527
    1680	,	... %% Was 1680		
    1887	,	...	%% Was 1887	
    2049	,	...	%% Was 2049	
    2410	,	... %% Was 2410
    2470	,	... %% 2470
    2532	,	... %% 2532
    2592	,	... %% 2592
    2772	,	... %% 2772
    2953	,	...	
    3082	,	...	
    3324    ,   ...
    3525	,	...
    3610	,	...
    3720	,	...
    3850	,   ...
    3934    ,   ...
    3955    ,   ...
    4050];	

    
end
% This gives the data a center of zero and similar
% variation to what we get with generated data



if useRefinedData == 1
    XwellModified = importdata('well_data_refined.txt');
    Xwell2 = XwellModified(:,2);

    Xwell = Xwell2(1:length(Xwell2));
    Xwell = 8*Xwell/10^4; %Scaled for easier visualization

    Xwell = Xwell - mean(Xwell);
else
    Xwell2 = importdata('well_data');
    Xwell  = Xwell2(1:length(Xwell2));
    Xwell  = 8*Xwell/10^4;
    Xwell  = Xwell - mean(Xwell); %Centers it all on zero
end
%%

if useCovidData1 == 1
    Xcovid = importdata('covidCasesWisconsin1.txt');
    if useLinearized == 1
        Xcovid = importdata('covidCasesWisconsin2.txt');
    end

    if useARMAgenerator == 1
       ARMA_generator_practice %%%%%%% RUN FILE
       Xcovid = XseriesManual;
       %S_covid = manualPoints(2:length(manualPoints));
       S_covid = manualPoints;
    else
          
    %Initial estimated change points
    S_covid = [8,17,36,44,59,78,116,152,232,273,285, ...
               348,378,463,522,529,540,550,556,577,602,608, ...
               613,623,629,619,659,700];

    end
    
    %dataRange = [79,521];%Who series goes from 1 to 700
    %dataRange = [1,length(Xcovid)];
    dataRange = [1,300];
    
    Xcovid = Xcovid(dataRange(1):dataRange(2));
    close all
    plot(Xcovid)
    
    numCaseReports = length(Xcovid);
  
    j = 0;
    jLow = 0;
    S_covid2 = [];
    for i = S_covid
        if (i >= dataRange(1) && i <= dataRange(2))
            S_covid2 = [S_covid2,i];
        end

    end
    S_covid2 = [S_covid2,dataRange(2)];
    S_covid = S_covid2 - dataRange(1)+1;
    
    S_well = S_covid; %Variable placeholder for calculations is S_well
    
    Xcovid_standardized = (Xcovid - mean(Xcovid))/sqrt(var(Xcovid));

    Xwell = Xcovid_standardized; %Xwell placeholder for calculations
end


%% modify outliers
if modifyOutliers == 1
    for i=1:length(Xwell)
        if Xwell(i) < -4
            Xwell(i) = Xwell(i)/4;
        end
    end

    for i = 1100:1500
        if Xwell(i) < 2
            Xwell(i) = 2.5;
        end
    end
end
%%

Xwell_afterShift = Xwell; %Before we do any signed root or moving average

%Different data modifications for analysis
%Signed root of data
%Initialized

Xwell_Root              =  Xwell./abs(Xwell).*(abs(Xwell)).^(rtPower);
Xwell_Moving            = (Xwell(movingAverageSteps:length(Xwell)) + Xwell(1:(length(Xwell)-movingAverageSteps+1)))./movingAverageSteps;
Xwell_Moving_thenRoot   = Xwell_Moving./abs(Xwell_Moving).*(abs(Xwell_Moving)).^(rtPower);                
Xwell_Root_thenMoving   = (Xwell_Root(movingAverageSteps:length(Xwell_Root)) + Xwell_Root(1:(length(Xwell_Root)-movingAverageSteps+1)))./movingAverageSteps;
Xwell_Difference = (Xwell((differenceStep+1):length(Xwell)) - Xwell(1:(length(Xwell)-differenceStep)));


%Xwell_integrated = (Xwell((integratedStep+1):length(Xwell)) + Xwell(1:(length(Xwell)-differenceStep)));

%Xwell_UN_Difference = (Xwell((differenceStep+1):length(Xwell)) - Xwell_Difference(1:(length(Xwell)-differenceStep)));

%Xwell_afterShift   Before we do any signed root or moving average
%Xwell_Moving_thenRoot       After Moving Average
%Xwell_Root_thenMoving   After Signed Root
%Xwell_Root
%Xwell_MovingXwell;

if signedRoot == 1 && movingAverage == 0
   %Attempts to reduce the magnitude of non-linear trends by taking
   %The square roots of the magnitudes of the values
   for i = 1:length(Xwell)
        %if abs(Xwell(i)) > 1
            if logData == 1
                Xwell(i) = log(abs(Xwell(i)))* sign(Xwell(i));
            else
                Xwell(i) = abs(Xwell(i)).^(1/rtPower) * sign(Xwell(i));
            end
        % else
        %     if logData == 1
        %        Xwell(i) = abs(Xwell(i)).^(rtPower) * sign(Xwell(i));
        %     else
        %        Xwell(i) = exp(abs(Xwell(i))) * sign(Xwell(i));
        %     end
        % end
        % 
        


        % if abs(Xwell(i)) < 1
        %    Xwell(i) = sign(Xwell(i))*abs(Xwell(i))^(rtPower);
        % else
        %    Xwell(i) = sign(Xwell(i))*abs(Xwell(i)).^(rtPower);
        % end
   end
end

if movingAverage == 1 && signedRoot == 0
   Xwell(movingAverageSteps:length(Xwell)) = (Xwell(movingAverageSteps:length(Xwell)) + Xwell(1:(length(Xwell)-movingAverageSteps+1)))./movingAverageSteps;


   %Xwell(movingAverageSteps:length(Xwell)) = Xwell_Moving;
end

if movingAverage == 1 && signedRoot == 1
    if movingAverageFirst == 1
        Xwell = Xwell_Moving_thenRoot;
    else
        Xwell = Xwell_Root_thenMoving;
    end
end


if differences == 1
    Xwell((differenceStep+1):length(Xwell)) = Xwell_Difference;
end

if addNoise == 1
    Xwell = Xwell + normrnd(0,noiseVar,length(Xwell),1);
end

% if integrated == 1
%     Xwell_integrated = (Xwell((differenceStep+1):length(Xwell)) + Xwell(1:(length(Xwell)-differenceStep)));
%     Xwell = Xwell_integrated()
% end



%Data have been standardized at this point
if shiftData == 1
    Xwell = dataWidthFactor*Xwell; %Modifies the standard deviation by dataWidthFactor
    Xwell = Xwell - dataLengthFactor*sign(Xwell); %Shifts the means of the groups
end



C_well = zeros(1,length(S_well)-1);
sig2vect = zeros(1,length(C_well));

for i = 1:length(C_well)
    C_well(i) = mean(Xwell(S_well(i):(S_well(i+1)-1)) );
    sig2vect(i) =  var(Xwell(S_well(i):(S_well(i+1)-1)));
end


sig2well = median(sig2vect);  %We don't take the mean because of heavy outliers

G_well = zeros(1,length(C_well));
groupColor = num2str(zeros(1,length(C_well)));

groupCutoff = 0;
for i =1:length(G_well)
    if(C_well(i) < groupCutoff)
        G_well(i) = 1;
    else
        G_well(i) = 2;
    end

end

%Estimate group means and variances
g1_mean_sum = 0; nG1 = 0;
g2_mean_sum = 0; nG2 = 0;

for i = 1:length(G_well)
    if G_well(i) == 1
        g1_mean_sum = g1_mean_sum + C_well(i);
        nG1 = nG1+1;
    else
        nG2 = nG2 + 1;
        g2_mean_sum = g2_mean_sum + C_well(i);
    end
end
nG1_well = sum(abs(G_well - 2));
nG2_well = sum(G_well - 1);
pi1_well = nG1_well/(nG1_well+nG2_well);
pi2_well = 1- pi1_well;
pi1_true = pi1_well;
pi2_true = pi2_well;

g1_mean = g1_mean_sum/nG1;
g2_mean = g2_mean_sum/nG2;


group1_Mean_shift = 0; %.5 * abs(g1_mean); %Shift up or down by a factor proportional to
    %the group means
group2_Mean_shift = 0.0 ; %* abs(g2_mean);

g1_mean = g1_mean_sum/nG1 + group1_Mean_shift;
g2_mean = g2_mean_sum/nG2 + group2_Mean_shift;

m1_true = g1_mean;
m2_true = g2_mean;

g1_Cvect = zeros(1,nG1);
g2_Cvect = zeros(1,nG2);

k1 = 0;
k2 = 0;
for i = 1:length(G_well)
    if G_well(i) == 1
        k1 = k1+1;
        g1_Cvect(k1) = C_well(i);
    else
        k2 = k2+1;
        g2_Cvect(k2) = C_well(i);
    end
end

group1_Var_scale = 1; %Scale group variances, if deemed appropriate
group2_Var_scale = 1;

g1_var = var(g1_Cvect)  * group1_Var_scale;
g2_var = var(g2_Cvect)  * group2_Var_scale; 

t1_true = g1_var;
t2_true = g2_var;
% if useMediansForCk == 1
% end

figure()
plot(Xwell,'.')

% Manual Entry of Change points
hold on
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

yline(g2_mean,'Color','red','LineWidth',2)
hold off

%close all
if plotAtStart == 1
    plot(dataRange(1):dataRange(2),Xwell,'.')
    hold on
    hold on; arrayfun(@xline,[dataRange(1),(S_well+dataRange(1)-1)])
else
    plot(Xwell,'.')
    hold on
    hold on; arrayfun(@xline,[1,S_well])
end
%%%%%% Initialize variables to use in the insertion_deletion_demo code