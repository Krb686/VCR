function varargout = Train_gui(varargin)
% TRAIN_GUI MATLAB code for Train_gui.fig
%      TRAIN_GUI, by itself, creates a new TRAIN_GUI or raises the existing
%      singleton*.
%
%      H = TRAIN_GUI returns the handle to a new TRAIN_GUI or the handle to
%      the existing singleton*.
%
%      TRAIN_GUI('CALLBACK',hObject,eventData,h,...) calls the local
%      function named CALLBACK in TRAIN_GUI.M with the given input arguments.
%
%      TRAIN_GUI('Property','Value',...) creates a new TRAIN_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Train_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Train_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIh

% Edit the above text to modify the response to help Train_gui

% Last Modified by GUIDE v2.5 06-Nov-2014 22:59:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Train_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @Train_gui_OutputFcn, ...
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


% --- Executes just before Train_gui is made visible.
function Train_gui_OpeningFcn(hObject, eventdata, h, varargin)
global version
% This function has no output args, see OutputFcn.
% Choose default command line output for Train_gui
h.output = hObject;
% Update h structure
guidata(hObject, h);
% UIWAIT makes Train_gui wait for user response (see UIRESUME)
% uiwait(h.figure1);
%updateNames(hObject, eventdata, h);
makeButtons(hObject, eventdata, h);
set(h.versionText, 'String', ['Version: ' version]);

function updateNames(hObject, eventdata, h)
global cmd_list buttonsLoaded
%delete(h.figure1);
Train_gui();
return;


function makeButtons(hObject, eventdata, h)
global cmd_list buttonsLoaded 
len = length(cmd_list);
len = min(9,len);
buttonsLoaded = len;
for i = 1:len
    vpos = 300 - i*30;
    
    if cmd_list{i}.trained
        enableTest = 'on';
    else 
        enableTest = 'off';
    end
    
    h.tags{i} =  uicontrol('Style','text',... %'Parent', hObject.buttonPanel,...
        'String',[cmd_list{i}.name],...
        'Position', [35 vpos-2 110 20],...
        'HorizontalAlignment','left',...
        'Callback', {@testbutton_Callback, h, i} );
    
    h.trainButtons{i} =  uicontrol('Style','pushbutton',... %'Parent', hObject.buttonPanel,...
        'String',['Train'],...
        'Position', [145 vpos 70 20],...
        'Callback', {@trainbutton_Callback, h, i} );
    
    h.testButtons{i} =  uicontrol('Style','pushbutton',... %'Parent', hObject.buttonPanel,...
        'String',['Test'],...
        'Position', [235 vpos 70 20],...
        'Callback', {@testbutton_Callback, h, i},...
        'enable', enableTest);
    
end


function testbutton_Callback(hObject, eventdata, h, word_no)
    thing = hObject
    data = test_data(-1, word_no);
    if iscell(data)
        displayMatchResults(data, h);
    end
    

    
function trainbutton_Callback(hObject, eventdata, h, word_no)    
    newTraining(word_no);
    updateNames(hObject, eventdata, h);
    
    
% --- Outputs from this function are returned to the command line.
function varargout = Train_gui_OutputFcn(hObject, eventdata, h) 
% varargout  cell array for returning output args (see VARARGOUT);
% Get default command line output from h structure
varargout{1} = h;


% --- Executes on button press in addNewButton.
function addNewButton_Callback(hObject, eventdata, h)
message = 'Please enter the Command Word';
TITLE = 'New Command Word';
newCMD = {nameEntry_gui({message, TITLE, ''})};
if strcmp(newCMD{1}, '')
    disp('No text entered');
    return;
end
 newCommand(newCMD{1});
 makeButtons(hObject, eventdata, h)



% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, h)
delete(h.figure1);
return;


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, h)
Main();
