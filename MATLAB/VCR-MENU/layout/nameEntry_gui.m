function varargout = nameEntry_gui(varargin)
% NAMEENTRY_GUI MATLAB code for nameEntry_gui.fig
%      NAMEENTRY_GUI, by itself, creates a new NAMEENTRY_GUI or raises the existing
%      singleton*.
%
%      H = NAMEENTRY_GUI returns the handle to a new NAMEENTRY_GUI or the handle to
%      the existing singleton*.
%
%      NAMEENTRY_GUI('CALLBACK',hObject,eventData,h,...) calls the local
%      function named CALLBACK in NAMEENTRY_GUI.M with the given input arguments.
%
%      NAMEENTRY_GUI('Property','Value',...) creates a new NAMEENTRY_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nameEntry_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nameEntry_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIh

% Edit the above text to modify the response to help nameEntry_gui

% Last Modified by GUIDE v2.5 07-Nov-2014 00:14:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nameEntry_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @nameEntry_gui_OutputFcn, ...
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


% --- Executes just before nameEntry_gui is made visible.
function nameEntry_gui_OpeningFcn(hObject, eventdata, h, varargin)
% This function has no output args, see OutputFcn.
% varargin   command line arguments to nameEntry_gui (see VARARGIN)
% Choose default command line output for nameEntry_gui
h.output = hObject;
% Update h structure
guidata(hObject, h);
% UIWAIT makes nameEntry_gui wait for user response (see UIRESUME)
set(h.text1 , 'String', varargin{1}{1});
set(h.nameEntry , 'Name', varargin{1}{2});

if length(varargin{1}) > 2
    set(h.name_field, 'String', varargin{1}{3});
else
    set(h.name_field, 'String', '--0--');
end
uiwait(h.nameEntry);
global output
%output = '--0--';


% --- Outputs from this function are returned to the command line.
function varargout = nameEntry_gui_OutputFcn(hObject, eventdata, h) 
% varargout  cell array for returning output args (see VARARGOUT);
global output
% Get default command line output from h structure
varargout{1} = output;



function name_field_Callback(hObject, eventdata, h)
global output
output = get(h.name_field,'String');
nameEntry_CloseRequestFcn(hObject, eventdata, h)


% --- Executes during object creation, after setting all properties.
function name_field_CreateFcn(hObject, eventdata, h)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, h)
name_field_Callback(hObject, eventdata, h);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, h)
nameEntry_CloseRequestFcn(hObject, eventdata, h)


% --- Executes when user attempts to close nameEntry.
function nameEntry_CloseRequestFcn(hObject, eventdata, h)
%set(h.name_field, 'String', varargin{1}{3});
uiresume(h.nameEntry);
% Hint: delete(hObject) closes the figure
delete(h.nameEntry);
