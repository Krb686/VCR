function saveTEST()
%saveTEST Simple function to allow write control for the testing data. 
%no other function writes directly to this savefile.
global commandLists testRuns WRITE

if WRITE
    save('vars/testing', 'commandLists', 'testRuns' );
    disp('Writing Testing Data');
else
    disp('Write to testing data disabled');
end