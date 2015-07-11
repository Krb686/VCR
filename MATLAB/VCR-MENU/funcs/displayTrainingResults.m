function displayTrainingResults(audioData, signatures, hObject)

global Fs dur

position = get(hObject.tabpanel1, 'position');
position(1) = position(3) - 382;
position(3) = position(3) - 387;
hObject.trainPanel = uitabgroup(hObject.tabpanel1, 'Tag', 'trainPanel',...
    'units', 'pixels', 'position', position);

try
    set(hObject.trainPanel,'visible','on');
    set(hObject.testPanel,'visible','off');
end

% create tab 1 and put the time domain plot
hObject.htab1 = uitab(hObject.trainPanel, 'Title', 'Time Signal');
hObject.results1 = axes('parent', hObject.htab1);
hObject.results1 = plot(dur/Fs:dur/Fs:dur*length(audioData)/Fs, audioData);
title('Time domain signal');

% create tab 2 and put the LPC in here
hObject.htab2 = uitab(hObject.trainPanel, 'Title', 'LPC');
hObject.results2 = axes('parent', hObject.htab2);
%hObject.results2 = stem(1:length(signatures{1}.value),signatures{1}.value); title(signatures{1}.name);

% create tab 3 and put the LPCC data here
hObject.htab3 = uitab(hObject.trainPanel, 'Title', 'LPCC');
hObject.results3 = axes('parent', hObject.htab3);
hObject.results3 = stem(1:length(signatures{2}.value),signatures{2}.value); title(signatures{2}.name);

% show the first tab
hObject.trainPanel.SelectedChild = 1;
       