function [out_status, out_data] = VCR_MAIN()
%VCR_MAIN - Vocal Command Recognition - primary function
%The function executes the full vocal command recognition system as defined
%
% Syntax:  [out_status, out_data] = VCR_MAIN()
%
% Inputs:
%   input1 - Description
%
% Outputs:
%   out_status  - status output for signal/mode
%   out_data    - Data output; indicates word or specific details based on
%                   status output
%
% Example: 
%   Line 1 of example
%
% Other m-files required: 
%   startFinder.m
%   
% Subfunctions: none
% MAT-files required: none
%
% See also: OTHER_FUNCTION_NAME1,  OTHER_FUNCTION_NAME2
    %
% Authors: David Wernli, Jason Page, Antonia Paris, 
%          Kevin Briggs, Scott Carlson
% George Mason University - Senior Design Project (ECE492/493)
% email: 
% Website: http://www.
% September 2014; Last revision: 03-Nov-2014

%------------- BEGIN CODE --------------
%% Function Header
    %Enter optional argument control and persistent variables here
    out_status = 0;
    out_data = 0;
 % function variables (constants)
    Fs      = 8000; %sample freq
    nBits   = 8;    %sample bit depth
    nChan   = 1;    %mono/stereo
    dur     = 1;    %duration of the recording in seconds
    LF      = 64;  %low pass freq
    HF      = 3700; %high pass freq
    Tw  = 25;   %window size in ms
    wSamp   = floor(Fs/Tw);    %window size in samples


%% Function Body
%pre-set several variables
startFlag = 0;  %the position of the start of the word in time samples
lastWordStart = 0; %for when we use continuous sampling
timeSample = [];
windows = [];

%Get the recording from the user - ideally this will be real-time
%processing, for now - get a file from the mic
sampleData = get_recording(Fs, nBits, nChan, dur);

%will pretend data is recieved in real-time, processing one sample at a
%time looking for the start of a word.

for i = 1:1:length(sampleData)
    if(startFinder(sampleData(i),0.010,wSamp))  %calling startfinder - cutoff = sample window size to not miss the end of a word
        if(startFlag == lastWordStart)
            startFlag = i;
        end
        %process the signal
        timeSample = horzcat(timeSample,sampleData(i));
            %add the current sample value to the truncated signal
        %check to see if a full window's length has passed based on startFlag
            %send each window to the FFT algorithm
            %send the FFT results to the MFCC
            %Store the results from MFCC in an array
        %
    elseif(startFlag ~= lastWordStart)   %if we have already seen some speech and it's now over
        %send the MFCC results array to the matching setup(s)
        %look at the matches and see what we've got
        lastWordStart = startFlag;  %reset the lastWordStart
        lastWordEnd   = i;
    end
end

%Extract features of only relevant sections of the sampled audio
if(startFlag ~= 0) %only execute if we found something...
    out_status = 0;
    out_data = get_MFCCs(timeSample, 1);
end
%------------- END OF CODE --------------
%datalogging hints/uses
% [junk, mfccs] = VCR_MAIN;
% results={results{:},mfccs}
% filename = sprintf('mfcc-results_%s_x%d.mat', CMD_WORD, ITERATION);
% save(filename,'results')