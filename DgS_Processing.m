function varargout = DgS_Processing(varargin)
% DGS_PROCESSING MATLAB code for DgS_Processing.fig
%      DGS_PROCESSING, by itself, creates a new DGS_PROCESSING or raises the existing
%      singleton*.
%
%      H = DGS_PROCESSING returns the handle to a new DGS_PROCESSING or the handle to
%      the existing singleton*.
%
%      DGS_PROCESSING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DGS_PROCESSING.M with the given input arguments.
%
%      DGS_PROCESSING('Property','Value',...) creates a new DGS_PROCESSING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DgS_Processing_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DgS_Processing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DgS_Processing

% Jasmine Zhu,2022, jzhu@whoi.edu.

% Last Modified by GUIDE v2.5 02-Jun-2022 08:43:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DgS_Processing_OpeningFcn, ...
                   'gui_OutputFcn',  @DgS_Processing_OutputFcn, ...
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


% --- Executes just before DgS_Processing is made visible.
function DgS_Processing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DgS_Processing (see VARARGIN)

% Choose default command line output

tf=ispc;
if isequal(tf,0)
    if ismac || isunix
    	tf='unix';
        handles.os='/';
    end
else
    tf='pc';
    handles.os='\';
end

% Choose default command line output for DgS_Processing
handles.output = hObject;
set(handles.openInput,'Enable','on');
set(handles.loadNav,'Enable','off');
set(handles.plotFAA,'Enable','off');
set(handles.plotCC,'Enable','off');
set(handles.saveData,'Enable','off');
set(handles.clearAll,'Enable','off');
set(handles.axes1,'Box','on');

guidata(hObject, handles);

% UIWAIT makes DgS_Processing wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DgS_Processing_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in openInput.
function openInput_Callback(hObject, eventdata, handles)
% hObject    handle to openInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% loading parameters from Parameters.m 
Parameters;
% handles.ship = ship;
% handles.sampling = sampling;  
% handles.gravCal = gravCal;  
% handles.g0 = g0;   
% handles.preTie = preTie;   
% handles.preTieTimeString = preTieTimeString;   
% handles.postTie = postTie;   
% handles.postTieTimeString = postTieTimeString;   
% handles.kFactor = kFactor;

%% Compute meter drift 
% only applicable if the post cruise tie is available
d2s = 24*3600;
if postTie >0
    preTieTs = datenum(preTieTimeString)*d2s;  % in sec
    postTieTs = datenum(postTieTimeString)*d2s; % in sec

    driftRate = (postTie-preTie)/(postTieTs-preTieTs); % drift/sec (mGal/s)
else
    driftRate = 0;
end

%% open data file
[fName, fPath] = uigetfile('*','MultiSelect','on');
[yr,mon,dd,hh,mm,ss,grav,rvcc,rve,ral,rax] = loadRawDGS(ship,fName,fPath);

T = datenum(yr,mon,dd,hh,mm,ss);
T = T*d2s;
[~, ind] = unique(T); % remove duplicated signals
T1 = T(ind);
iT = (T1(1):T1(end))'; % 1s interval

iGrav = interp1(T1,grav(ind),iT);  % mGal interpolated raw gravity
iRvcc  = interp1(T1,rvcc(ind),iT); % mGal cross coupling coefficient monitor
iRve   = interp1(T1,rve(ind),iT);  % mGal cross coupling coefficient monitor
iRal   = interp1(T1,ral(ind),iT);  % mGal long axis cross coupling coefficient monitor
iRax   = interp1(T1,rax(ind),iT);  

drift = driftRate*(iT-preTieTs);
rawGrav = gravCal/8388607*iGrav+g0; 		% scale gravity....this is the "raw, unprocessed" gravity in mGal 

handles.dat.grav = kFactor*rawGrav+preTie + drift; % absolute gravity mGal
handles.dat.ve = 0.00001*iRve;            
handles.dat.vcc = 0.00001*iRvcc;     
handles.dat.al = 0.00001*iRal;                
handles.dat.ax = 0.00001*iRax; 

handles.dat.ts = iT; % numeric date in seconds
handles.dat.td = iT/24/3600; % numerical date in days
handles.dat.datetime = datetime(yr,mon,dd,hh,mm,ss);
doy = day(handles.dat.datetime,'dayofyear');
% [doy,~] = date2doy(handles.dat.td);  % day of year
handles.dat.doy = doy;

handles.fPath = fPath;
handles.ship = ship;
set(handles.loadNav,'Enable','on');
set(handles.clearAll,'Enable','on');

guidata(hObject, handles);

% --- Executes on button press in loadNav.
function loadNav_Callback(hObject, eventdata, handles)
% hObject    handle to loadNav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ship = handles.ship;
[fName, fPath] = uigetfile('*','MultiSelect','on');
gps = loadINGGA(ship,fName,fPath);

handles.dat.lon = interp1(gps.Ts,gps.lon,handles.dat.ts,[],'extrap');
handles.dat.lat  = interp1(gps.Ts,gps.lat,handles.dat.ts,[],'extrap');

ndata = length(handles.dat.lon);
    
% set(handles.LatCorr,'Enable','on');
% set(handles.EotvosCorr,'Enable','on');
% set(handles.TideCorr,'Enable','on');


handles.dat.elipsoidHeight=zeros(ndata,1);
handles.dat.latCorr=-WGS84(handles.dat.lat)-FAC2ord(deg2rad(handles.dat.lat),handles.dat.elipsoidHeight);

eotvos=calc_eotvos_full(handles.dat.lat,handles.dat.lon,handles.dat.elipsoidHeight,1);

handles.dat.eotvos=eotvos'; % Eotvos includes eotvos and vertical acceleration

handles.dat.tideCorr=LongmanTidePredictor(handles.dat.lon,handles.dat.lat,handles.dat.td);

handles.dat.FAA=handles.dat.grav...
            + handles.dat.eotvos...
            + handles.dat.tideCorr...
            + handles.dat.latCorr;

set(handles.plotFAA,'Enable','on');

guidata(hObject, handles);


% --- Executes on selection change in plotting.
function plotFAA_Callback(hObject, eventdata, handles)
% hObject    handle to plotting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns plotting contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plotting

%%

cla(handles.axes1);
set(handles.axes1,'Visible','on');
axes(handles.axes1);


prompt = {'Enter a value of filter time (sec)'};
dlgtitle = 'Filter Time';
definput = {'240'};
answer = inputdlg(prompt,dlgtitle,[1 40],definput);
handles.filterT = str2double(answer{1});

if handles.filterT == 0  %% No filter 
    handles.filt = 0;
    handles.dat.fFAA = handles.dat.FAA;
    handles.dat.fVe = handles.dat.ve;
    handles.dat.fVcc = handles.dat.vcc;
    handles.dat.fAl = handles.dat.al;
    handles.dat.fAx = handles.dat.ax';
    
        
else
    handles.filt = 1;
    [~,fFAA] = gaussfilt(handles.dat.ts,handles.dat.FAA,handles.filterT);
    [~,fVe] = gaussfilt(handles.dat.ts,handles.dat.ve,handles.filterT);
    [~,fVcc] = gaussfilt(handles.dat.ts,handles.dat.vcc,handles.filterT);
    [~,fAl] = gaussfilt(handles.dat.ts,handles.dat.al,handles.filterT);
    [~,fAx] = gaussfilt(handles.dat.ts,handles.dat.ax,handles.filterT);
    handles.dat.fFAA = fFAA';
    handles.dat.fVe = fVe';
    handles.dat.fVcc = fVcc';
    handles.dat.fAl = fAl';
    handles.dat.fAx = fAx';
    
    handles.dat.fFAA(end-handles.filterT:end)=handles.dat.fFAA(end-handles.filterT);
    handles.dat.fVe(end-handles.filterT:end)=handles.dat.fVe(end-handles.filterT);
    handles.dat.fVcc(end-handles.filterT:end)=handles.dat.fVcc(end-handles.filterT);
    handles.dat.fAl(end-handles.filterT:end)=handles.dat.fAl(end-handles.filterT);
    handles.dat.fAx(end-handles.filterT:end)=handles.dat.fAx(end-handles.filterT);
    
    handles.dat.fFAA(1:handles.filterT)=handles.dat.fFAA(handles.filterT);
    handles.dat.fVe(1:handles.filterT)=handles.dat.fVe(handles.filterT);
    handles.dat.fVcc(1:handles.filterT)=handles.dat.fVcc(handles.filterT);
    handles.dat.fAl(1:handles.filterT)=handles.dat.fAl(handles.filterT);
    handles.dat.fAx(1:handles.filterT)=handles.dat.fAx(handles.filterT);

end


plot(handles.dat.doy,handles.dat.fFAA,'k','linewidth',1)
hold on
% 
ylabel('mGals','FontSize', 14,'FontWeight','bold');
xlabel('Day of Year','FontSize', 14,'FontWeight','bold');
set(handles.plotCC,'Enable','on');
guidata(hObject, handles);



% --- Executes on button press in plotCC.
function plotCC_Callback(hObject, eventdata, handles)
% hObject    handle to plotCC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try 
    delete(handles.plt);
catch
end
%% cross coupling correction

% select ship cog between [6,15] (normal speed)
cog = sqrt((diff(handles.dat.lon)).^2 + (diff(handles.dat.lat)).^2)*60*3600;  % speed over ground (kn)
cog = [cog(1);cog];

prompt = {'Enter minimum cog (kn):','Enter maximum cog (kn):'};
dlgtitle = 'Ship''s normal speed range';
dims = [1 100];
definput = {'6','15'};
answer = inputdlg(prompt,dlgtitle,dims,definput);
cog_min = str2double(answer{1});
cog_max = str2double(answer{2});

k = find(cog>=cog_min & cog<=cog_max);
g = handles.dat.fFAA(k);
fve = handles.dat.fVe(k);
fvcc = handles.dat.fVcc(k);
fal = handles.dat.fAl(k);
fax = handles.dat.fAx(k);

% Perform a double derivation of Free Air gravity and each of the monitor Channels
% % 
d=convn(g,tay10','same');
ddg=convn(d,tay10','same');
% % 
d=convn(fal,tay10','same');
ddal=convn(d,tay10','same');
 
d=convn(fax,tay10','same');
ddax=convn(d,tay10','same');
 
d=convn(fve,tay10','same');
ddve=convn(d,tay10','same');
 
d=convn(fvcc,tay10','same');
ddvcc=convn(d,tay10','same');
% % % 
% % % % % 
% eliminate the ends of the data
ddg=ddg(10:end-11);
ddve=ddve(10:end-11);
ddal=ddal(10:end-11);
ddax=ddax(10:end-11);
ddvcc=ddvcc(10:end-11);
% % % 
% filter to eliminate hightfrequency
% noise generated by the double derivation
%  Calculate the filter coefficients
fl=10;    % filter length
tapsCorr=2*fl; % 
BM = fir1(tapsCorr,1/tapsCorr,blackman(tapsCorr+1));
% % %  
% low pass filter 
fddg=filter(BM,1,ddg);
fddve=filter(BM,1,ddve);
fddal=filter(BM,1,ddal);
fddax=filter(BM,1,ddax);
fddvcc=filter(BM,1,ddvcc);

% eliminate filter transients
fddg=fddg(tapsCorr:end);
fddve=fddve(tapsCorr:end); 
fddal=fddal(tapsCorr:end); 
fddax=fddax(tapsCorr:end); 
fddvcc=fddvcc(tapsCorr:end); 
% % % 
%--------------- end filtering 

% solve the curvatures equation by least equares
% minimum vovariance method
cc=[fddve fddvcc fddal fddax];
mycoef=lscov(cc,-fddg);
format long
handles.dat.P=mycoef;
% % % 
handles.dat.ccFAA = handles.dat.fFAA...
        + handles.dat.P(1)*handles.dat.fVe...
        + handles.dat.P(2)*handles.dat.fVcc...
        + handles.dat.P(3)*handles.dat.fAl...
        + handles.dat.P(4)*handles.dat.fAx;

handles.plt = plot(handles.dat.doy,handles.dat.ccFAA,'r','linewidth',1);
hold on
legend({'Free Air','CC Corrected'},'FontSize',12);
set(handles.saveData,'Enable','on');

guidata(hObject, handles);



% % % 
% --- Executes on button press in saveData.
function saveData_Callback(hObject, eventdata, handles)
% hObject    handle to saveData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[ccFile,ccPath] = uiputfile([handles.fPath 'gravity.mat']); 
f = waitbar(0,'Please wait...');
waitbar(0.1 ,f,'Saving...');
gdata.timeString = datestr(handles.dat.td,'yyyy-mm-dd HH:MM:SS.FFF');
waitbar(0.5 ,f,'Continuing...');
gdata.lon = handles.dat.lon;
gdata.lat = handles.dat.lat;
gdata.measuredGrav = handles.dat.grav;
gdata.ve = handles.dat.ve;
gdata.vcc = handles.dat.vcc;
gdata.al = handles.dat.al;
gdata.ax = handles.dat.ax;
pause(1)

gdata.latCorr = handles.dat.latCorr;
gdata.eotvos = handles.dat.eotvos;
gdata.tideCorr = handles.dat.tideCorr;
gdata.FAA = handles.dat.FAA;
gdata.fiteredFAA = handles.dat.fFAA;
gdata.ccFAA = handles.dat.ccFAA;

gdata.ve_gain = handles.dat.P(1);
gdata.vcc_gain = handles.dat.P(2);
gdata.al_gain = handles.dat.P(3);
gdata.ax_gain = handles.dat.P(4);

save([ccPath ccFile],'gdata');
waitbar(1,f,'Finished!');
guidata(hObject, handles);


% --- Executes on button press in clearall.
function clearAll_Callback(hObject, eventdata, handles)
% hObject    handle to clearall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla(handles.axes1);
set(handles.axes1,'Visible','on');
axes(handles.axes1);
delete(findall(findall(gcf,'Type','axe'),'Type','text'))

handles = rmfield(handles,'dat');
% clear all
set(handles.openInput,'Enable','on');
set(handles.loadNav,'Enable','off');
set(handles.plotFAA,'Enable','off');
set(handles.plotCC,'Enable','off');
set(handles.saveData,'Enable','off');
guidata(hObject, handles);



% ------------------ Create functions ---------------------


% --- Executes during object creation, after setting all properties.
function plotFAA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function plotCC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




%----------------------------------------------------------------------
%         sub functions
%----------------------------------------------------------------------


function [yr,mon,day,hh,mm,ss,grav,rvcc,rve,ral,rax] = loadRawDGS(ship,fName,fPath)
if contains(ship,'Thompson')
	fmt = ['%2d/%2d/%4d%2d:%2d:%f%s' repmat('%d',1,13) repmat('%f',1,5) '%*[^\n]'];
% elseif contains(ship,'Armstrong')
%     fmt = ['DGS %04d/%02d/%02d %02d:%02d:%f DgS %s' repmat('%d',1,13) repmat('%f',1,5) '%*[^\n]'];
end

k = count(fName,'.');
nFiles = length(k);
f = waitbar(0,'Please wait...');
pause(0.5)
grav = [];
yr  = []; mon = []; day = [];
hh  = []; mm  = []; ss  = [];
rvcc = []; rve = []; ral = []; rax = [];
for i=1:nFiles
    waitbar(0.2*i ,f,'Loading your data');
    pause(1)
    if nFiles > 1
        fid=fopen([fPath,fName{i}],'r');
    else
        fid=fopen([fPath,fName],'r');
    end
    C = textscan(fid,fmt,'delimiter',',');
    fclose(fid);
    [yr0,mon0,day0,hh0,mm0,ss0,grav0,rvcc0,rve0,ral0,rax0] = parsingRawDGS(ship,C);
    yr = [yr;yr0];
    mon = [mon;mon0];
    day = [day;day0];
    hh  = [hh;hh0];
    mm  = [mm;mm0];
    ss  = [ss;ss0];
    grav = [grav;grav0];
    rvcc = [rvcc;rvcc0];
    rve = [rve;rve0];
    ral = [ral;ral0];
    rax = [rax;rax0];
    
        
end
waitbar(.8,f,'Parsing your data');
pause(1)
waitbar(1,f,'Finishing');
pause(1)
close(f)
 
% ---------------------------

function [yr,mon,day,hh,mm,ss,grav,rvcc,rve,ral,rax] = parsingRawDGS(ship,C) 
if contains(ship,'Thompson')
    mon = double(C{1});
    day = double(C{2});
    yr  = double(C{3});
% elseif contains(ship,'Armstrong')
%     yr  = double(C{1});
%     mon = double(C{2});
%     day = double(C{3});
end
hh = double(C{4});
mm = double(C{5});
ss = double(C{6});
grav=double(C{8});   
rvcc=double(C{15});        % mGal vcc monitor
rve=double(C{16});        % mGal ve monitor
ral=double(C{17});        % mGal al monitor
rax=double(C{18});

%-------------------------------------
% -----------------------------------------------
function gps = loadINGGA(ship,fName,fPath)
if contains(ship,'Thompson')
	fmt = '%2d/%2d/%4d%2d:%2d:%f$INGGA%*s%2d%f%s%3d%f%s%*[^\n]';
    
% elseif contains(ship,'Armstrong')
%     fmt = ['DGS %04d/%02d/%02d %02d:%02d:%f DgS %s' repmat('%d',1,13) repmat('%f',1,5) '%*[^\n]'];
end

k = count(fName,'.');
nFiles = length(k);
f = waitbar(0,'Please wait...');
pause(0.5)
time  = [];
lat = [];
lon = [];

for i=1:nFiles
	waitbar(0.2*i ,f,['Loading nav data' num2str(i)]);
    pause(1)
    try
        fid=fopen([fPath,fName{i}],'r');
    catch
        fid=fopen([fPath,fName],'r');
    end
    C = textscan(fid,fmt,'delimiter',',');
    fclose(fid);
    [time0,lat0,lon0] = parsingINGGA(ship,C);
    time = [time;time0];
    lat  = [lat;lat0];
    lon  = [lon;lon0];  
end
waitbar(.8,f,'Parsing nav data');
pause(1)
close(f)

yr  = time(:,1);
mon = time(:,2);
day = time(:,3);
hh  = time(:,4);
mm  = time(:,5);
ss  = time(:,6);
time_all=datenum(yr,mon,day,hh,mm,ss)*24*3600;
[~, ind] = unique(time_all); 
gps.Ts = time_all(ind);
gps.lon = lon(ind);
gps.lat = lat(ind);


function [time,lat,lon] = parsingINGGA(ship,C)

if contains(ship,'Thompson')
    time = double([C{3} C{1} C{2} C{4} C{5} C{6}]);
    latD = double(C{7});
    latM = double(C{8});
    latNS = C{9};
    lat = latD + latM/60;
    k = strcmp(latNS,'S');
    if ~isempty(k)
        lat(k) = -lat(k);
    end
    clear k
    lonD = double(C{10});
    lonM = double(C{11});
    lonEW = C{12};
    lon = lonD + lonM/60;
    k = strcmp(lonEW,'W');
    if ~isempty(k)
        lon(k) = -lon(k);
    end
% elseif contains(ship,'Armstrong')
    
end
