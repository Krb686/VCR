function loadCMD(filename)
global ActiveFile cmd_list

disp(['loading ' filename])

%update the local active file with the file to be loaded
ActiveFile = filename;

%load the file specified
load(filename);

%check to see if this was a testing file
if filename(1:4) == 'test'
    %set the test list to the active list
    if exist('cmd_test_list', 'var')
        cmd_list = cmd_test_list;
    elseif exist('refList', 'var')
        cmd_list = refList;
    elseif exist('datList', 'var')
        cmd_list = datList;
    else
        disp('Data not found. Load aborted')
    end
end

%save the mess to the list variable, for use in future loads
save('vars/list', 'ActiveFile', 'cmd_list');