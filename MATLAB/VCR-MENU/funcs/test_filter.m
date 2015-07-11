function test_filter(testBank, filter, ext, match)
%test_filter - runs a comparison of the given filter against the current
%implementation
%
% Globals : Read/Write - refer to README for global variable descriptions
%
% Inputs:
%   testBank - testbank filename to use as signatures
%   filter   - filter description, text similar to '[1 1],[1 0]'
%               uses transfer notation, so above is (s + 1)/(s + 0)
%   ext      - extraction method to be used, integer
%   match    - match method to be used, integer
%
% Outputs:
%   none
%
% References:
%
    %
% Authors: David Wernli, Jason Page, Antonia Paris, 
%          Kevin Briggs, Scott Carlson
% George Mason University - Senior Design Project (ECE492/493)
% email: 
% Website: http://www.
% November 2014; Last revision: 23-Nov-2014

%------------- BEGIN CODE --------------
%% Function Header
global FEATURES METHOD
    
%% Function Body

%take test bank, filter, extraction, and match methods as input from user

%get an utterance - or allow testing of a full dataset
%ask user if we want to use a live utterance or a pre-recorded
%if live, get the audiodata
%if pre-recorded, popup a window asking user to select 
    %--- dataset -> word -> speaker -> utterance
    % or just a dataset & then do that.
    

%with given single audio data, run the test case with the currently implemented filter
%save the resulting table to a local table variable
    %table is - each row is the word.name, best match, 2nd best, ...
    %table header is filter used description

%set the filter of the specified extraction method to the text given by user

%run the test case again with the new filter in place
%save the resulting table to a local table variable
    %table is - each row is the word.name, best match, 2nd best, ...
    %table header is filter used description

%present the results to the user in the results window - figure(1)
    %tables are to be side by side in the window, each 400 x 400 px
    %present filter on left, trial filter on right
    %button on bottom right allows user to click and update the in-use
    % filter to the one tested if the restults look good.
    %button also allows exporting of results data to excel?
