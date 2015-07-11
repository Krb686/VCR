function updateSignature(signatures, word_no, speaker_no)
%FUNCTION_NAME - One line description of what the function or script performs (H1 line)
%Optional file header info (to give more details about the function than in the H1 line)
%
% Globals : Read/Write - refer to README for global variable descriptions
%
% Inputs:
%   input1 - Description
%   input2 - Description
%   input3 - Description
%
% Outputs:
%   output1 - Description
%   output2 - Description
%
% References:
%
%
% Authors: David Wernli, Jason Page, Antonia Paris,
%          Kevin Briggs, Scott Carlson
% George Mason University - Senior Design Project (ECE492/493)
% email:
% Website: http://www.
% November 2014; Last revision: 23-Oct-2014

%------------- BEGIN CODE --------------
%% Function Header

global cmd_list FEATURES weighting

%% Function Body

% figure out how to weight the new signature
prev = 0;
no_spkr = length(cmd_list{word_no}.speaker);
for i = 1:no_spkr
    prev = prev + length(cmd_list{word_no}.speaker{i}.utterances);
end
if prev > weighting
    prev = weighting;
end
    
% for each type of feature/signature array we are storing
for i = 1:length(FEATURES); %update all signatures in use
    % verify signatures are the same type
    if ~isequal(cmd_list{word_no}.signature{i}.name, signatures{i}.name)
        disp(' Data error: Input and Word signatures are not of the same type.');
    else
        % perform a weighted average of the vectors
        % weight the existing signature as calculated above
        newsig = cmd_list{word_no}.signature{i}.value * prev;
        newsig = newsig + signatures{i}.value;
        newsig = newsig / (prev +1);
        % update the command list
        cmd_list{word_no}.signature{i}.value = newsig;
    end
    
    % verify signatures are the same type
    if ~isequal(cmd_list{word_no}.speaker{speaker_no}.signature{i}.name, signatures{i}.name)
        disp(' Data error: Input and Speaker signatures are not of the same type.');
    else
        % update the speaker specific array
        prev_spk = length(cmd_list{word_no}.speaker{speaker_no}.utterances);
        newsig = cmd_list{word_no}.speaker{speaker_no}.signature{i}.value * prev_spk;
        newsig = newsig + signatures{i}.value;
        newsig = newsig / (prev_spk +1);
    end
end

saveCMD();

%------------- END OF CODE --------------

