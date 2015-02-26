function varargout = guiFLOW(varargin)
% GUIFLOW MATLAB code for guiFLOW.fig
%      GUIFLOW, by itself, creates a new GUIFLOW or raises the existing
%      singleton*.
%
%      H = GUIFLOW returns the handle to a new GUIFLOW or the handle to
%      the existing singleton*.
%
%      GUIFLOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIFLOW.M with the given input arguments.
%
%      GUIFLOW('Property','Value',...) creates a new GUIFLOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiFLOW_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiFLOW_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiFLOW

% Last Modified by GUIDE v2.5 02-Dec-2014 19:31:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guiFLOW_OpeningFcn, ...
                   'gui_OutputFcn',  @guiFLOW_OutputFcn, ...
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

% --- Executes just before guiFLOW is made visible.
function guiFLOW_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiFLOW (see VARARGIN)

% Initialize le GUI

% splashscreen(handles)
h=imread('resources/help-icon.png');
h=imresize(h, [50 65]);
set(handles.help_button,'CData',h);

% Generate the field
resolution = 40;
handles.vars.xlim = [-10 10];
handles.vars.ylim = [-5 5];
xrange = linspace(handles.vars.xlim(1),handles.vars.xlim(2),resolution);
yrange = linspace(handles.vars.ylim(1),handles.vars.ylim(2),resolution);
[handles.vars.x, handles.vars.y] = meshgrid(xrange,yrange);

% Labels
set(handles.flowplot,'Xlim',handles.vars.xlim,'Ylim',handles.vars.ylim,'DataAspectRatio',[1 1 1]);
xlabel(handles.flowplot,'X');ylabel(handles.flowplot,'Y');

% read in from free stream text boxes
handles.vars.u_f = str2double(get(handles.u_f,'String'));
handles.vars.v_f = str2double(get(handles.v_f,'String'));

% generate free stream velocity and potentials
handles.vars.u = handles.vars.u_f.*ones(resolution,resolution);
handles.vars.v = handles.vars.v_f.*ones(resolution,resolution);
handles.vars.phi = -handles.vars.u.*handles.vars.x - handles.vars.v.*handles.vars.y;
handles.vars.psi = handles.vars.u.*handles.vars.y + handles.vars.v.*handles.vars.x;

% -----------End Setup----------------

% Choose default command line output for guiFLOW
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = guiFLOW_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function splashscreen(handles)
fh = figure('Visible','off','MenuBar','none','NumberTitle','off');
ah = axes('Parent',fh,'Visible','off');
load earth.mat;
ih = image(X,'parent',ah);
colormap(map)
% set the figure size to be just big enough for the image, and centered at
% the center of the screen
imxpos = get(ih,'XData');
imypos = get(ih,'YData');
set(ah,'Unit','Normalized','Position',[0,0,1,1]);
figpos = get(fh,'Position');
figpos(3:4) = [imxpos(2) imypos(2)];
set(fh,'Position',figpos);
movegui(fh,'center')
% make the figure visible
set(fh,'Visible','on');
ht = timer('StartDelay',1,'ExecutionMode','SingleShot');
set(ht,'TimerFcn','close(fh);stop(ht);delete(ht)');
start(ht);

function update_plot(handles,x,y,u,v,psi,phi)
% update the plot
cla(handles.flowplot);
set(handles.flowplot,'Xlim',1*handles.vars.xlim,'Ylim',1*handles.vars.ylim,'DataAspectRatio',[1 1 1],'NextPlot','replacechildren');

% point potential velocity components
u_s = u./sqrt(u.^2+v.^2);
v_s = v./sqrt(u.^2+v.^2);

% show velocity arrows
if get(handles.showvelocities,'Value')
    h.v = quiver(handles.flowplot,x,y,u_s,v_s);
    set(h.v,'AutoScaleFactor',0.6,'Color','k');
end
hold on
% show potential field lines
% if get(handles.showpotentials,'Value')
%     [~,h.c] = contour(handles.flowplot,x,y,phi,20);
%     colormap(handles.flowplot,'Cool');
% else
% end
hold off

% show streamlines
[strx, stry] = meshgrid(-10:1:10,-5:1:5); % where to draw the streamlines
if get(handles.showstreamlines,'Value')
    h.str = streamline(handles.flowplot,x,y,u,v,strx,stry);
    set(h.str,'Color','r');
end

function [psi,phi,x,y,u,v] = create_potential(handles,ptype)
% Create potential flow based off input

phi = handles.vars.phi;psi = handles.vars.psi;
x = handles.vars.x;y = handles.vars.y;
u = handles.vars.u;v = handles.vars.v;

% Check to see if one of the new portential buttons was pressed
spressed = get(handles.new_source_button,'Value');
sspressed = get(handles.new_sink_button,'Value');
vpressed = get(handles.new_vortex_button,'Value');
dpressed = get(handles.new_dipole_button,'Value');

% if one was, then generate goes high
if spressed + sspressed + vpressed + dpressed == 1
    generate = 1;
end

%Open a prompt to take input about the point potential
msgtitle = 'New Point Potential: ';
prompt = {'X Coordinate:','Y Coordinate:','Strength?:'};
lines = 1;
defaults = {'0','0','1'}; % use source as default
options.Resize = 'on';
options.WindowStyle = 'modal';
options.Interpreter = 'tex'; 
answervalue = inputdlg(prompt,msgtitle,lines,defaults,options);
% append velocities for potential type on to pre-existing vars
if ~isempty(answervalue)
    x_in = str2double(answervalue{1});
    y_in = str2double(answervalue{2});
    m = str2double(answervalue{3});
    [new_u,new_v,new_psi,new_phi] = newPot(handles,x,y,x_in,y_in,m,ptype);
    u = u + new_u;
    v = v + new_v;
    psi = psi + new_psi;
    phi = phi + new_phi;
    update_plot(handles,x,y,u,v,psi,phi);
end

function free_flow(hObject,handles)
% Regenerate the field with free flow velocities
u_f = str2double(get(handles.u_f,'String'));
v_f = str2double(get(handles.v_f,'String'));
u_f0 = handles.vars.u_f;
v_f0 = handles.vars.v_f;
x = handles.vars.x;
y = handles.vars.y;
u = handles.vars.u + (u_f-u_f0)*ones(size(handles.vars.u,1),size(handles.vars.u,2));
v = handles.vars.v + (v_f-v_f0)*ones(size(handles.vars.u,1),size(handles.vars.u,2));
psi = u.*y + v.*x;
phi = -u.*x - v.*y;

% update plot with 
update_plot(handles,x,y,u,v,psi,phi);
handles.vars.x = x;
handles.vars.y = y;
handles.vars.u = u;
handles.vars.v = v;
handles.vars.psi = psi;
handles.vars.phi = phi;
handles.vars.u_f = u_f;
handles.vars.v_f = v_f;
guidata(hObject, handles);

function [u,v,psi,phi] = newPot(handles,X,Y,x,y,m,ptype)
% Calculations for each type of potential
%calculations completed in polar to make this easier
switch ptype
    case 'Source'
        v_r = m/2/pi./sqrt((X-x).^2+(Y-y).^2);
        omega = 0; %no angular velocity for a source or sink
        phi = -m/2/pi.*log(sqrt((X-x).^2+(Y-y).^2));
        psi = m/2/pi*atan2((Y-y)./sqrt((X-x).^2+(Y-y).^2),(X-x)./sqrt((X-x).^2+(Y-y).^2));
        
    case 'Sink'
        v_r = -m/2/pi./sqrt((X-x).^2+(Y-y).^2);
        omega = 0;%no angular velocity for a source or sink
        phi = m/2/pi.*log(sqrt((X-x).^2+(Y-y).^2));
        psi = -m/2/pi*atan2((Y-y)./sqrt((X-x).^2+(Y-y).^2),(X-x)./sqrt((X-x).^2+(Y-y).^2));
        
    case 'Vortex'
        v_r = 0;%no radial velocity for a vortex
        omega = m/2/pi./sqrt((X-x).^2+(Y-y).^2);
        phi = -m/2/pi*atan2((Y-y)./sqrt((X-x).^2+(Y-y).^2),(X-x)./sqrt((X-x).^2+(Y-y).^2));
        psi = -m/2/pi.*log(sqrt((X-x).^2+(Y-y).^2));
        
    case 'Dipole'
        v_r = -m./sqrt((X-x).^2+(Y-y).^2).^2.*((X-x)./sqrt((X-x).^2+(Y-y).^2));
        omega = -m./sqrt((X-x).^2+(Y-y).^2).^2.*((Y-y)./sqrt((X-x).^2+(Y-y).^2));
        phi = -m./sqrt((X-x).^2+(Y-y).^2).*((X-x)./sqrt((X-x).^2+(Y-y).^2));
        psi = -m./sqrt((X-x).^2+(Y-y).^2).*((Y-y)./sqrt((X-x).^2+(Y-y).^2));
        
end
%convert to cartesian
u = v_r.*(X-x)./sqrt((X-x).^2+(Y-y).^2) - omega.*(Y-y);
v = v_r.*(Y-y)./sqrt((X-x).^2+(Y-y).^2) + omega.*(X-x);
% ------------------------------------------CALLBACKS ----------------------------------------

% --- Executes on button press in newpotential.
function newpotential_Callback(hObject, eventdata, handles)
% hObject    handle to newpotential (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% run create_potential when the new potential buttton is clicked
[psi,phi,x,y,u,v]= create_potential(handles);
% extract variables from namespace in to vars object
handles.vars.psi = psi;
handles.vars.phi = phi;
handles.vars.x = x;
handles.vars.y = y;
handles.vars.u = u;
handles.vars.v = v;

guidata(hObject, handles);

% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Clear all potential variables and reset the plot
handles.vars.phi = -handles.vars.u.*handles.vars.x - handles.vars.v.*handles.vars.y;
handles.vars.psi = handles.vars.u.*handles.vars.y + handles.vars.v.*handles.vars.x;

handles.vars.u_f = str2double(get(handles.u_f,'String'));
handles.vars.v_f = str2double(get(handles.v_f,'String'));

handles.vars.u = handles.vars.u_f.*ones(size(handles.vars.x,1),size(handles.vars.y,2));
handles.vars.v = handles.vars.v_f.*ones(size(handles.vars.x,1),size(handles.vars.y,2));


cla(handles.flowplot);

guidata(hObject, handles);

% --- Executes on button press in showvelocities.
function showvelocities_Callback(hObject, eventdata, handles)
% hObject    handle to showvelocities (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showvelocities
% refresh plot
update_plot(handles,handles.vars.x,handles.vars.y,handles.vars.u,handles.vars.v,handles.vars.psi,handles.vars.phi);

% --- Executes on button press in showstreamlines.
function showstreamlines_Callback(hObject, eventdata, handles)
% hObject    handle to showstreamlines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showstreamlines
% refresh plot
update_plot(handles,handles.vars.x,handles.vars.y,handles.vars.u,handles.vars.v,handles.vars.psi,handles.vars.phi);

% --- Executes on button press in showpotentials.
% function showpotentials_Callback(hObject, eventdata, handles)
% % hObject    handle to showpotentials (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: get(hObject,'Value') returns toggle state of showpotentials
% % refresh plot
% update_plot(handles,handles.vars.x,handles.vars.y,handles.vars.u,handles.vars.v,handles.vars.psi,handles.vars.phi);

function u_f_Callback(hObject, eventdata, handles)
% hObject    handle to u_f (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of u_f as text
%        str2double(get(hObject,'String')) returns contents of u_f as a double
free_flow(hObject,handles)

% --- Executes during object creation, after setting all properties.
function u_f_CreateFcn(hObject, eventdata, handles)
% hObject    handle to u_f (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function v_f_Callback(hObject, eventdata, handles)
% hObject    handle to v_f (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of v_f as text
%        str2double(get(hObject,'String')) returns contents of v_f as a double
free_flow(hObject,handles)

% --- Executes during object creation, after setting all properties.
function v_f_CreateFcn(hObject, eventdata, handles)
% hObject    handle to v_f (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in new_source_button.
function new_source_button_Callback(hObject, eventdata, handles)
% hObject    handle to new_source_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% run create_potential when the new potential buttton is clicked
[psi,phi,x,y,u,v]= create_potential(handles,'Source');
% extract variables from namespace in to vars object
handles.vars.psi = psi;
handles.vars.phi = phi;
handles.vars.x = x;
handles.vars.y = y;
handles.vars.u = u;
handles.vars.v = v;

guidata(hObject, handles);

% --- Executes on button press in new_sink_button.
function new_sink_button_Callback(hObject, eventdata, handles)
% hObject    handle to new_sink_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[psi,phi,x,y,u,v]= create_potential(handles,'Sink');
% extract variables from namespace in to vars object
handles.vars.psi = psi;
handles.vars.phi = phi;
handles.vars.x = x;
handles.vars.y = y;
handles.vars.u = u;
handles.vars.v = v;

guidata(hObject, handles);

% --- Executes on button press in new_vortex_button.
function new_vortex_button_Callback(hObject, eventdata, handles)
% hObject    handle to new_vortex_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[psi,phi,x,y,u,v]= create_potential(handles,'Vortex');
% extract variables from namespace in to vars object
handles.vars.psi = psi;
handles.vars.phi = phi;
handles.vars.x = x;
handles.vars.y = y;
handles.vars.u = u;
handles.vars.v = v;

guidata(hObject, handles);

% --- Executes on button press in new_dipole_button.
function new_dipole_button_Callback(hObject, eventdata, handles)
% hObject    handle to new_dipole_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[psi,phi,x,y,u,v]= create_potential(handles,'Dipole');
% extract variables from namespace in to vars object
handles.vars.psi = psi;
handles.vars.phi = phi;
handles.vars.x = x;
handles.vars.y = y;
handles.vars.u = u;
handles.vars.v = v;

guidata(hObject, handles);

% --- Executes on button press in help_button.
function help_button_Callback(hObject, eventdata, handles)
% hObject    handle to help_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dlgname = 'About GuiFlow';
txt = {'GuiFlow allows for the visualization of simple point potential flows.';
    'These include Sources, Sinks, Vortices and Dipoles.';
    '';
    
    '  The free stream velocity components can easily be adjusted';
    '  below the plotting area. Changing these parameters will';
    '  adjust the direction and amplitude of the free stream.' ;
    '';
    '  Select a type of potential flow from the right of the GUI';
    '  and a prompt will allow for the user to input the location';
    '  and strength of the selected potential. The potential will';
    '  then appear in the plotting area. Using superposition, it';
    '  is possible to add several different potentials and even a';
    '  stream too!';
    '';
    '  Potentials:';
    '   *New Source: opens a dialog to create a new point source';
    '   *New Sink: opens a dialog to create a new point Sink';
    '   *New Vortex: opens a dialog to create a new point Vortex';
    '   *New Dipole: opens a dialog to create a new point Dipole';
    '';
    '  View Options:';
    '   *Streamlines: toggle the view of streamlines in the flow';
%     '   *Velocity Potential: toggle the view of the potential field';
    '   *Tangent Velocities: toggle the view of tangent velocity arrows';
    '';
    '';
    '';
    'Made by Dylan Morano, Rebecca Cressman, Charles McGann and Alex Shaw';
    '                      for The University of Rhode Island'
    '';
    '**guiFlow uses some similar source code to MathWorks potentialFlowGUI.m (c) but was developed independantly using the latter as reference within the legal rights of its provided license';
    '';
     };
helpdlg(txt,dlgname);

function file_menu_Callback(hObject, eventdata, handles)
% hObject    handle to file_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function screenshot_menu_Callback(hObject, eventdata, handles)
% hObject    handle to screenshot_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[name,path] = uiputfile('*.png','Output Files');
F = getframe(handles.flowplot);
imwrite(F.cdata,[path name],'png');
