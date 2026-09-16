%Find where means assignment becomes zero and figure out why

%%%% Output

%rep
tic
if run_debug_meanCheck == 1

    for i=1:length(Cm)
        if Cm(i) == 0
            disp(['           Error Seg mean set to zero','Cm ='])
            disp(Cm)
            disp(['           Cm previous',num2srt(Cm_previous)])
            disp('LC = ', num2str(LC))

        end
    end
    %disp(['Cindex = ', num2str(Cindex)])
end
debugMeanCheckTime = debugMeanCheckTime + toc;

