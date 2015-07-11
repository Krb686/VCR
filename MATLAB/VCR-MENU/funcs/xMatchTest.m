function resultsTable = xMatchTest(fileName1, fileName2, extractMethod, matchMethod)
%FUNCTION_NAME - One line description of what the function or script performs (H1 line)
%Optional file header info (to give more details about the function than in the H1 line)
%Optional file header info (to give more details about the function than in the H1 line)
%Optional file header info (to give more details about the function than in the H1 line)
%
% Syntax:  [output1,output2] = function_name(input1,input2,input3)
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
    %
% Authors: David Wernli, Jason Page, Antonia Paris, 
%          Kevin Briggs, Scott Carlson
% George Mason University - Senior Design Project (ECE492/493)
% email: 
% Website: http://www.
% September 2014; Last revision: 23-Oct-2014

%------------- BEGIN CODE --------------
%% Function Header
global FEATURES 

%% Function Body
%load file 1
%save the variable to a local
load(['testing/' fileName1]);
list1 = cmd_test_list;

%load file 2
%save the variable to a local
load(['testing/' fileName2]);
list2 = cmd_test_list;

%check to see if they have the same number of words
tableData = {};
colheaders = {};
rowheaders = {};

for i = 1:length(list1) %for each word in list 1
    for j = 1:length(list1{i}.speaker) %for each speaker in list 1, word i
        for k = 1:length(list1{i}.speaker{j}.utterances )%for each utterance in list 1, word i, speaker j
            name1 = [list1{i}.name '_' list1{i}.speaker{j}.name '_' num2str(k)];   %name = 1_word_spk_k
            %get signature for 1_wordi.spkj.uttk
            sig1 = extract(extractMethod, list1{i}.speaker{j}.utterances{k});
            colData = {};    %reset the column data
            rowheaders   = {};   %reset the row headers
            
            for x = 1:length(list2) %for each word in list 1
                for y = 1:length(list2{x}.speaker) %for each speaker in list 1, word i
                    for z = 1:length(list2{x}.speaker{y}.utterances )%for each utterance in list 1, word i, speaker j
                        name2 = [list2{x}.name '_' list2{x}.speaker{y}.name '_' num2str(z)];   %name = 1_word_spk_k
                        rowheaders   = {rowheaders{:}   name2};         %add column header to the list
                        %get signature for 2_wordx_spky_uttz
                        sig2 = extract(extractMethod, list2{x}.speaker{y}.utterances{z});
                        
                        matchRes = rate_match(matchMethod, sig1, sig2);    %ratematch(#1.i.j.k, #2.x.y.z)
                        celldata = matchRes.value;       %cell = column, row
                        colData = {colData{:} celldata}; %concatenate column data
                        
                    end
                end
            end
            
            tableData = vertcat(tableData, colData);%add column data to the table
            colheaders   = {colheaders{:}   name1};         %add column header to the list
        end
    end
end

% tableText = [headers ;];
% numRows = length(tableData{1});
% for row = 1:numRows
%     for col = 1:length(tableData)
%         tableText = {tableText{:} tableData{col}{row}};
%     end
%     tableText = {tableText{:} ;};
% end
% cell2table(tableText)

width = length(colheaders)*100+50;
colSizes = {ones(1,length(colheaders))*100};

window = Results_gui();
window = guidata(window);
position = get(window.figure1, 'position');
position = [5 5 (position(3) - 10) (position(4) - 10) ];

%set(hObject, 'position', [100 100 710 410], 'name', 'RESULTS');
window.t1 = uitable(...
    'Position', position,...
    'Data', tableData,... 
    'ColumnName', rowheaders,...
    'RowName',colheaders,...
    'ColumnWidth', 'auto'...
    );

%format as table
T = cell2table(tableData, 'RowNames', colheaders, 'VariableNames', rowheaders);
%save table as excel file
filename = ['testing/' colheaders{1} '-vs-' rowheaders{1} '.xlsx'];
writetable(T, filename);

%------------- END OF CODE --------------