
%%% ONLY ONE GUI FUNCTION IS ACTUALLY USED

% THE   inputdlg    command


% you can't change the window location with this command

% answer = inputdlg(prompt,dlgtitle,dims,definput,opts)
% https://www.mathworks.com/help/matlab/ref/inputdlg.html#d124e796166                    

global Ktrue        % Actual number of estimates
global obs_per_seg  %observations per segment
global Kguess       % Initial guess number of segments
global runDemoFile      % determines whether we run the demo file

groupsDefault = num2str('Ksegments');

prompt = {'K segments'      ,...
          'obs per segment' ,...
          'K guess'         ,...
          'RUN demoFile?'}; %run: insertion_deletion_demo.m ?'};
      
windowTitle = 'Initial conditions'; %totle at top of box

dims = [1 20]; % size of input boxes

initialWindowValues = { num2str(Ktrue),...       
                        num2str(obs_per_seg),...
                        num2str(Kguess),...
                        num2str(runDemoFile)};

%        ACTUAL GUI COMMAND
windowEntries = inputdlg( prompt,...                %<--- THIS IS THE ONLY ACTUAL GUI COMMAND
                          windowTitle,...
                          dims,...
                          initialWindowValues);    %<--- We don't even need initial window  values if we don't want to have them
                      
%All we actually need is the prompt
%                     
                      

%Output values to assign to variables
Ktrue            = str2num( windowEntries{1} );
obs_per_seg      = str2num( windowEntries{2} );
Kguess           = str2num( windowEntries{3} );
runDemoFile      = str2num( windowEntries{4} );




%K_segments
%Obs_per
%K_guess
