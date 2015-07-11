function filename = test_setup(wordList)
%test_setup - Obtains a full testing dataset. Used for system tuning.
%Optional file header info (to give more details about the function than in the H1 line)
%
% Globals : Read/Write - refer to README for global variable descriptions
%   uttPerWord  : R
%   emptyWord   : R
%
% Inputs:
%   wordList    = the list of words to record
%   
% Outputs:
%   filename    = string of the file saved for reference/use
%
% References:
%
    %
% Authors: David Wernli, Jason Page, Antonia Paris, 
%          Kevin Briggs, Scott Carlson
% George Mason University - Senior Design Project (ECE492/493)
% email: 
% Website: http://www.
% November 2014; Last revision: 20-Nov-2014

%------------- BEGIN CODE --------------
%% Function Header
global uttPerWord emptyWord speakerObject FEATURES testRuns
persistent iteration;   %variable to ensure we aren't writing over other tests in the same session
    
%% Function Body

%set up an empty command list
cmd_test_list = {};

%get speaker name
message = 'Enter the filename to save the data under (use "DEFAULT" for autonaming) (existing files will be overwritten without warning)';
title = 'File Name';
defaultText = 'DEFAULT';
filename = nameEntry_gui({message, title, defaultText})

%get speaker name
message = 'Is this a [R]eference file or [D]ata file?';
title = 'File type';
defaultText = 'ENTER D or R only'
filetype = nameEntry_gui({message, title, defaultText});

%get speaker name
message = 'Please enter the name of the speaker for this training run';
title = 'Speaker Name';
defaultText = 'Speaker Name'
spkrName = nameEntry_gui({message, title, defaultText});
if strcmp(spkrName, defaultText)
    disp('No text entered');
    return;
end



%get mic in use
message = 'Provide a name for the microphone in use';
title = 'Microphone Tag';
defaultText = 'Mic Name'
micName = nameEntry_gui({message, title, defaultText});

for   i = 1:length(wordList)
    %setup new word object
    wordObject = emptyWord;
    wordObject.speaker{1} = speakerObject;
    wordObject.speaker{1}.name = spkrName;
    wordObject.name = wordList{i};
    cmd_test_list{i} = wordObject;
end

%for each word in the list
for  k = 1:uttPerWord     %for each utterance required
    for  i = 1:length(cmd_test_list)
        %get word name from specified list
        audioData =  captureAudio_gui(cmd_test_list{i}.name);
        cmd_test_list{i}.speaker{1}.utterances{k} = audioData;
        %get utterances
        %create a name for the utterance
        timestamp = datestr(now,'yyyy-mm-dd, HH:MM::SS');
        cmd_test_list{i}.speaker{1}.recTime = ...
            [cmd_test_list{i}.speaker{1}.recTime {timestamp}];
        %save the mic name with the utterance.
        cmd_test_list{i}.speaker{1}.mics = ...
            [cmd_test_list{i}.speaker{1}.mics {micName}];
    end    
end

%make a filename if one was not already created by the user
% if strcomp(filename,'DEFAULT')
%     timestamp = datestr(now,'mm-dd@HH-MM-SS');
%     filename = [spkrName '_' timestamp];
% end

%save the new file in the testing directory
if filetype == 'R'
    refList = cmd_test_list;
    save(['testing/' filename], 'refList');
    testRuns.refData = {testRuns.refData{:} filename};
elseif filetype == 'D'
    datList = cmd_test_list;
    save(['testing/' filename], 'datList');
    testRuns.testData = {testRuns.testData{:} filename};
end

%save the list of test parameters
saveTEST();

%------------- END OF CODE --------------