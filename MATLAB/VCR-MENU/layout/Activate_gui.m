function varargout = Activate_gui(varargin)
% ACTIVATE_GUI MATLAB code for Activate_gui.fig
%      ACTIVATE_GUI, by itself, creates a new ACTIVATE_GUI or raises the existing
%      singleton*.
%
%      H = ACTIVATE_GUI returns the handle to a new ACTIVATE_GUI or the handle to
%      the existing singleton*.
%
%      ACTIVATE_GUI('CALLBACK',hObject,eventData,h,...) calls the local
%      function named CALLBACK in ACTIVATE_GUI.M with the given input arguments.
%
%      ACTIVATE_GUI('Property','Value',...) creates a new ACTIVATE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Activate_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Activate_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIh

% Edit the above text to modify the response to help Activate_gui

% Last Modified by GUIDE v2.5 22-Nov-2014 15:31:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Activate_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @Activate_gui_OutputFcn, ...
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


% --- Executes just before Activate_gui is made visible.
function Activate_gui_OpeningFcn(hObject, eventdata, h, varargin)
global version
% This function has no output args, see OutputFcn.
% varargin   command line arguments to Activate_gui (see VARARGIN)
% Choose default command line output for Activate_gui
h.output = hObject;
% Update h structure
guidata(hObject, h);
% UIWAIT makes Activate_gui wait for user response (see UIRESUME)
% uiwait(h.test_window);
makeButtons(hObject, eventdata, h);
%updateNames(hObject, eventdata, h);
set(h.versionText, 'String', ['Version: ' version]);

function updateNames(hObject, eventdata, h)
global cmd_list
len = length(cmd_list);
for i = 1:len
    if cmd_list{i}.trained
        enableTest = 'on';
    else 
        enableTest = 'off';
    end
    set(h.buttons{i}, 'visible','on',...
        'enable', enableTest, 'String', sprintf('Test %s',cmd_list{i}.name));
end

function makeButtons(hObject, eventdata, h)
global cmd_list
len = length(cmd_list);
for i = 1:len
    if i/2 ~= round(i/2)
        hpos = 50;
        vpos = 285 - i*15;
    else
        hpos = 200;
        vpos = 300 - i*15;
    end
    
    if cmd_list{i}.trained
        enableTest = 'on';
    else 
        enableTest = 'off';
    end
    
    h.buttons{i} =  uicontrol('Style','pushbutton','String',['Test: ' cmd_list{i}.name],...
        'Position', [hpos vpos 100 20],...
        'Callback', {@testbutton_Callback, h, i},...
        'enable', enableTest);
end

function testbutton_Callback(hObject, eventdata, h, word_no)
    data = test_data(-1, word_no);
    displayMatchResults(data, h);

% --- Outputs from this function are returned to the command line.
function varargout = Activate_gui_OutputFcn(hObject, eventdata, h) 
% varargout  cell array for returning output args (see VARARGOUT);
% Get default command line output from h structure
varargout{1} = h.output;


% --- Executes on button press in backButton.
function backButton_Callback(hObject, eventdata, h)
delete(h.test_window);


% --- Executes during object deletion, before destroying properties.
function test_window_DeleteFcn(hObject, eventdata, h)
Main();


% --- Executes on button press in testallButton.
function testallButton_Callback(hObject, eventdata, h)
% hObject    handle to testallButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
    data = test_data();
    displayMatchResults(data, h);
