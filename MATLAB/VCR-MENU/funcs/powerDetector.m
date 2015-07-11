%Signal Instantaneous Power Calculation
%ECE 492

function  [startFrame, endFrame] = powerDetector(input)
    global thresh;
    %global DEBUG;
    DEBUG = 0;

    %Constants
    THRESHVAL = 0.00005; %thresh;
	
	startFrame = 1;
    endFrame = length(input)-1;
	
	STARTTOLERANCE = 10;
	ENDTOLERANCE = 10;	
	
	startToleranceCounter = 0;
	endToleranceCounter = 0;
	
	%Mode - 0 = Searching for start
	%     - 1 = Searching for end
	mode = 0;

	%Get the length of the input signal
    len = length(input);

    %Compute simple threshold line
    threshold = ones(len, 1) * THRESHVAL;
    
    %Create power signal vector
    pwrSignal = zeros(len, 1);
    
    %Create fixed widnth average power signal vector
    avgPwrSignal = zeros(len, 1);
    avgWidth = 512;
    avgVal = 0;

    %Compute the power and avg. power
    for i = 1:len
        instantPwr = abs(input(i)^2);
        pwrSignal(i) = instantPwr;
        
        for j = 1:avgWidth
            if(i > j)
                avgVal = avgVal + pwrSignal(i-j);
            end;
        end;
        
        avgVal = avgVal / avgWidth;
        avgPwrSignal(i) = avgVal;
    end;

    %Correct the flag signal vector by turning all points to 1 between first
    %and last occurrence of points above threshold
    for i = 1:len
		%Searching for start frame
		if(mode == 0)
			if(avgPwrSignal(i) > threshold(i))
				startToleranceCounter = startToleranceCounter+1;
				
				if(startToleranceCounter == STARTTOLERANCE)
					startFrame = i-STARTTOLERANCE;
					mode = mode + 1;
				end;
			
			else
				%Reset the tolerance counter if there is a gap
				if(startToleranceCounter > 0)
					startToleranceCounter = 0;
				end;
			end;
		
		%Searching for end frame
		elseif(mode ==1)
			if(avgPwrSignal(i) < threshold(i))
				endToleranceCounter = endToleranceCounter+1;
				
				if(endToleranceCounter == ENDTOLERANCE)
					endFrame = i - ENDTOLERANCE;
					mode = mode + 1;
				end;
			else
				if(endToleranceCounter > 0)
					endToleranceCounter = 0;
				end;
			end;
		end;
     end;
     
     if(DEBUG)
         
         disp(['start = ', num2str(startFrame)]);
         disp(['end   = ', num2str(endFrame)]);
         
         FS = 44100;
         TS = 1/FS;
         len = length(input);
         tVector = 1:1:len;
         
         subplot(4, 1, 2);
         plot(tVector, pwrSignal);
         
         subplot(4, 1, 3);
         plot(tVector, avgPwrSignal);
         hold;
         
         subplot(4, 1, 3);
         plot(tVector, threshold);
     end;
end
