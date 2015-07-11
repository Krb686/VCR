function test_single(audioData)
%test_single - tests a given audio signal against the current live signature bank for a match
%
% Globals : Read/Write - refer to README for global variable descriptions
%
% Inputs:
%   audioData - audio signal for comparison
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
global FEATURES PLOT
    
%% Function Body

%test this data... using existing functions
testResults = test_data(audioData);


if iscell(testResults)
    if (PLOT)
        window = Results_gui();
        window = guidata(window);
        displayMatchResults(testResults, window);
    
        % get the feature vectors for the given signal
        signature = {};
        for i = 1:length(FEATURES);
            sig = extract(i, audioData);
            signature = [signature {sig}];
        end

        %setup the training data display (does not retrain system)
        audioData = trimAudio(audioData);
        if (PLOT)
            displayTrainingResults(audioData, signature, window)
        end
    end
end

%------------- END OF CODE --------------