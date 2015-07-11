function varargout = tune_gui(varargin)
% TUNE_GUI MATLAB code for tune_gui.fig
%      TUNE_GUI, by itself, creates a new TUNE_GUI or raises the existing
%      singleton*.
%
%      H = TUNE_GUI returns the handle to a new TUNE_GUI or the handle to
%      the existing singleton*.
%
%      TUNE_GUI('CALLBACK',hObject,eventData,h,...) calls the local
%      function named CALLBACK in TUNE_GUI.M with the given input arguments.
%
%      TUNE_GUI('Property','Value',...) creates a new TUNE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tune_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tune_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIh

% Edit the above text to modify the response to help tune_gui

% Last Modified by GUIDE v2.5 04-Dec-2014 19:36:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @tune_gui_OpeningFcn, ...
    'gui_OutputFcn',  @tune_gui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before tune_gui is made visible.
function tune_gui_OpeningFcn(hObject, eventdata, h, varargin)
global version ActiveFile
% This function has no output args, see OutputFcn.
% varargin   command line arguments to tune_gui (see VARARGIN)
% Choose default command line output for tune_gui
h.output = hObject;
% Update h structure
guidata(hObject, h);
% UIWAIT makes tune_gui wait for user response (see UIRESUME)
% uiwait(h.figure1);
set(h.figure1, 'Position', [520 410 700 390]);
set(h.versionText, 'String', ['Version: ' version]);
set(h.CurDataSet, 'String', ActiveFile);
setupAdminPanels(h);
set(h.listbox_spk, 'Value', 1);
set_lists(h)
set_cmd_buttons1(h)
%setup the second panel
set_mat_boxes(h);
set_ext_boxes(h);
set_ext_details(h, 1)
set_mat_details(h, 1)

% list = list_cmds();
% set(h.listbox_cmd, 'String', list);
%
% word_no = get(h.listbox_cmd,'Value');
% list = list_speakers(word_no);
% set(h.listbox_spk, 'String', list);
%
% spk_no = get(h.listbox_spk,'Value');
% list = list_utters(word_no, spk_no);
% set(h.listbox_rec, 'String', list);
%

function setupAdminPanels(h)
h.tabpanel = uitabgroup(h.tabpanel1);

% create tab 1 and put the time domain plot
h.htab1 = uitab(h.tabpanel, 'Tag', 'htab1', 'Title', 'Dataset');
set( get(h.Panel1,'children'), 'Parent', h.htab1);
set(h.Panel1, 'visible', 'off');

% create tab 2 and put the elements in. Refer to tune_gui.fig for contents
h.htab2 = uitab(h.tabpanel, 'Tag', 'htab2', 'Title', 'Tuning Parameters');
set( get(h.Panel2,'children'), 'Parent', h.htab2);
%set(h.Panel2, 'visible', 'off');

% create tab 3 and put the elements in.
h.htab3 = uitab(h.tabpanel, 'Tag', 'htab2', 'Title', 'Other');
%set( get(h.Panel3,'children'), 'Parent', h.htab3);
%set(h.Panel3, 'visible', 'off');



%----------------------------------------
%----------------------------------------
%----------------------------------------
function list = list_cmds()
global cmd_list
list = sprintf('');
len = length(cmd_list);
breaker = '#';
for i = 1:len
    if i == len
        breaker = '';
    end
    list = sprintf('%s%s%s', list, cmd_list{i}.name, breaker );
end
list = regexp(list, '#', 'split');

function list = list_speakers(word_no)
global cmd_list
list = sprintf('');
len = 0;
if length(cmd_list) > 0
    len = length(cmd_list{word_no}.speaker);
end
breaker = '#';
for i = 1:len
    if i == len
        breaker = '';
    end
    list = sprintf('%s%s%s', list, cmd_list{word_no}.speaker{i}.name,breaker );
end
list = regexp(list, '#', 'split');

function list = list_utters(word_no, spk_no)
global cmd_list
list = sprintf('');
len = 0;
if length(cmd_list) > 0
    if length(cmd_list{word_no}.speaker) > 0
        len = length(cmd_list{word_no}.speaker{spk_no}.utterances);
    end
end
breaker = '#';
for i = 1:len
    if i == len
        breaker = ' ';
    end
    list = sprintf('%s%s%s', list, cmd_list{word_no}.speaker{spk_no}.recTime{i}, breaker );
end
list = regexp(list, '#', 'split');

function set_cmd_buttons1(h)
global cmd_list
word_no = get(h.listbox_cmd,'Value');
spk_no = get(h.listbox_spk,'Value');

len0 = length(cmd_list);

if len0 == 0            %if there are no words in the list - set the buttons
    set(h.cmd_movedn_but, 'enable', 'off');
    set(h.cmd_moveup_but, 'enable', 'off');
    set(h.cmd_delete_but, 'enable', 'off');
    %set(h.cmd_dupe_but, 'enable', 'off');
    set(h.cmd_reset_but, 'enable', 'off');
    set(h.cmd_resetAll_but, 'enable', 'off');
    set(h.cmd_merge_but, 'enable', 'off');
    %set(h.cmd_clear_but, 'enable', 'off');
    
    set(h.listbox_spk, 'enable', 'off');
    set(h.spk_delete_but, 'enable', 'off');
    set(h.spk_clear_but, 'enable', 'off');
    set(h.spk_reset_but, 'enable', 'off');
    
    set(h.listbox_rec, 'enable', 'off');
    set(h.rec_delete_but, 'enable', 'off');
    set(h.rec_analyze_but, 'enable', 'off');
    set(h.rec_extra_but, 'enable', 'off');
    set(h.rec_play_but, 'enable', 'off');
    set(h.rec_playTrim_but, 'enable', 'off');
    
else                                        %if there are words...
    set(h.cmd_delete_but, 'enable', 'on');
    %set(h.cmd_dupe_but, 'enable', 'on');
    set(h.cmd_reset_but, 'enable', 'on');
    set(h.cmd_resetAll_but, 'enable', 'on');
    set(h.cmd_merge_but, 'enable', 'on');
    %set(h.cmd_clear_but, 'enable', 'on');
    
    len1 = length(cmd_list{word_no}.speaker);   %get the list of speakers for selected word
    
    if len1 > 0                                 %if there are speakers for the current word
        set(h.listbox_spk, 'enable', 'on');
        set(h.spk_delete_but, 'enable', 'on');
        %    set(h.spk_clear_but, 'enable', 'on');
        %    set(h.spk_reset_but, 'enable', 'on');
        
        %check to see if the selected word/speaker has any utterances & set buttons
        len2 = length(cmd_list{word_no}.speaker{spk_no}.utterances);
        if len2 > 0
            set(h.listbox_rec, 'enable', 'on');
            set(h.rec_delete_but, 'enable', 'on');
            set(h.rec_analyze_but, 'enable', 'on');
            set(h.rec_setSig_but, 'enable', 'on');
            set(h.rec_play_but, 'enable', 'on');
            set(h.rec_playTrim_but, 'enable', 'on');
            set(h.cmd_reset_but, 'enable', 'on');            
            set(h.spk_reset_but, 'enable', 'on');
        else
            set(h.listbox_rec, 'enable', 'off');
            set(h.rec_delete_but, 'enable', 'off');
            set(h.rec_analyze_but, 'enable', 'off');
            set(h.rec_setSig_but, 'enable', 'off');
            set(h.rec_play_but, 'enable', 'off');
            set(h.rec_playTrim_but, 'enable', 'off');
            set(h.cmd_reset_but, 'enable', 'off');            
            set(h.spk_reset_but, 'enable', 'off');
        end
        
    else %if the selected word has no speaker objects associated
        set(h.listbox_spk, 'enable', 'off');
        set(h.listbox_rec, 'enable', 'off');
        set(h.spk_delete_but, 'enable', 'off');
        set(h.spk_clear_but, 'enable', 'off');
        set(h.spk_reset_but, 'enable', 'off');
        set(h.rec_delete_but, 'enable', 'off');
        set(h.rec_analyze_but, 'enable', 'off');
        set(h.rec_setSig_but, 'enable', 'off');
        set(h.rec_play_but, 'enable', 'off');
        set(h.rec_playTrim_but, 'enable', 'off');
        set(h.cmd_reset_but, 'enable', 'off');        
        set(h.spk_reset_but, 'enable', 'off');
    end
end

function recalc_signature(handles)
global cmd_list FEATURES
%get selected word from gui
word_no = get(handles.listbox_cmd, 'Value');

%get the list of all utterances in the word / speaker combo
word = cmd_list{word_no};
if length(word.speaker) > 0
    uttList = { word.speaker{spk_no}.utterances{:} };  %add all utterances to the list
    %for each type of extraction (and thus signature)
    %send the utterances with equal weighting to the create signature function
    for k = 1:length(FEATURES)
        signature = create_signature(uttList, k);
        cmd_list{word_no}.signature{k}.value = signature;
        cmd_list{word_no}.signature{k}.name = FEATURES{k}.name;
    end
else
    %if there's no speakers
end
return;

function set_lists(h)
global cmd_list

list = list_cmds();
set(h.listbox_cmd, 'String', list);

wn = get(h.listbox_cmd,'Value'); %returns selected item from listbox_cmd
if length(cmd_list) > 0         %if there are any words in the list
    list = list_speakers(wn);   %get the speakers for the current word
    if get(h.listbox_spk, 'Value') > length(cmd_list{wn}.speaker)   %correct errors with selecting non valid entries
        set(h.listbox_spk, 'String', list, 'Value', 1);
    else
        set(h.listbox_spk, 'String', list);
    end
    
    sn = get(h.listbox_spk,'Value');
    list = list_utters(wn, sn);
    set(h.listbox_rec, 'String', list);
    
    if length(cmd_list{wn}.speaker) == 0
        set(h.listbox_rec, 'String', list, 'Value', 1);
    elseif get(h.listbox_rec, 'Value') > length(cmd_list{wn}.speaker{sn}.utterances)
        set(h.listbox_rec, 'String', list, 'Value', 1);
    end
else
    set(h.listbox_spk, 'String', list);
    set(h.listbox_rec, 'String', list, 'Value', 1);
end
set_cmd_buttons1(h);

%----------------------------------------
%----------------------------------------
%----------------------------------------
function set_ext_boxes(h)
global FEATURES
enableStatus = {'off','off','off','off'};
inUseStatus = {0,0,0,0};
titles = {'','','',''};
for i = 1:length(FEATURES)
    enableStatus{i} = 'on';
    inUseStatus{i} = FEATURES{i}.enable;
    titles{i} = FEATURES{i}.name;
end
set(h.check_ext1, 'enable', enableStatus{1}, 'Value', inUseStatus{1}, 'String', titles{1});
set(h.check_ext2, 'enable', enableStatus{2}, 'Value', inUseStatus{2}, 'String', titles{2});
set(h.check_ext3, 'enable', enableStatus{3}, 'Value', inUseStatus{3}, 'String', titles{3});
set(h.check_ext4, 'enable', enableStatus{4}, 'Value', inUseStatus{4}, 'String', titles{4});
set(h.rad_ext1,   'enable', enableStatus{1}, 'String', '');
set(h.rad_ext2,   'enable', enableStatus{2}, 'String', '');
set(h.rad_ext3,   'enable', enableStatus{3}, 'String', '');
set(h.rad_ext4,   'enable', enableStatus{4}, 'String', '');

function set_mat_boxes(h)
global METHOD
enableStatus = {'off','off','off','off'};
inUseStatus = {0,0,0,0};
titles = {'','','',''};
for i = 1:length(METHOD)
    enableStatus{i} = 'on';
    inUseStatus{i} = METHOD{i}.enable;
    titles{i} = METHOD{i}.name;
end
set(h.check_match1, 'enable', enableStatus{1}, 'Value', inUseStatus{1}, 'String', titles{1});
set(h.check_match2, 'enable', enableStatus{2}, 'Value', inUseStatus{2}, 'String', titles{2});
set(h.check_match3, 'enable', enableStatus{3}, 'Value', inUseStatus{3}, 'String', titles{3});
set(h.check_match4, 'enable', enableStatus{4}, 'Value', inUseStatus{4}, 'String', titles{4});
set(h.rad_match1,   'enable', enableStatus{1}, 'String', '');
set(h.rad_match2,   'enable', enableStatus{2}, 'String', '');
set(h.rad_match3,   'enable', enableStatus{3}, 'String', '');
set(h.rad_match4,   'enable', enableStatus{4}, 'String', '');

function set_ext_details(h, val)
global FEATURES;
set(h.extName, 'String', FEATURES{val}.name);
filterString = ['num: [' num2str(FEATURES{val}.filter.num) ']   den: [' ...
    num2str(FEATURES{val}.filter.den) ']'];
set(h.extFilter, 'String', filterString);

function set_mat_details(h, val)
global METHOD FEATURES;
enableStatus = {'off','off','off','off'};
featList = {'','','',''};
for i = 1:length(FEATURES)
    featList{i} = FEATURES{i}.name;
    if FEATURES{i}.enable == 1
        enableStatus{i} = 'on';
    end
end
set(h.matchName, 'String', METHOD{val}.name);
set(h.matchMethod1,'enable', enableStatus{1} ,'Value', METHOD{val}.features{1}, 'String', featList{1});
set(h.matchMethod2,'enable', enableStatus{2} , 'Value', METHOD{val}.features{1}, 'String', featList{2});
set(h.matchMethod3,'enable', enableStatus{3} , 'Value', METHOD{val}.features{1}, 'String', featList{3});
set(h.matchMethod4,'enable', enableStatus{4} , 'Value', METHOD{val}.features{1}, 'String', featList{4});

%----------------------------------------
%----------------------------------------
%----------------------------------------

% --- Outputs from this function are returned to the command line.
function varargout = tune_gui_OutputFcn(hObject, eventdata, h)
% varargout  cell array for returning output args (see VARARGOUT);
% Get default command line output from h structure
varargout{1} = h.output;


% --- Executes on button press in backButton.
function backButton_Callback(hObject, eventdata, h)
% hObject    handle to backButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
delete(h.figure1);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, h)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
Main();


% --- Executes on button press in rec_delete_but.
function rec_delete_but_Callback(hObject, eventdata, h)
global cmd_list
% hObject    handle to rec_delete_but (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wn = get(h.listbox_cmd,'Value');
sn = get(h.listbox_spk,'Value');
rn = get(h.listbox_rec,'Value');
U = {};
T = {};
%M = {};
for i = 1:length(cmd_list{wn}.speaker{sn}.utterances)
    if i ~= rn
        U = [U cmd_list{wn}.speaker{sn}.utterances{i}];
        T = [T cmd_list{wn}.speaker{sn}.recTime{i}];
        %M = [T cmd_list{wn}.speaker{sn}.mic{i}];
    end
end
cmd_list{wn}.speaker{sn}.utterances = U;
cmd_list{wn}.speaker{sn}.recTime = T;

totalCount = 0;
if length(U) == 0
    for i = 1:length(cmd_list{wn}.speaker)
        totalCount = totalCount + length(cmd_list{wn}.speaker{i}.utterances);
    end
    if totalCount == 0
        cmd_list{wn}.trained = 0;
    end
end

recalc_signature(h);
set_lists(h);
saveCMD();


% --- Executes on button press in rec_analyze_but.
function rec_analyze_but_Callback(hObject, eventdata, handles)
global cmd_list
%get currently selected word / speaker / recording
word_no = get(handles.listbox_cmd, 'Value');
spk_no = get(handles.listbox_spk, 'Value');
sel = get(handles.listbox_rec, 'Value');

%get the audio from the command list
audioData = cmd_list{word_no}.speaker{spk_no}.utterances{sel};

test_single(audioData);

% --- Executes on button press in rec_setSig_but.
function rec_setSig_but_Callback(hObject, eventdata, handles)
global FEATURES cmd_list
%get the current selected word & speaker
word_no = get(handles.listbox_cmd, 'Value');
spk_no = get(handles.listbox_spk, 'Value');
%get the selection
sel = get(handles.listbox_rec, 'Value');

%use the selection to retrieve the audioData
audioData = cmd_list{word_no}.speaker{spk_no}.utterances{sel};

%for each extraction type specified
for i = 1:length(FEATURES)
    %get signature for selected word
    tempSig = extract(i, audioData);
    %set current word's signature to the value returned
    cmd_list{word_no}.signature{i} = tempSig;
end
saveCMD();
msgbox('Signature updated');


% --- Executes on selection change in listbox_rec.
function listbox_rec_Callback(hObject, eventdata, h)
% hObject    handle to listbox_rec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns listbox_rec contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_rec
set_lists(h);

% --- Executes during object creation, after setting all properties.
function listbox_rec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_rec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_spk.
function listbox_spk_Callback(hObject, eventdata, h)
% hObject    handle to listbox_spk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns listbox_spk contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_spk
set_lists(h);


% --- Executes during object creation, after setting all properties.
function listbox_spk_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_spk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in spk_reset_but.
function spk_reset_but_Callback(hObject, eventdata, handles)
global cmd_list FEATURES

%get selected word from gui
word_no = get(handles.listbox_cmd, 'Value');
%get selected speaker from gui
spk_no = get(handles.listbox_spk, 'Value');

%get the list of all utterances in the word / speaker combo
word = cmd_list{word_no};
uttList = { word.speaker{spk_no}.utterances{:} };  %add all utterances to the list

%for each type of extraction (and thus signature)
%send the utterances with equal weighting to the create signature function
for k = 1:length(FEATURES)
    signature = create_signature(uttList, k);
    cmd_list{word_no}.signature{k}.value = signature;
    cmd_list{word_no}.signature{k}.name = FEATURES{k}.name;
end

%set the trained flag to indicate a signature now exists
cmd_list{word_no}.trained = 1;

%save the returned signature into the cmd_list
saveCMD();
msgbox(['Signature for ' cmd_list{word_no}.name ...
    ', speaker: ' cmd_list{word_no}.speaker{spk_no}.name ...
    ', updated based on the average of ' num2str(length(uttList)) ' samples.'], ...
    'Signature UPDATED');


% --- Executes on button press in spk_clear_but.
function spk_clear_but_Callback(hObject, eventdata, handles)
% hObject    handle to spk_clear_but (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in spk_delete_but.
function spk_delete_but_Callback(hObject, eventdata, h)
global cmd_list
% hObject    handle to rec_delete_but (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wn = get(h.listbox_cmd,'Value');
sn = get(h.listbox_spk,'Value');
S = {};
for i = 1:length(cmd_list{wn}.speaker)
    if i ~= sn
        S = [S cmd_list{wn}.speaker{i}];
    end
end
cmd_list{wn}.speaker = S;

totalCount = 0;
if length(S) == 0
    for i = 1:length(cmd_list{wn}.speaker)
        totalCount = totalCount + length(cmd_list{wn}.speaker{i}.utterances);
    end
    if totalCount == 0
        cmd_list{wn}.trained = 0;
    end
end
recalc_signature(h);
set_lists(h);
saveCMD();

% --- Executes on selection change in listbox_cmd.
function listbox_cmd_Callback(hObject, eventdata, h)
% hObject    handle to listbox_cmd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%contents = cellstr(get(hObject,'String')); %returns listbox_cmd contents as cell array
set_lists(h)


% --- Executes during object creation, after setting all properties.
function listbox_cmd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_cmd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cmd_delete_but.
function cmd_delete_but_Callback(hObject, eventdata, h)
global cmd_list
% hObject    handle to rec_delete_but (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wn = get(h.listbox_cmd,'Value');
C = {};
for i = 1:length(cmd_list)
    if i ~= wn
        C = [C cmd_list{i}];
    end
end
cmd_list = C;

if length(C) == 0
    set(hObject, 'enable', 'off');
end

set(h.listbox_cmd,'Value',1);
set_lists(h);
saveCMD();


% --- Executes on button press in cmd_dupe_but.
function cmd_dupe_but_Callback(hObject, eventdata, handles)
% hObject    handle to cmd_dupe_but (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cmd_clear_but.
function cmd_clear_but_Callback(hObject, eventdata, handles)
% hObject    handle to cmd_clear_but (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cmd_reset_but.
function cmd_reset_but_Callback(hObject, eventdata, handles)
global cmd_list FEATURES

%get selected word from gui
word_no = get(handles.listbox_cmd, 'Value');

%setup a list variable
uttList = {};
%get the list of all utterances in the word
word = cmd_list{word_no};
for i = 1:length(word.speaker)     %for each speaker present in the word
    word.speaker{i}.utterances{:};
    uttList = {uttList{:} word.speaker{i}.utterances{:} };  %add all utterances to the list
end

%for each type of extraction (and thus signature)
%send the utterances with equal weighting to the create signature function

for k = 1:length(FEATURES)
    if length(uttList) > 0
        signature = create_signature(uttList, k);
    else
        signature = 0;        
    end
    cmd_list{word_no}.signature{k}.value = signature;
    cmd_list{word_no}.signature{k}.name = FEATURES{k}.name;
end

%save the returned signature into the cmd_list
cmd_list{word_no}.trained = 1;
saveCMD();
msgbox(['Signature for ' cmd_list{word_no}.name ...
    ' updated based on the average of ' num2str(length(uttList)) ' samples.'], ...
    'Signature UPDATED');


% --- Executes on button press in cmd_merge_but.
function cmd_merge_but_Callback(hObject, eventdata, handles)
global testRuns cmd_list ActiveFile
%msgbox('Select the file to load the current word list into.');
fileList = {'Live System' ' --- TEST RUNS ---' testRuns.refData{:} testRuns.testData{:}};
Selection  = FileSelect_gui(fileList);
if Selection > 2       %as long as the separator is not selected
    tempList = cmd_list;
    tempList2 = cmd_list;
    currFile = ActiveFile;
    filename = ['testing/' fileList{Selection}];
    set(handles.listbox_spk, 'Value', 1);
    loadCMD(filename);
    
    for i = 1:length(cmd_list)
        %check if the words have the same name
        for x = 1:length(tempList)
            if strcmp(cmd_list{i}.name, tempList{x}.name)
                for j = 1:length(cmd_list{i}.speaker)
                    for y = 1:length(tempList{x}.speaker)
                        if strcmp(cmd_list{i}.speaker{j}.name,tempList{x}.speaker{y}.name)
                            cmd_list{i}.speaker{j}.utterances = ...
                                {cmd_list{i}.speaker{j}.utterances{:} tempList{x}.speaker{y}.utterances{:}};
                            cmd_list{i}.speaker{j}.recTime = ...
                                {cmd_list{i}.speaker{j}.recTime{:} tempList{x}.speaker{y}.recTime{:}};
                            %cmd_list{i}.speaker{j}.mics = ...
                            %    {cmd_list{i}.speaker{j}.mics tempList{x}.speaker{y}.mics};
                        else
                            cmd_list{i}.speaker = ...
                                {cmd_list{i}.speaker{:} tempList{x}.speaker{y}};
                        end
                    end
                end
                %remove the word from the temp list upon success
                %tempList2(x) = [];
            end
        end
    end
%cmd_list = {cmd_list{:} tempList2{:}};

%save the changes
    tempList = cmd_list;
    loadCMD(currFile);
    cmd_list = tempList;
    %saveCMD();

    tune_gui();
else
    disp('Invalid file selection');
end


% --- Executes on button press in cmd_resetAll_but.
function cmd_resetAll_but_Callback(hObject, eventdata, handles)
global cmd_list
for i = 1:length(cmd_list)
    set(handles.listbox_cmd, 'Value', i);
    cmd_reset_but_Callback(hObject, eventdata, handles);
end



% --- Executes on button press in load_data_but.
function load_data_but_Callback(hObject, eventdata, handles)
%get file list from globals
global testRuns
fileList = {'Live System' ' --- TEST RUNS ---' testRuns.refData{:} testRuns.testData{:}};
Selection  = FileSelect_gui(fileList);
if Selection ~= 2       %as long as the separator is not selected
    if Selection == 1
        filename = 'vars/LiveSystem';
    else
        filename = ['testing/' fileList{Selection}]
    end
    set(handles.listbox_spk, 'Value', 1);
    loadCMD(filename);
    tune_gui();
else
    disp('Invalid file selection');
end


% --- Executes on button press in rec_playTrim_but.
function rec_playTrim_but_Callback(hObject, eventdata, h)
global cmd_list Fs
% hObject    handle to rec_delete_but (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wn = get(h.listbox_cmd,'Value');
sn = get(h.listbox_spk,'Value');
rn = get(h.listbox_rec,'Value');
audio = trimAudio( cmd_list{wn}.speaker{sn}.utterances{rn} );
if length(audio) > 0
    playback = audioplayer(audio,Fs);
    playblocking(playback);
end


% --- Executes on button press in check_ext1.
function check_ext1_Callback(hObject, eventdata, handles)
% hObject    handle to check_ext1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of check_ext1
status = get(hObject,'Value')
FEATURE{1}.enable = status;

% --- Executes on button press in check_ext2.
function check_ext2_Callback(hObject, eventdata, handles)
% hObject    handle to check_ext2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of check_ext2
status = get(hObject,'Value')
FEATURE{2}.enable = status;

% --- Executes on button press in check_ext3.
function check_ext3_Callback(hObject, eventdata, handles)
% hObject    handle to check_ext3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of check_ext3
status = get(hObject,'Value')
FEATURE{3}.enable = status;


% --- Executes on button press in check_ext4.
function check_ext4_Callback(hObject, eventdata, handles)
% hObject    handle to check_ext4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of check_ext4
status = get(hObject,'Value')
FEATURE{4}.enable = status;


% --- Executes on button press in check_match1.
function check_match1_Callback(hObject, eventdata, handles)
% hObject    handle to check_match1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of check_match1
status = get(hObject,'Value')
METHOD{1}.enable = status;

% --- Executes on button press in check_match2.
function check_match2_Callback(hObject, eventdata, handles)
% hObject    handle to check_match2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of check_match2
status = get(hObject,'Value')
METHOD{2}.enable = status;

% --- Executes on button press in check_match3.
function check_match3_Callback(hObject, eventdata, handles)
% hObject    handle to check_match3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of check_match3
status = get(hObject,'Value')
METHOD{3}.enable = status;


% --- Executes on button press in check_match4.
function check_match4_Callback(hObject, eventdata, handles)
% hObject    handle to check_match4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of check_match4
status = get(hObject,'Value')
METHOD{4}.enable = status;



function extName_Callback(hObject, eventdata, handles)
% hObject    handle to extName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of extName as text
%        str2double(get(hObject,'String')) returns contents of extName as a double


% --- Executes during object creation, after setting all properties.
function extName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to extName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in saveExtBut.
function saveExtBut_Callback(hObject, eventdata, handles)
% hObject    handle to saveExtBut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function extFilter_Callback(hObject, eventdata, handles)
% hObject    handle to extFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of extFilter as text
%        str2double(get(hObject,'String')) returns contents of extFilter as a double


% --- Executes during object creation, after setting all properties.
function extFilter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to extFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function extCode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to extCode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in saveMatBut.
function saveMatBut_Callback(hObject, eventdata, handles)
% hObject    handle to saveMatBut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function matchName_Callback(hObject, eventdata, handles)
% hObject    handle to matchName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of matchName as text
%        str2double(get(hObject,'String')) returns contents of matchName as a double


% --- Executes during object creation, after setting all properties.
function matchName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to matchName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in matchMethod1.
function matchMethod1_Callback(hObject, eventdata, handles)
% hObject    handle to matchMethod1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of matchMethod1


% --- Executes on button press in matchMethod2.
function matchMethod2_Callback(hObject, eventdata, handles)
% hObject    handle to matchMethod2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of matchMethod2


% --- Executes on button press in matchMethod3.
function matchMethod3_Callback(hObject, eventdata, handles)
% hObject    handle to matchMethod3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of matchMethod3


% --- Executes on button press in matchMethod4.
function matchMethod4_Callback(hObject, eventdata, handles)
% hObject    handle to matchMethod4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of matchMethod4


% --- Executes when selected object is changed in ExtrPanel.
function ExtrPanel_SelectionChangeFcn(hObject, eventdata, h)
% hObject    handle to the selected object in ExtrPanel
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
value = get(eventdata.NewValue,'UserData');
set_ext_details(h, value);

% --- Executes when selected object is changed in matchPanel.
function matchPanel_SelectionChangeFcn(hObject, eventdata, h)
% hObject    handle to the selected object in matchPanel
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
value = get(eventdata.NewValue,'UserData');
set_mat_details(h, value)


% --- Executes on button press in rec_play_but.
function rec_play_but_Callback(hObject, eventdata, h)
% hObject    handle to rec_play_but (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cmd_list Fs
% hObject    handle to rec_delete_but (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wn = get(h.listbox_cmd,'Value');
sn = get(h.listbox_spk,'Value');
rn = get(h.listbox_rec,'Value');
audio =  cmd_list{wn}.speaker{sn}.utterances{rn} ;
if length(audio) > 0
    playback = audioplayer(audio,Fs);
    playblocking(playback);
end


