%Audio Trimming 
%Makes use of the signal energy and zero crossing rate detectors

function output = trimAudio(input)
    %global DEBUG;
    DEBUG = 0;
    
    %Plotting options for debugging purposes
    if(DEBUG)
        FS = 44100;
        TS = 1/FS;
        len = length(input);
        disp(['signal length = ', num2str(len)]);
        tVector = 1:1:len;
        figure (1);
        subplot(4, 1, 1);
        plot(tVector, input);
    end;	

        

    powerStartFrame 	= 0;
    powerEndFrame		= 0;

    zcrStartFrame 		= 0;
    zcrEndFrame         = 0;

    [powerStartFrame, powerEndFrame] = powerDetector(input);
   
    %zcrStartFrame, zcrEndFrame = zcrDetector(input);

    output = input(powerStartFrame:powerEndFrame);
    
    
    if(DEBUG)
        tVector2 = 1:1:length(output);
        subplot(4, 1, 4);
        plot(tVector2, output);
    end;
end