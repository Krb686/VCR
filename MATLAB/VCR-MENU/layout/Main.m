function varargout = Main(varargin)
% GUIDE_TEST MATLAB code for guide_test.fig
%      GUIDE_TEST, by itself, creates a new GUIDE_TEST or raises the existing
%      singleton*.
%
%      H = GUIDE_TEST returns the handle to a new GUIDE_TEST or the handle to
%      the existing singleton*.
%
%      GUIDE_TEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIDE_TEST.M with the given input arguments.
%
%      GUIDE_TEST('Property','Value',...) creates a new GUIDE_TEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guide_test_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guide_test_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guide_test

% Last Modified by GUIDE v2.5 22-Nov-2014 15:36:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guide_test_OpeningFcn, ...
                   'gui_OutputFcn',  @guide_test_OutputFcn, ...
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


% --- Executes just before guide_test is made visible.
function guide_test_OpeningFcn(hObject, eventdata, h, varargin)
global version
% This function has no output args, see OutputFcn.
% Choose default command line output for guide_test
h.output = hObject;
% Update handles structure
guidata(hObject, h);
% UIWAIT makes guide_test wait for user response (see UIRESUME)
% uiwait(h.main_window);
axes(h.viewbox1);
imshow('layout/logo.png')
set(h.versionText, 'String', ['Version: ' version]);



% --- Outputs from this function are returned to the command line.
function varargout = guide_test_OutputFcn(hObject, eventdata, h) 
% Get default command line output from handles structure
varargout{1} = h.output;


% --- Executes on button press in trainButton.
function trainButton_Callback(hObject, eventdata, h)
%set(h.tuneButton, 'enable', 'off');
%set(h.activateButton, 'enable', 'off');
Train_gui();

% --- Executes on button press in activateButton.
function activateButton_Callback(hObject, eventdata, h)
Activate_gui();

% --- Executes on button press in tuneButton.
function tuneButton_Callback(hObject, eventdata, h)
tune_gui();


% --- Executes on button press in testButton.
function testButton_Callback(hObject, eventdata, handles)
% hObject    handle to testButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Test_gui();
