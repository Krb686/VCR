function testCase = test_data(audioData, word_no, speaker_no)
%test_data Tests the given (or can obtain) audio for best match. Uses all algorithms and will return a testCase object for manipulation or display
%When given no input arguments, the function will gather a new audio sample
%using the gui interface for doing so.
%When only given the audio data (or no inputs), the system will run a test
%of the obtained audio against the entire system.
%
% Globals : Read/Write - refer to README for global variable descriptions
%
% Inputs:
%   audioData   = array of time domain audio signal sample points
%   word_no     = INT; cmd_list{word_no} to be tested against, can be omitted
%   speaker_no  = INT; cmd_list{word_no}.speaker{speaker_no} to be tested against
%
% Outputs:
%   testCase = testcaseObject; refer to README for object structure
%
% References:
%
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
%bring in globals
global cmd_list FEATURES METHOD signatureObject PLOT

%Enter optional argument control and persistent variables here
if nargin < 3           %if we only got 2 arguments or less as inputs
    speaker_no = 0;
end
if nargin < 2           %if we only got 1 argument as input
    word_no = 0;
end
if nargin < 1           %if we only got 1 argument as input
    %we need data to test
    audioData =  captureAudio_gui('Speak'); %ones(Fs*dur,1);%
end

if audioData == -1
    %allows user to call with a specific word in mind, but no gathered data
    %yet at the time of function call.
    audioData =  captureAudio_gui('Speak'); %ones(Fs*dur,1);%
end


%% Function Body
if max(audioData) <= 0
    testCase = 0
    return;
end;
% get the feature vectors for the given signal
no_cmds = length(cmd_list);     %number of commands in the list
signatures = {};    %variable to hold the returned signatures
results = [];       %variable to hold the results from each match score
result_array = [];

% get the match results for each method against each word
for i = 1:length(FEATURES);
    if FEATURES{i}.enable == 0
        signatures = [signatures {signatureObject}];
        continue; %skip this step for any non-enabled feature extraction methods
    else
        sig = extract(i, audioData);
        signatures = [signatures {sig}];
    end    
    
    for j = 1:length(METHOD)
        if METHOD{j}.enable == 0
            %if the match method is totally disabled.            
            continue; %skip this step for any non-enabled feature extraction methods
        end
        if METHOD{j}.features{i} == 0
            % if the current match method is disabled for this feature type.
            %disp(['SKIPPING: ' METHOD{j}.name ' for ' FEATURES{i}.name ' signatures'])
            %disp(' ')  
            continue;
        end
        
        %test the signatures against the existing signatures for all commands
        %result_array{i}{j} = [];
        
        if word_no > 0 %if we're only matching to one specific word
            result = rate_match(j, signatures{i}, cmd_list{word_no}.signature{i});
            values(i,j,1)= result.value;
            if values(i,j,1) > 0 %as long as the match type is defined
                result_array(i,j,1) = results(i,j,1);
            end
        else
            for k = 1:no_cmds
                %disp(['Matching: ' cmd_list{k}.name ' via ' FEATURES{i}.name ' :: ' METHOD{j}.name ])
                if max(cmd_list{k}.signature{i}.value) ~= [0]
                    result = rate_match(j, signatures{i}, cmd_list{k}.signature{i});
                    values(i,j,k)= result.value;
                    %results array will be structured as a 3D array,
                    %   each word is N x M, where N is # of extraction methods,
                    %   M is # of matching methods,
                    %   position i,j in the matrix is the ith(of N) extraction
                    %   method, paired with the jth(of M) matchin method
                    if values(i,j,k) > 0 %as long as the match type is defined
                        result_array(i,j,k) = values(i,j,k);
                    end
                end
            end            
        end
    end
end

%compare the results from each extraction method
%d={'Extraction','Match Method','Word','Match Value','Margin'};
d1={'','','','',''};
d2={'','','',''};

%create a list of the results from smallest to largest
%using sort - sorting in the third dimension - meaning the results
%will be a matrix where the first N x M set is the best match for
%each extraction/match pair - the matrix would say [3 3; 2 3] if
%the third word was the best match for three ext/match pairs
[value, index] = sort(result_array,3);

dims = size(index);     %size of NxMxZ index as [N M Z]

%make a list, as long as the number of words list - this will hold the sum
%of each word's position for each match type
weight = zeros(1,dims(3));


for i = 1:dims(1);          %for each feature extraction type
    for j = 1:dims(2)       %and for each method
        for k = 1:dims(3)   %and for each word in the list
            if  (METHOD{j}.features{i} ~= 0) && (FEATURES{i}.enable ~= 0)
            %if the match that brought us here is allowed
                word = index(i,j,k);   %the word ranked k-th in the i,j extract/match method
                %global factor
                factor = 0.5;
                weight(word) = weight(word) + (k^factor);
            end
        end
        if (PLOT)
            %------ setup for display - not used for actual calculations
            %calculate a match 'margin' from the best match to the second best match
            m1 = index(i,j,1);  %the first best match word
            v1 = values(i,j,m1);
            if no_cmds > 1
                m2 = index(i,j,2);  %the second best match word
                v2 = values(i,j,m2);
                margin{i}{j} = abs(v1-v2);
            else
                margin{i}{j} = -1;
            end

            if (v1 ~= -1 & METHOD{j}.features{i} ~= 0)
                dataRow1 = { FEATURES{i}.name, ...
                    METHOD{j}.name, ...
                    cmd_list{m1}.name, ...
                    v1, ...
                    margin{i}{j} };
                % Define the data for the table
                d1 = vertcat(d1, dataRow1);

                for k = 1:dims(3)
                    dataRow2 = { FEATURES{i}.name, ...
                        METHOD{j}.name, ...
                        cmd_list{index(i,j,k)}.name, ...
                        values(i,j, index(i,j,k) )  };
                    % Define the data for the table
                    d2 = vertcat(d2, dataRow2);
                end
            end
        end %end PLOT bracket
    end
end

%------------ WEIGHTING ------------
%from weight, find the best hypothesis based on summed rankings
global score guess;
[score, guess] = sort(weight);
confidence = 3/score(1);    %5 is a perfect score...

testCase = {d1,d2};
global confidenceReport 
confidenceReport = {cmd_list{guess(1)}.name num2str(confidence)};

title = 'Best Guess';
message = ['   The word spoken in assumed to be ' cmd_list{guess(1)}.name ...
    ' with confidence of ' num2str(confidence)];
title = 'Best Guess';

disp(message)
%disp(['   guess: ' num2str(guess)])
%disp(['   score: ' num2str(score)])
disp(' ')
%msgbox(message, title);

return;

if (PLOT)
    hObject = Train_gui;
    displayMatchResults(d1, d2, hObject);
end
%------------- END OF CODE --------------
%% Pseudocode