function displayMatchResults(testData, hObject)

hObject.testPanel = uitabgroup(hObject.tabpanel1, 'Tag', 'testPanel');
drawnow;

hObject.htab1 = uitab(hObject.testPanel, 'Title', 'Results', 'Tag', 'htab1','Position', [0 0 378 330]);

try
    %turn off the training results if displayed.
    set(hObject.trainPanel,'visible','off');
    set(hObject.testPanel,'visible','on');
end

% Column names and column format
columnname = {'Extraction','Match Method','Word','Match Value', 'Margin'};
columnformat = {'char','char','char','char','char'};

% Create the uitable
hObject.t1 = uitable('Parent', hObject.htab1, ...
            'Position', [0 0 378 300],...
            'Data', testData{1},... 
            'ColumnName', columnname,...
            'ColumnFormat', columnformat,...
            'RowName',[],...
            'ColumnWidth', {80 80 75 80 55});



%set up the second tab
hObject.htab2 = uitab(hObject.testPanel, 'Title', 'Detailed', 'Tag', 'htab1');
% add contents
columnname = {'Extraction','Match Method','Compared','Match Value'};
columnformat = {'char','char','char','char'};
hObject.t2 = uitable('Parent', hObject.htab2, ...
            'Position', [0 0 378 300],...
            'Data', testData{2},... 
            'ColumnName', columnname,...
            'ColumnFormat', columnformat,...
            'RowName',[],...
            'ColumnWidth', {80 80 75 80 });
        
        
hObject.testPanel.SelectedChild = 1;