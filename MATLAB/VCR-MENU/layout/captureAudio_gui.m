function varargout = captureAudio_gui(varargin)
% CAPTUREAUDIO_GUI MATLAB code for captureAudio_gui.fig
%      CAPTUREAUDIO_GUI, by itself, creates a new CAPTUREAUDIO_GUI or raises the existing
%      singleton*.
%
%      H = CAPTUREAUDIO_GUI returns the handle to a new CAPTUREAUDIO_GUI or the handle to
%      the existing singleton*.
%
%      CAPTUREAUDIO_GUI('CALLBACK',hObject,eventData,h,...) calls the local
%      function named CALLBACK in CAPTUREAUDIO_GUI.M with the given input arguments.
%
%      CAPTUREAUDIO_GUI('Property','Value',...) creates a new CAPTUREAUDIO_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before captureAudio_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to captureAudio_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIh

% Edit the above text to modify the response to help captureAudio_gui

% Last Modified by GUIDE v2.5 07-Nov-2014 00:01:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @captureAudio_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @captureAudio_gui_OutputFcn, ...
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


% --- Executes just before captureAudio_gui is made visible.
function captureAudio_gui_OpeningFcn(hObject, eventdata, h, varargin)
global myRecording
myRecording = [0 0 0];
% This function has no output args, see OutputFcn.
% varargin   command line arguments to captureAudio_gui (see VARARGIN)

% Choose default command line output for captureAudio_gui
h.output = hObject;

% Update h structure
guidata(hObject, h);
% UIWAIT makes captureAudio_gui wait for user response (see UIRESUME)
set(h.figure1, 'Name', varargin{1})
uiwait(h.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = captureAudio_gui_OutputFcn(hObject, eventdata, h) 
% varargout  cell array for returning output args (see VARARGOUT);
global myRecording
% Get default command line output from h structure
varargout{1} = myRecording;


% --- Executes on button press in readyButton.
function readyButton_Callback(hObject, eventdata, h)
global myRecording
set(h.readyButton, 'visible', 'off');
set(h.text1, 'visible', 'on');  %pause(1);
% set(h.text1, 'String', '3');
% drawnow;    pause(0.5);
% set(h.text1, 'String', '2');
% drawnow;    pause(0.5);
% set(h.text1, 'String', '1');
% drawnow;    pause(0.5);
set(h.text1, 'String', 'RECORDING', 'ForegroundColor','white',...
    'BackgroundColor','red');
drawnow;    
%get the recording from the user
myRecording = get_recording(8000,8,1,1);
%store in the appropriate place in the cmd_list variable
pause(1);
set(h.text1, 'String', 'Complete', 'ForegroundColor','black',...
    'BackgroundColor',[.94 .94 .94]);
drawnow;
%pause(1);
close(h.figure1);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, h)
uiresume(h.figure1)
% Hint: delete(hObject) closes the figure
delete(hObject);
