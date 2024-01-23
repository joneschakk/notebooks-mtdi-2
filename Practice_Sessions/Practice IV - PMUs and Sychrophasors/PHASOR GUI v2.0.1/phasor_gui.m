
function varargout = phasor_gui(varargin)
% UNTITLED1 MATLAB code for untitled1.fig
%      UNTITLED1, by itself, creates a new UNTITLED1 or raises the existing
%      singleton*.
%
%      H = UNTITLED1 returns the handle to a new UNTITLED1 or the handle to
%      the existing singleton*.
%
%      UNTITLED1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNTITLED1.M with the given input arguments.
%
%      UNTITLED1('Property','Value',...) creates a new UNTITLED1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before untitled1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to untitled1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help untitled1

% Last Modified by GUIDE v2.5 04-Jan-2017 22:07:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @phasor_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @phasor_gui_OutputFcn, ...
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




% --- Executes just before untitled1 is made visible.
function phasor_gui_OpeningFcn(hObject, eventdata, handles, varargin)

% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to untitled1 (see VARARGIN)
global l
global data
l = 0;
data = [];
data.state = 0;
data.error_flag = 5;
data.N = NaN;
data.frequency = NaN;
data.frequency_nominal = NaN;
data.rms = NaN;
data.phase = NaN;
data.ctr = 0;
axes(handles.axes7)
matlabImage = imread('logo.png');
image(matlabImage)
axis off
axis image
% Choose default command line output for untitled1
%handles.output = hObject;

% Update handles structure

% UIWAIT makes untitled1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = phasor_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;


% --- Executes on button press in Calculate_phasors.
function Calculate_phasors_Callback(hObject, eventdata, handles)

global l
global data

data;


if data.error_flag == 0

    if l >= 1
         l = l + 1;

    else
         l = 1;

    end


    X1 = phasor_calculation_non_recursive(l,data.amp,data.phase,data.frequency,data.N);
    real_X1 = real(X1);
    imag_X1 = imag(X1);
    set(handles.Phasor1_real,'String', real_X1);
    set(handles.Phasor1_imag,'String', imag_X1);

    hold all
    axes(handles.axes2);
    compass(X1);

    X2(1,:) = phasor_calculation_recursive(l,data.amp,data.phase,data.frequency,data.N,data.frequency_nominal);
    real_X2 = real(X2(1,l));
    imag_X2 = imag(X2(1,l));
    set(handles.Phasor2_real,'String', real_X2);
    set(handles.Phasor2_imag,'String', imag_X2);

    X_filtered = 0;
        if l > data.N
            data.ctr = data.ctr + 1;
        end
        
        if data.state == 1 && l > data.N
                k60=round((data.N)/6);
                k120=round((data.N)/3);
                Xs(1:3)=0;
                Xs(1) = X2(1,data.ctr+1);
                Xs(2)=  X2(1,data.ctr+k60+1);
                Xs(3) = X2(1,data.ctr+k120+1);
            X_filtered=sum(Xs)/3;
            Xf(l) = X_filtered;
        else
            Xf(l) = X2(1,l); 
        end


    hold all
    axes(handles.axes3);
    compass(Xf(l));

    y1 = abs(Xf(l));
    y2 = rad2deg(angle(Xf(l)));


    cla(handles.axes4)

    phi = data.phase;
    amp = data.amp;
    f0 = data.frequency_nominal;
    n = data.N;
    fs = n*f0;
    dt = 1/fs;
    t = [l-1:n+l-2]*dt;

    wave = amp*cos(2*pi*f0*t + phi);
    axes(handles.axes4);
    stem(t,wave);

    hold all
    axes(handles.axes3);
    compass(Xf(l));

    hold all
    axes(handles.axes5);
    plot(l,y1,'*b');

    hold all
    axes(handles.axes6);
    plot(l,y2,'+r');
else
    errordlg('Please specify all the parameters','Input Parameter Error');
end






function Phase_Callback(hObject, eventdata, handles)
% hObject    handle to Phase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of Phase as text
%        str2double(get(hObject,'String')) returns contents of Phase as a double
global data
ph_angle = pi*str2double(get(hObject,'String'))/180;
if ph_angle < (-2*pi) || ph_angle > (2*pi) || isnan(ph_angle)
    errordlg('Phase angle must lie between -360 to +360 degrees','Input Parameter Error');
    set(handles.Phase, 'String', '');
    data.phase = NaN;
    data.error_flag = data.error_flag + 1;
else
    data.phase = ph_angle;
    if data.error_flag >= 1
        data.error_flag = data.error_flag - 1;
    end
end

% --- Executes during object creation, after setting all properties.
function Phase_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Phase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function frequency_Callback(hObject, eventdata, handles)
% hObject    handle to frequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frequency as text
%        str2double(get(hObject,'String')) returns contents of frequency as a double
global data
freq = str2double(get(hObject,'String'));
if freq <= 0 || isnan(freq)
    errordlg('Frequency must be positive','Input Parameter Error');
    set(handles.frequency, 'String', '');
    data.frequency = NaN;
    data.error_flag = data.error_flag + 1;
else
    data.frequency = freq;
   if data.error_flag >= 1
        data.error_flag = data.error_flag - 1;
   end
end


% --- Executes during object creation, after setting all properties.
function frequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Samples_Callback(hObject, eventdata, handles)
% hObject    handle to Samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Samples as text
%        str2double(get(hObject,'String')) returns contents of Samples as a double
global data

samples = str2double(get(hObject,'String'));
if samples <= 1 || isnan(samples) || samples - round(samples) ~= 0
    errordlg('Number of Samples must be a positive integer','Input Parameter Error');
    set(handles.Samples, 'String', '');
    data.N = NaN;
    data.error_flag = data.error_flag + 1;
else
    data.N = samples;
    if data.error_flag >= 1
        data.error_flag = data.error_flag - 1;
    end
end

% --- Executes during object creation, after setting all properties.
function Samples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Nominal_System_Frequency_Callback(hObject, eventdata, handles)
% hObject    handle to Nominal_System_Frequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Nominal_System_Frequency as text
%        str2double(get(hObject,'String')) returns contents of Nominal_System_Frequency as a double
global data
n_freq = str2double(get(hObject,'String'));
if n_freq <= 0 || isnan(n_freq)
    errordlg('Frequency must be positive','Input Parameter Error');
    set(handles.Nominal_System_Frequency, 'String', '');
    data.frequency_nominal = NaN;
    data.error_flag = data.error_flag + 1;
else
    data.frequency_nominal = n_freq;
    if data.error_flag >= 1
        data.error_flag = data.error_flag - 1;
    end
end



% --- Executes during object creation, after setting all properties.
function Nominal_System_Frequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Nominal_System_Frequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function amplitude_Callback(hObject, eventdata, handles)
% hObject    handle to amplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of amplitude as text
%        str2double(get(hObject,'String')) returns contents of amplitude as a double
global data
amplitude = str2double(get(hObject,'String'));
if amplitude < 0 || isnan(amplitude)
   errordlg('RMS value must be positive','Input Parameter Error');
   set(handles.amplitude, 'String', '');
   data.amp = NaN;
   data.error_flag = data.error_flag + 1;
else
   data.amp = amplitude;
   if data.error_flag >= 1
        data.error_flag = data.error_flag - 1;
   end
end

% --- Executes during object creation, after setting all properties.
function amplitude_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global l
global data
l = 0;
data.N = NaN;
data.frequency = NaN;
data.frequency_nominal = NaN;
data.state = 0;
data.amp = NaN;
data.phase = NaN;
data.ctr = 0;
cla(handles.axes2)
cla(handles.axes3)
cla(handles.axes4)
cla(handles.axes5)
cla(handles.axes6)
set(handles.Phasor2_real,'String', 0);
set(handles.Phasor2_imag,'String', 0);
set(handles.Phasor1_real,'String', 0);
set(handles.Phasor1_imag,'String', 0);
string1 = '';
set(handles.amplitude, 'String', string1);
set(handles.frequency, 'String', string1);
set(handles.Nominal_System_Frequency, 'String', string1);
set(handles.Samples, 'String', string1);
set(handles.Phase, 'String', string1);
data.error_flag = 5;



% --- Executes on button press in three_point_averaging.
function three_point_averaging_Callback(hObject, eventdata, handles)
% hObject    handle to three_point_averaging (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of three_point_averaging
global data

if (get(hObject,'Value') == get(hObject,'Max'))
	data.state = 1;
else
	data.state = 0;
end
