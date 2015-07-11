function newTraining(word_no)
%newTraining Obtains a new audio sample from the user & Adds to command word
%Takes the position of a word within the command list and creates a new
%training entry for the word. 
%
% Globals : Read/Write - refer to README for global variable descriptions
%   cmd_list    : RW
%   Fs          : R 
%   dur         : R 
%   FEATURES    : R 
%
% Inputs:
%   word_number = the position of the word to be trained within the command list
%
% Outputs:
%   none (writes to cmd_list)
%
    %
% Authors: David Wernli, Jason Page, Antonia Paris, 
%          Kevin Briggs, Scott Carlson
% George Mason University - Senior Design Project (ECE492/493)
% email: 
% Website: http://www.
% September 2014; Last revision: 07-Nov-2014

%------------- BEGIN CODE --------------
%% Function Header
global cmd_list Fs dur FEATURES speakerObject
hObject = Train_gui();

%% Function Body
speaker_no = speakerName_gui(word_no);
if speaker_no > 0
    audioData =  captureAudio_gui('SPEAK'); %ones(Fs*dur,1);%
    if max(audioData) ~= 0;        

        %?Prompt for user input on whether the signatures for the individual
        %or the whole word should be updated, or none
        
        %update the command list file with the new recording
        cmd_list{word_no}.speaker{speaker_no}.utterances = ...
            [cmd_list{word_no}.speaker{speaker_no}.utterances {audioData}];
        timestamp = datestr(now,'yyyy-mm-dd, HH:MM::SS');
        cmd_list{word_no}.speaker{speaker_no}.recTime = ...
            [cmd_list{word_no}.speaker{speaker_no}.recTime {timestamp}];
        cmd_list{word_no}.trained = 1;        
        saveCMD();
                
        % get the feature vectors for the given signal
        signatures = {};
        for i = 1:length(FEATURES);
            sig = extract(i, audioData);
            signatures = [signatures {sig}];
        end
        
        % update command word's signature
        updateSignature(signatures, word_no, speaker_no)
        
        % setup the window for display of gathered data
        displayTrainingResults(trimData, signatures, hObject)
    else
        msgbox('No Audio recieved. File not saved')
    end
end
%------------- END OF CODE --------------