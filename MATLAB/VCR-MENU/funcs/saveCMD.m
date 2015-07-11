function saveCMD();
%saveCMD Simple function to allow write control for the command list. 
%no other function writes directly to this savefile.
global cmd_list WRITE ActiveFile

if WRITE 
    
    if ActiveFile(1:4) == 'test'        %if we're using a testing file
        load(ActiveFile);
        if exist('cmd_test_list', 'var')
            cmd_test_list = cmd_list;            
            varname = 'cmd_test_list';
        elseif exist('refList', 'var')
            refList = cmd_list;
            varname = 'refList';
        elseif exist('datList', 'var')
            datList = cmd_list;
            varname = 'datList';
        else
            disp('ERROR: File not saved')
        end
    else                                %if this is the live file
        varname = 'cmd_list';
    end
    save(ActiveFile, varname);
    disp([ 'Writing Command List: ' ActiveFile]);

else
    disp('Write to command list disabled');

end