function excel_create_detailed_workbook(varargin)
%%Declare Globals
global FEATURES METHOD testRuns
nargin
%breakup varargin
%varargin = {refFile, datFile, saveFileSuffix}
if nargin < 3
    saveFileSuffix = '';
else
    saveFileSuffix = varargin{3}
end

%% Setup the variable spaces for use in the excel file
%Named Ranges
r_refFile = 'B1:D1';        % signature reference filename
r_datFile = 'B2:D2';        % tested data filename
r_speaker = 'J1:K1';        % speaker name (for utterances if different)
r_datetime = 'J2:K2';       % date/time stamp for tracking
r_extMeth = 'G1:H1';        % extraction method display (changes on each sheet)
r_matMeth = 'G2:H2';        % match method display (changes on each sheet)
r_refWords = 'B5:K5';       % list of words in the reference file
r_datWords = 'A6:A105';     % list of utterance names in the test data file
r_results = 'B6:K105';      % where the results go on each sheet
r_sheetNames = 'B5:K5';     % used on summary page only

%% Get the files to compare from the user

%breakup varargin
%varargin = {refFile, datFile, saveFileSuffix}
if nargin < 2
    testOptions = '';
        for i = 1:length(testRuns.refData)
            testOptions = sprintf('%s%s#', testOptions, testRuns.refData{i});
        end
        testOptions = testOptions(1:end-1);       %trim the last separator character
        if length(testOptions) == 0, testOptions = '---'; end   %make sure we show something
        testOptions = regexp(testOptions, '#', 'split');        %split the string on '#' chars
        fileList = {'Select Reference File' ' --- REFERNECE RUNS ---' testOptions{:}};
        Selection  = FileSelect_gui(fileList);
        if Selection ~= 2       %as long as the separator is not selected
            if Selection == 1
                %
            else
                refFile = ['testing/' fileList{Selection}];
            end
            clear('cmd_test_list');
            load(refFile);
            if exist('cmd_test_list','var');    refList = cmd_test_list; clear('cmd_test_list');   end
        else
            disp('Invalid file selection');
        end


    testOptions = '';
        for i = 1:length(testRuns.testData)
            testOptions = sprintf('%s%s#', testOptions, testRuns.testData{i});
        end
        testOptions = testOptions(1:end-1);       %trim the last separator character
        if isempty(testOptions), testOptions = '---'; end   %make sure we show something
        testOptions = regexp(testOptions, '#', 'split');        %split the string on '#' chars
            fileList = {'Select Reference File' ' --- REFERNECE RUNS ---' testOptions{:}};
        Selection  = FileSelect_gui(fileList);
        if Selection ~= 2       %as long as the separator is not selected
            if Selection == 1
                %
            else
                datFile = ['testing/' fileList{Selection}];
            end
            load(datFile);
            if exist('cmd_test_list','var');    datList = cmd_test_list; clear('cmd_test_list');   end
        else
            disp('Invalid file selection');
            return;
        end
else
    clear('cmd_test_list');
    refFile = ['testing/' varargin{1}]
    load(refFile);
    if exist('cmd_test_list','var');    refList = cmd_test_list; clear('cmd_test_list');   end
    datFile = ['testing/' varargin{2}]
    load(datFile);
    if exist('cmd_test_list','var');    datList = cmd_test_list; clear('cmd_test_list');   end
end
disp('Processing... Please wait')

%% Setup variables used throughout process
datetime = datestr(now,'yyyy-mm-dd, HH:MM:SS');
% figure out the names of each sheet
sheetNames = {};
XMPairs = {};       %extraction / match pairs
for iFeat = 1:length(FEATURES);
    if FEATURES{iFeat}.enable == 0
        continue; %skip this step for any non-enabled feature extraction methods
    end
        
    for jMethod = 1:length(METHOD)
        if METHOD{jMethod}.enable == 0
            %if the match method is totally disabled.            
            continue; %skip this step for any non-enabled feature extraction methods
        elseif METHOD{jMethod}.features{iFeat} == 0
            % if the current match method is disabled for this feature type.
            continue;
        end
        extMeth = [FEATURES{iFeat}.name];
        matMeth = [METHOD{jMethod}.name];
        sheetName = [extMeth ' - ' matMeth];
        sheetNames = {sheetNames{:} sheetName};
        XMPairs = {XMPairs{:} [iFeat jMethod]};
        
    end
end 

%% Setup the excel file 
filename = [refFile(9:end) '--' datFile(9:end) saveFileSuffix '.xlsx'];    %'testdata.xlsx';             %filename for the new excel sheet
path = fileparts( mfilename( 'fullpath' ) ); %current path of this matlab file
copyfile('testing\ExcelData\TestOutputFormatted.xlsx', [path '\ExcelData\' filename]);  %copies the template file to the new file

% Using the COM connection of matlab - open excel and edit the sheets within the workbook
excel = actxserver('excel.application');
Excel.Visible = -1;                     % Open excel without displaying a window
wkbk = excel.Workbooks.Open([path '/ExcelData/' filename]) % open the excel file, full path need to be mentioned or else excel will pick it from most recently opened files.
%SHS = wkbk.Sheets;                      %sheets of template Workbook
for iNames = 1:length(sheetNames)
    SH = wkbk.Worksheets.Item('Detail 1');   % Choose desired sheet
    invoke(SH,'Copy',SH);                   % Copies the active page
    SH = wkbk.Worksheets.Item('Detail 1 (2)');
    SH.Name = sheetNames{iNames};
end
SH = wkbk.Worksheets.Item('Detail 1'); 
% Save and close the workbook. Exit the matlab linked excel instance.
wkbk.Save;                              % save the changes
wkbk.Close;                             % close the workbook
excel.Quit;                             % close excel

%% Set up the variables used for all sheets 

% from the provided files, extract the names of the words in each 
speaker = refList{1}.speaker{1}.name;
A = {' '};
refWords = repmat(A,[1  10]);   % creates an array of space characters to hold the place in the array
datWords = repmat(A,[100 1]);

%% Populate the sheets
% setup the placeholder variables
filename = ['testing/ExcelData/' filename];
results = repmat(A, [100 10]);       %This will be the data which goes into the spreadsheet, spaces are used for excel formatting issues
%for each extraction/match pair
for xm = 1:length(XMPairs)
    disp(['    Calculating...' XMPairs{xm}])
    
    for iRef = 1:length(refList)   % for each word (refList was loaded from the refFile)
        % get reference signature
        refSig = extract(XMPairs{xm}(1), refList{iRef}.speaker{1}.utterances{1} );
        % set up the word list
        refWords(iRef) = {refList{iRef}.name};
        
        for iTestWord = 1:length(datList)
            for jData = 1:length(datList{iTestWord}.speaker{1}.utterances)  % for each utterance
                % set up the word list
                datWords((iTestWord-1)*10 + jData) = {datList{iTestWord}.name};
                % get utterance signature
                uttAudio = datList{iTestWord}.speaker{1}.utterances{jData};
                uttSig = extract(XMPairs{xm}(1), uttAudio);
                % get the raw match score            
                score = rate_match(XMPairs{xm}(2), refSig, uttSig);
                %disp(['M:' num2str(score.method) ' V:' num2str(score.value) ' -- W:' num2str(iTestWord)])
                % store that score in the table at row = (word# - 1)*10 + j && col = word#
                results((iTestWord-1)*10 + jData, iRef) = {score.value(1)};
            end
        end
    end
    
    disp('    Calculations Complete. Writing excel file...')
    % Write the data to the excel sheet
    % Write the reference signature filename
        DATA    = {  refFile(9:end) };
        xlRange =  r_refFile ;
        xlswrite(filename, DATA, sheetNames{xm}, xlRange)
    % Write the test data filename
        DATA    = {  datFile(9:end) };
        xlRange =  r_datFile ;
        xlswrite(filename, DATA, sheetNames{xm}, xlRange)
    % Write the speaker
        DATA    = {  speaker };
        xlRange =  r_speaker ;
        xlswrite(filename, DATA, sheetNames{xm}, xlRange)
    % Write the timestamp
        DATA    = {  datetime };
        xlRange =  r_datetime ;
        xlswrite(filename, DATA, sheetNames{xm}, xlRange)
    % Write the extraction method
        DATA    = {  extMeth };
        xlRange =  r_extMeth ;
        xlswrite(filename, DATA, sheetNames{xm}, xlRange)
    % Write the match method
        DATA    = {  matMeth };
        xlRange =  r_matMeth ;
        xlswrite(filename, DATA, sheetNames{xm}, xlRange)
    % Write the reference words column headers
        DATA    =   refWords ;
        xlRange =  r_refWords ;
        xlswrite(filename, DATA, sheetNames{xm}, xlRange)
    % Write the utterance row headers
        DATA    =   datWords ;
        xlRange =  r_datWords ;
        xlswrite(filename, DATA, sheetNames{xm}, xlRange)
    % Write the results table
        DATA    =    results ;
        xlRange =  r_results ;
        xlswrite(filename, DATA, sheetNames{xm}, xlRange)

    disp(['Extraction / Match pair # ' num2str(xm) ' of ' num2str(length(XMPairs)) ' complete'])
end
disp('    Writing Summary page...')
% Write the summary page
    DATA    =    sheetNames ;
    xlRange =  r_sheetNames ;
    xlswrite(filename, DATA, 'Summary', xlRange)
% Write the reference signature filename
    DATA    = {  refFile(9:end) };
    xlRange =  r_refFile ;
    xlswrite(filename, DATA, 'Summary', xlRange)
% Write the test data filename
    DATA    = {  datFile(9:end) };
    xlRange =  r_datFile ;
    xlswrite(filename, DATA, 'Summary', xlRange)
% Write the speaker
    DATA    = {  speaker };
    xlRange =  r_speaker ;
    xlswrite(filename, DATA, 'Summary', xlRange)
% Write the timestamp
    DATA    = {  datetime };
    xlRange =  r_datetime ;
    xlswrite(filename, DATA, 'Summary', xlRange)
    
disp('COMPLETE')