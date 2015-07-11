%Zero Crossing Rate (ZCR) Detector
%ECE 492

function output = zcrDetectorModule(~)

    %Constants
    FS = 44100;
    TS = 1/FS;

    WINDOW_WIDTH = 1000;
    WINDOW_TIME = WINDOW_WIDTH * TS;

    THRESHVAL = 2500;

    TOLERANCE_WINDOW = 200;


    trackedIndex = 1;
    continuousWidth = 0;
    binaryVal = 0;
    lastVal = 0;
    storeVal = 0;
    isContinuous = 0;
    moveDist = 0;

    %Create ZCR Detector Object
    zcrDetector = dsp.ZeroCrossingDetector;

    %Read audio sample
    inputSignal = audioread('C:\Users\Kevin\Desktop\My Directory\hello.wav');
    len = length(inputSignal);

    maxTime = TS * len;
    timeVector = 0:TS:maxTime-TS; 


    zcrSignal = zeros(len, 1);

    thresholdSignal = ones(len, 1) * THRESHVAL;

    zcrFlagSignal = zeros(len, 1);


    %Compute ZCR Values
    for i=1:len-WINDOW_WIDTH
        window = inputSignal(i:i+WINDOW_WIDTH);
        window = window.';

        numZeroCrossArray = step(zcrDetector, window);
        numZeroCross = numZeroCrossArray;
        zcRate = numZeroCross / WINDOW_TIME;
        zcrSignal(i) = zcRate;
    end;


    for i=1:len
        if(zcrSignal(i) > THRESHVAL)
            zcrFlagSignal(i) = 0;
        else
            zcrFlagSignal(i) = 1;
        end;
    end;


    i=1;
    while(i < len)
        if(i > 1)
            lastVal = zcrFlagSignal(i-1);
        else
            lastVal = 0;
        end;

        if(zcrFlagSignal(i) ~= lastVal)
            trackedIndex = i;
            [isContinuous, moveDist] = checkContinuous(zcrFlagSignal, trackedIndex, TOLERANCE_WINDOW);
            
            if(isContinuous == 1)
                for j = trackedIndex : i + TOLERANCE_WINDOW
                    zcrFlagSignal(j) = zcrFlagSignal(i);
                end;
                
                i = i + TOLERANCE_WINDOW;
            else
                for j = trackedIndex : i + moveDist
                    zcrFlagSignal(j) = zcrFlagSignal(i - 1);
                end;
                
                i = i + moveDist;
                trackedIndex = trackedIndex + moveDist;
            end;
        end;
        
        i = i+1;
    end;
% 
%     figure();
%     subplot1 = subplot(2, 1, 1);
%     plot(timeVector, zcrSignal);
%     hold();
%     plot(timeVector, thresholdSignal);
%     title('hey');
%     
%     
%     subplot2 = subplot(2, 1, 2);
%     plot(timeVector, zcrFlagSignal);
%     set(subplot2, 'Ylim', [0, 2]);
    
    output = zcrFlagSignal;
end



function [isContinuous, moveDist] = checkContinuous(zcrFlagSignal, trackedIndex, TOLERANCE_WINDOW)
    moveDist = 0;
    checkVal = zcrFlagSignal(trackedIndex);
    
    i = 0;
    while(i < TOLERANCE_WINDOW)
        
        if(zcrFlagSignal(trackedIndex + i) ~= checkVal)
            isContinuous = 0;
            moveDist = i;
            return;
        end;
        
        i = i+1;
    end;
    
    isContinuous = 1;
end

    