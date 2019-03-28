function varargout = seamCarving_GUI(varargin)
% SEAMCARVING_GUI MATLAB code for seamCarving_GUI.fig
%      SEAMCARVING_GUI, by itself, creates a new SEAMCARVING_GUI or raises the existing
%      singleton*.
%
%      H = SEAMCARVING_GUI returns the handle to a new SEAMCARVING_GUI or the handle to
%      the existing singleton*.
%
%      SEAMCARVING_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEAMCARVING_GUI.M with the given input arguments.
%
%      SEAMCARVING_GUI('Property','Value',...) creates a new SEAMCARVING_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before seamCarving_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to seamCarving_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help seamCarving_GUI

% Last Modified by GUIDE v2.5 29-Mar-2017 23:46:21

%Author: Mahmoud Afifi - York University

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @seamCarving_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @seamCarving_GUI_OutputFcn, ...
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


% --- Executes just before seamCarving_GUI is made visible.
function seamCarving_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to seamCarving_GUI (see VARARGIN)


% Choose default command line output for seamCarving_GUI
handles.output = hObject;

global img; %image
global mask; %markup mask
if exist('ocean.bmp','file')~=0
    img=imread('ocean.bmp'); %load default image
    axes(handles.img); %show it
    imshow(img);
    mask=zeros(size(img,1),size(img,2));  %initialize the mask of markup
    handles.cwidth.String=num2str(size(img,2)); %get current dim of the image
    handles.cheight.String=num2str(size(img,1));
    
else
    img=[];
   
    handles.retarget_btn.Enable='off'; 
    handles.markup_plus_btn.Enable='off';
    handles.markup_minus_btn.Enable='off';
    
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes seamCarving_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = seamCarving_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in browse_btn.
function browse_btn_Callback(hObject, eventdata, handles)
% hObject    handle to browse_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img; %image
global mask; %markup mask
global filename;
global pathname;
[filename, pathname] = ...
    uigetfile({'*.bmp';'*.jpg';'*.png';'*.jpeg'},'Image File Selector');
if filename~=0
    img=imread(fullfile(pathname,filename)); %read the image
    mask=zeros(size(img,1),size(img,2)); %initialize the mask of markup
    handles.cwidth.String=num2str(size(img,2)); %get current dim of the image
    handles.cheight.String=num2str(size(img,1));
    axes(handles.img); %show it
    imshow(img);
    handles.markup_plus_btn.Enable='on';
    handles.markup_minus_btn.Enable='on';
    handles.save_btn.Enable='off';
    handles.retarget_btn.Enable='on';
end
% --- Executes on button press in markup_plus_btn.
function markup_plus_btn_Callback(hObject, eventdata, handles)
% hObject    handle to markup_plus_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img; %image
global mask; %markup mask
h=figure;
imshow(img);
title('Specify a polygonal region of interest (ROI)');
bw=roipoly; %get ROI
mask=mask+(double(bw)*+100000000000000000); %+inf
close(h);

% --- Executes on button press in markup_minus_btn.
function markup_minus_btn_Callback(hObject, eventdata, handles)
% hObject    handle to markup_minus_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img; %image
global mask; %markup mask
h=figure;
imshow(img);
title('Specify a polygonal region of interest (ROI)');
bw=roipoly; %get ROI
mask=mask+(double(bw)*-100000000000000000000); %-inf
close(h);

% --- Executes on button press in retarget_btn.
function retarget_btn_Callback(hObject, eventdata, handles)
% hObject    handle to retarget_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img;
global mask;
global out_img;

if length(handles.nwidth.String)<=1 || length(handles.nheight.String)<=1
    msgbox('Please specify valid dimensions of the image','Error','error');
else
    w=round(str2double(handles.nwidth.String)); %get new width
    h=round(str2double(handles.nheight.String)); %get new height
    if w<=0 || h<=0
        msgbox('Please specify non-zero dimensions of the image','Error','error');
    else
        out_img=seamCarving(img,mask,w,h);
        h=figure;
        imshow(out_img);
        title('Results');
        handles.save_btn.Enable='on';
    end
end

% --- Executes on button press in save_btn.
function save_btn_Callback(hObject, eventdata, handles)
% hObject    handle to save_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global out_img;
global filename;
global pathname;

if length(filename)<=1 %should be more than 1 character ! otherwise it is 0 or empty obj
    imwrite(out_img,'Ocean_result.bmp'); %save image
else
    imwrite(out_img,fullfile(pathname,strcat(filename(1:end-4),'_result',...
        filename(end-3:end)))); %save image
    
end
msgbox('saved!');

function nwidth_Callback(hObject, eventdata, handles)
% hObject    handle to nwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nwidth as text
%        str2double(get(hObject,'String')) returns contents of nwidth as a double


% --- Executes during object creation, after setting all properties.
function nwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nheight_Callback(hObject, eventdata, handles)
% hObject    handle to nheight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nheight as text
%        str2double(get(hObject,'String')) returns contents of nheight as a double


% --- Executes during object creation, after setting all properties.
function nheight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nheight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cwidth_Callback(hObject, eventdata, handles)
% hObject    handle to cwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cwidth as text
%        str2double(get(hObject,'String')) returns contents of cwidth as a double


% --- Executes during object creation, after setting all properties.
function cwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cheight_Callback(hObject, eventdata, handles)
% hObject    handle to cheight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cheight as text
%        str2double(get(hObject,'String')) returns contents of cheight as a double


% --- Executes during object creation, after setting all properties.
function cheight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cheight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
%global image object



