function varargout = FileSelect_gui(varargin)
% FILESELECT_GUI MATLAB code for FileSelect_gui.fig
%      FILESELECT_GUI, by itself, creates a new FILESELECT_GUI or raises the existing
%      singleton*.
%
%      H = FILESELECT_GUI returns the handle to a new FILESELECT_GUI or the handle to
%      the existing singleton*.
%
%      FILESELECT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FILESELECT_GUI.M with the given input arguments.
%
%      FILESELECT_GUI('Property','Value',...) creates a new FILESELECT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FileSelect_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FileSelect_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FileSelect_gui

% Last Modified by GUIDE v2.5 23-Nov-2014 20:59:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FileSelect_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @FileSelect_gui_OutputFcn, ...
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

%-----------------------------------------------------------------
%-----------------------------------------------------------------
%-----------------------------------------------------------------
function set_list(contents, h)
%break the list in order
len = length(contents);
breaker = '#';
list = '';

for i = 1:len
    if i == len
        breaker = '';
    end
    list = sprintf('%s%s%s', list, contents{i}, breaker );
end
list = regexp(list, '#', 'split'); 
set(h.listbox1, 'String', list);


%-----------------------------------------------------------------
%-----------------------------------------------------------------
%-----------------------------------------------------------------


% --- Executes just before FileSelect_gui is made visible.
function FileSelect_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FileSelect_gui (see VARARGIN)

% Choose default command line output for FileSelect_gui
handles.output = 2;

% Update handles structure
guidata(hObject, handles);
set_list(varargin{1}, handles); %set up the list with dynamic data

% UIWAIT makes FileSelect_gui wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FileSelect_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.figure1);


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
handles.output = get(hObject, 'Value');
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadBut.
function loadBut_Callback(hObject, eventdata, handles)
% hObject    handle to loadBut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = get(handles.listbox1, 'Value');
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in cancelBut.
function cancelBut_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = 2;
% Update handles structure
guidata(hObject, handles);
uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);
delete(hObject);
