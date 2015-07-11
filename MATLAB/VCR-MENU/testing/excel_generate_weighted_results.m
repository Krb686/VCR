global confidenceReport factor FEATURES cmd_list METHOD
%added the above variable to the test_data function to get some extra data
%from it in the hopes of writing it to an excel file...

refFile_options = testRuns.refData;
datFile_options = testRuns.testData;

refFile_options = {'R_Toni_Num' 'R_Toni_Com' 'R_Toni_LR' 'R_Nilo_Num' ...
                   'R_Nilo_Com' 'R_Nilo_LR' 'R_Scott_Num' 'R_Scott_Com'...
                   'R_Scott_LR' 'R_Jason_Num' 'R_Jason_Com' 'R_Jason_LR'...
                   'R_Dave_Num' 'R_Dave_Com' 'R_Dave_LR'};

datFile_options = {'D_Toni_Num' 'D_Toni_Com' 'D_Toni_LR' 'D_Nilo_Num'...
                   'D_Nilo_Com' 'D_Nilo_LR' 'D_Scott_Num' 'D_Scott_Com'...
                   'D_Scott_LR' 'D_Jason_Num' 'D_Jason_Com' 'D_Jason_LR'...
                   'D_Dave_Num' 'D_Dave_Com' 'D_Dave_LR'};

refFile_options = {'R_Dave_Num' 'R_Dave_Com' 'R_Dave_LR'};
%% Only the data we want to use in this test...
%refFile_options = {'R_Scott_Num'}; %'R_Jason_Com' 'R_Jason_LR'
%datFile_options = {'D_Dave_Num'}; %'D_Jason_Com' 'D_Jason_LR'

load('vars/reference')

% export ranges
r_refFile  = 'B1:B1';        % signature reference filename
r_datFile  = 'B2:B2';        % tested data filename
r_speaker  = 'J1:J1';        % speaker name (for utterances if different)
r_datetime = 'J2:J2';        % date/time stamp for tracking
r_descrip  = {'A6:A6'   'H6:H6'   'O6:O6'   'V6:V6'  };        % description of the test
r_results  = {'A8:C107' 'H8:J107' 'O8:Q107' 'V8:X107'};      % where the results go on each sheet

path = fileparts( mfilename( 'fullpath' ) ); %current path of this matlab file
filename  = [path '/ExcelData/WeightingTemplate.xlsx']
sheetName = 'Confidence Test';
datetime = datestr(now,'yyyy-mm-dd, HH:MM:SS');

%%               
%setup the excel file
sheetNames = refFile_options;

% excel = actxserver('excel.application');
% Excel.Visible = -1;                     % Open excel without displaying a window
% wkbk = excel.Workbooks.Open(filename) % open the excel file, full path need to be mentioned or else excel will pick it from most recently opened files.
% %SHS = wkbk.Sheets;                      %sheets of template Workbook
% for iNames = 1:length(sheetNames)
%     SH = wkbk.Worksheets.Item('Confidence Test');   % Choose desired sheet
%     invoke(SH,'Copy',SH);                   % Copies the active page
%     SH = wkbk.Worksheets.Item('Confidence Test (2)');
%     SH.Name = sheetNames{iNames};
% end
% SH = wkbk.Worksheets.Item('Confidence Test');
% % Save and close the workbook. Exit the matlab linked excel instance.
% wkbk.Save;                              % save the changes
% wkbk.Close;                             % close the workbook
% excel.Quit;


%% set the test parameters
METHOD{3}.enable = 1;
METHOD{1}.features{1} = 0;
factor = 0.5;
description  = 'No LPC/Cov (k^0.5)'; 

for iFile = 1:length(refFile_options)
    %set as the active file in the system
    refFile = refFile_options{iFile}
    loadCMD(['testing/' refFile]);
    
    spot = 0;
    
    sheetName = sheetNames{iFile};
    
    for iDFile = 1:length(refFile_options)
        datFile = datFile_options{iDFile};
        %get the datafile in...
        load(['testing/' datFile]); %loads variable datList
        
        if or(~strcmp(datFile_options{iDFile}((length(datFile_options{iDFile})-2):end), ...
                refFile_options{iFile }((length(refFile_options{iFile})-2):end)),  ...
                strcmp(datList{1}.speaker{1}.name, cmd_list{1}.speaker{1}.name))
            disp(['skipping ' datFile_options{iDFile} ' FOR ' sheetNames{iFile} ])
            continue
        else
            spot = spot +1;
        end
        %set the variables to placehold
        data = repmat({' '}, [100 3]);
        %set the dataFile we'll be using        

        disp(['putting  ' datFile_options{iDFile} ' onto ' sheetNames{iFile} ' in spot ' num2str(spot)])
        
        %for each utterance in the test data
        for iWord = 1:length(datList)
            for iUtt = 1:length(datList{iWord}.speaker{1}.utterances)
                %test the utterance against the current system
                test_data( datList{iWord}.speaker{1}.utterances{iUtt} );
                %store it in the results array
                data((iWord-1)*10 + iUtt, 1) = {datList{iWord}.name};
                data((iWord-1)*10 + iUtt, 2) = {confidenceReport{1}};
                data((iWord-1)*10 + iUtt, 3) = {confidenceReport{2}};
            end
        end

        speaker = datList{iWord}.speaker{1}.name;
        %write the data to excel

        % Write the reference signature filename
                DATA    = {  refFile };
                xlRange =  r_refFile ;
                xlswrite(filename, DATA, sheetName, xlRange)
            % Write the test data filename
            %    DATA    = {  datFile };
            %    xlRange =  r_datFile ;
            %    xlswrite(filename, DATA, sheetName, xlRange)
            % Write the speaker
                DATA    = {  speaker };
                xlRange =  r_speaker ;
                xlswrite(filename, DATA, sheetName, xlRange)
            % Write the timestamp
                DATA    = {  datetime };
                xlRange =  r_datetime ;
                xlswrite(filename, DATA, sheetName, xlRange)
            % Write the test description
                description = datList{iWord}.speaker{1}.name;
                DATA    = {  description };                                        
                xlRange =  r_descrip{spot};
                xlswrite(filename, DATA, sheetName, xlRange)
            % Write the test data
                DATA    =   data ;                
                xlRange =  r_results{spot} ;
                xlswrite(filename, DATA, sheetName, xlRange)
    end
end