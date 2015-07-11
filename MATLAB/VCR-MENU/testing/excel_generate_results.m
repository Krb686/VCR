%% To find options for ref File and dat file, copy and run these lines
global testRuns
refFile_options = testRuns.refData
datFile_options = testRuns.testData

refFile_options = {'R_Toni_Num' 'R_Toni_Com' 'R_Toni_LR' 'R_Nilo_Num' ...
                   'R_Nilo_Com' 'R_Nilo_LR' 'R_Scott_Num' 'R_Scott_Com'...
                   'R_Scott_LR' 'R_Jason_Num' 'R_Jason_Com' 'R_Jason_LR'...
                   'R_Dave_Num' 'R_Dave_Com' 'R_Dave_LR'};

datFile_options = {'D_Toni_Num' 'D_Toni_Com' 'D_Toni_LR' 'D_Nilo_Num'...
                   'D_Nilo_Com' 'D_Nilo_LR' 'D_Scott_Num' 'D_Scott_Com'...
                   'D_Scott_LR' 'D_Jason_Num' 'D_Jason_Com' 'D_Jason_LR'...
                   'D_Dave_Num' 'D_Dave_Com' 'D_Dave_LR'};

%%
%set the first test up
global FEATURES
FEATURES{1}.filter.num = [1 -.96]
FEATURES{2}.filter.num = [1 -.96]
FEATURES{3}.filter.num = [1 -.96]

for i = 1:length(refFile_options)
    refFile = refFile_options{i}
    datFile = datFile_options{i}
    saveFileSuffix = 'SpkDependent'
    excel_create_detailed_workbook(refFile, datFile, saveFileSuffix)
end

%%
% Second Test
refFile_options = {'R_Toni_Num' 'R_Nilo_Num' 'R_Scott_Num'...
                   'R_Jason_Num' 'R_Dave_Num'};

datFile_options = {'D_Toni_Num' 'D_Nilo_Num' 'D_Scott_Num'...
                   'D_Jason_Num' 'D_Dave_Num'};

for i = 1:length(refFile_options)
    for j = 1:length(refFile_options)
        if i ~= j
            refFile = refFile_options{i}
            datFile = datFile_options{j}
            saveFileSuffix = 'SpkInd'
            excel_create_detailed_workbook(refFile, datFile, saveFileSuffix)
        end
    end
end
               