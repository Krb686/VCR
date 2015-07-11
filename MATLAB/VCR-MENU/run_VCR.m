function run_VCR()
%Turn off warning about tab group functionality deprication.
warning off MATLAB:uitabgroup:OldVersion
warning off MATLAB:uitabgroup:OldVersion

%change the local folder & add the necessary subfolders to the matlab path
thisdir = fileparts( mfilename( 'fullpath' ) );
cd(thisdir);
addpath('funcs');
addpath('layout');
%addpath('add-in\GUILayout-v1p17');

%load parameters
global Fs nChannels nBits dur LF HF Tw thresh num_feats version ...
       weighting WRITE uttPerWord PLOT
load('vars/parameters');

%load reference data
global emptyWord speakerObject signatureObject testcaseObject ...
       resultsObject METHOD FEATURES
load('vars/reference');

%load command list
global cmd_list ActiveFile
load('vars/list');

%load testing data
global commandLists testRuns
load('vars/testing');


%reload the Live command list
loadCMD('vars/LiveSystem');
%call the main program GUI interface
Main();