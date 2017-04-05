function varargout = mvadBooter(varargin)
% MVADBOOTER MATLAB code for mvadBooter.fig
%      MVADBOOTER, by itself, creates a new MVADBOOTER or raises the existing
%      singleton*.
%
%      H = MVADBOOTER returns the handle to a new MVADBOOTER or the handle to
%      the existing singleton*.
%
%      MVADBOOTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MVADBOOTER.M with the given input arguments.
%
%      MVADBOOTER('Property','Value',...) creates a new MVADBOOTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mvadBooter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mvadBooter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mvadBooter

% Last Modified by GUIDE v2.5 05-Apr-2017 09:04:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mvadBooter_OpeningFcn, ...
                   'gui_OutputFcn',  @mvadBooter_OutputFcn, ...
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


% --- Executes just before mvadBooter is made visible.
function mvadBooter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mvadBooter (see VARARGIN)

% Choose default command line output for mvadBooter
handles.output = hObject;
handles.step = [];
handles.labelNameVar = [];
handles.labelName = [];
handles.trainRatio = [];
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mvadBooter wait for user response (see UIRESUME)
% uiwait(handles.mvadBooter);


% --- Outputs from this function are returned to the command line.
function varargout = mvadBooter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% Read path %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit_readPath.
function edit_readPath_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit_readPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'Enable', 'On');
handles.readPath = get(handles.edit_readPath,'String');
if strcmp(handles.readPath, 'Input here or click [Read path] to set folder')
    set(handles.edit_readPath,'String', []);
    set(handles.edit_readPath,'ForegroundColor', [0 0 0]);
end
uicontrol(hObject);
guidata(hObject, handles);

function edit_readPath_Callback(hObject, eventdata, handles)
% hObject    handle to edit_readPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_readPath as text
%        str2double(get(hObject,'String')) returns contents of edit_readPath as a double
handles.readPath = get(handles.edit_readPath,'String');
set(handles.edit_readPath,'ForegroundColor', [0 0 0]);
if isempty(handles.readPath)
    set(hObject, 'Enable', 'inactive');
    set(handles.edit_readPath,'ForegroundColor', [0.494 0.494 0.494]);
    set(handles.edit_readPath,'String', 'Input here or click [Read path] to set folder');
end
guidata(hObject, handles);

% --- Executes on button press in pushbutton_readPath.
function pushbutton_readPath_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_readPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.readPath = uigetdir;
if handles.readPath ~= 0
    set(handles.edit_readPath,'String', handles.readPath);
    set(handles.edit_readPath,'ForegroundColor', [0 0 0]);
end
guidata(hObject, handles);

% Save path %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit_savePath.
function edit_savePath_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit_savePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'Enable', 'On');
handles.savePath = get(handles.edit_savePath,'String');
if strcmp(handles.savePath, 'Input here or click [Save path] to set folder')
    set(handles.edit_savePath,'String', []);
    set(handles.edit_savePath,'ForegroundColor', [0 0 0]);
end
uicontrol(hObject);
guidata(hObject, handles);

function edit_savePath_Callback(hObject, eventdata, handles)
% hObject    handle to edit_savePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_savePath as text
%        str2double(get(hObject,'String')) returns contents of edit_savePath as a double
handles.savePath = get(handles.edit_savePath,'String');
if isempty(handles.savePath)
    set(hObject, 'Enable', 'inactive');
    set(handles.edit_savePath,'ForegroundColor', [0.494 0.494 0.494]);
    set(handles.edit_savePath,'String', 'Input here or click [Save path] to set folder');
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_savePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_savePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton_savePath.
function pushbutton_savePath_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_savePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.savePath = uigetdir;
if handles.savePath ~= 0
    set(handles.edit_savePath,'String', handles.savePath);
    set(handles.edit_savePath,'ForegroundColor', [0 0 0]);
end
guidata(hObject, handles);

% Start date %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit_dateStart.
function edit_dateStart_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit_dateStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'Enable', 'On');
handles.dateStart = get(handles.edit_dateStart,'String');
if strcmp(handles.dateStart, 'yyyy-mm-dd')
    set(handles.edit_dateStart,'String', []);
    set(handles.edit_dateStart,'ForegroundColor', [0 0 0]);
end
uicontrol(hObject);
guidata(hObject, handles);

function edit_dateStart_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dateStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dateStart as text
%        str2double(get(hObject,'String')) returns contents of edit_dateStart as a double
handles.dateStart = get(handles.edit_dateStart,'String');
if isempty(handles.dateStart)
    set(hObject, 'Enable', 'inactive');
    set(handles.edit_dateStart,'ForegroundColor', [0.494 0.494 0.494]);
    set(handles.edit_dateStart,'String', 'yyyy-mm-dd');
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_dateStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dateStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% End date %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit_dateEnd.
function edit_dateEnd_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit_dateEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'Enable', 'On');
handles.dateEnd = get(handles.edit_dateEnd,'String');
if strcmp(handles.dateEnd, 'yyyy-mm-dd')
    set(handles.edit_dateEnd,'String', []);
    set(handles.edit_dateEnd,'ForegroundColor', [0 0 0]);
end
uicontrol(hObject);
guidata(hObject, handles);

function edit_dateEnd_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dateEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dateEnd as text
%        str2double(get(hObject,'String')) returns contents of edit_dateEnd as a double
handles.dateEnd = get(handles.edit_dateEnd,'String');
if isempty(handles.dateEnd)
    set(hObject, 'Enable', 'inactive');
    set(handles.edit_dateEnd,'ForegroundColor', [0.494 0.494 0.494]);
    set(handles.edit_dateEnd,'String', 'yyyy-mm-dd');
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_dateEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dateEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Sensor No. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit_sensorVar.
function edit_sensorVar_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit_sensorVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.sensorVar = get(handles.edit_sensorVar,'String');
if strcmp(handles.sensorVar, 'variable name')
    set(hObject, 'Enable', 'On');
    set(handles.edit_sensorVar,'String', []);
    set(handles.edit_sensorVar,'ForegroundColor', [0 0 0]);
end
uicontrol(hObject);
guidata(hObject, handles);

function edit_sensorVar_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sensorVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sensorVar as text
%        str2double(get(hObject,'String')) returns contents of edit_sensorVar as a double
handles.sensorVar = get(handles.edit_sensorVar,'String');
handles.sensorNum = evalin('base', handles.sensorVar);
if isempty(handles.sensorVar)
    set(hObject, 'Enable', 'inactive');
    set(handles.edit_sensorVar,'ForegroundColor', [0.494 0.494 0.494]);
    set(handles.edit_sensorVar,'String', 'variable name');
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_sensorVar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sensorVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Preview %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in pushbutton_preview.
function pushbutton_preview_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_preview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.preview = get(handles.edit_sensorVar,'String');
if  ~strcmp(handles.preview, 'variable name')
    if iscell(handles.sensorNum)
        handles.sensorNumVec = cell2mat(handles.sensorNum);
    else
        handles.sensorNumVec = handles.sensorNum;
    end
    handles.preview = tidyName(abbr(handles.sensorNumVec));
    handles.preview(1) = [];
    handles.preview = ['No. ' handles.preview];
    set(handles.text_sensorNum,'String', handles.preview);
end
guidata(hObject, handles);

% Advanced options %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in pushbutton_advOption.
function pushbutton_advOption_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_advOption (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% unfinish! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if isfield(handles, 'sensorNum') && isfield(handles, 'dateStart') && isfield(handles, 'dateEnd')
%     if ~iscell(handles.sensorNum), handles.sensorNum = {handles.sensorNum}; end
%     groupTotal = length(handles.sensorNum(:));
%     handles.sensorNumVec = [];
%     for g = 1 : groupTotal, handles.sensorNumVec = [handles.sensorNumVec handles.sensorNum{g}(:)']; end
%     handles.sensorStr = tidyName(abbr(handles.sensorNumVec));
%     if groupTotal == sensorTotal
%         handles.netlayout = '_parallel';
%     elseif groupTotal == 1
%         handles.netlayout = '_fusion';
%     elseif groupTotal > 1 && groupTotal < sensorTotal
%         handles.netlayout = '_customGroups';
%     end
%     handles.dirName.home = sprintf('%s/%s--%s_sensor%s%s', saveRoot, handles.dateStart, handles.dateEnd, handles.sensorStr, handles.netlayout);
%     handles.dirName.status = sprintf('%s--%s_sensor%s%s_status.mat', handles.dateStart, handles.dateEnd, handles.sensorStr, handles.netlayout);
%     
%     if exist(GetFullPath(handles.dirName.home), 'dir')
%         if exist([GetFullPath(handles.dirName.home) '/' handles.dirName.status], 'file')
%             load([GetFullPath(handles.dirName.home) '/' handles.dirName.status]);
%             fprintf('STATUS:\n');
%             for n = 1:5
%                 fprintf('%s: %s\n', cell2mat(status(1,n)), num2str(cell2mat(status(2,n))));
%             end
%         else
%             fprintf('Status file missing.\n');
%         end
%     else
%         fprintf('Brand new start!\n');
%     end
% else
%     fprintf('Not enough input, status unknown.');
% end

mvadBooterAdv

guidata(hObject, handles);


% mvadAbout %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in pushbutton_about.
function pushbutton_about_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mvadAbout
guidata(hObject, handles);

% Help %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in pushbutton_help.
function pushbutton_help_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Quit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in pushbutton_quit.
function pushbutton_quit_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

checkSubGUI = findobj(0,'Name', 'mvadBooterAdv');
close(checkSubGUI); 

close(gcf)

% Start %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in pushbutton_Start.
function pushbutton_Start_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.readPath = get(handles.edit_readPath,'String');
handles.savePath = get(handles.edit_savePath,'String');

% subGUI = findobj('Tag','mvadBooterAdv');
% if ~isempty(subGUI)
%     subData = guidata(subGUI);
% end
handles.step = getappdata(figure(mvadBooter), 'step');
handles.labelName = getappdata(figure(mvadBooter), 'labelName');
handles.trainRatio = getappdata(figure(mvadBooter), 'trainRatio');

mvad(handles.readPath, handles.savePath, handles.sensorNum, ...
    handles.dateStart, handles.dateEnd, handles.trainRatio, [], handles.step, handles.labelName);
guidata(hObject, handles);
