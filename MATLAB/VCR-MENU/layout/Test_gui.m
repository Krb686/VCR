function varargout = Test_gui(varargin)
% TEST_GUI MATLAB code for Test_gui.fig
%      TEST_GUI, by itself, creates a new TEST_GUI or raises the existing
%      singleton*.
%
%      H = TEST_GUI returns the handle to a new TEST_GUI or the handle to
%      the existing singleton*.
%
%      TEST_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST_GUI.M with the given input arguments.
%
%      TEST_GUI('Property','Value',...) creates a new TEST_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Test_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Test_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Test_gui

% Last Modified by GUIDE v2.5 06-Dec-2014 00:15:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Test_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @Test_gui_OutputFcn, ...
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


% --- Executes just before Test_gui is made visible.
function Test_gui_OpeningFcn(hObject, eventdata, handles, varargin)
global commandLists testRuns dataList testOptions FEATURES METHOD
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Test_gui (see VARARGIN)

% Choose default command line output for Test_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% setup all the variables
listOptions = '';
    for i = 1:length(commandLists)
        listOptions = sprintf('%s%s#', listOptions, commandLists{i}.name );
    end
    listOptions = sprintf('%s---', listOptions);
    listOptions = regexp(listOptions, '#', 'split');

testOptions = '';
    for i = 1:length(testRuns.refData)
        testOptions = sprintf('%s%s#', testOptions, testRuns.refData{i});
    end
    for i = 1:length(testRuns.testData)
        testOptions = sprintf('%s%s#', testOptions, testRuns.testData{i});
    end
    testOptions = testOptions(1:end-1);       %trim the last separator character
    if length(testOptions) == 0, testOptions = '---'; end   %make sure we show something
    testOptions = regexp(testOptions, '#', 'split');        %split the string on '#' chars
    dataList = { testRuns.refData{:} testRuns.testData{:} };

extractionOptions = '';
    for i = 1:length(FEATURES)
        extractionOptions = sprintf('%s%s#', extractionOptions, FEATURES{i}.name);
    end
    extractionOptions = extractionOptions(1:end-1);
    if length(extractionOptions) == 0, extractionOptions = '---'; end
    extractionOptions = regexp(extractionOptions, '#', 'split');
    
matchOptions = '';
    for i = 1:length(METHOD)
        matchOptions = sprintf('%s%s#', matchOptions, METHOD{i}.name);
    end
    matchOptions = matchOptions(1:end-1);
    if length(matchOptions) == 0, matchOptions = '---'; end
    matchOptions = regexp(matchOptions, '#', 'split');

    
%place variable results into the popup menus
set(handles.cre_list_pop, 'String', listOptions);
set(handles.xspk_spk1_pop,'String', testOptions);
set(handles.xspk_spk2_pop,'String', testOptions);
set(handles.sig_bank_pop, 'String', testOptions);
set(handles.fil_bank_pop, 'String', testOptions);
set(handles.s_bank_pop,   'String', testOptions);
set(handles.xspk_ext_pop, 'String', extractionOptions);
set(handles.fil_ext_pop,  'String', extractionOptions);
set(handles.xspk_mat_pop, 'String', matchOptions);
set(handles.fil_mat_pop,  'String', matchOptions);
% UIWAIT makes Test_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

% --- Outputs from this function are returned to the command line.
function varargout = Test_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in xspk_sigDepth_pop.
function xspk_sigDepth_pop_Callback(hObject, eventdata, handles)
% hObject    handle to xspk_sigDepth_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns xspk_sigDepth_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from xspk_sigDepth_pop


% --- Executes during object creation, after setting all properties.
function xspk_sigDepth_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xspk_sigDepth_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in xspk_spk2_pop.
function xspk_spk2_pop_Callback(hObject, eventdata, handles)
% hObject    handle to xspk_spk2_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns xspk_spk2_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from xspk_spk2_pop


% --- Executes during object creation, after setting all properties.
function xspk_spk2_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xspk_spk2_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in xspk_spk1_pop.
function xspk_spk1_pop_Callback(hObject, eventdata, handles)
% hObject    handle to xspk_spk1_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns xspk_spk1_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from xspk_spk1_pop


% --- Executes during object creation, after setting all properties.
function xspk_spk1_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xspk_spk1_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in xspk_testBut.
function xspk_testBut_Callback(hObject, eventdata, handles)
global testOptions
% hObject    handle to xspk_testBut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spkr1 = get(handles.xspk_spk1_pop, 'value');
spkr2 = get(handles.xspk_spk2_pop, 'value');
extract = get(handles.xspk_ext_pop, 'Value'); 
match = get(handles.xspk_mat_pop, 'Value');
xMatchTest(testOptions{spkr1}, testOptions{spkr2}, extract, match);


% --- Executes on button press in sig_testBut.
function sig_testBut_Callback(hObject, eventdata, handles)
% hObject    handle to sig_testBut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in sig_bank_pop.
function sig_bank_pop_Callback(hObject, eventdata, handles)
% hObject    handle to sig_bank_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sig_bank_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sig_bank_pop


% --- Executes during object creation, after setting all properties.
function sig_bank_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sig_bank_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sig_cmd_pop.
function sig_cmd_pop_Callback(hObject, eventdata, handles)
% hObject    handle to sig_cmd_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sig_cmd_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sig_cmd_pop


% --- Executes during object creation, after setting all properties.
function sig_cmd_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sig_cmd_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sig_num_pop.
function sig_num_pop_Callback(hObject, eventdata, handles)
% hObject    handle to sig_num_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sig_num_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sig_num_pop


% --- Executes during object creation, after setting all properties.
function sig_num_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sig_num_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fil_bank_pop.
function fil_bank_pop_Callback(hObject, eventdata, handles)
% hObject    handle to fil_bank_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fil_bank_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fil_bank_pop


% --- Executes during object creation, after setting all properties.
function fil_bank_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fil_bank_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fil_filterText_Callback(hObject, eventdata, handles)
% hObject    handle to fil_filterText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fil_filterText as text
%        str2double(get(hObject,'String')) returns contents of fil_filterText as a double


% --- Executes during object creation, after setting all properties.
function fil_filterText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fil_filterText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fil_ext_pop.
function fil_ext_pop_Callback(hObject, eventdata, handles)
% hObject    handle to fil_ext_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fil_ext_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fil_ext_pop


% --- Executes during object creation, after setting all properties.
function fil_ext_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fil_ext_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fil_mat_pop.
function fil_mat_pop_Callback(hObject, eventdata, handles)
% hObject    handle to fil_mat_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fil_mat_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fil_mat_pop


% --- Executes during object creation, after setting all properties.
function fil_mat_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fil_mat_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in fil_testBut.
function fil_testBut_Callback(hObject, eventdata, handles)
% hObject    handle to fil_testBut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in s_cmd_pop.
function s_cmd_pop_Callback(hObject, eventdata, handles)
global testOptions
% hObject    handle to s_bank_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns s_bank_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from s_bank_pop
if length(testOptions) < 1
    return
else
    %get the list of utterances
    pos = get(handles.s_bank_pop, 'Value');
    filename = testOptions{pos};
    load(['testing/' filename]);
    curWord = get(hObject, 'Value');
    curWord = cmd_test_list{curWord};
    setList = '';    
    for i = 1:length(curWord.speaker{1}.utterances)
        setList = sprintf('%s%s#', setList, curWord.speaker{1}.recTime{i});
    end
    setList = sprintf('%s---', setList);
    setList = regexp(setList, '#', 'split');
    
    %get the speaker name for the set
    spkName = cmd_test_list{1}.speaker{1}.name;
    
    set(handles.s_utt_pop, 'String', setList, 'enable', 'on');
    set(handles.s_testBut, 'enable', 'on');
end


% --- Executes during object creation, after setting all properties.
function s_cmd_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to s_cmd_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in s_spk_pop.
function s_spk_pop_Callback(hObject, eventdata, handles)
% hObject    handle to s_spk_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns s_spk_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from s_spk_pop


% --- Executes during object creation, after setting all properties.
function s_spk_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to s_spk_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in s_utt_pop.
function s_utt_pop_Callback(hObject, eventdata, handles)
% hObject    handle to s_utt_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns s_utt_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from s_utt_pop


% --- Executes during object creation, after setting all properties.
function s_utt_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to s_utt_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in s_testBut.
function s_testBut_Callback(hObject, eventdata, handles)
global dataList
%get the word list
filename = dataList{ get(handles.s_bank_pop, 'Value') };
filename = ['testing/' filename];
load(filename);
list = cmd_test_list;

%get currently selected word / speaker / recording
word_no = get(handles.s_cmd_pop, 'Value');
spk_no = get(handles.s_spk_pop, 'Value');
sel = get(handles.s_utt_pop, 'Value');

%get the audio from the command list
audioData = list{word_no}.speaker{spk_no}.utterances{sel};

test_single(audioData);


% --- Executes on button press in cre_testBut.
function cre_testBut_Callback(hObject, eventdata, handles) 
global commandLists
% hObject    handle to cre_testBut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
listNo = get(handles.cre_list_pop, 'Value');
if listNo > length(commandLists) 
    disp('Invalid Selection');
else
    retFile = test_setup(commandLists{listNo}.contents);
end



% --- Executes on selection change in cre_list_pop.
function cre_list_pop_Callback(hObject, eventdata, handles)
% hObject    handle to cre_list_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cre_list_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cre_list_pop


% --- Executes during object creation, after setting all properties.
function cre_list_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cre_list_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cre_utts_pop.
function cre_utts_pop_Callback(hObject, eventdata, handles)
global uttPerWord
% Hints: contents = cellstr(get(hObject,'String')) returns cre_utts_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cre_utts_pop
uttPerWord = get(hObject, 'Value');


% --- Executes during object creation, after setting all properties.
function cre_utts_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cre_utts_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cre_spk_text_Callback(hObject, eventdata, handles)
% hObject    handle to cre_spk_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cre_spk_text as text
%        str2double(get(hObject,'String')) returns contents of cre_spk_text as a double


% --- Executes during object creation, after setting all properties.
function cre_spk_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cre_spk_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in s_bank_pop.
function s_bank_pop_Callback(hObject, eventdata, handles)
global dataList
% hObject    handle to s_bank_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns s_bank_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from s_bank_pop
if length(dataList) < 1
    return
else
    %get the list of words in this testRun
    pos = get(hObject, 'Value');
    filename = dataList{pos};
    load(['testing/' filename]);
    setList = '';
    for i = 1:length(cmd_test_list)
        setList = sprintf('%s%s#', setList, cmd_test_list{i}.name);
    end
    setList = sprintf('%s---', setList);
    setList = regexp(setList, '#', 'split');
    
    %get the speaker name for the set
    spkName = cmd_test_list{1}.speaker{1}.name;
    
    set(handles.s_cmd_pop, 'String', setList, 'enable', 'on');
    set(handles.s_spk_pop, 'String', spkName, 'enable', 'on');
    set(handles.s_utt_pop, 'String', ' - - ', 'enable', 'off');
    set(handles.s_testBut, 'enable', 'off');
end


% --- Executes during object creation, after setting all properties.
function s_bank_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to s_bank_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_data_but.
function load_data_but_Callback(hObject, eventdata, handles)
%get file list from globals
global dataList 
fileList = {'Live System' ' --- TEST RUNS ---' dataList{:}};
Selection  = FileSelect_gui(fileList);
if Selection ~= 2       %as long as the separator is not selected
    if Selection == 1
        filename = 'vars/LiveSystem';
    else
        filename = ['testing/' fileList{Selection}];
    end
    loadCMD(filename);
    Test_gui();
else
    disp('Invalid file selection');
end


% --- Executes on selection change in xspk_ext_pop.
function xspk_ext_pop_Callback(hObject, eventdata, handles)
% hObject    handle to xspk_ext_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns xspk_ext_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from xspk_ext_pop


% --- Executes during object creation, after setting all properties.
function xspk_ext_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xspk_ext_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in xspk_mat_pop.
function xspk_mat_pop_Callback(hObject, eventdata, handles)
% hObject    handle to xspk_mat_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns xspk_mat_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from xspk_mat_pop


% --- Executes during object creation, after setting all properties.
function xspk_mat_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xspk_mat_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
global uttPerWord
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uttPerWord = 1;
% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in make_excel_but.
function make_excel_but_Callback(hObject, eventdata, handles)
excel_create_detailed_workbook();
