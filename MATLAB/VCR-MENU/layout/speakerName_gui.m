function varargout = speakerName_gui(varargin)
% SPEAKERNAME_GUI MATLAB code for speakerName_gui.fig
%      SPEAKERNAME_GUI, by itself, creates a new SPEAKERNAME_GUI or raises the existing
%      singleton*.
%
%      H = SPEAKERNAME_GUI returns the handle to a new SPEAKERNAME_GUI or the handle to
%      the existing singleton*.
%
%      SPEAKERNAME_GUI('CALLBACK',hObject,eventData,h,...) calls the local
%      function named CALLBACK in SPEAKERNAME_GUI.M with the given input arguments.
%
%      SPEAKERNAME_GUI('Property','Value',...) creates a new SPEAKERNAME_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before speakerName_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to speakerName_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIh

% Edit the above text to modify the response to help speakerName_gui

% Last Modified by GUIDE v2.5 07-Nov-2014 00:54:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @speakerName_gui_OpeningFcn, ...
    'gui_OutputFcn',  @speakerName_gui_OutputFcn, ...
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


% --- Executes just before speakerName_gui is made visible.
function speakerName_gui_OpeningFcn(hObject, eventdata, h, varargin)
% This function has no output args, see OutputFcn.
% varargin   command line arguments to speakerName_gui (see VARARGIN)
% Choose default command line output for speakerName_gui
h.output = hObject;
% Update h structure
guidata(hObject, h);
% UIWAIT makes speakerName_gui wait for user response (see UIRESUME)
global varg
varg = varargin{:};
global cmd_list;
list = sprintf('Select User#');
speakers = cmd_list{varargin{1}}.speaker;
len = length(speakers);
for i = 1:len
    list = sprintf('%s%s#', list, speakers{i}.name );
end
list = sprintf('%sAdd New Speaker', list);
list = regexp(list, '#', 'split');
set(h.popupmenu1,'String', list)
name = cmd_list{varargin{1}}.name;
title = sprintf('%s: Training', name);
set(h.figure1, 'name', title);
uiwait(h.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = speakerName_gui_OutputFcn(hObject, eventdata, h)
% varargout  cell array for returning output args (see VARARGOUT);
% Get default command line output from h structure
global varg
global cmd_list
if isequal(get(h.name_field, 'visible'), 'on')
    varargout{1} = length(cmd_list{varg}.speaker);
    %get(h.text1, 'String');
else
    output = get(h.popupmenu1, 'Value') - 1;
    varargout{1} = output;
end
delete(hObject);



function name_field_Callback(hObject, eventdata, h)
global cmd_list speakerObject varg;
pos = length(cmd_list{varg}.speaker) + 1;
cmd_list{varg}.speaker{pos} = speakerObject;
cmd_list{varg}.speaker{pos}.name = get(h.name_field, 'String');
saveCMD();
h.output = pos;
cancelButton_Callback(hObject, eventdata, h);


% --- Executes during object creation, after setting all properties.
function name_field_CreateFcn(hObject, eventdata, h)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, h)
cancelButton_Callback(hObject, eventdata, h)

% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, h)
figure1_CloseRequestFcn(hObject, eventdata, h)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, h)
contents = cellstr(get(h.popupmenu1,'String'));
input = get(h.popupmenu1,'Value');
if input == length(contents)
    set(h.name_field, 'visible', 'on');
    set(h.popupmenu1, 'visible', 'off');
    set(h.okButton, 'enable', 'on');
elseif input ~= 1
    h.output = input - 1;    %set the output of the 'window' to the speaker ID
    set(h.okButton, 'enable', 'on');
end



% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, h)
% h    empty - h not created until after all CreateFcns called
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, h)
uiresume(h.figure1);
% Hint: delete(hObject) closes the figure
