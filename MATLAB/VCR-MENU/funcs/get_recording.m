function myRecording = get_recording( Fs, nBits, nChan, duration)
%get_recording - gets a recording with the specified parameters.
%
% Syntax:  myRecording = get_recording(Fs, nBits, nChan, duration)
%
% Globals : Read/Write : description
%   
% Inputs:
%   Fs      - sample rate in Hz
%   nBits   - number of bits each sample (bit-depth)
%   nChan   - number of channels (stereo/mono)
%   dur     - duration of the recording
%
% Outputs:
%   myRecording - returns a column vector of the sampled data
%
    %
% Authors: David Wernli, Jason Page, Antonia Paris, 
%          Kevin Briggs, Scott Carlson
% George Mason University - Senior Design Project (ECE492/493)
% email: 
% Website: http://www.
% September 2014; Last revision: 08-Nov-2014

%------------- BEGIN CODE --------------
%% Function Header
    %Enter optional argument control and persistent variables here
    DATALOGGING = 0;
%% Function Body

recObj = audiorecorder(Fs, nBits, nChan);
disp('Start speaking.')
recordblocking(recObj, duration);
    %record(recObj);
    %do something to look at the input stream
    %stop(recObj);
disp(['End of Recording. ']);
% Store data in double-precision array.
myRecording = getaudiodata(recObj);
disp(['End of Recording. ' num2str(max(myRecording))]);

% if(DATALOGGING)
%     filename = sprintf('wav_files/DRW_%s_%d.wav', CMD_WORD, ITERATION);
%     ITERATION = ITERATION + 1;
%     audiowrite(filename,myRecording,Fs);
% end

%------------- END OF CODE --------------