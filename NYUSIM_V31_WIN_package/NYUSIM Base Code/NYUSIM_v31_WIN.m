% NYUSIM Version 3.0, developed by:
%
% Shihao Ju, Shu Sun, Mathew K. Samimi - NYU WIRELESS, Nov. 2021
%
% This script runs NYUSIM.
%
% Copyright @ 2021 NYU

function NYUSIM_v31_WIN
%% Clear all variables and set runningFolder as the current path
clear; close all; runningFolder = pwd; 
if (~isdeployed)
    addpath(runningFolder);
end

%% Background
bgGUI = [0.8 0.8 0.8];
% figGUI = figure('Visible','on','Position',[70,50,880,580],'Color',bgGUI); 
figGUI = figure('Visible','on','Position',[100,100,1280,650],'Color',bgGUI); 
set(figGUI,'Resize','off');

% hLogo = axes('Position',[-0.108,0.86,1.2,0.14]);
hLogo = axes('Units','pixels','Position',[0,550,1280,100]);
[X,map] = imread('header.png');
imshow(X,map,'Parent',hLogo); clear hLogo X map;

bgColor2 = [1 1 1]; FS = 10;
hPanel0 = uipanel('Parent',figGUI,'Units','pixels','Position',[10,460,1260,90],'BackgroundColor',bgColor2);
txt = uicontrol('Style','text','Position',[36 530 250 15],'String','1. To begin the simulator, click Start',...
    'FontSize',FS,'FontWeight','bold','BackgroundColor',bgColor2);
txt = uicontrol('Style','text','Position',[33 515 250 15],'String','2. Set your input parameters below',...
    'FontSize',FS,'FontWeight','bold','BackgroundColor',bgColor2);
txt = uicontrol('Style','text','Position',[29 500 220 15],'String','3. Select a folder to save files',...
    'FontSize',FS,'FontWeight','bold','BackgroundColor',bgColor2);
txt = uicontrol('Style','text','Position',[40 485 90 15],'String','4. Click Run',...
    'FontSize',FS,'FontWeight','bold','BackgroundColor',bgColor2);
txt = uicontrol('Style','text','Position',[24 470 440 15],'String','5. To run another simulation, click Reset, and repeat Steps 2-4',...
    'FontSize',FS,'FontWeight','bold','BackgroundColor',bgColor2);
rs = uicontrol('Position',[970 480 120 60],'String','Start','Callback',@rs_Callback);
set(rs,'Foregroundcolor',[0 0 0],'Backgroundcolor',[1 1 0],'FontSize',14,'Fontname','Calibri','Fontweight','bold');
ex = uicontrol('Style','pushbutton','Position',[1100 10 120 60],'String','Exit','Callback',@ex_Callback);
set(ex,'Foregroundcolor',[1 1 1],'Backgroundcolor',[1 0 0],'FontSize',14,'Fontname','Calibri','Fontweight','bold');

%% Exit function
function ex_Callback(~,~) 
    clear; close all; exit;
end

%% Start function
function rs_Callback(~,~) 

%% Set GUI background size and color
set(figGUI, 'HandleVisibility', 'off'); close all; set(figGUI, 'HandleVisibility', 'on');
Reset = uicontrol('Position',[1100 480 120 60],'String','Reset','Callback',@Reset_Callback);
set(Reset,'Foregroundcolor',[1 1 1],'Backgroundcolor',[0 0.4 0],'FontSize',14,'Fontname','Calibri','Fontweight','bold');

%% Parameter Initialization
distType = 'Standard (10-500 m)'; 
sceType = 'UMi'; 
envType = 'LOS'; 
TxArrayType = 'ULA'; 
RxArrayType = 'ULA'; 
f = 28; RFBW = 800; dmin = 10; dmax = 50; TXPower = 30; N = 1; 
p = 1013.25; u = 50; temp = 20; RR = 0; h_BS = 3; h_MS = 1.5;
Pol = 'Co-Pol';Fol = 'No';
dFol = 0; folAtt = 0.4;

Nt = 1; Nr = 1; dTxAnt = 0.5; dRxAnt = 0.5;
Wt = 1; Wr = 1; theta_3dB_TX = 10; phi_3dB_TX = 10; 
theta_3dB_RX = 10; phi_3dB_RX = 10;
fileType = 'Text File'; 

% Indicator
scIdc = 'On'; hbIdc = 'On';

% Spatial consistency parameters
trackType = 'Linear';
d_co = 10;d_co_los = 15; direction = 45;
d_update = 1;movDistance = 40; velocity = 1;side_length = 10;
orient = 'Clockwise';o2iLoss = 'No';o2iType = 'Low Loss';transExist = 'Yes';

% Human blockage parameters
default = 'No';SEmean = 14.4; lambdaDecay = 0.2; lambdaShad = 8.1; 
lambdaRise = 7.8; lambdaUnshad = 6.7; 

%% Panel 1 for channel parameters  
bgColor1 = [1 1 1]; 
hPanel1 = uipanel('Title','Channel Parameters','FontSize',10,'Fontweight','bold','parent',figGUI,...
    'Units','pixels','Position',[10,10,350,445],'BackgroundColor',bgColor1);

% Scenario
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[15 405 100 20],...
    'String','Scenario','BackgroundColor',bgColor1);
scePopup = uicontrol('Parent',hPanel1,'Style','popupmenu','String',{'UMi','UMa','RMa','InH'},...
          'Position',[15,390,100,20],'Callback',@scePopup_Callback);
      
% freq
txtFreq = uicontrol('Parent',hPanel1,'Style','text','Position',[15 368 130 20],'String',...
    'Frequency (0.5-100 GHz)','BackgroundColor',bgColor1);
fEdit = uicontrol('Parent',hPanel1,'style','edit','String',num2str(f),'position',[15,353,100,20],'Callback',@fEdit_Callback);
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[115 351 30 20],'String','GHz','BackgroundColor',bgColor1);

% RFBW
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[15 330 140 20],'String',...
    'RF Bandwidth (0-800 MHz)','BackgroundColor',bgColor1);
bwEdit = uicontrol('Parent',hPanel1,'style','edit','String',num2str(RFBW),'position',[15,315,100,20],'Callback',@bwEdit_Callback);
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[115 313 30 20],'String',...
    'MHz','BackgroundColor',bgColor1);

% distance popup
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[15 293 130 20],'String',...
    'Distance Range Option','BackgroundColor',bgColor1);
distPopup = uicontrol('Parent',hPanel1,'Style','popupmenu','String',{'Standard (10-500 m)',...
    'Extended (10-10,000 m)','Indoor (5-50 m)'},'Position',[15,278,130,20],'Callback',@distPopup_Callback);

% Environment      
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[15 255 100 20],'String','Environment','BackgroundColor',bgColor1);
envPopup = uicontrol('Parent',hPanel1,'Style','popupmenu','String',{'LOS','NLOS'},...
          'Position',[15,240,100,20],'Callback',@envPopup_Callback);
      
% T-R seperation distance      
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[15 215 120 20],'String',...
    'T-R Separation Distance (5-50/10-500/10,000 m)','BackgroundColor',bgColor1);
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[15 200 120 20],'String',...
    ['Lower Bound'],'BackgroundColor',bgColor1);
dminEdit = uicontrol('Parent',hPanel1,'style','edit','String',num2str(dmin),'position',[15 185 100 20],'Callback',@dminEdit_Callback);
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[115 183 20 20],'String','m','BackgroundColor',bgColor1);
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[15 165 120 20],'String',...
    ['Upper Bound'],'BackgroundColor',bgColor1);
dmaxEdit = uicontrol('Parent',hPanel1,'style','edit','String',num2str(dmax),'position',[15 150 100 20],'Callback',@dmaxEdit_Callback);
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[115 148 20 20],'String','m','BackgroundColor',bgColor1);


% TX power
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[15 130 120 20],'String',...
    ['TX Power (0-50 dBm)'],'BackgroundColor',bgColor1);
PtEdit = uicontrol('Parent',hPanel1,'style','edit','String',num2str(TXPower),'position',[15 115 100 20],'Callback',@PtEdit_Callback);
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[115 113 30 20],'String','dBm','BackgroundColor',bgColor1);

% BS height
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[15 95 120 20],'String','Base Station Height (10-150 m)','BackgroundColor',bgColor1);
hBS = uicontrol('Parent',hPanel1,'style','edit','String',num2str(h_BS),'position',[15 80 100 20],'Callback',@hBS_Callback);
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[115 78 20 20],'String','m','BackgroundColor',bgColor1);

% MS height
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[15 60 120 20],'String','User Terminal Height (1-10 m)','BackgroundColor',bgColor1);
hMS = uicontrol('Parent',hPanel1,'style','edit','String',num2str(h_MS),'position',[15 45 100 20],'Callback',@hMS_Callback);
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[115 43 20 20],'String','m','BackgroundColor',bgColor1);

% Number of RX locations
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[15 25 120 20],'String','Number of RX Locations','BackgroundColor',bgColor1);
nRun = uicontrol('Parent',hPanel1,'style','edit','String',num2str(N),'position',[15 5 100 20],'Callback',@nRun_Callback);

% Second column in channel parameters
% Pressure
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[180 405 130 20],'String',...
    'Barometric Pressure','BackgroundColor',bgColor1);
pEdit = uicontrol('Parent',hPanel1,'style','edit','String',num2str(p),'position',[180,390,100,20],'Callback',@pEdit_Callback);
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[280 388 30 20],'String','mbar','BackgroundColor',bgColor1);

% Humidity
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[180 365 100 20],'String',...
    'Humidity (0-100%)','BackgroundColor',bgColor1);
uEdit = uicontrol('Parent',hPanel1,'style','edit','String',num2str(u),'position',[180,350,100,20],'Callback',@uEdit_Callback);
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[280 348 20 20],'String','%','BackgroundColor',bgColor1);

% Temperature
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[180 330 100 20],...
    'String','Temperature','BackgroundColor',bgColor1);
tEdit = uicontrol('Parent',hPanel1,'style','edit','String',num2str(temp),'position',[180,315,100,20],'Callback',@tEdit_Callback);
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[280 313 20 20],'String',sprintf('%cC', char(176)),'BackgroundColor',bgColor1);

% Polarization
txt = uicontrol('Parent',hPanel1,'Style','text','Position',[180 295 100 20],...
    'String','Polarization','BackgroundColor',bgColor1);
polPopup = uicontrol('Parent',hPanel1,'Style','popupmenu','String',{'Co-Pol','X-Pol','Co/X-Pol','All-Pol'},...
          'Position',[180,280,100,20],'Callback',@polPopup_Callback);

% All Polarization Indicator
% txt = uicontrol('Parent',hPanel1,'Style','text','Position',[180 295 100 20],...
%     'String','Polarization','BackgroundColor',bgColor1);
% polCheckbox = uicontrol('Parent',hPanel1,'Style','checkbox','String',{'All-Pol'},...
%           'Position',[250,280,60,20],'Callback',@polCheckbox_Callback,'BackgroundColor',[1,1,1]);
      
% Rain rate
txtRain1 = uicontrol('Parent',hPanel1,'Style','text','Position',[180 255 120 20],...
    'String','Rain Rate (0-150 mm/hr)','BackgroundColor',bgColor1);
tEditRain = uicontrol('Parent',hPanel1,'style','edit','String',num2str(RR),'position',[180,240,100,20],'Callback',@RREdit_Callback);
txtRain2 = uicontrol('Parent',hPanel1,'Style','text','Position',[280 238 35 20],'String','mm/hr','BackgroundColor',bgColor1);

% Foliage loss
txtFol = uicontrol('Parent',hPanel1,'Style','text','Position',[180 215 100 20],...
    'String','Foliage Loss','BackgroundColor',bgColor1);
folPopup = uicontrol('Parent',hPanel1,'Style','popupmenu','String',{'No','Yes'},...
          'Position',[180,200,100,20],'Callback',@folPopup_Callback);

% Dist within foliage      
txtDistFol1 = uicontrol('Parent',hPanel1,'Style','text','Position',[180 175 120 20],...
    'String','Distance Within Foliage','BackgroundColor',bgColor1);
dFolEdit = uicontrol('Parent',hPanel1,'style','edit','String',num2str(dFol),'position',[180,160,100,20],'Callback',@dFolEdit_Callback);
txtDistFol2 = uicontrol('Parent',hPanel1,'Style','text','Position',[280 158 20 20],'String','m','BackgroundColor',bgColor1);

% Foliage att.
txtFolAtt1 = uicontrol('Parent',hPanel1,'Style','text','Position',[180 140 120 20],...
    'String','Foliage Attenuation','BackgroundColor',bgColor1);
folAttEdit = uicontrol('Parent',hPanel1,'style','edit','String',num2str(folAtt),'position',[180,125,100,20],'Callback',@folAttEdit_Callback);
txtFolAtt2 = uicontrol('Parent',hPanel1,'Style','text','Position',[280 123 30 20],'String','dB/m','BackgroundColor',bgColor1);

% O2I loss
txtO2I1 = uicontrol('Parent',hPanel1,'Style','text','Position',[180 105 120 20],...
    'String','Outdoor to Indoor (O2I)','BackgroundColor',bgColor1);
txtO2I2 = uicontrol('Parent',hPanel1,'Style','text','Position',[180 90 120 20],...
    'String','Penetration Loss','BackgroundColor',bgColor1);
o2iLossPopup = uicontrol('Parent',hPanel1,'Style','popupmenu','String',{'No','Yes'},...
          'Position',[180,75,100,20],'Callback',@o2iLossPopup_Callback);
      
% O2I type
txtO2I3 = uicontrol('Parent',hPanel1,'Style','text','Position',[180 50 100 20],...
    'String','O2I Loss Type','BackgroundColor',bgColor1);
o2iTypePopup = uicontrol('Parent',hPanel1,'Style','popupmenu','String',{'Low Loss','High Loss'},...
          'Position',[180,35,100,20],'Callback',@o2iTypePopup_Callback);
set(o2iLossPopup,'enable','off');
set(o2iTypePopup,'enable','off');
set(txtO2I1,'enable','off');
set(txtO2I2,'enable','off');
set(txtO2I3,'enable','off'); 

%% Panel 2 for antenna properties
bgColor = [1 1 1]; 
hPanel2 = uipanel('Title','Antenna Properties','FontSize',10,'Fontweight','bold','parent',figGUI,...
    'Units','pixels','Position',[365,10,350,445],'BackgroundColor',bgColor);        

% TX array type
txt = uicontrol('Parent',hPanel2,'Style','text','Position',[15 405 130 20],'String','TX Array Type','BackgroundColor',bgColor);
TxArrayPopup = uicontrol('Parent',hPanel2,'Style','popupmenu','String',{'ULA','URA'},...
          'Position',[40,390,80,20],'Callback',@TxArrayPopup_Callback);

% RX array type      
txt = uicontrol('Parent',hPanel2,'Style','text','Position',[180 405 130 20],'String','RX Array Type','BackgroundColor',bgColor);
RxArrayPopup = uicontrol('Parent',hPanel2,'Style','popupmenu','String',{'ULA','URA'},...
          'Position',[205,390,80,20],'Callback',@RxArrayPopup_Callback);

% # of TX ant.      
txt = uicontrol('Parent',hPanel2,'Style','text','Position',[15 350 140,30],'String','Number of TX Antenna Elements Nt','BackgroundColor',bgColor);
nTxAnt = uicontrol('Parent',hPanel2,'style','edit','String',num2str(Nt),'position',[40 330 80 20],'Callback',@nTxAnt_Callback);

% # of RX ant. 
txt = uicontrol('Parent',hPanel2,'Style','text','Position',[180 350 140 30],'String','Number of RX Antenna Elements Nr','BackgroundColor',bgColor);
nRxAnt = uicontrol('Parent',hPanel2,'style','edit','String',num2str(Nr),'position',[205 330 80 20],'Callback',@nRxAnt_Callback);

% TX ant. spacing
txt = uicontrol('Parent',hPanel2,'Style','text','Position',[15 295 140 30],'String',...
    'TX Antenna Spacing (in wavelength, 0.1-100)','BackgroundColor',bgColor);
distTxAnt = uicontrol('Parent',hPanel2,'style','edit','String',num2str(dTxAnt),'position',[40 275 80 20],'Callback',@distTxAnt_Callback);

% RX ant. spacing
txt = uicontrol('Parent',hPanel2,'Style','text','Position',[180 295 140 30],'String',...
    'RX Antenna Spacing (in wavelength, 0.1-100)','BackgroundColor',bgColor);
distRxAnt = uicontrol('Parent',hPanel2,'style','edit','String',num2str(dRxAnt),'position',[205 275 80 20],'Callback',@distRxAnt_Callback);


% TX ant. per row
txt = uicontrol('Parent',hPanel2,'Style','text','Position',[15 240 140 30],'String',...
    'Number of TX Antenna Elements Per Row Wt','BackgroundColor',bgColor);
nnTxAnt = uicontrol('Parent',hPanel2,'style','edit','String',num2str(Wt),'position',[40 220 80 20],'Callback',@nnTxAnt_Callback);

% RX ant. per row
txt = uicontrol('Parent',hPanel2,'Style','text','Position',[180 240 140 30],'String',...
    'Number of RX Antenna Elements Per Row Wr','BackgroundColor',bgColor);
nnRxAnt = uicontrol('Parent',hPanel2,'style','edit','String',num2str(Wr),'position',[205 220 80 20],'Callback',@nnRxAnt_Callback);

% TX azi
txt = uicontrol('Parent',hPanel2,'Style','text','Position',[15 185 140 30],'String',...
    ['TX Antenna Azimuth HPBW (7',sprintf('%c- 360', char(176)),sprintf('%c)', char(176))],'BackgroundColor',bgColor);
TxAziBW = uicontrol('Parent',hPanel2,'style','edit','String',num2str(theta_3dB_TX),'position',[40 165 80 20],'Callback',@TxAziBW_Callback);
txt = uicontrol('Parent',hPanel2,'Style','text','Position',[120 175 10 10],'String',[sprintf('%c', char(176))],'BackgroundColor',bgColor);

% TX ele
txt = uicontrol('Parent',hPanel2,'Style','text','Position',[15 130 140 30],'String',...
    ['TX Antenna Elevation HPBW (7',sprintf('%c- 45', char(176)),sprintf('%c)', char(176))],'BackgroundColor',bgColor);
TxElvBW = uicontrol('Parent',hPanel2,'style','edit','String',num2str(phi_3dB_TX),'position',[40 110 80 20],'Callback',@TxElvBW_Callback);
txt = uicontrol('Parent',hPanel2,'Style','text','Position',[120 120 10 10],'String',[sprintf('%c', char(176))],'BackgroundColor',bgColor);

% RX azi
txt = uicontrol('Parent',hPanel2,'Style','text','Position',[180 185 140 30],'String',...
    ['RX Antenna Azimuth HPBW (7',sprintf('%c- 360', char(176)),sprintf('%c)', char(176))],'BackgroundColor',bgColor);
RxAziBW = uicontrol('Parent',hPanel2,'style','edit','String',num2str(theta_3dB_RX),'position',[205 165 80 20],'Callback',@RxAziBW_Callback);
txt = uicontrol('Parent',hPanel2,'Style','text','Position',[285 175 10 10],'String',[sprintf('%c', char(176))],'BackgroundColor',bgColor);

% RX ele
txt = uicontrol('Parent',hPanel2,'Style','text','Position',[180 130 140 30],'String',...
    ['RX Antenna Elevation HPBW (7',sprintf('%c- 45', char(176)),sprintf('%c)', char(176))],'BackgroundColor',bgColor);
RxElvBW = uicontrol('Parent',hPanel2,'style','edit','String',num2str(phi_3dB_RX),'position',[205 110 80 20],'Callback',@RxElvBW_Callback);
txt = uicontrol('Parent',hPanel2,'Style','text','Position',[285 120 10 10],'String',[sprintf('%c', char(176))],'BackgroundColor',bgColor);

%% Panel 3 Spatial consistency parameters
bgColor = [1 1 1]; 
hPanel3 = uipanel('Title','Spatial Consistency Parameters','FontSize',10,'Fontweight','bold','parent',figGUI,...
    'Units','pixels','Position',[720,190,350,265],'BackgroundColor',bgColor);

bg = uibuttongroup('Parent',figGUI,'Visible','off','Unit','pixels',...
                  'Position',[720,460,160,40],'Title','Spatial consistency',...
                  'SelectionChangedFcn',@bg_Callback);

r1 = uicontrol(bg,'Style',...
                  'radiobutton',...
                  'String','On',...
                  'Position',[0 0 50 30],...
                  'HandleVisibility','off');
              
r2 = uicontrol(bg,'Style','radiobutton',...
                  'String','Off',...
                  'Position',[60 0 50 30],...
                  'HandleVisibility','off');
bg.Visible = 'on';

% Correlation distance of shadow fading     
txt = uicontrol('Parent',hPanel3,'Style','text','Position',[15 215 140 30],...
    'String','Correlation Distance of Shadow Fading (5-60 m)','BackgroundColor',bgColor1);
d_coEdit = uicontrol('Parent',hPanel3,'style','edit','String',num2str(d_co),'position',[40,195,80,20],'Callback',@d_coEdit_Callback);
txt = uicontrol('Parent',hPanel3,'Style','text','Position',[120 193 20 20],'String','m','BackgroundColor',bgColor1);

% Correlation distance of LOS/NLOS condition      
txt = uicontrol('Parent',hPanel3,'Style','text','Position',[15 160 150 30],...
    'String','Correlation Distance of LOS/NLOS Condition (5-60 m)','BackgroundColor',bgColor1);
d_co_losEdit = uicontrol('Parent',hPanel3,'style','edit','String',num2str(d_co_los),'position',[40,140,80,20],'Callback',@d_co_losEdit_Callback);
txt = uicontrol('Parent',hPanel3,'Style','text','Position',[120 138 20 20],'String','m','BackgroundColor',bgColor1);

% Track type
txt = uicontrol('Parent',hPanel3,'Style','text','Position',[15 118 140 20],...
    'String','User Track Type','BackgroundColor',bgColor1);
trackTypePopup = uicontrol('Parent',hPanel3,'Style','popupmenu','String',{'Linear','Hexagon'},...
          'Position',[40,100,80,20],'Callback',@trackTypePopup_Callback);

% Moving distance
txt = uicontrol('Parent',hPanel3,'Style','text','Position',[15 75 140 20],...
    'String','Moving Distance (1-100 m)','BackgroundColor',bgColor1);
movDistanceEdit = uicontrol('Parent',hPanel3,'style','edit','String',num2str(movDistance),'position',[40,55,80,20],'Callback',@movDistanceEdit_Callback);
txt = uicontrol('Parent',hPanel3,'Style','text','Position',[120 53 20 20],'String','m','BackgroundColor',bgColor1);

% Segment Transitions
txt = uicontrol('Parent',hPanel3,'Style','text','Position',[15 30 140 20],...
    'String','Segment Transitions','BackgroundColor',bgColor1);
transPopup = uicontrol('Parent',hPanel3,'Style','popupmenu','String',{'Yes','No'},...
          'Position',[40,10,80,20],'Callback',@transPopup_Callback);

% Update Distance
txt = uicontrol('Parent',hPanel3,'Style','text','Position',[180 225 140 20],...
    'String','Update Distance','BackgroundColor',bgColor1);
d_updateEdit = uicontrol('Parent',hPanel3,'style','edit','String',num2str(d_update),'position',[205,205,80,20],'Callback',@d_updateEdit_Callback);
txt = uicontrol('Parent',hPanel3,'Style','text','Position',[285 203 20 20],'String','m','BackgroundColor',bgColor1);

% Moving direction
txt = uicontrol('Parent',hPanel3,'Style','text','Position',[180 170 140 30],'String',...
    ['Moving direction (0',sprintf('%c- 360', char(176)),sprintf('%c)', char(176))],'BackgroundColor',bgColor);
directionEdit = uicontrol('Parent',hPanel3,'style','edit','String',num2str(direction),'position',[205 160 80 20],'Callback',@directionEdit_Callback);
txt = uicontrol('Parent',hPanel3,'Style','text','Position',[285 170 10 10],'String',[sprintf('%c', char(176))],'BackgroundColor',bgColor);

% Velocity
txt = uicontrol('Parent',hPanel3,'Style','text','Position',[180 135 140 20],...
    'String','User Velocity (1-30 m/s)','BackgroundColor',bgColor1);
velocityEdit = uicontrol('Parent',hPanel3,'style','edit','String',num2str(velocity),'position',[205,115,80,20],'Callback',@velocityEdit_Callback);
txt = uicontrol('Parent',hPanel3,'Style','text','Position',[285 113 30 20],'String','m/s','BackgroundColor',bgColor1);

% Side length
txt = uicontrol('Parent',hPanel3,'Style','text','Position',[180 80 140 30],...
    'String','Side Length (Only for Hexagon track)','BackgroundColor',bgColor1);
side_lengthEdit = uicontrol('Parent',hPanel3,'style','edit','String',num2str(side_length),'position',[205,60,80,20],'Callback',@side_lengthEdit_Callback);
txt = uicontrol('Parent',hPanel3,'Style','text','Position',[285 58 20 20],'String','m','BackgroundColor',bgColor1);

% Orientation
txt = uicontrol('Parent',hPanel3,'Style','text','Position',[180 30 140 30],...
    'String','Orientation (Only for Hexagon track)','BackgroundColor',bgColor1);
% orientationEdit = uicontrol('Parent',hPanel3,'style','edit','String',orientation,'position',[205,160,80,20],'Callback',@orientationEdit_Callback);
orientPopup = uicontrol('Parent',hPanel3,'Style','popupmenu','String',{'Clockwise','Counter'},...
          'Position',[205,10,80,20],'Callback',@orientPopup_Callback);
      
%% Panel 4 Human Blockage parameters
bgColor = [1 1 1]; 
hPanel4 = uipanel('Title','Human Blockage Parameters','FontSize',10,'Fontweight','bold','parent',figGUI,...
    'Units','pixels','Position',[720,10,350,175],'BackgroundColor',bgColor);

bg2 = uibuttongroup('Parent',figGUI,'Visible','off','Unit','pixels',...
                  'Position',[725,125,130,40],'Title','Human Blockage',...
                  'SelectionChangedFcn',@bg2_Callback);

rr1 = uicontrol(bg2,'Style',...
                  'radiobutton',...
                  'String','On',...
                  'Position',[0 0 50 30],...
                  'HandleVisibility','off');
              
rr2 = uicontrol(bg2,'Style','radiobutton',...
                  'String','Off',...
                  'Position',[60 0 50 30],...
                  'HandleVisibility','off');
bg2.Visible = 'on';

% Default Setting

txtDefault = uicontrol('Parent',hPanel4,'Style','text','Position',[25 80 120 30],...
    'String','Default Settings for Human Blockage','BackgroundColor',bgColor1);
defaultPopup = uicontrol('Parent',hPanel4,'Style','popupmenu','String',{'No','Yes'},...
          'Position',[40,60,80,20],'Callback',@defaultPopup_Callback);

% SE Mean
txt = uicontrol('Parent',hPanel4,'Style','text','Position',[15 30 140 20],...
    'String','Mean Attenuation','BackgroundColor',bgColor1);
SEmeanEdit = uicontrol('Parent',hPanel4,'style','edit','String',num2str(SEmean),'position',[40,10,80,20],'Callback',@SEmeanEdit_Callback);
txt = uicontrol('Parent',hPanel4,'Style','text','Position',[120 8 20 20],'String','dB','BackgroundColor',bgColor1);

% Lambda U2D
txt = uicontrol('Parent',hPanel4,'Style','text','Position',[140 135 210 20],...
    'String','Trans. Rate from Unshadow to Decay','BackgroundColor',bgColor1);
lambdaDecayEdit = uicontrol('Parent',hPanel4,'style','edit','String',num2str(lambdaDecay),'position',[205,120,80,20],'Callback',@lambdaDecayEdit_Callback);
txt = uicontrol('Parent',hPanel4,'Style','text','Position',[290 118 50 20],'String','/sec','BackgroundColor',bgColor1);

% Lambda D2S
txt = uicontrol('Parent',hPanel4,'Style','text','Position',[140 100 200 20],...
    'String','Trans. Rate from Decay to Shadow','BackgroundColor',bgColor1);
lambdaShadEdit = uicontrol('Parent',hPanel4,'style','edit','String',num2str(lambdaShad),'position',[205,85,80,20],'Callback',@lambdaShadEdit_Callback);
txt = uicontrol('Parent',hPanel4,'Style','text','Position',[290 83 50 20],'String','/sec','BackgroundColor',bgColor1);

% Lambda S2R
txt = uicontrol('Parent',hPanel4,'Style','text','Position',[140 65 200 20],...
    'String','Trans. Rate from Shadow to Rise','BackgroundColor',bgColor1);
lambdaRiseEdit = uicontrol('Parent',hPanel4,'style','edit','String',num2str(lambdaRise),'position',[205,50,80,20],'Callback',@lambdaRiseEdit_Callback);
txt = uicontrol('Parent',hPanel4,'Style','text','Position',[290 47 50 20],'String','/sec','BackgroundColor',bgColor1);

% Lambda S2R
txt = uicontrol('Parent',hPanel4,'Style','text','Position',[140 30 200 20],...
    'String','Trans. Rate from Rise to Unshadow','BackgroundColor',bgColor1);
lambdaUnshadEdit = uicontrol('Parent',hPanel4,'style','edit','String',num2str(lambdaUnshad),'position',[205,15,80,20],'Callback',@lambdaUnshadEdit_Callback);
txt = uicontrol('Parent',hPanel4,'Style','text','Position',[290 13 50 20],'String','/sec','BackgroundColor',bgColor1);     

%% Output file type

oft = uicontrol('Style','text','Position',[1100 160 120 40],'String','Output File Type','BackgroundColor',bgGUI);
set(oft,'Enable','on','ForegroundColor',[0 0 0],'Fontsize',10,'Fontweight','bold');
oftPopup = uicontrol('Parent',figGUI,'Style','popupmenu','String',{'Text File','MAT File','Both Text and MAT File'},...
          'Position',[1100,158,120,20],'Callback',@oftPopup_Callback);

h = uicontrol('Style','pushbutton','Position',[1100 80 120 60],'String','Run','Callback',@run_Callback);
set(h,'Foregroundcolor',[0 0 0],'Backgroundcolor',[0 1 0],'FontSize',16,'Fontname','Calibri','Fontweight','bold');


% Select a folder
txtOp = uicontrol('Style','text','Position',[1070 435 200 20],'String','Select a Folder to Save Files',...
    'BackgroundColor',bgGUI);
set(txtOp,'Enable','on','ForegroundColor',[0 0 0],'Fontsize',10,'Fontweight','bold');
[mtree, container] = uitree('v0', 'Root','C:/Users/');
set(container,'Parent',figGUI,'Position',[1070 205 200 230]);
txtPb = [];
uiwait(gcf);  

nodes = mtree.getSelectedNodes;
if isempty(nodes)
        return
end
node = nodes(1);
outputFolder = node.getValue;

%% Panel 1 Callbacks
function scePopup_Callback(source,~) 
    str = source.String;
    val = source.Value;
    switch str{val}
        case 'UMi' 
            sceType = 'UMi';
        case 'UMa' 
            sceType = 'UMa';
        case 'RMa' 
            sceType = 'RMa';
        case 'InH'
            sceType = 'InH';
    end
    if strcmp(sceType,'InH')
        distPopup.Value = 3;
        distPopup_Callback(distPopup);
        set(distPopup,'enable','off');
        txtFreq.String = 'Frequency (0.5-150 GHz)';
        set(txtRain1,'enable','off');
        set(tEditRain,'enable','off');
        set(txtRain2,'enable','off');
        set(txtFol,'enable','off');
        set(folPopup,'enable','off');
        set(txtDistFol1,'enable','off');
        set(dFolEdit,'enable','off');
        set(txtDistFol2,'enable','off');
        set(txtFolAtt1,'enable','off');
        set(folAttEdit,'enable','off');
        set(txtFolAtt2,'enable','off');
        set(o2iLossPopup,'enable','off');
        set(o2iTypePopup,'enable','off');
        set(txtO2I1,'enable','off');
        set(txtO2I2,'enable','off');
        set(txtO2I3,'enable','off');
        set(bg,'SelectedObject',r2);
        scIdc = 'Off';
        set(r1,'enable','off');
        set(r2,'enable','off');
        set(findall(hPanel3, '-property', 'enable'), 'enable', 'off');
    else
        distPopup.Value = 1;
        distPopup_Callback(distPopup);
        set(distPopup,'enable','on');
        txtFreq.String = 'Frequency (0.5-100 GHz)';
        set(txtRain1,'enable','on');
        set(tEditRain,'enable','on');
        set(txtRain2,'enable','on');
        set(txtFol,'enable','on');
        set(folPopup,'enable','on');
        set(txtDistFol1,'enable','on');
        set(dFolEdit,'enable','on');
        set(txtDistFol2,'enable','on');
        set(txtFolAtt1,'enable','on');
        set(folAttEdit,'enable','on');
        set(txtFolAtt2,'enable','on');
        set(o2iLossPopup,'enable','on');
        set(o2iTypePopup,'enable','on');
        set(txtO2I1,'enable','on');
        set(txtO2I2,'enable','on');
        set(txtO2I3,'enable','on');
        set(bg,'SelectedObject',r1);
        scIdc = 'On';
        set(r1,'enable','on');
        set(r2,'enable','on');
        set(findall(hPanel3, '-property', 'enable'), 'enable', 'on');
    end
end % maybe check all inputs here

function bg_Callback(source,event)
    scIdc = event.NewValue.String;
    if strcmp(scIdc,'On')
        set(o2iLossPopup,'enable','off');
        set(o2iTypePopup,'enable','off');
        set(txtO2I1,'enable','off');
        set(txtO2I2,'enable','off');
        set(txtO2I3,'enable','off');
        set(findall(hPanel3, '-property', 'enable'), 'enable', 'on');
    elseif strcmp(scIdc,'Off')
        set(findall(hPanel3, '-property', 'enable'), 'enable', 'off');
        set(o2iLossPopup,'enable','on');
        set(o2iTypePopup,'enable','on');
        set(txtO2I1,'enable','on');
        set(txtO2I2,'enable','on');
        set(txtO2I3,'enable','on');
    end
end

function fEdit_Callback(source,~) 
    f = source.String;
    f = str2double(f);
    if strcmp(sceType, 'InH')
        if f < 0.5 || f > 150
            h1 = msgbox('Frequency exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.',...
                'Error','error');
            waitfor(h1);
            return;
        end
    else 
        if f < 0.5 || f > 100
            h1 = msgbox('Frequency exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.',...
                'Error','error');
            waitfor(h1);
            return;
        end
    end

end  

function bwEdit_Callback(source,~) 
    RFBW = source.String;
    RFBW = str2double(RFBW);
    if RFBW < 0 || RFBW > 800
        h2 = msgbox('RF Bandwidth exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
        waitfor(h2);
        return;
    end
end

function distPopup_Callback(source,~) 
     str = source.String;
     val = source.Value;
     distType = str{val};
end 

function envPopup_Callback(source,~) 
     str = source.String;
         val = source.Value;
         envType = str{val};
end 

function dminEdit_Callback(source,~) 
    dmin = source.String;
    dmin = str2double(dmin);
    if strcmp(distType,'Standard (10-500 m)')
        if dmin < 10 || dmin > 500
            h3 = msgbox('Lower Bound of T-R Distance exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
            waitfor(h3);
            return;
        end
    elseif strcmp(distType,'Indoor (5-50 m)')
        if dmin < 5 || dmin > 50
            h3 = msgbox('Lower Bound of T-R Distance exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
            waitfor(h3);
            return;
        end
    else
        if dmin < 10 || dmin > 10000
            h3 = msgbox('Lower Bound of T-R Distance exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
            waitfor(h3);
            return;
        end
    end
end 

function dmaxEdit_Callback(source,~) 
     dmax = source.String;
     dmax = str2double(dmax);
     if strcmp(distType,'Standard (10-500 m)')
        if dmax < 10 || dmax > 500
            h4 = msgbox('Upper Bound of T-R Distance exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
            waitfor(h3);
            return;
        end
    elseif strcmp(distType,'Indoor (5-50 m)')
        if dmax < 5 || dmax > 50
            h4 = msgbox('Upper Bound of T-R Distance exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
            waitfor(h3);
            return;
        end
    else
        if dmax < 10 || dmax > 10000
            h4 = msgbox('Upper Bound of T-R Distance exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
            waitfor(h3);
            return;
        end
    end
end 

function PtEdit_Callback(source,~) 
    TXPower = source.String;
    TXPower = str2double(TXPower);
    if TXPower < 0 || TXPower > 50
        h6 = msgbox('TX Power exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
        waitfor(h6);
        return;
    end
end 

function pEdit_Callback(source,~) 
    p = source.String;
    p = str2double(p);
end

function uEdit_Callback(source,~) 
    u = source.String;
    u = str2double(u);
    if u < 0 || u > 100
        h8 = msgbox('Humidity exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
        waitfor(h8);
        return;
    end
end 

function tEdit_Callback(source,~) 
    temp = source.String;
    temp = str2double(temp);
end

function RREdit_Callback(source,~) 
    RR = source.String;
    RR = str2double(RR);
    if RR < 0 || RR > 150
        h9 = msgbox('Rain Rate exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
        waitfor(h9);  
        return;
    end
end

function polPopup_Callback(source,~) 
    str = source.String;
    val = source.Value;
    Pol = str{val};
end

% function polCheckbox_Callback(source,~) 
%     str = source.String;
%     val = source.Value;
%     AllPolInd = val;
%     if AllPolInd == 1
%         set(polPopup,'enable','off');
%     else
%         set(polPopup,'enable','on');
%     end
% end

function folPopup_Callback(source,~) 
    str = source.String;
    val = source.Value;
    Fol = str{val};
end

function dFolEdit_Callback(source,~)
    dFol = source.String;
    dFol = str2double(dFol);
end

function folAttEdit_Callback(source,~)
    folAtt = source.String;
    folAtt = str2double(folAtt);
end

function o2iLossPopup_Callback(source,~)
    str = source.String;
    val = source.Value;
    o2iLoss = str{val};
end

function o2iTypePopup_Callback(source,~)
    str = source.String;
    val = source.Value;
    o2iType = str{val};
end

function nRun_Callback(source,~) 
     N = source.String;
     N = str2double(N);
end 

function hBS_Callback(source,~) 
     h_BS = source.String;
     h_BS = str2double(h_BS);
     if strcmp(sceType, 'InH')
        if h_BS < 1 || h_BS > 5
            h7 = msgbox('Base Station Height exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
            waitfor(h7);
            return;
        end
    else 
        if h_BS < 10 || h_BS > 150
            h7 = msgbox('Base Station Height exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
            waitfor(h7);
            return;
        end
     end
end

function hMS_Callback(source,~) 
     h_MS = source.String;
     h_MS = str2double(h_MS);
     if strcmp(sceType, 'InH')
        if h_MS < 0.5 || h_MS > 2
            h21 = msgbox('Mobile Device Height exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
            waitfor(h21);
            return;
        end
    else 
        if h_MS < 1 || h_MS > 5
            h21 = msgbox('Mobile Device Height exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
            waitfor(h21);
            return;
        end
     end
end

%% Panel 2 Callbacks
function TxArrayPopup_Callback(source,~) 
     str = source.String; 
     val = source.Value;
     TxArrayType = str{val};
end 

function RxArrayPopup_Callback(source,~) 
     str = source.String; 
     val = source.Value;
     RxArrayType = str{val};
end 

function nTxAnt_Callback(source,~) 
     Nt = source.String; 
     Nt = str2double(Nt);
end

function nRxAnt_Callback(source,~) 
     Nr = source.String;
     Nr = str2double(Nr);
end

function distTxAnt_Callback(source,~) 
     dTxAnt = source.String;
     dTxAnt = str2double(dTxAnt);
     if dTxAnt < 0.1 || dTxAnt > 100
        h11 = msgbox('TX Antenna Spacing exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
        waitfor(h11);
        return;
    end
end

function distRxAnt_Callback(source,~) 
    dRxAnt = source.String;
    dRxAnt = str2double(dRxAnt);
    if dRxAnt < 0.1 || dRxAnt > 100
        h12 = msgbox('RX Antenna Spacing exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
        waitfor(h12);
        return;
    end
end

function nnTxAnt_Callback(source,~) 
     Wt = source.String;
     Wt = str2double(Wt);
end 

function nnRxAnt_Callback(source,~) 
     Wr = source.String; 
     Wr = str2double(Wr);
end

function TxAziBW_Callback(source,~) 
    theta_3dB_TX = source.String;
    theta_3dB_TX = str2double(theta_3dB_TX);
    if theta_3dB_TX < 7 || theta_3dB_TX > 360
        h17 = msgbox('TX Azimuth HPBW exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
        waitfor(h17);
        return;
    end
end

function TxElvBW_Callback(source,~) 
    phi_3dB_TX = source.String;
    phi_3dB_TX = str2double(phi_3dB_TX);
    if phi_3dB_TX < 7 || phi_3dB_TX > 45
        h18 = msgbox('TX Elevation HPBW exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
        waitfor(h18);
        return;
    end
end

function RxAziBW_Callback(source,~) 
    theta_3dB_RX = source.String;
    theta_3dB_RX = str2double(theta_3dB_RX);
    if theta_3dB_RX < 7 || theta_3dB_RX > 360
        h19 = msgbox('RX Azimuth HPBW exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
        waitfor(h19);
        return;
    end
     if strcmp(default,'Yes')
         SEmean_tmp = 10*log10(9.8+180/theta_3dB_RX);
         set(SEmeanEdit,'String',SEmean_tmp);
         
         lambdaShadEdit_tmp = 0.065*theta_3dB_RX+7.425;
         set(lambdaShadEdit,'String',lambdaShadEdit_tmp);
         
         lambdaRiseEdit_tmp = 0.05*theta_3dB_RX+7.35;
         set(lambdaRiseEdit,'String',lambdaRiseEdit_tmp);
     end
end

function RxElvBW_Callback(source,~) 
    phi_3dB_RX = source.String;
    phi_3dB_RX = str2double(phi_3dB_RX);
    if phi_3dB_RX < 7 || phi_3dB_RX > 45
        h20 = msgbox('RX Elevation HPBW exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
        waitfor(h20);
        return;
    end
end

function oftPopup_Callback(source,~) 
     str = source.String;
     val = source.Value;
     fileType = str{val};
end 

%% Panel 3 Callbacks
function d_coEdit_Callback(source,~)
    d_co = source.String;
    d_co = str2double(d_co);
    if mod(d_co, d_update) ~= 0 
        h31 = msgbox('Please set Correlation distance to multiples of Update distance.', 'Error','error');
        waitfor(h31);
        return;
    end
end

function d_co_losEdit_Callback(source,~)
    d_co_los = source.String;
    d_co_los = str2double(d_co_los);
%     if mod(d_co, 1) ~= 0
%         h32 = msgbox('LOS Correlation distance needs to be integer, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
%         waitfor(h32);
%         return;
%     end
end

function transPopup_Callback(source,~) 
     str = source.String;
     val = source.Value;
     transExist = str{val};
end

function trackTypePopup_Callback(source,~)
     str = source.String;
     val = source.Value;
     trackType = str{val};
     if strcmp(trackType,'Linear')
        if mod(d_co, d_update) ~= 0 || mod(movDistance, d_update) ~= 0 
            h33 = msgbox('Correlation distance and Moving distance should be multiples of Update distance.', 'Error','error');
            waitfor(h33);
            return;
        end
     elseif strcmp(trackType,'Hexagon')
        if mod(d_co, d_update) ~= 0 || mod(movDistance, d_update) ~= 0 || mod(side_length, d_update) ~= 0 
            h33 = msgbox('Correlation distance, Moving distance, and Hexagon side length should be multiples of Update distance.', 'Error','error');
            waitfor(h33);
            return;
        end
     end
end 

function d_updateEdit_Callback(source,~)
    d_update = source.String;
    d_update = str2double(d_update);
    if strcmp(trackType,'Linear')
        if mod(d_co, d_update) ~= 0 || mod(movDistance, d_update) ~= 0 
            h36 = msgbox('Correlation distance and Moving distance should be multiples of Update distance.', 'Error','error');
            waitfor(h36);
            return;
        end
    elseif strcmp(trackType,'Hexagon')
        if mod(d_co, d_update) ~= 0 || mod(movDistance, d_update) ~= 0 || mod(side_length, d_update) ~= 0 
            h36 = msgbox('Correlation distance, Moving distance, and Hexagon side length should be multiples of Update distance.', 'Error','error');
            waitfor(h36);
            return;
        end
    end
end

function movDistanceEdit_Callback(source,~)
    movDistance = source.String;
    movDistance = str2double(movDistance);
    if mod(movDistance, d_update) ~= 0 
        h34 = msgbox('Please set Moving distance to multiples of Update distance.', 'Error','error');
        waitfor(h34);
        return;
    end
end

function velocityEdit_Callback(source,~)
    velocity = source.String;
    velocity = str2double(velocity);
end

function directionEdit_Callback(source,~)
    direction = source.String;
    direction = str2double(direction);
end

function side_lengthEdit_Callback(source,~)
    side_length = source.String;
    side_length = str2double(side_length);
    if mod(side_length,d_update) ~= 0 
        h35 = msgbox('Please set Hexagon side length to multiples of Update distance.', 'Error','error');
        waitfor(h35);
        return;
    end
end

function orientPopup_Callback(source,~)
     str = source.String;
     val = source.Value;
     orient = str{val};
end 
    
%% Panel 4 Callbacks
function bg2_Callback(source,event)
    hbIdc = event.NewValue.String;
    if strcmp(hbIdc,'On')
        set(findall(hPanel4, '-property', 'enable'), 'enable', 'on');
    elseif strcmp(hbIdc,'Off')
        set(findall(hPanel4, '-property', 'enable'), 'enable', 'off');
    end
end

function defaultPopup_Callback(source,event)
     str = source.String;
     val = source.Value;
     default = str{val};
     if strcmp(default,'Yes')
         set(SEmeanEdit, 'enable', 'off');
         set(lambdaDecayEdit,'enable', 'off');
         set(lambdaShadEdit,'enable', 'off');
         set(lambdaRiseEdit,'enable', 'off');
         set(lambdaUnshadEdit,'enable', 'off');
     elseif strcmp(default,'No')
         set(findall(hPanel4, '-property', 'enable'), 'enable', 'on');
     end
end 

function SEmeanEdit_Callback(source,~)
    SEmean = source.String;
    SEmean = str2double(SEmean);
end

function lambdaDecayEdit_Callback(source,~)
    lambdaDecay = source.String;
    lambdaDecay = str2double(lambdaDecay);
end

function lambdaShadEdit_Callback(source,~)
    lambdaShad = source.String;
    lambdaShad = str2double(lambdaShad);
end

function lambdaRiseEdit_Callback(source,~)
    lambdaRise = source.String;
    lambdaRise = str2double(lambdaRise);
end

function lambdaUnshadEdit_Callback(source,~)
    lambdaUnshad = source.String;
    lambdaUnshad = str2double(lambdaUnshad);
end

%% Extra checklist
if dmin > dmax 
    h5 = msgbox('Lower Bound of T-R Distance exceeds Upper Bound of T-R Distance, please reset either or both parameters on GUI, or modify the source code to realize your goal.', 'Error','error');
    waitfor(h5);
    delete(txtPb);
    return;
end
if h_MS > h_BS
    h22 = msgbox('Mobile Device is Higher than Base Station, please reset either or both parameters on GUI, or modify the source code to realize your goal.', 'Error','error');
    waitfor(h22);
    return;
end
if strcmp(Fol,'Yes') == true
    if dFol > dmin
        h10 = msgbox('Distance Within Foliage > Lower Bound of T-R Distance, please reset either or both parameters on GUI, or modify the source code to realize your goal.', 'Error','error');
        waitfor(h10);
        return;
    end
end
if sign(Nt-Wt) == -1
    h13 = msgbox('Wt > Nt, please reset either or both parameters on GUI, or modify the source code to realize your goal.', 'Error','error');
              waitfor(h13);
            return;
end
if sign(Nr-Wr) == -1
    h14 = msgbox('Wr > Nr, please reset either or both parameters on GUI, or modify the source code to realize your goal.', 'Error','error');
              waitfor(h14);
            return;
end
if mod(Nt,Wt) ~= 0
    h15 = msgbox('Wt does not divide Nt, please reset either or both parameters on GUI, or modify the source code to realize your goal.', 'Error','error');
              waitfor(h15);
            return;
end
if mod(Nr,Wr) ~= 0
    h16 = msgbox('Wr does not divide Nr, please reset either or both parameters on GUI, or modify the source code to realize your goal.', 'Error','error');
              waitfor(h16);
            return;
end
if theta_3dB_TX < 7 || theta_3dB_TX > 360
    h17 = msgbox('TX Azimuth HPBW exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
              waitfor(h17);
            return;
end
if phi_3dB_TX < 7 || phi_3dB_TX > 45
    h18 = msgbox('TX Elevation HPBW exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
              waitfor(h18);
            return;
end
if theta_3dB_RX < 7 || theta_3dB_RX > 360
    h19 = msgbox('RX Azimuth HPBW exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
              waitfor(h19);
            return;
end
if phi_3dB_RX < 7 || phi_3dB_RX > 45
    h20 = msgbox('RX Elevation HPBW exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
              waitfor(h20);
            return;
end

Length = N; Count = 0; 
jBarHandle = javax.swing.JProgressBar(0,N);
jBarHandle.setStringPainted(true);
jBarHandle.setIndeterminate(false);
[jhandle, hhandle] = javacomponent(jBarHandle);
set(hhandle, 'parent', figGUI, 'Units', 'norm', 'Position', [0.03 0 .45 .02]);
javaMethodEDT('setValue', jBarHandle, Count);
% txtPb = uicontrol('Style','text');
function run_Callback(hObject, eventdata, handles) 
txtPb = uicontrol('Style','text','Position',[150 13 180 15],'String','Running, please wait...',...
    'BackgroundColor',bgGUI);
set(txtPb,'Enable','on','ForegroundColor',[1 0 0],'Fontweight','bold');
uiresume(gcbf);
end

%% NYUSIM Main Code Start
%%%%%%%%%%%%%%%%%%%%%%% Alternate  Start %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(scIdc,'On')
%% Constants
d0 = 1; % Free space reference distance in meters
c = physconst('LightSpeed'); % Speed of light in m/s

%% Preparation
% Structure containing generated CIRs
CIR_SISO_Struct = struct; 
CIR_MIMO_Struct = struct;

SEG_SISO_struct = struct;
SEG_MIMO_struct = struct;

% CIR_SISO_EVO = struct;
CIR_MIMO_EVO = struct;
CIR_SISO_EVO_DIR = struct;

% Set plot status
plotStatus = true; 
% Set plot rotation status
plotRotate = false; 
% Determine if spatial plot is needed 
plotSpatial = true;
FigVisibility = 'on';

% scIdc = 'On';
% hbIdc = 'On';

%% Set user trajectory 
% Update distance (usually set to be 1, 0.1, 0.01 m) represents the
% distance interval of two consecutive channel snapshots
% e.g. the UT moves 10 m, update distance is 1 m, then 10 channel snapshots
% are generated in total. 
% d_update = 1;

% User trajectory type: 'Linear' or 'Hexagon'
% linear type is fully realized; hexagon type is almost fully realized
% except the transitions between channel segments. However, both types of
% track can be used to generate spatially correlated channel snapshots
% along the user movement without considering the transitions between
% channel segments.
% trackType = 'Hexagon'; % Linear or Hexagon

% relative initial position of the UT (unit of meter) 
relPos = [0;0;h_MS]; 

% BS position (always at the origin)
TX_Pos = [0;0;h_BS];

% Moving distance (the length of user trajectory) Please use an integer
% movDistance = 41; % Moving distance, unit of meter

% Moving direction where positive x-axis is 0, and positive y-axis is pi/2.
% direction = 45; % Direction of the track, unit of degree

% Set the moving speed unit of meter per second
% velocity = 1;

% Update time is basically update distance divided by velocity
t_update = d_update/velocity;

% The number of channel snapshots corresponding to the user movement
numberOfSnapshot = round(movDistance/d_update);

% Only for hexagon track
% side_length = 10; % side length of the hexagon track
% orient = 'Clockwise';

%%%%% An example about these distances
% A user moves 30 m. The correlation distance is 10 m, and the update
% distance is 1 m. Then, there are 3 segments (corresponding to 3 
% independent channel generations), and there are 10 snapshots in each
% segment. Thus, there are 30 snapshots in total. If the velocity is 10 m/s
% , the update time is 0.1 s, and the total moving duration is 3 s.

%% Large-scale shadow fading correlated map

% Correlation distance of SF (Please use an integer for the correlation distance, like 10, 15, 20)
% d_co = 10;

% The side length of the simulated area. Since the TX (or BS) is always at
% the origin, then here the maps is from -100 to 100
area = ceil((dmax+movDistance)/100*2)*100*2;

%%%%% A new function of generating spatially correlated value of shadow fading
[sfMap,SF] = getSfMap(area,d_co,sceType,envType);

%% Obtain spatially correlated LOS/NLOS condition

% Usually, correlation distances for UMi, UMa, RMa are 15, 50, 60 m.
% d_co_los = 15;

% Granularity of the map
% d_px = 1;

%%%%% A new function of generating spatially correlated value of LOS/NLOS
losMap = getLosMap(area,d_co_los,h_BS,h_MS,sceType);

%% The number of channel snapshots for each channel segment
co_dps = round(d_co/d_update);
t_dps = co_dps*t_update;

%% Channel Segments
% The moving distance may not be the multiplicity of the correlation
% distance, thus the last segment may not have full length

% Note that the envType (LOS or NLOS), sceType (UMi,UMa,RMa) do not
% change in a segment

% Generate the initial T-R separation distance
dini = getTRSep(dmin,dmax);

% Obtain the number of channel segments
numberOfSegments = ceil(movDistance/d_co);

% Obtain the vector of the lengths of channel segments 
lengthOfSegments = [co_dps*ones(1,numberOfSegments-1), int8(mod(movDistance,d_co)/d_update)];
if lengthOfSegments(end) == 0
    lengthOfSegments(end) = d_co/d_update;
end

% Generate segment-wise environment parameters
% The initial T-R separation distance for each segment (the first segment 
% has been determined.)
segDist = zeros(1,numberOfSegments); segDist(1,1) = dini;

% The environment type and scenario type of each segment (the first segment
% has been determined.)
segEnvType = cell(1,numberOfSegments); segEnvType{1,1} = envType;

% The shadow fading 
segSF = zeros(1,numberOfSegments);

% The number of time clusters in each segment (independent among segments)
nTC = zeros(1,numberOfSegments); % # of time clusters in each segment

% For loop for segments
% In each loop, an anchor channel snapshot (large-scale and small-scale 
% parameters) is first generated, then, the spatial consistency procedure
% is used to update the small-scale parameters (delays, angles, powers) of
% the rest snapshots in this segment
for segIdx = 1:numberOfSegments
    %% load channel parameters
    if strcmp(sceType,'UMi') == true && strcmp(envType,'LOS') == true 
    n = 2; SF = 4.0; mu_AOD = 1.9; mu_AOA = 1.8;X_max = 0.2;mu_tau = 123; 
    minVoidInterval = 25;sigmaCluster = 1;Gamma = 25.9; sigmaSubpath = 6; 
    gamma = 16.9; mean_ZOD = -12.6;sigma_ZOD = 5.9; std_AOD_RMSLobeAzimuthSpread = 8.5;
    std_AOD_RMSLobeElevationSpread = 2.5;distributionType_AOD = 'Gaussian'; 
    mean_ZOA = 10.8; sigma_ZOA = 5.3;std_AOA_RMSLobeAzimuthSpread = 10.5;
    std_AOA_RMSLobeElevationSpread = 11.5;distributionType_AOA = 'Laplacian';   
    % UMi NLOS
    elseif strcmp(sceType,'UMi') == true && strcmp(envType,'NLOS') == true
    n = 3.2; SF = 7.0; mu_AOD = 1.5; mu_AOA = 2.1; X_max = 0.5; mu_tau = 83;
    minVoidInterval = 25; sigmaCluster = 3; Gamma = 51.0; sigmaSubpath = 6;
    gamma = 15.5; mean_ZOD = -4.9; sigma_ZOD = 4.5; std_AOD_RMSLobeAzimuthSpread = 11.0;
    std_AOD_RMSLobeElevationSpread = 3.0; distributionType_AOD = 'Gaussian'; 
    mean_ZOA = 3.6; sigma_ZOA = 4.8; std_AOA_RMSLobeAzimuthSpread = 7.5;
    std_AOA_RMSLobeElevationSpread = 6.0; distributionType_AOA = 'Laplacian';
    % UMa LOS
    elseif strcmp(sceType,'UMa') == true && strcmp(envType,'LOS') == true 
    n = 2; SF = 4.0; mu_AOD = 1.9; mu_AOA = 1.8;X_max = 0.2; mu_tau = 123; 
    minVoidInterval = 25; sigmaCluster = 1;Gamma = 25.9; sigmaSubpath = 6; 
    gamma = 16.9; mean_ZOD = -12.6;sigma_ZOD = 5.9; std_AOD_RMSLobeAzimuthSpread = 8.5;
    std_AOD_RMSLobeElevationSpread = 2.5;distributionType_AOD = 'Gaussian'; 
    mean_ZOA = 10.8; sigma_ZOA = 5.3;std_AOA_RMSLobeAzimuthSpread = 10.5;
    std_AOA_RMSLobeElevationSpread = 11.5;distributionType_AOA = 'Laplacian'; 
    % UMa NLOS
    elseif strcmp(sceType,'UMa') == true && strcmp(envType,'NLOS') == true 
    n = 2.9; SF = 7.0; mu_AOD = 1.5; mu_AOA = 2.1; X_max = 0.5; mu_tau = 83;
    minVoidInterval = 25; sigmaCluster = 3; Gamma = 51.0; sigmaSubpath = 6;
    gamma = 15.5; mean_ZOD = -4.9; sigma_ZOD = 4.5; std_AOD_RMSLobeAzimuthSpread = 11.0;
    std_AOD_RMSLobeElevationSpread = 3.0; distributionType_AOD = 'Gaussian'; 
    mean_ZOA = 3.6; sigma_ZOA = 4.8; std_AOA_RMSLobeAzimuthSpread = 7.5;
    std_AOA_RMSLobeElevationSpread = 6.0; distributionType_AOA = 'Laplacian';
    % RMa LOS
    elseif strcmp(sceType,'RMa') == true && strcmp(envType,'LOS') == true
    SF = 1.7; mu_AOD = 1; mu_AOA = 1;X_max = 0.2; mu_tau = 123; 
    minVoidInterval = 25; sigmaCluster = 1;Gamma = 25.9; sigmaSubpath = 6; 
    gamma = 16.9; mean_ZOD = -12.6;sigma_ZOD = 5.9; std_AOD_RMSLobeAzimuthSpread = 8.5;
    std_AOD_RMSLobeElevationSpread = 2.5;distributionType_AOD = 'Gaussian'; 
    mean_ZOA = 10.8; sigma_ZOA = 5.3;std_AOA_RMSLobeAzimuthSpread = 10.5;
    std_AOA_RMSLobeElevationSpread = 11.5;distributionType_AOA = 'Laplacian';
    % RMa NLOS
    elseif strcmp(sceType,'RMa') == true && strcmp(envType,'NLOS') == true
    SF = 6.7; mu_AOD = 1; mu_AOA = 1; X_max = 0.5; mu_tau = 83;
    minVoidInterval = 25; sigmaCluster = 3; Gamma = 51.0; sigmaSubpath = 6;
    gamma = 15.5; mean_ZOD = -4.9; sigma_ZOD = 4.5; std_AOD_RMSLobeAzimuthSpread = 11.0;
    std_AOD_RMSLobeElevationSpread = 3.0; distributionType_AOD = 'Gaussian'; 
    mean_ZOA = 3.6; sigma_ZOA = 4.8; std_AOA_RMSLobeAzimuthSpread = 7.5;
    std_AOA_RMSLobeElevationSpread = 6.0; distributionType_AOA = 'Laplacian';
    end

    % Generate # of TCs,SPs,SLs
    [numberOfTimeClusters,numberOfAOALobes,numberOfAODLobes] = ...
                             getNumClusters_AOA_AOD(mu_AOA,mu_AOD,sceType);
    nTC(segIdx) = numberOfTimeClusters;
    numberOfClusterSubPaths = ...
                  getNumberOfClusterSubPaths(numberOfTimeClusters,sceType);
    nSP = numberOfClusterSubPaths;
    
    % Generate delay info
    rho_mn = getIntraClusterDelays(numberOfClusterSubPaths,X_max,sceType);
    phases_mn = getSubpathPhases(rho_mn);
    tau_n = getClusterExcessTimeDelays(mu_tau,rho_mn,minVoidInterval);
    
    % Gnerate angle info 
    % Angles between [0 360]
    [subpath_AODs, cluster_subpath_AODlobe_mapping] = ...
        getSubpathAngles(numberOfAODLobes,numberOfClusterSubPaths,mean_ZOD,...
        sigma_ZOD,std_AOD_RMSLobeElevationSpread,std_AOD_RMSLobeAzimuthSpread,...
        distributionType_AOD);
    [subpath_AOAs, cluster_subpath_AOAlobe_mapping] = ...
        getSubpathAngles(numberOfAOALobes,numberOfClusterSubPaths,mean_ZOA,...
        sigma_ZOA,std_AOA_RMSLobeElevationSpread,std_AOA_RMSLobeAzimuthSpread,...
        distributionType_AOA);
    % If it is the first channel segment running, the initial location of
    % the UT needs to be found first. 
    if segIdx == 1
        initPos = getInitPos(subpath_AODs,subpath_AOAs,segDist(segIdx),segEnvType{segIdx}, h_MS);
        % side length and orientation will not be used if the track type is
        % linear. 

        if strcmp(orient, 'Clockwise') % orientation of the hexagon track, '0'-counter;'1'-clock
            orientInd = 1;
        elseif strcmp(orient,'Counter')
            orientInd = 0;
        end
        
        [track, v_dir] = getUserTrack(trackType,initPos,movDistance,d_update,direction,side_length,orientInd);
        ss = 1+((1:numberOfSegments)-1)*co_dps;
        segInitPos = track(:,ss); 
        segDist = sqrt(sum((segInitPos-TX_Pos).^2,1));
        if sum(segDist>500) == 0
            DR = 190;
        else
            DR = 220;
        end
        Th = TXPower - DR;
        
        % Obtain LOS/NLOS condition
        for oo = 2:numberOfSegments
           losCon = losMap(round(area/2+segInitPos(2,oo)),round(area/2+segInitPos(1,oo)));
           if losCon == 1
               ttemp = 'NLOS';
           elseif losCon == 0
               ttemp = 'LOS';
           end
           segEnvType{1,oo} = ttemp; 
        end
    end
    % Obtain shadow fading from the map
    segSF(segIdx) = sfMap(round(area/2+segInitPos(2,segIdx)),round(area/2+segInitPos(1,segIdx)));
    
    % Generate total received power
    [PL_dB, Pr_dBm, FSPL, PLE] = getPowerInfo(sceType,envType,f,n,segSF(segIdx),TXPower,...
                                    segDist(segIdx),d0,p,c,u,temp,RR,Pol,Fol,h_BS,folAtt,dFol); 
                                
    % Generate SP powers based on the total received power
    clusterPowers = getClusterPowers(tau_n,Pr_dBm,Gamma,sigmaCluster,Th);
    subpathPowers = ...
      getSubpathPowers(rho_mn,clusterPowers,gamma,sigmaSubpath,segEnvType(segIdx),Th);
    
    % Recover absolute timing
    t_mn = getAbsolutePropTimes(segDist(segIdx),tau_n,rho_mn);
    
    % Collect all channel information into powerSpectrum 
    % Angles between [0 360]
    powerSpectrumOld = getPowerSpectrum(numberOfClusterSubPaths,t_mn,...
                     subpathPowers,phases_mn,subpath_AODs,subpath_AOAs,Th);
    [powerSpectrum,numberOfClusterSubPaths, SubpathIndex] = ...
                                getNewPowerSpectrum(powerSpectrumOld,RFBW);
    % LOS alignment                        
    powerSpectrum = getLosAligned(envType,powerSpectrum);
    powerSpectrumOld = getLosAligned(envType,powerSpectrumOld);      
    
    % Generate a struct foe each independently generated channel segment
    CIR.pathDelays = powerSpectrumOld(:,1);
    pathPower = powerSpectrumOld(:,2);
    clear indNaN; indNaN = find(pathPower<=10^(Th/10));
    pathPower(indNaN,:) = 10^(Th/10);
    CIR.pathPowers = pathPower;
    CIR.pathPhases = powerSpectrumOld(:,3);
    CIR.AODs = powerSpectrumOld(:,4);
    CIR.ZODs = powerSpectrumOld(:,5);
    CIR.AOAs = powerSpectrumOld(:,6);
    CIR.ZOAs = powerSpectrumOld(:,7);
    CIR.frequency = f;
    CIR.TXPower = TXPower;
    CIR.OmniPower = Pr_dBm;
    CIR.OmniPL = PL_dB;
    CIR.TRSep = segDist(segIdx);
    CIR.environment = envType;
    CIR.scenario = sceType;
    CIR.HPBW_TX = [theta_3dB_TX phi_3dB_TX];
    CIR.HPBW_RX = [theta_3dB_RX phi_3dB_RX];  
    CIR.numSP = nSP;
    % SISO CIR is stored
    CIR_SISO_Struct.(['CIR_SISO_',num2str(segIdx)]) = CIR;

    [CIR_MIMO,H,HPowers,HPhases,H_ensemble] = getLocalCIR(CIR,...
        TxArrayType,RxArrayType,Nt,Nr,Wt,Wr,dTxAnt,dRxAnt,RFBW);
    % MIMO CIR is stored
    CIR_MIMO_Struct.(['CIR_MIMO_',num2str(segIdx)]) = CIR_MIMO; 
      
    %% Time evolution
    % In a segment, the channel small-scale information will be updated for
    % each snapshot (or say for each step)
    
    % Here powerSpectrumOld for 800 MHz band width is used to ensure that the
    % number of multipath components in spatial and temporal domain are identical. 
    sc_powerSpectrum = powerSpectrumOld; 
    segTrack = track(:,(segIdx-1)*co_dps+1:(segIdx-1)*co_dps+lengthOfSegments(segIdx));
    segV = v_dir(:,(segIdx-1)*co_dps+1:(segIdx-1)*co_dps+lengthOfSegments(segIdx));
    
    no_snap = lengthOfSegments(segIdx);
    v = [cos(segV);sin(segV);zeros(1,no_snap)];
    r = zeros(3,no_snap);
    RX_Pos = segInitPos(:,segIdx);
    r(:,1) = RX_Pos - TX_Pos;
    
    % Here a geometry-based approach using multiple refleciton surfaces is
    % applied here to update angular information.
    if (strcmp(segEnvType(segIdx),'LOS'))
        no_mpc = size(sc_powerSpectrum,1)-1;
        
        % Initialize LOS and NLOS info in local coordinate system 
        sc_AOA_los = zeros(1,no_snap);sc_AOA_los(1,1) = sc_powerSpectrum(1,6);
        sc_AOD_los = zeros(1,no_snap);sc_AOD_los(1,1) = sc_powerSpectrum(1,4);
        sc_ZOA_los = zeros(1,no_snap);sc_ZOA_los(1,1) = sc_powerSpectrum(1,7);
        sc_ZOD_los = zeros(1,no_snap);sc_ZOD_los(1,1) = sc_powerSpectrum(1,5);
        sc_delay_los = zeros(1,no_snap);sc_delay_los(1,1) = sc_powerSpectrum(1,1);

        sc_AOA_nlos = zeros(no_mpc,no_snap);sc_AOA_nlos(:,1) = sc_powerSpectrum(2:end,6);
        sc_AOD_nlos = zeros(no_mpc,no_snap);sc_AOD_nlos(:,1) = sc_powerSpectrum(2:end,4);
        sc_ZOA_nlos = zeros(no_mpc,no_snap);sc_ZOA_nlos(:,1) = sc_powerSpectrum(2:end,7);
        sc_ZOD_nlos = zeros(no_mpc,no_snap);sc_ZOD_nlos(:,1) = sc_powerSpectrum(2:end,5);
        sc_delay_nlos = zeros(no_mpc,no_snap);sc_delay_nlos(:,1) = sc_powerSpectrum(2:end,1);
        
        % power is updated los and nlos together
        sc_power = zeros(no_mpc+1,no_snap);sc_power(:,1) = sc_powerSpectrum(:,2);
        sc_phase = zeros(no_mpc+1,no_snap);sc_phase(:,1) = sc_powerSpectrum(:,3);
        sc_delay = zeros(no_mpc+1,no_snap);sc_delay(:,1) = sc_powerSpectrum(:,1);
        % Initialize LOS and NLOS info in GCS
        % Convert angles into GCS
        gcs_AOD_los = zeros(1,no_snap); gcs_AOD_los(1,1) = mod(pi/2 - deg2rad(sc_AOD_los(1,1)),2*pi);
        gcs_ZOD_los = zeros(1,no_snap); gcs_ZOD_los(1,1) = pi/2 - deg2rad(sc_ZOD_los(1,1));
        gcs_AOA_los = zeros(1,no_snap); gcs_AOA_los(1,1) = mod(pi/2 - deg2rad(sc_AOA_los(1,1)),2*pi);
        gcs_ZOA_los = zeros(1,no_snap); gcs_ZOA_los(1,1) = pi/2 - deg2rad(sc_ZOA_los(1,1));

        gcs_AOD_nlos = zeros(no_mpc,no_snap); gcs_AOD_nlos(:,1) = mod(pi/2 - deg2rad(sc_AOD_nlos(:,1)),2*pi);
        gcs_ZOD_nlos = zeros(no_mpc,no_snap); gcs_ZOD_nlos(:,1) = pi/2 - deg2rad(sc_ZOD_nlos(:,1));
        gcs_AOA_nlos = zeros(no_mpc,no_snap); gcs_AOA_nlos(:,1) = mod(pi/2 - deg2rad(sc_AOA_nlos(:,1)),2*pi);
        gcs_ZOA_nlos = zeros(no_mpc,no_snap); gcs_ZOA_nlos(:,1) = pi/2 - deg2rad(sc_ZOA_nlos(:,1));
 
        xBern = randi(2,no_mpc,1);
        for t = 2:no_snap
            
            % Update LOS component
            r(:,t) = r(:,t-1) + v(:,t-1)*t_update;
            sc_delay_los(1,t) = norm(r(:,t))/c*1e9;
            
            % delta is the difference term between two snapshots 
            deltaAOD_los = v(:,t-1)'*[-sin(gcs_AOD_los(1,t-1));cos(gcs_AOD_los(1,t-1));0]*t_update;
            gcs_AOD_los(1,t) = gcs_AOD_los(1,t-1) + deltaAOD_los/(c*sc_delay_los(1,t-1)*1e-9*sin(gcs_ZOD_los(1,t-1)));

            deltaZOD_los = v(:,t-1)'*[cos(gcs_ZOD_los(1,t-1))*cos(gcs_AOD_los(1,t-1));cos(gcs_ZOD_los(1,t-1))*sin(gcs_AOD_los(1,t-1));-sin(gcs_ZOD_los(1,t-1))]*t_update;
            gcs_ZOD_los(1,t) = gcs_ZOD_los(1,t-1) + deltaZOD_los/(c*sc_delay_los(1,t-1)*1e-9);

            deltaAOA_los = v(:,t-1)'*[-sin(gcs_AOA_los(1,t-1));cos(gcs_AOA_los(1,t-1));0]*t_update;
            gcs_AOA_los(1,t) = gcs_AOA_los(1,t-1) - deltaAOA_los/(c*sc_delay_los(1,t-1)*1e-9*sin(gcs_ZOA_los(1,t-1)));

            deltaZOA_los = v(:,t-1)'*[cos(gcs_ZOA_los(1,t-1))*cos(gcs_AOA_los(1,t-1));cos(gcs_ZOA_los(1,t-1))*sin(gcs_AOA_los(1,t-1));-sin(gcs_ZOA_los(1,t-1))]*t_update;
            gcs_ZOA_los(1,t) = gcs_ZOA_los(1,t-1) + deltaZOA_los/(c*sc_delay_los(1,t-1)*1e-9);
            
            % Update delay
            azi = gcs_AOA_nlos(:,t-1);
            ele = gcs_ZOA_nlos(:,t-1);
            r_hat = [cos(ele).*sin(azi), cos(ele).*cos(azi), sin(ele)];
            deltaDist = r_hat*v(:,t-1)*t_update;
            sc_delay_nlos(:,t) = sc_delay_nlos(:,t-1)-deltaDist/c*1e9;            
            [sc_tau_n,sc_rho_mn] = getDelayInfo([sc_delay_los(t);sc_delay_nlos(:,t)],nSP);
            
            % Update power
            sfc = sfMap(round(area/2+track(1,t+(segIdx-1)*co_dps)),round(area/2+track(2,t+(segIdx-1)*co_dps)));
            dc = sqrt(sum(track(:,t+(segIdx-1)*co_dps).^2));
            [~, Prc,~,~] = getPowerInfo(sceType,envType,f,n,sfc,TXPower,...
                                    dc,d0,p,c,u,temp,RR,Pol,Fol,h_BS,folAtt,dFol);
            sc_power_cluster = getClusterPowers(sc_tau_n,Prc,Gamma,sigmaCluster,Th);
            power_temp = getSubpathPowers(sc_rho_mn,sc_power_cluster,gamma,sigmaSubpath,segEnvType(segIdx),Th);
            sc_power(:,t) = structToList(power_temp,nSP);
            
            % Update phase
            sc_delay(:,t) = [sc_delay_los(1,t);sc_delay_nlos(:,t)];
            dt_delay = sc_delay(:,t)-sc_delay(:,t-1);
            sc_phase(:,t) = mod(sc_phase(:,t-1) + dt_delay*2*pi*f*1e-3, 2*pi);
            
            % Update NLOS components one by one
            for i_path = 1:no_mpc
            
                tempBern = xBern(i_path);
                deltaRS = gcs_AOA_nlos(i_path,t-1)+(-1)^tempBern*gcs_AOD_nlos(i_path,t-1)+tempBern*pi;
                v_RS = mod(deltaRS+(-1)^tempBern*v(1:2,t-1),2*pi);
                v_RS = [v_RS;0];
                
                deltaAOD = v_RS'*[-sin(gcs_AOD_nlos(i_path,t-1));cos(gcs_AOD_nlos(i_path,t-1));0]*t_update;
                gcs_AOD_nlos(i_path,t) = gcs_AOD_nlos(i_path,t-1) + deltaAOD/(c*sc_delay_nlos(i_path,t-1)*1e-9*sin(gcs_ZOD_nlos(i_path,t-1)));

                deltaZOD = v_RS'*[cos(gcs_ZOD_nlos(i_path,t-1))*cos(gcs_AOD_nlos(i_path,t-1));cos(gcs_ZOD_nlos(i_path,t-1))*sin(gcs_AOD_nlos(i_path,t-1));-sin(gcs_ZOD_nlos(i_path,t-1))]*t_update;
                gcs_ZOD_nlos(i_path,t) = gcs_ZOD_nlos(i_path,t-1) + deltaZOD/(c*sc_delay_nlos(i_path,t-1)*1e-9);

                deltaAOA = v_RS'*[-sin(gcs_AOA_nlos(i_path,t-1));cos(gcs_AOA_nlos(i_path,t-1));0]*t_update;
                gcs_AOA_nlos(i_path,t) = gcs_AOA_nlos(i_path,t-1) - deltaAOA/(c*sc_delay_nlos(i_path,t-1)*1e-9*sin(gcs_ZOA_nlos(i_path,t-1)));

                deltaZOA = v_RS'*[cos(gcs_ZOA_nlos(i_path,t-1))*cos(gcs_AOA_nlos(i_path,t-1));cos(gcs_ZOA_nlos(i_path,t-1))*sin(gcs_AOA_nlos(i_path,t-1));-sin(gcs_ZOA_nlos(i_path,t-1))]*t_update;
                gcs_ZOA_nlos(i_path,t) = gcs_ZOA_nlos(i_path,t-1) + deltaZOA/(c*sc_delay_nlos(i_path,t-1)*1e-9);
                
            end
           
        end
        
        % Change angles back to local coordinate system
        sc_AOD_los = mod(rad2deg(pi/2 - gcs_AOD_los),360);sc_AOD_nlos = mod(rad2deg(pi/2 - gcs_AOD_nlos),360);
        sc_ZOD_los = rad2deg(pi/2 - gcs_ZOD_los);sc_ZOD_nlos = rad2deg(pi/2 - gcs_ZOD_nlos);
        sc_AOA_los = mod(rad2deg(pi/2 - gcs_AOA_los),360);sc_AOA_nlos = mod(rad2deg(pi/2 - gcs_AOA_nlos),360);
        sc_ZOA_los = rad2deg(pi/2 - gcs_ZOA_los);sc_ZOA_nlos = rad2deg(pi/2 - gcs_ZOA_nlos);
        
        % Save updated info of all snapshots
        evoCIR.pathDelays = [sc_delay_los;sc_delay_nlos];
        sc_pathPower = sc_power;
        % Deal with low powers
        for tt = 1:no_snap
            clear indNaN; 
            indNaN = find(sc_pathPower(:,tt)<=10^(Th/10));
            sc_pathPower(indNaN,tt) = 10^(Th/10);
        end
        evoCIR.pathPowers = sc_pathPower;
        evoCIR.pathPhases = sc_phase;
        evoCIR.AODs = [sc_AOD_los;sc_AOD_nlos];
        evoCIR.ZODs = [sc_ZOD_los;sc_ZOD_nlos];
        evoCIR.AOAs = [sc_AOA_los;sc_AOA_nlos];
        evoCIR.ZOAs = [sc_ZOA_los;sc_ZOA_nlos];
        evoCIR.no_snap = no_snap;
        evoCIR.AOA_AOD_mapping = [cluster_subpath_AODlobe_mapping cluster_subpath_AOAlobe_mapping(:,3)];
        CIR_SISO_Struct.(['CIR_SISO_',num2str(segIdx)]).('Evolution') = evoCIR;
        
        
    elseif (strcmp(segEnvType(segIdx),'NLOS'))
        no_mpc = size(sc_powerSpectrum,1);
        sc_AOA_nlos = zeros(no_mpc,no_snap);sc_AOA_nlos(:,1) = sc_powerSpectrum(:,6);
        sc_AOD_nlos = zeros(no_mpc,no_snap);sc_AOD_nlos(:,1) = sc_powerSpectrum(:,4);
        sc_ZOA_nlos = zeros(no_mpc,no_snap);sc_ZOA_nlos(:,1) = sc_powerSpectrum(:,7);
        sc_ZOD_nlos = zeros(no_mpc,no_snap);sc_ZOD_nlos(:,1) = sc_powerSpectrum(:,5);
        sc_delay_nlos = zeros(no_mpc,no_snap);sc_delay_nlos(:,1) = sc_powerSpectrum(:,1);
        sc_power = zeros(no_mpc,no_snap);sc_power(:,1) = sc_powerSpectrum(:,2);  
        sc_phase = zeros(no_mpc,no_snap);sc_phase(:,1) = sc_powerSpectrum(:,3);
        
        gcs_AOD_nlos = zeros(no_mpc,no_snap); gcs_AOD_nlos(:,1) = mod(pi/2 - deg2rad(sc_AOD_nlos(:,1)),2*pi);
        gcs_ZOD_nlos = zeros(no_mpc,no_snap); gcs_ZOD_nlos(:,1) = pi/2 - deg2rad(sc_ZOD_nlos(:,1));
        gcs_AOA_nlos = zeros(no_mpc,no_snap); gcs_AOA_nlos(:,1) = mod(pi/2 - deg2rad(sc_AOA_nlos(:,1)),2*pi);
        gcs_ZOA_nlos = zeros(no_mpc,no_snap); gcs_ZOA_nlos(:,1) = pi/2 - deg2rad(sc_ZOA_nlos(:,1));
        
        xBern = randi(2,no_mpc,1);
        
        for t = 2:no_snap

            % Update delay
            azi = gcs_AOA_nlos(:,t-1);
            ele = gcs_ZOA_nlos(:,t-1);
            r_hat = [cos(ele).*sin(azi), cos(ele).*cos(azi), sin(ele)];
            deltaDist = r_hat*v(:,t-1)*t_update;
            sc_delay_nlos(:,t) = sc_delay_nlos(:,t-1)-deltaDist/c*1e9;            
%             [sc_tau_n,sc_rho_mn] = getDelayInfo([sc_delay_los(t);sc_delay_nlos(:,t)],nSP);
            [sc_tau_n,sc_rho_mn] = getDelayInfo(sc_delay_nlos(:,t),nSP);


            % Update power
            sfc = sfMap(round(area/2+track(1,t+(segIdx-1)*co_dps)),round(area/2+track(2,t+(segIdx-1)*co_dps)));
            dc = sqrt(sum(track(:,t+(segIdx-1)*co_dps).^2));
            [~, Prc,~,~] = getPowerInfo(sceType,envType,f,n,sfc,TXPower,...
                                    dc,d0,p,c,u,temp,RR,Pol,Fol,h_BS,folAtt,dFol);
            sc_power_cluster = getClusterPowers(sc_tau_n,Pr_dBm,Gamma,sigmaCluster,Th);
            power_temp = getSubpathPowers(sc_rho_mn,sc_power_cluster,gamma,sigmaSubpath,segEnvType(segIdx),Th);
            sc_power(:,t) = structToList(power_temp,nSP);
            
            % Update phase
            dt_delay = sc_delay_nlos(:,t)-sc_delay_nlos(:,t-1);
            sc_phase(:,t) = mod(sc_phase(:,t-1) + dt_delay*2*pi*f*1e-3, 2*pi);
            
            % Update angles (NLOS components)
            for i_path = 1:no_mpc

                tempBern = xBern(i_path);
                deltaRS = gcs_AOA_nlos(i_path,t-1)+(-1)^tempBern*gcs_AOD_nlos(i_path,t-1)+tempBern*pi;
                v_RS = mod(deltaRS+(-1)^tempBern*v(1:2,t-1),2*pi);
                v_RS = [v_RS;0];
                
                deltaAOD = v_RS'*[-sin(gcs_AOD_nlos(i_path,t-1));cos(gcs_AOD_nlos(i_path,t-1));0]*t_update;
                gcs_AOD_nlos(i_path,t) = gcs_AOD_nlos(i_path,t-1) + deltaAOD/(c*sc_delay_nlos(i_path,t-1)*1e-9*sin(gcs_ZOD_nlos(i_path,t-1)));

                deltaZOD = v_RS'*[cos(gcs_ZOD_nlos(i_path,t-1))*cos(gcs_AOD_nlos(i_path,t-1));cos(gcs_ZOD_nlos(i_path,t-1))*sin(gcs_AOD_nlos(i_path,t-1));-sin(gcs_ZOD_nlos(i_path,t-1))]*t_update;
                gcs_ZOD_nlos(i_path,t) = gcs_ZOD_nlos(i_path,t-1) + deltaZOD/(c*sc_delay_nlos(i_path,t-1)*1e-9);

                deltaAOA = v_RS'*[-sin(gcs_AOA_nlos(i_path,t-1));cos(gcs_AOA_nlos(i_path,t-1));0]*t_update;
                gcs_AOA_nlos(i_path,t) = gcs_AOA_nlos(i_path,t-1) - deltaAOA/(c*sc_delay_nlos(i_path,t-1)*1e-9*sin(gcs_ZOA_nlos(i_path,t-1)));

                deltaZOA = v_RS'*[cos(gcs_ZOA_nlos(i_path,t-1))*cos(gcs_AOA_nlos(i_path,t-1));cos(gcs_ZOA_nlos(i_path,t-1))*sin(gcs_AOA_nlos(i_path,t-1));-sin(gcs_ZOA_nlos(i_path,t-1))]*t_update;
                gcs_ZOA_nlos(i_path,t) = gcs_ZOA_nlos(i_path,t-1) + deltaZOA/(c*sc_delay_nlos(i_path,t-1)*1e-9);

            end 
        end
        
        % Change angles back to local coordinate system
        sc_AOD_nlos = mod(rad2deg(pi/2 - gcs_AOD_nlos),360);
        sc_ZOD_nlos = rad2deg(pi/2 - gcs_ZOD_nlos);
        sc_AOA_nlos = mod(rad2deg(pi/2 - gcs_AOA_nlos),360);
        sc_ZOA_nlos = rad2deg(pi/2 - gcs_ZOA_nlos);
        
        evoCIR.pathDelays = sc_delay_nlos;
        % Deal with low powers
        for tt = 1:no_snap
            clear indNaN; 
            indNaN = find(sc_power(:,tt)<=10^(Th/10));
            sc_power(indNaN,tt) = 10^(Th/10);
        end
        evoCIR.pathPowers = sc_power;
        evoCIR.pathPhases = sc_phase;
        evoCIR.AODs = sc_AOD_nlos;
        evoCIR.ZODs = sc_ZOD_nlos;
        evoCIR.AOAs = sc_AOA_nlos;
        evoCIR.ZOAs = sc_ZOA_nlos;
        evoCIR.no_snap = no_snap;
        evoCIR.AOA_AOD_mapping = [cluster_subpath_AOAlobe_mapping cluster_subpath_AODlobe_mapping(:,3)];
        CIR_SISO_Struct.(['CIR_SISO_',num2str(segIdx)]).('Evolution') = evoCIR;
        
    end
     
end % End of a channel segment

%% Blockage 
%
% There is another additional feature of NYUSIM using a human blockage
% model which is well explained in 
% G. R. MacCartney, Jr., T. S. Rappaport, and Sundeep Rangan “Rapid Fading 
% Due to Human Blockage in Pedestrian Crowds at 5G Millimeter-Wave 
% Frequencies,” 2017 IEEE Global Communications Conference (GLOBECOM), 
% Singapore, Dec. 2017. https://arxiv.org/pdf/1709.05883.pdf
%
% Basically, the function transforms the saved CIRs into a big struct
% having the size of # of snapshots x 1. Each entry (snapshot) has angle,
% delay, power info.
% CIR_SISO_EVO = getTimeEvolvedChannel(CIR_SISO_Struct,numberOfSegments,lengthOfSegments);

% Obtain the Markov chain of the blockage state during the RX movement,
% where 1 is "unshadowed", 2 is "decay", 3 is "shadowed", 4 is "rise"

% Whether the user uses default relationship between HPBW and transition
% rates or uses customized transition rates. "Yes" corresponds the former 
% while "No" corresponds the latter.
% default = 'No';

% Set the length of the Markov Chain 'mcLen'
if t_dps > 10 % unit:s
    mcLen = ceil((t_dps+1)*2e3);
else
    mcLen = 20e3;
end

% Note that the time resolution of Markov chain is always 1 ms.
t_px = 1e-3;
intervalSamples = ceil(t_update/t_px);

for k = 1:numberOfSegments
    tmpCIR = CIR_SISO_Struct.(['CIR_SISO_',num2str(k)]).('Evolution');
    numAOAlobes = max(tmpCIR.('AOA_AOD_mapping')(:,3));
    numAODlobes = max(tmpCIR.('AOA_AOD_mapping')(:,4));
    
    % Generate Markov trace with different states for each AOA and AOD lobe
    % combination.
    for i_aoa = 1:numAOAlobes
        allMPC_AOA = find(tmpCIR.AOA_AOD_mapping(:,3)==i_aoa);
        maxAng = max(CIR_SISO_Struct.(['CIR_SISO_',num2str(k)]).AOAs(allMPC_AOA));
        minAng = min(CIR_SISO_Struct.(['CIR_SISO_',num2str(k)]).AOAs(allMPC_AOA));
        HPBW = maxAng-minAng; % in degree
        if HPBW > 200
            HPBW = minAng+360-maxAng;
        end
        
        for j_aod = 1:numAODlobes
            
            loss = zeros(5,mcLen);
            for m = 1:5 
                if strcmp(default,'Yes')
                    
                    [mc,r] = getMarkovTrace_default(HPBW,mcLen,t_px);
                    [numberOfBlockage, blocksnap] = getBlockageEvent(mc);
                    
                    for bk = 1:numberOfBlockage
                        
                        lengthOfDecay = length(blocksnap.(['b',num2str(bk)]).decay);
                        lengthOfShad = length(blocksnap.(['b',num2str(bk)]).shad);
                        lengthOfRise = length(blocksnap.(['b',num2str(bk)]).rise);

                        % Find the blocked MPCs
                        blockMPC_AOA = find(tmpCIR.AOA_AOD_mapping(:,3)==i_aoa);
                        blockMPC_AOD = find(tmpCIR.AOA_AOD_mapping(:,4)==j_aod);
                        blockMPC = intersect(blockMPC_AOA,blockMPC_AOD);

                        % Add attenuation caused by human blockage events
                        % to the multipath component power
                        % Decay part
                        count_decay = 1;
                        for k_decay = blocksnap.(['b',num2str(bk)]).decay(1):blocksnap.(['b',num2str(bk)]).decay(end)
                            loss(m,k_decay) = r*count_decay/lengthOfDecay;
                            count_decay = count_decay +1;
                        end

                        % Shadow part
                        for k_shad = blocksnap.(['b',num2str(bk)]).shad(1):blocksnap.(['b',num2str(bk)]).shad(end)
                            loss(m,k_shad) = r;
                        end  

                        % Rise part
                        count_rise = 1;
                        for k_rise = blocksnap.(['b',num2str(bk)]).rise(1):blocksnap.(['b',num2str(bk)]).rise(end)
                            loss(m,k_rise) = r*(1-count_rise/lengthOfRise);
                            count_rise = count_rise + 1;
                        end  
                    
                    end % End of blockages for each trace
                    
                    
                elseif strcmp(default,'No')
                    lambdaDecay = 0.21;
                    lambdaShad = 7.88;
                    lambdaRise = 7.70;
                    lambdaUnshad = 7.67;
                    SEmean = 15.8;
                    mc = getMarkovTrace(lambdaDecay,lambdaShad,lambdaRise,lambdaUnshad,mcLen,t_px);
                    r = SEmean; % Let user input positive value
                    
                    [numberOfBlockage, blocksnap] = getBlockageEvent(mc);
                    
                    for bk = 1:numberOfBlockage
                        
                        lengthOfDecay = length(blocksnap.(['b',num2str(bk)]).decay);
                        lengthOfShad = length(blocksnap.(['b',num2str(bk)]).shad);
                        lengthOfRise = length(blocksnap.(['b',num2str(bk)]).rise);

                        % Find the blocked MPCs
                        blockMPC_AOA = find(tmpCIR.AOA_AOD_mapping(:,3)==i_aoa);
                        blockMPC_AOD = find(tmpCIR.AOA_AOD_mapping(:,4)==j_aod);
                        blockMPC = intersect(blockMPC_AOA,blockMPC_AOD);


                        % Decay part
                        count_decay = 1;
                        for k_decay = blocksnap.(['b',num2str(bk)]).decay(1):blocksnap.(['b',num2str(bk)]).decay(end)
                            loss(m,k_decay) = r*count_decay/lengthOfDecay;
                            count_decay = count_decay +1;
                        end

                        % Shadow part
                        for k_shad = blocksnap.(['b',num2str(bk)]).shad(1):blocksnap.(['b',num2str(bk)]).shad(end)
                            loss(m,k_shad) = r;
                        end  

                        % Rise part
                        count_rise = 1;
                        for k_rise = blocksnap.(['b',num2str(bk)]).rise(1):blocksnap.(['b',num2str(bk)]).rise(end)
                            loss(m,k_rise) = r*(1-count_rise/lengthOfRise);
                            count_rise = count_rise + 1;
                        end  
                    
                    end % End of blockages for each trace
                    
                end % End of default on or off
                
            end % End of 5 blockers
            sum_loss = sum(loss,1);
            
%             actual_loss = sum_loss(randi(mcLen,1),1);

            init = randi(999,1);
            for t = 1:lengthOfSegments(k)
                linearLoss = 10^(sum_loss(init+(t-1)*intervalSamples)/10);
                tmpCIR.pathPowers(blockMPC) = tmpCIR.pathPowers(blockMPC)/linearLoss;
            end % End of snapshot
            
        end % End of AOD lobes
        
    end % ENd of AOA lobes

end % End of channel segments

%% Put all snapshots together
CIR_SISO_EVO = getTimeEvolvedChannel(CIR_SISO_Struct,numberOfSegments,lengthOfSegments);

%% Smooth transitions
%
% Note that the blockage part (if enabled) should be run before we do
% transition between segments.
%
% This part is to deal with one problem. Considering the first CIR of each
% segment is independent from each other. Then, the last snapshot in the
% former segment might be very different from the first snapshot in the
% latter segment. Thus, a smooth transition is necessary to be implemented
% in the post processing.
%
% The method is to do cluster birth and death
% - If the # of clusters in the former (denoted as A) is greater than the # of clusters in
% the latter (denoted as B), then one of the clusters of A is dropped in a
% snapshot.
% - If the # of clusters in A is greater than the # of clusters in
% B, then one of the clusters of B is generated in a snapshot
% - if the # of clusters in A is equal the # of clusters in
% B, then one of clusters of A is dropped and one of clusters of B is
% generated in the same snapshot. 
%
% Note that usually, the cluster birth and death starts from the weakest one. 
if strcmp(transExist, 'Yes') == 1
    CIR_SISO_EVO = getTransitions(nTC,numberOfSegments,co_dps,CIR_SISO_Struct,CIR_SISO_EVO);
end
TR3D = sqrt(sum((track-TX_Pos).^2));
TR2D = sqrt(sum(track(1:2,:).^2));
omniPL = zeros(numberOfSnapshot,1);
omniPr = zeros(numberOfSnapshot,1);
omniDS = zeros(numberOfSnapshot,1);
KFactor = zeros(numberOfSnapshot,1);

for i_snap = 1:numberOfSnapshot
    
    % Omnidirectional channels
    sdf = sfMap(round(area/2+track(1,i_snap)),round(area/2+track(2,i_snap)));
    [PL_dB, Pr_dBm, FSPL, PLE] = getPowerInfo(sceType,envType,f,n,sdf,TXPower,...
                                    TR2D(i_snap),d0,p,c,u,temp,RR,Pol,Fol,h_BS,folAtt,dFol); 
    omniPL(i_snap,1) = PL_dB;
    omniPr(i_snap,1) = Pr_dBm;
    CIR_tmp = CIR_SISO_EVO.(['Snapshot',num2str(i_snap)]);
    multipathArray = CIR_tmp.pathPowers;
    Pr = 10*log10(multipathArray);
    xmaxInd = find(Pr>Th);
    Pr = Pr(xmaxInd);
    timeArray = CIR_tmp.pathDelays;
    timeArray = timeArray(xmaxInd);
    multipathArray = multipathArray(xmaxInd);
    meanTau = sum(timeArray.*multipathArray)/sum(multipathArray);
    meanTau_Sq = sum(timeArray.^2.*multipathArray)/sum(multipathArray);
    RMSDelaySpread = sqrt(meanTau_Sq-meanTau^2);
    omniDS(i_snap) = RMSDelaySpread;
    KFactor(i_snap) = 10*log10(max(multipathArray)/(sum(multipathArray)-max(multipathArray)));
    
end

%% MIMO CIR for each channel snapshot
for i_snap = 1:numberOfSnapshot
    CIR_tmp = CIR_SISO_EVO.(['Snapshot',num2str(i_snap)]);
    [CIR_MIMO_tmp,~,~,~,~] = getLocalCIR(CIR_tmp,...
        TxArrayType,RxArrayType,Nt,Nr,Wt,Wr,dTxAnt,dRxAnt,RFBW);
    % MIMO CIR is stored
    CIR_MIMO_EVO.(['Snapshot',num2str(i_snap)]) = CIR_MIMO_tmp;
end

%% Directional CIR for each channel snapshot
DirPDPInfo = [];
for i_snap = 1:numberOfSnapshot
    CIR_tmp = CIR_SISO_EVO.(['Snapshot',num2str(i_snap)]);
    ps = [CIR_tmp.pathDelays, CIR_tmp.pathPowers, CIR_tmp.pathPhases,...
        CIR_tmp.AODs, CIR_tmp.ZODs, CIR_tmp.AOAs, CIR_tmp.ZOAs];
    TRd = sqrt(sum(track(1:2,i_snap).^2));
    
    [DirRMSDelaySpread, PL_dir, PLE_dir, Pr_dir] = getDirStat(ps,...
    theta_3dB_TX,phi_3dB_TX,theta_3dB_RX,phi_3dB_RX,TXPower,FSPL,TRd,d0);
    
    % Plot the strongest directional PDP
    [maxP, maxIndex] = max(ps(:,2));
    
    % Angles for use
    theta_TX_d = CIR_tmp.AODs;
    phi_TX_d = CIR_tmp.ZODs;
    theta_RX_d = CIR_tmp.AOAs;
    phi_RX_d = CIR_tmp.ZOAs;
    
    % Get directive antenna gains
    [TX_Dir_Gain_Mat, RX_Dir_Gain_Mat, G_TX, G_RX] = getDirectiveGains(theta_3dB_TX,...
        phi_3dB_TX,theta_3dB_RX,phi_3dB_RX,theta_TX_d(maxIndex),phi_TX_d(maxIndex),...
        theta_RX_d(maxIndex),phi_RX_d(maxIndex),ps);

    % Recover the directional PDP
    [timeArray_Dir, multipathArray_Dir] = getDirPDP(ps,...
        TX_Dir_Gain_Mat,RX_Dir_Gain_Mat);
    
%     Pr_Dir = 10^(sum(multipathArray_Dir)/10);
    meanTau = sum(timeArray_Dir.*multipathArray_Dir)/sum(multipathArray_Dir);
    meanTau_Sq = sum(timeArray_Dir.^2.*multipathArray_Dir)/sum(multipathArray_Dir);
    rmsDS_best = sqrt(meanTau_Sq-meanTau^2);
    DirPDP = [timeArray_Dir, multipathArray_Dir];
    
    CIR_tmp.pathPowers_BestDir = multipathArray_Dir; % Best direction
    CIR_tmp.rmsDS = DirRMSDelaySpread;
    CIR_tmp.PL_dir = PL_dir;
    CIR_tmp.PLE_dir = PLE_dir;
    CIR_tmp.rmsDS_BestDir = rmsDS_best;
    CIR_tmp.Pr_dir = Pr_dir;
    CIR_SISO_EVO_DIR.(['Snapshot',num2str(i_snap)]) = CIR_tmp;
    psDB = ps;
    psDB(:,2) = 10.*log10(psDB(:,2));
    onefill = ones(length(Pr_dir),1);
    DirPDPInfo_temp = [i_snap*onefill,TR3D(i_snap)*onefill,psDB,PL_dir,DirRMSDelaySpread];DirPDPInfo = vertcat(DirPDPInfo,DirPDPInfo_temp);
end

%% plot
if plotStatus == true
    %%% Plot 1: Spatially correlated SF map
    h1 = plotSFMap(d_co,area,sfMap,track,sceType,envType,SF,movDistance,velocity,f,dini,FigVisibility);
    %%% Plot 2: Spatially correlated LOS/NLOS map
    h2 = plotLOSMap(d_co_los,area,losMap,track,sceType,envType,movDistance,velocity,f,dini,FigVisibility);
    %%% Plot 3: User track
    h3 = plotUserTrack(area,track,sfMap,sceType,envType,f,SF,dini,movDistance,velocity,FigVisibility);
    %%% Plot 4: Consecutive omnidirectional PDPs
    h4 = plotConPDP(CIR_SISO_EVO,Th,f,sceType,envType,dini,d_update,d_co,movDistance,velocity,FigVisibility);
    %%% Plot 5: Consecutive directional PDPs
    h5 = ...
    plotConDirPDP(CIR_SISO_EVO,theta_3dB_TX,phi_3dB_TX,theta_3dB_RX,phi_3dB_RX,Th,f,sceType,envType,dini,d_update,d_co,movDistance,velocity,FigVisibility);
    
end

%% Processing bar update
Count = Count+1;
javaMethodEDT('setValue', jBarHandle, Count);
pause(0.2);

%% Basic Parameters
BasicParameters = struct;
BasicParameters.Frequency = f; 
BasicParameters.Bandwidth = RFBW; 
BasicParameters.TXPower = TXPower;
BasicParameters.Environment = envType; 
BasicParameters.Scenario = sceType;
BasicParameters.TXHeight = h_BS;
BasicParameters.RXHeight = h_MS;
BasicParameters.Pressure = p; 
BasicParameters.Humidity = u;
BasicParameters.Temperature = temp; 
BasicParameters.RainRate = RR;
BasicParameters.Polarization = Pol; 
BasicParameters.Foliage = Fol;
BasicParameters.DistFol = dFol; 
BasicParameters.FoliageAttenuation = folAtt;

BasicParameters.TxArrayType = TxArrayType; 
BasicParameters.RxArrayType = RxArrayType;
BasicParameters.NumberOfTxAntenna = Nt; 
BasicParameters.NumberOfRxAntenna = Nr;
BasicParameters.NumberOfTxAntennaPerRow = Wt; 
BasicParameters.NumberOfRxAntennaPerRow = Wr;
BasicParameters.TxAntennaSpacing = dTxAnt; 
BasicParameters.RxAntennaSpacing = dRxAnt; 
BasicParameters.TxAzHPBW = theta_3dB_TX; 
BasicParameters.TxElHPBW = phi_3dB_TX; 
BasicParameters.RxAzHPBW = theta_3dB_RX; 
BasicParameters.RxElHPBW = phi_3dB_RX;

BasicParameters.SCenable = scIdc;
BasicParameters.CorrDistanceSF = d_co;
BasicParameters.CorrDistanceLOS = d_co_los;
BasicParameters.TrackType = trackType;
BasicParameters.MovDistance = movDistance;
BasicParameters.MovDirection = direction;
BasicParameters.UpdateDist = d_update;
BasicParameters.Velocity = velocity;

BasicParameters.HBenable = hbIdc;
BasicParameters.HBdefault = default;
BasicParameters.SEMean = SEmean;
BasicParameters.U2Drate = lambdaDecay;
BasicParameters.D2Srate = lambdaShad;
BasicParameters.S2Rrate = lambdaRise;
BasicParameters.R2Urate = lambdaUnshad;

%% Save files
saveas(h1,[outputFolder,'SF_Map.png']);
saveas(h2,[outputFolder,'LOS_Map.png']); 
saveas(h3,[outputFolder,'UserTrack.png']); 
saveas(h4,[outputFolder,'OmniConsecutivePDP.png']);
saveas(h5,[outputFolder,'DirConsecutive.png']);

if strcmp(fileType,'Text File') == true
    for SI = 1:numberOfSnapshot
    CIR_write = CIR_SISO_EVO_DIR.(['Snapshot',num2str(SI)]);
    OmniPDP = [CIR_write.pathDelays, CIR_write.pathPowers, CIR_write.pathPhases,...
       CIR_write.AODs, CIR_write.ZODs, CIR_write.AOAs, CIR_write.ZOAs];
    DirPDP = [CIR_write.pathDelays, CIR_write.pathPowers_BestDir, CIR_write.pathPhases,...
       CIR_write.AODs, CIR_write.ZODs, CIR_write.AOAs, CIR_write.ZOAs];
    dlmwrite([outputFolder,'OmniPDP_Snap' sprintf('%d',SI) '.txt'],OmniPDP,'delimiter', '\t', 'newline', 'pc');
    dlmwrite([outputFolder,'DirectionalPDP_Snap' sprintf('%d',SI) '.txt'],DirPDP,'delimiter', '\t', 'newline', 'pc');
    end
    
    OmniPDPInfo = [TR3D',omniPr,omniPL,omniDS,KFactor];
    OmniPDPInfo(find(omniPL>DR),2:5)= NaN;
    file_name = ['OmniPDPInfo.txt'];
    fid = fopen([outputFolder,file_name],'wt');
    fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t',...
        'T-R Separation Distance (m)','Received Power (dBm)','Path Loss (dB)','RMS Delay Spread (ns)','K-Factor (dB)'); 
    fprintf(fid,'\n%15.1f\t%25.1f\t%15.1f\t%15.1f\t%20.1f',OmniPDPInfo.'); 
    fclose(fid);
    file_name = ['DirPDPInfo.txt'];
    fid = fopen([outputFolder,file_name],'wt');
    fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t',...
        'Simulation Run Number','T-R Separation Distance (m)','Time Delay (ns)','Received Power (dBm)','Phase (rad)',...
        'Azimuth AoD (degree)','Elevation AoD (degree)','Azimuth AoA (degree)','Elevation AoA (degree)',...
        'Path Loss (dB)','RMS Delay Spread (ns)'); 
    fprintf(fid,'\n%15.1f\t%15.1f\t%20.0f\t%17.1f\t%13.1f\t%15.0f\t%17.1f\t%17.1f\t%17.0f\t%17.1f\t%17.1f',DirPDPInfo.'); 
    fclose(fid);
    
    % Save BasicParameters as .txt file
    struct2File(BasicParameters,[outputFolder,'BasicParameters.txt'],'align',true,'sort',false);

elseif strcmp(fileType,'MAT File') == true 
    for SI = 1:numberOfSnapshot
    CIR_write = CIR_SISO_EVO_DIR.(['Snapshot',num2str(SI)]);
    OmniPDP = [CIR_write.pathDelays, CIR_write.pathPowers, CIR_write.pathPhases,...
       CIR_write.AODs, CIR_write.ZODs, CIR_write.AOAs, CIR_write.ZOAs];
    DirPDP = [CIR_write.pathDelays, CIR_write.pathPowers_BestDir, CIR_write.pathPhases,...
       CIR_write.AODs, CIR_write.ZODs, CIR_write.AOAs, CIR_write.ZOAs];
    save([outputFolder,'OmniPDP_Snap' sprintf('%d',SI)],'OmniPDP');
    save([outputFolder,'DirectionalPDP_Snap' sprintf('%d',SI)],'DirPDP');
    end
    OmniPDPInfo = [TR3D',omniPr,omniPL,omniDS,KFactor];
    OmniPDPInfo(find(omniPL>DR),2:5)= NaN;
    save([outputFolder,'OmniPDPInfo'],'OmniPDPInfo');
    save([outputFolder,'DirPDPInfo'],'DirPDPInfo');    
    
    % Save BasicParameters as .mat file
    save([outputFolder,'BasicParameters.mat'],'BasicParameters');

elseif strcmp(fileType,'Both Text and MAT File') == true
    for SI = 1:numberOfSnapshot
    CIR_write = CIR_SISO_EVO_DIR.(['Snapshot',num2str(SI)]);
    OmniPDP = [CIR_write.pathDelays, CIR_write.pathPowers, CIR_write.pathPhases,...
       CIR_write.AODs, CIR_write.ZODs, CIR_write.AOAs, CIR_write.ZOAs];
    DirPDP = [CIR_write.pathDelays, CIR_write.pathPowers_BestDir, CIR_write.pathPhases,...
       CIR_write.AODs, CIR_write.ZODs, CIR_write.AOAs, CIR_write.ZOAs];
    save([outputFolder,'OmniPDP_Snap' sprintf('%d',SI)],'OmniPDP');
    save([outputFolder,'DirectionalPDP_Snap' sprintf('%d',SI)],'DirPDP');
    dlmwrite([outputFolder,'OmniPDP_Snap' sprintf('%d',SI) '.txt'],OmniPDP,'delimiter', '\t', 'newline', 'pc');
    dlmwrite([outputFolder,'DirectionalPDP_Snap' sprintf('%d',SI) '.txt'],DirPDP,'delimiter', '\t', 'newline', 'pc');
    end
    
    OmniPDPInfo = [TR3D',omniPr,omniPL,omniDS,KFactor];
    OmniPDPInfo(find(omniPL>DR),2:5)= NaN;
    save('OmniPDPInfo','OmniPDPInfo');
    file_name = ['OmniPDPInfo.txt'];
    fid = fopen([outputFolder,file_name],'wt');
    fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t',...
        'T-R Separation Distance (m)','Received Power (dBm)','Path Loss (dB)','RMS Delay Spread (ns)','K-Factor (dB)'); 
    fprintf(fid,'\n%15.1f\t%25.1f\t%15.1f\t%15.1f\t%20.1f',OmniPDPInfo.'); 
    fclose(fid);
    save('DirPDPInfo','DirPDPInfo');
    file_name = ['DirPDPInfo.txt'];
    fid = fopen([outputFolder,file_name],'wt');
    fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t',...
    'Simulation Run Number','T-R Separation Distance (m)','Time Delay (ns)','Received Power (dBm)','Phase (rad)',...
    'Azimuth AoD (degree)','Elevation AoD (degree)','Azimuth AoA (degree)','Elevation AoA (degree)',...
    'Path Loss (dB)','RMS Delay Spread (ns)'); 
    fprintf(fid,'\n%15.1f\t%15.1f\t%20.0f\t%17.1f\t%13.1f\t%15.0f\t%17.1f\t%17.1f\t%17.0f\t%17.1f\t%17.1f',DirPDPInfo.');
    fclose(fid);
    
    % Save BasicParameters as .mat file
    save([outputFolder,'BasicParameters.mat'],'BasicParameters');
    % Save BasicParameters as .txt file
    struct2File(BasicParameters,[outputFolder,'BasicParameters.txt'],'align',true,'sort',false);
end

%% Processing bar update
Count = Count+1;
javaMethodEDT('setValue', jBarHandle, Count);
pause(0.2);
if exist('hhandle','var') == 1
delete(hhandle); 
end
delete(txtPb);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif strcmp(scIdc,'Off')

%% Channel Model Parameters
% Free space reference distance in meters
d0 = 1; 
% Speed of light in m/s
c = physconst('LightSpeed');

if strcmp(sceType,'InH') == true && strcmp(envType,'LOS') == true 
% Path loss exponent (PLE)
% Calculation of frequency-depedent PLE for InH LOS scenario since we
% observed that the PLE at 28 GHz is particular low about 1.4. PLE at sub-6
% GHz from the literature is about 1.8, and the PLE measured by NYU at 140
% GHz is 1.75, approximately 1.8. Thus, we applied such two-segement PLE
% calculation across frequencies from 0.5 to 150 GHz.

% PLE
n = calPleLos(f);
% Shadow fading standard deviation in dB
SF = calPar(3,2.9,f); 
% Mean number of time clusters
lambda_C = calPar(3.6,0.9,f);
% Number of cluster subpaths
beta_S = calPar(0.7,1.0,f);
mu_S = calPar(3.7,1.4,f);
SPlimit = round(calPar(35,10,f));
% For indoor scenario, mu_AOD stands for the maximum number of spatial lobes
mu_AOD = round(calPar(3,2,f)); 
% For indoor scenario, mu_AOA stands for the maximum number of spatial lobes
mu_AOA = round(calPar(3,2,f)); 
% For indoor scenario, X_max stands for mu_rho -> intra-cluster delay
X_max = calPar(3.4,1.1,f);
% Mean excess delay in ns
mu_tau = calPar(17.3,14.6,f); 
% Minimum inter-cluster void interval, typically set to 25 ns for outdoor environments
minVoidInterval = 6;
% Per-cluster shadowing in dB
sigmaCluster = calPar(10,9,f);
% Time cluster decay constant in ns
Gamma = calPar(20.7,18.2,f); 
% Per-subpath shadowing in dB
sigmaSubpath = calPar(5,5,f); 
% Subpath decay constant in ns
gamma = calPar(2.0,2.0,f); 
% Mean zenith angle of departure (ZOD) in degrees
mean_ZOD = calPar(-7.3,-6.8,f);
% Standard deviation of the ZOD distribution in degrees
sigma_ZOD = calPar(3.8,4.9,f); 
% Standard deviation of the azimuth offset from the lobe centroid
std_AOD_RMSLobeAzimuthSpread = calPar(20.6,4.8,f);
% Standard deviation of the elevation offset from the lobe centroid
std_AOD_RMSLobeElevationSpread = calPar(15.7,4.3,f);
% A string specifying which distribution to use: 'Gaussian' or 'Laplacian'
distributionType_AOD = 'Gaussian'; 
% Mean zenith angle of arrival (ZOA) in degrees
mean_ZOA = calPar(7.4,7.4,f); 
% Standard deviation of the ZOA distribution in degrees
sigma_ZOA = calPar(3.8,4.5,f);
% Standard deviation of the azimuth offset from the lobe centroid
std_AOA_RMSLobeAzimuthSpread = calPar(17.7,4.7,f);
% Standard deviation of the elevation offset from the lobe centroid
std_AOA_RMSLobeElevationSpread = calPar(14.4,4.4,f);
% A string specifying which distribution to use: 'Gaussian' or 'Laplacian'
distributionType_AOA = 'Gaussian';   
elseif strcmp(sceType,'InH') == true && strcmp(envType,'NLOS') == true
% See the parameter definitions for InH LOS
n = calPar(2.7,2.7,f); 
SF = calPar(9.8,6.6,f); 
lambda_C = calPar(5.1,1.8,f);
beta_S = calPar(0.7,1.0,f);
mu_S = calPar(5.3,1.2,f);
SPlimit = round(calPar(35,10,f));
mu_AOD = round(calPar(3,3,f)); 
mu_AOA = round(calPar(3,2,f));
X_max = calPar(22.7,2.7,f);
mu_tau = calPar(10.9,21.0,f); 
minVoidInterval = 6;
sigmaCluster = calPar(10,10,f);
Gamma = calPar(23.6,16.1,f); 
sigmaSubpath = calPar(6,6,f); 
gamma = calPar(9.2,2.4,f); 
mean_ZOD = calPar(-5.5,-2.5,f);
sigma_ZOD = calPar(2.9,2.7,f); 
std_AOD_RMSLobeAzimuthSpread = calPar(27.1,4.8,f);
std_AOD_RMSLobeElevationSpread = calPar(16.2,2.8,f);
distributionType_AOD = 'Gaussian'; 
mean_ZOA = calPar(5.5,4.8,f); 
sigma_ZOA = calPar(2.9,2.8,f);
std_AOA_RMSLobeAzimuthSpread = calPar(20.3,6.6,f);
std_AOA_RMSLobeElevationSpread = calPar(15.0,4.5,f);
distributionType_AOA = 'Gaussian'; 
% UMi LOS
elseif strcmp(sceType,'UMi') == true && strcmp(envType,'LOS') == true 
% Path loss exponent (PLE)
n = 2; 
% Shadow fading standard deviation in dB
SF = 4.0; 
% Mean angle of departure (AOD)
mu_AOD = 1.9; 
% Mean angle of arrival (AOA)
mu_AOA = 1.8;
% A number between 0 and 1 for generating intra-cluster delays
X_max = 0.2;
% Mean excess delay in ns
mu_tau = 123; 
% Minimum inter-cluster void interval, typically set to 25 ns for outdoor environments
minVoidInterval = 25;
% Per-cluster shadowing in dB
sigmaCluster = 1;
% Time cluster decay constant in ns
Gamma = 25.9; 
% Per-subpath shadowing in dB
sigmaSubpath = 6; 
% Subpath decay constant in ns
gamma = 16.9; 
% Mean zenith angle of departure (ZOD) in degrees
mean_ZOD = -12.6;
% Standard deviation of the ZOD distribution in degrees
sigma_ZOD = 5.9; 
% Standard deviation of the azimuth offset from the lobe centroid
std_AOD_RMSLobeAzimuthSpread = 8.5;
% Standard deviation of the elevation offset from the lobe centroid
std_AOD_RMSLobeElevationSpread = 2.5;
% A string specifying which distribution to use: 'Gaussian' or 'Laplacian'
distributionType_AOD = 'Gaussian'; 
% Mean zenith angle of arrival (ZOA) in degrees
mean_ZOA = 10.8; 
% Standard deviation of the ZOA distribution in degrees
sigma_ZOA = 5.3;
% Standard deviation of the azimuth offset from the lobe centroid
std_AOA_RMSLobeAzimuthSpread = 10.5;
% Standard deviation of the elevation offset from the lobe centroid
std_AOA_RMSLobeElevationSpread = 11.5;
% A string specifying which distribution to use: 'Gaussian' or 'Laplacian'
distributionType_AOA = 'Laplacian';   
% UMi NLOS
elseif strcmp(sceType,'UMi') == true && strcmp(envType,'NLOS') == true
% See the parameter definitions for UMi LOS
n = 3.2; 
SF = 7.0; 
mu_AOD = 1.5; 
mu_AOA = 2.1; 
X_max = 0.5; 
mu_tau = 83;
minVoidInterval = 25; 
sigmaCluster = 3; 
Gamma = 51.0; 
sigmaSubpath = 6;
gamma = 15.5; 
mean_ZOD = -4.9; 
sigma_ZOD = 4.5; 
std_AOD_RMSLobeAzimuthSpread = 11.0;
std_AOD_RMSLobeElevationSpread = 3.0; 
distributionType_AOD = 'Gaussian'; 
mean_ZOA = 3.6; 
sigma_ZOA = 4.8; 
std_AOA_RMSLobeAzimuthSpread = 7.5;
std_AOA_RMSLobeElevationSpread = 6.0; 
distributionType_AOA = 'Laplacian';
% UMa LOS
elseif strcmp(sceType,'UMa') == true && strcmp(envType,'LOS') == true 
% See the parameter definitions for UMi LOS
n = 2; 
SF = 4.0; 
mu_AOD = 1.9; 
mu_AOA = 1.8;
X_max = 0.2; 
mu_tau = 123; 
minVoidInterval = 25; 
sigmaCluster = 1;
Gamma = 25.9; 
sigmaSubpath = 6; 
gamma = 16.9; 
mean_ZOD = -12.6;
sigma_ZOD = 5.9; 
std_AOD_RMSLobeAzimuthSpread = 8.5;
std_AOD_RMSLobeElevationSpread = 2.5;
distributionType_AOD = 'Gaussian'; 
mean_ZOA = 10.8; 
sigma_ZOA = 5.3;
std_AOA_RMSLobeAzimuthSpread = 10.5;
std_AOA_RMSLobeElevationSpread = 11.5;
distributionType_AOA = 'Laplacian'; 
% UMa NLOS
elseif strcmp(sceType,'UMa') == true && strcmp(envType,'NLOS') == true 
% See the parameter definitions for UMi LOS
n = 2.9; 
SF = 7.0; 
mu_AOD = 1.5; 
mu_AOA = 2.1; 
X_max = 0.5; 
mu_tau = 83;
minVoidInterval = 25; 
sigmaCluster = 3; 
Gamma = 51.0; 
sigmaSubpath = 6;
gamma = 15.5; 
mean_ZOD = -4.9; 
sigma_ZOD = 4.5; 
std_AOD_RMSLobeAzimuthSpread = 11.0;
std_AOD_RMSLobeElevationSpread = 3.0; 
distributionType_AOD = 'Gaussian'; 
mean_ZOA = 3.6; 
sigma_ZOA = 4.8; 
std_AOA_RMSLobeAzimuthSpread = 7.5;
std_AOA_RMSLobeElevationSpread = 6.0; 
distributionType_AOA = 'Laplacian';
% RMa LOS
elseif strcmp(sceType,'RMa') == true && strcmp(envType,'LOS') == true
% See the parameter definitions for UMi LOS
SF = 1.7; 
mu_AOD = 1; 
mu_AOA = 1;
X_max = 0.2; 
mu_tau = 123; 
minVoidInterval = 25; 
sigmaCluster = 1;
Gamma = 25.9; 
sigmaSubpath = 6; 
gamma = 16.9; 
mean_ZOD = -12.6;
sigma_ZOD = 5.9; 
std_AOD_RMSLobeAzimuthSpread = 8.5;
std_AOD_RMSLobeElevationSpread = 2.5;
distributionType_AOD = 'Gaussian'; 
mean_ZOA = 10.8; 
sigma_ZOA = 5.3;
std_AOA_RMSLobeAzimuthSpread = 10.5;
std_AOA_RMSLobeElevationSpread = 11.5;
distributionType_AOA = 'Laplacian';
% RMa NLOS
elseif strcmp(sceType,'RMa') == true && strcmp(envType,'NLOS') == true
% See the parameter definitions for UMi LOS
SF = 6.7; 
mu_AOD = 1; 
mu_AOA = 1; 
X_max = 0.5; 
mu_tau = 83;
minVoidInterval = 25; 
sigmaCluster = 3; 
Gamma = 51.0; 
sigmaSubpath = 6;
gamma = 15.5; 
mean_ZOD = -4.9; 
sigma_ZOD = 4.5; 
std_AOD_RMSLobeAzimuthSpread = 11.0;
std_AOD_RMSLobeElevationSpread = 3.0; 
distributionType_AOD = 'Gaussian'; 
mean_ZOA = 3.6; 
sigma_ZOA = 4.8; 
std_AOA_RMSLobeAzimuthSpread = 7.5;
std_AOA_RMSLobeElevationSpread = 6.0; 
distributionType_AOA = 'Laplacian';
end
%% Initialize various settings and parameters
% Determine the dimension of OmniPDPInfo
if strcmp(Pol,'All-Pol')
    numPol = 4;
elseif strcmp(Pol,'Co/X-Pol')
    numPol = 2;
else
    numPol = 1;
end
% Structure containing generated CIRs
CIR_SISO_Struct = struct; 
CIR_MIMO_Struct = struct;
% Set plot status
plotStatus = true; 
% Set plot rotation status
plotRotate = false; 
% Determine if spatial plot is needed 
plotSpatial = true;
% Number of multipath components
nPath = zeros(N,1); 
% Best (i.e., smallest) directional path loss
PL_dir_best = zeros(N,numPol); 
% Directional PDP information
DirPDPInfo = []; 
% Omnidirectional PDP information
OmniPDPInfo = zeros(N,5,numPol);
% Run for each RX location, i.e., each channel realization
for CIRIdx = 1:N
    clear powerSpectrum PL_dir DirRMSDelaySpread TRDistance;

    %% Step 1: Generate T-R Separation distance (m) ranging from dmin - dmax.
    TRDistance = getTRSep(dmin,dmax);
    % Set dynamic range, i.e., maximum possible omnidirectional path loss 
    % in dB, according to T-R separation distance. If T-R separation 
    % distance is no larger than 500 m, then set dynamic range as 190 dB, 
    % otherwise set it to 220 dB.
    if TRDistance <= 500
        % Dynamic range in dB
        DR = 190;
    else
        DR = 220;
    end
    % Received power threshod in dBm
    Th = TXPower - DR;
    
    %% Step 2: Generate the total received omnidirectional power (dBm) and 
    % omnidirectional path loss (dB) 
    % non RMa, i.e., UMi or UMa
    if strcmp(sceType,'RMa') == false
    [Pr_dBm, PL_dB]= getRXPower(f,n,SF*randn,TXPower,TRDistance,d0);
    % RMa LOS
    elseif strcmp(sceType,'RMa') == true && strcmp(envType,'LOS') == true 
        PL_dB = 20*log10(4*pi*d0*f*1e9/c) + 23.1*(1-0.03*((h_BS-35)/35))*log10(TRDistance) + SF*randn;
    % RMa NLOS
    elseif strcmp(sceType,'RMa') == true && strcmp(envType,'NLOS') == true 
        PL_dB = 20*log10(4*pi*d0*f*1e9/c) + 30.7*(1-0.049*((h_BS-35)/35))*log10(TRDistance) + SF*randn;
    end
    
    % O2I penetration loss
    if strcmp(o2iLoss,'Yes')
        [PL_dB,o2iLossValue] = getO2IPL(PL_dB,f,o2iType);
    end
    % Atmospheric attenuation factor
    attenFactor = mpm93_forNYU(f,p,u,temp,RR);
    % Path loss incorporating atmospheric attenuation
    PL_dB = getAtmosphericAttenuatedPL(PL_dB,attenFactor,TRDistance);
    % Incorporating cross-polarization
%     if strcmp(Pol,'X-Pol') == true
%         PL_dB = PL_dB+25;
%     end
    % Incorporating foliage loss
    if strcmp(Fol,'Yes') == true
        PL_dB = getFoliageAttenuatedPL(PL_dB,folAtt,dFol);
    end      
    % Calculate received power based on transmit power and path loss
    Pr_dBm = TXPower - PL_dB;
    % Free space path loss
    FSPL = 20*log10(4*pi*d0*f*1e9/c);


    %% Step 3 and 4: Generate # of time clusters N, and # AOD and AOA 
    % spatial lobes and the number of subpaths per cluster
    
    %%%%%% Change in NYUSIM 3.0 Indoor scenario %%%%%%
    % Distribution of # of time clusters is Poisson for indoor, rather than
    % Uniform for outdoor
    if strcmp(sceType,'InH')
        [numberOfTimeClusters,numberOfAOALobes,numberOfAODLobes] = ...
            getNumClusters_AOA_AOD_Indoor(mu_AOA,mu_AOD,lambda_C);
        numberOfClusterSubPaths = getNumberOfClusterSubPaths_Indoor(...
            numberOfTimeClusters,beta_S,mu_S,SPlimit);
    else
        [numberOfTimeClusters,numberOfAOALobes,numberOfAODLobes] = ...
            getNumClusters_AOA_AOD(mu_AOA,mu_AOD,sceType);
        numberOfClusterSubPaths = getNumberOfClusterSubPaths(...
            numberOfTimeClusters,sceType);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Step 5: Generate the intra-cluster subpath delays rho_mn (ns)
    %%%%%% Change in NYUSIM 3.0 Indoor scenario %%%%%%
    % X_max represents mu_tau for indoor, rather than X_max for outdoor
    rho_mn = getIntraClusterDelays(numberOfClusterSubPaths,X_max,sceType);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Step 6: Generate the phases (rad) for each cluster
    phases_mn = getSubpathPhases(rho_mn);
    
    %% Step 7: Generate the cluster excess time delays tau_n (ns)
    tau_n = getClusterExcessTimeDelays(mu_tau,rho_mn,minVoidInterval);
    
    %% Step 8: Generate temporal cluster powers (mW)
    clusterPowers = getClusterPowers(tau_n,Pr_dBm,Gamma,sigmaCluster,Th);
    
    %% Step 9: Generate the cluster subpath powers (mW)
    subpathPowers = ...
        getSubpathPowers(rho_mn,clusterPowers,gamma,sigmaSubpath,envType,Th);
    
    %% Step 10: Recover absolute propagation times t_mn (ns) of each subpath component
    t_mn = getAbsolutePropTimes(TRDistance,tau_n,rho_mn);
    
    %% Step 11: Recover AODs and AOAs of the multipath components
    [subpath_AODs, cluster_subpath_AODlobe_mappingOld] = ...
        getSubpathAngles(numberOfAODLobes,numberOfClusterSubPaths,mean_ZOD,...
        sigma_ZOD,std_AOD_RMSLobeElevationSpread,std_AOD_RMSLobeAzimuthSpread,...
        distributionType_AOD);
    [subpath_AOAs, cluster_subpath_AOAlobe_mappingOld] = ...
        getSubpathAngles(numberOfAOALobes,numberOfClusterSubPaths,mean_ZOA,...
        sigma_ZOA,std_AOA_RMSLobeElevationSpread,std_AOA_RMSLobeAzimuthSpread,...
        distributionType_AOA);

    %% Step 12: Construct the multipath parameters
    % Delay, Linear Power, Phase, AOD, ZOD, AOA, ZOA
    powerSpectrumOldRaw = getPowerSpectrum(numberOfClusterSubPaths,t_mn,...
        subpathPowers,phases_mn,subpath_AODs,subpath_AOAs,Th);
    % Adjust power spectrum according to RF bandwidth
    [powerSpectrumRaw,numberOfClusterSubPaths,SubpathIndex] = ...
        getNewPowerSpectrum(powerSpectrumOldRaw,RFBW);
    % Change the corresponding time and angle mapping for later lobe
    % spectrum
    cluster_subpath_AODlobe_mapping = cluster_subpath_AODlobe_mappingOld(SubpathIndex-1,:);
    cluster_subpath_AOAlobe_mapping = cluster_subpath_AOAlobe_mappingOld(SubpathIndex-1,:);
    % For LOS environment, adjust subpath AoDs and AoAs such that the AoD
    % and AoA of the LOS component are aligned properly
    powerSpectrumRaw = getLosAligned(envType,powerSpectrumRaw);
    powerSpectrumOldRaw = getLosAligned(envType,powerSpectrumOldRaw);
    %% Compute the Polarization after constructing powerSpectrumOld
    polMod = getPolParameters(Pol,f,envType);
    
    for PolIdx = 1:numPol
    polDcm = polMod{PolIdx,1};
    polStr = polMod{PolIdx,2};
    powerSpectrumOld = powerSpectrumOldRaw;
    powerSpectrum = powerSpectrumRaw;
    powerSpectrumOld(:,2) = powerSpectrumOld(:,2)/db2pow(polDcm);
    powerSpectrum(:,2) = powerSpectrum(:,2)/db2pow(polDcm);

    
    %% Construct the 3-D lobe power spectra at TX and RX
    AOD_LobePowerSpectrum = getLobePowerSpectrum(numberOfAODLobes,...
        cluster_subpath_AODlobe_mapping,powerSpectrum,'AOD');
    AOA_LobePowerSpectrum = getLobePowerSpectrum(numberOfAOALobes,...
        cluster_subpath_AOAlobe_mapping,powerSpectrum,'AOA');
    
    %% Human Blockage
    if strcmp(hbIdc,'On')
        [powerSpectrum,hbLoss] = getHumanBlockageLoss(hbIdc,default,'omni',...
            cluster_subpath_AOAlobe_mapping,cluster_subpath_AODlobe_mapping,...
            powerSpectrum,theta_3dB_RX);
    end
    %% Store CIR parameters
    % Multipath delay
    CIR.pathDelays = powerSpectrum(:,1);
    % Multipath power
    pathPower = powerSpectrum(:,2);
    clear indNaN; indNaN = pathPower<=10^(Th/10);
    pathPower(indNaN,:) = 10^(Th/10);
    CIR.pathPowers = pathPower;
    % Multipath phase
    CIR.pathPhases = powerSpectrum(:,3);
    % Multipath AOD
    CIR.AODs = powerSpectrum(:,4);
    % Multipath ZOD
    CIR.ZODs = powerSpectrum(:,5);
    % Multipath AOA
    CIR.AOAs = powerSpectrum(:,6);
    % Multipath ZOA
    CIR.ZOAs = powerSpectrum(:,7);
    % Various global information for this CIR
    % Carrier frequency
    CIR.frequency = f;
    % Transmit power
    CIR.TXPower = TXPower;
    % Omnidirectional received power in dBm
    CIR.OmniPower = Pr_dBm - polDcm;
    % Omnidirectional path loss in dB
    CIR.OmniPL = PL_dB;
    % T-R separation distance in meters
    CIR.TRSep = TRDistance;
    % Environment, LOS or NLOS
    CIR.environment = envType;
    % Scenario, UMi, UMa, or RMa
    CIR.scenario = sceType;
    % TX HPBW
    CIR.HPBW_TX = [theta_3dB_TX phi_3dB_TX];
    % RX HPBW
    CIR.HPBW_RX = [theta_3dB_RX phi_3dB_RX];
    CIR.polarization = polStr;
    if strcmp(o2iLoss,'Yes')
        CIR.o2iLoss = o2iLossValue;
    end
    if strcmp(hbIdc,'On')
        CIR.HumanBlockageLoss = hbLoss;
    end
    % Store SISO CIR
    CIR_SISO_Struct.(['CIR_SISO_',num2str(CIRIdx)]) = CIR;   
    
    % Calculate and store MIMO CIR 
    [CIR_MIMO,H,HPowers,HPhases,H_ensemble] = getLocalCIR(CIR,...
        TxArrayType,RxArrayType,Nt,Nr,Wt,Wr,dTxAnt,dRxAnt,RFBW);
    CIR_MIMO_Struct.(['CIR_MIMO_',num2str(CIRIdx)]) = CIR_MIMO; 
    H_MIMO = CIR_MIMO.H;
    
    % Show the output figures for the first simulation run
    if CIRIdx == 1 && PolIdx == 1
        FigVisibility = 'on'; 
    else 
        FigVisibility = 'off'; 
    end
%% Plotting    
if plotStatus == true
    AODPower_SphericalSpectrum = getSphericalSpectrum(powerSpectrum,'AOD',Th);
    AOAPower_SphericalSpectrum = getSphericalSpectrum(powerSpectrum,'AOA',Th);
    if plotSpatial == true
        %% Fig1: AOD Spherical Plot
        titleName = ['3-D AOD Power Spectrum - ',num2str(f),' GHz, ',sceType,' ',envType,', ',...
            num2str(TRDistance,'%.1f'),' m T-R Separation'];
        h1 = plotSpherical_Modular(AODPower_SphericalSpectrum,titleName,envType,FigVisibility,Th); 
        
        %% Fig2: AOA Spherical Plot
        titleName = ['3-D AOA Power Spectrum - ',num2str(f),' GHz, ' sceType, ' ' envType, ', ',...
                    num2str(TRDistance,'%.1f'),' m T-R Separation'];
        h2 = plotSpherical_Modular(AOAPower_SphericalSpectrum,titleName,envType,FigVisibility,Th);  
    else
    end
    % Find time and power arrays                
    timeArray = powerSpectrum(:,1); multipathArray = powerSpectrum(:,2); 
    % Calculate the K-factor in dB for either LOS or NLOS
    KFactor = 10*log10(max(multipathArray)/(sum(multipathArray)-max(multipathArray)));

%% Fig3: omnidirectional PDP
if strcmp(o2iLoss,'No')
    o2iType = '';
    o2iLossValue = 0;
end
% PLE
PLE = (PL_dB+polDcm-FSPL)/(10*log10(TRDistance/d0));
h3 = plotPDP(FigVisibility,timeArray,multipathArray,TRDistance,f,sceType,envType,PL_dB,PLE,Th,o2iLoss,o2iType,o2iLossValue);
% Total received power in linear
Pr_Lin = sum(multipathArray);
% Mean time delay
meanTau = sum(timeArray.*multipathArray)/sum(multipathArray);
% Mean squared time delay
meanTau_Sq=sum(timeArray.^2.*multipathArray)/sum(multipathArray);
% RMS delay spread
RMSDelaySpread = sqrt(meanTau_Sq-meanTau^2);
% Create rotational plot
if plotRotate == true
    xlabel('x')
    ylabel('y')
    zlabel('z')
    el = 10;
    aziArray = 0:1:360;
    for index = 1:length(aziArray)
        currentAzi = aziArray(index);
        set(hGca_AOA,'view',[currentAzi el])
        pause(0.01)
    end
else
end

%% Fig4: Directional PDP with the strongest received power
% Find TX-RX combination index with maximum received power
[maxP, maxIndex] = max(powerSpectrum(:,2));

% Desired TX-RX pointing angles
theta_TX_d = powerSpectrum(:,4);
phi_TX_d = powerSpectrum(:,5);
theta_RX_d = powerSpectrum(:,6);
phi_RX_d = powerSpectrum(:,7);

% Number of multiapth components
nPath(CIRIdx) = size(powerSpectrum,1);

% Compute directive gains for each multipath component
PL_dir = zeros(nPath(CIRIdx),1); 

% Directional PLE
PLE_dir = zeros(nPath(CIRIdx),1);

% Directional RMS delay spread
DirRMSDelaySpread = zeros(nPath(CIRIdx),1);
for q = 1:nPath(CIRIdx)
    % See the parameter definitions above
    [TX_Dir_Gain_Mat, RX_Dir_Gain_Mat, G_TX, G_RX] = ...
    getDirectiveGains(theta_3dB_TX,phi_3dB_TX,theta_3dB_RX,phi_3dB_RX,...
    theta_TX_d(q),phi_TX_d(q),theta_RX_d(q),phi_RX_d(q),powerSpectrum);
    [timeArray_Dir, multipathArray_Dir] = getDirPDP(powerSpectrum,...
        TX_Dir_Gain_Mat,RX_Dir_Gain_Mat);
    Pr_Lin_Dir = sum(multipathArray_Dir);
    meanTau = sum(timeArray_Dir.*multipathArray_Dir)/sum(multipathArray_Dir);
    meanTau_Sq=sum(timeArray_Dir.^2.*multipathArray_Dir)/sum(multipathArray_Dir);
    DirRMSDelaySpread(q) = sqrt(meanTau_Sq-meanTau^2);
    % Obtain directional path loss
    PL_dir(q) = TXPower-10*log10(Pr_Lin_Dir)+10*log10(G_TX)+10*log10(G_RX);
    % Obtain directional PLE
    PLE_dir(q) = (PL_dir(q)-FSPL)/(10*log10(TRDistance/d0));
end
Pr_Lin = sum(multipathArray);

% Get directive antenna gains
[TX_Dir_Gain_Mat, RX_Dir_Gain_Mat, G_TX, G_RX] = getDirectiveGains(theta_3dB_TX,...
    phi_3dB_TX,theta_3dB_RX,phi_3dB_RX,theta_TX_d(maxIndex),phi_TX_d(maxIndex),...
    theta_RX_d(maxIndex),phi_RX_d(maxIndex),powerSpectrum);

% Recover the directional PDP
[timeArray_Dir, multipathArray_Dir] = getDirPDP(powerSpectrum,...
    TX_Dir_Gain_Mat,RX_Dir_Gain_Mat);
Pr_Lin_Dir = sum(multipathArray_Dir);
meanTau = sum(timeArray_Dir.*multipathArray_Dir)/sum(multipathArray_Dir);
meanTau_Sq=sum(timeArray_Dir.^2.*multipathArray_Dir)/sum(multipathArray_Dir);

% Dir Human blockage 
if strcmp(hbIdc,'On')
    powerSpectrumDir = horzcat(timeArray_Dir,multipathArray_Dir,powerSpectrum(:,3:7));
    [powerSpectrumDir,hbLossDir] = getHumanBlockageLoss(hbIdc,default,'dir',cluster_subpath_AOAlobe_mapping,...
                                    cluster_subpath_AODlobe_mapping,powerSpectrumDir,theta_3dB_RX);
    timeArray_Dir = powerSpectrumDir(:,1);
    multipathArray_Dir = powerSpectrum(:,2);
end
                    
% Directional PDP
DirPDP = [timeArray_Dir', 10*log10(multipathArray_Dir')];
clear indNaN; indNaN = find(10.*log10(multipathArray_Dir')<=Th);
DirPDP(indNaN,:) = NaN;
h4 = plotDirPDP(FigVisibility,timeArray_Dir,multipathArray_Dir,...
    Th,TRDistance,f,sceType,envType,maxIndex,DirRMSDelaySpread,Pr_Lin_Dir,...
    PL_dir,PLE_dir,theta_3dB_TX,phi_3dB_TX,theta_3dB_RX,phi_3dB_RX,TX_Dir_Gain_Mat,...
    RX_Dir_Gain_Mat,o2iLoss,o2iType,o2iLossValue);

%% Fig5: Small-scale PDPs    
[h5,X,Y,Pr_H] = plotSmallScalePDP(FigVisibility,CIR_MIMO,Nr,Th,TXPower,f,RFBW,...
    sceType,envType,TRDistance);
% Save output figures
saveas(h1,[outputFolder,'AOD_Run',num2str(CIRIdx),'_',polStr,'.png']);
saveas(h2,[outputFolder,'AOA_Run',num2str(CIRIdx),'_',polStr,'.png']); 
saveas(h3,[outputFolder,'OmniPDP_Run',num2str(CIRIdx),'_',polStr,'.png']); 
saveas(h4,[outputFolder,'DirPDP_Run',num2str(CIRIdx),'_',polStr,'.png']);
saveas(h5,[outputFolder,'SmallScalePDP_Run',num2str(CIRIdx),'_',polStr,'.png']);
end

OmniPDP = [timeArray,10.*log10(multipathArray)];
clear indNaN; indNaN = find(10.*log10(multipathArray)<=Th);
OmniPDP(indNaN,:) = NaN;
if CIRIdx > 1
    close(h1); close(h2); close(h3); close(h4); close(h5);
end
%%
if strcmp(fileType,'Text File') == true
SNames = fieldnames(AOD_LobePowerSpectrum); 
for m = 1:numberOfAODLobes
    dlmwrite([outputFolder,'AODLobePowerSpectrum' sprintf('%d',CIRIdx) '_' polStr '_Lobe' sprintf('%d',m) '.txt'],...
        AOD_LobePowerSpectrum.(SNames{m}),'delimiter', '\t', 'newline', 'pc');
end
clear SNames m; SNames = fieldnames(AOA_LobePowerSpectrum); 
for m = 1:numberOfAOALobes
    dlmwrite([outputFolder,'AOALobePowerSpectrum' sprintf('%d',CIRIdx) '_' polStr '_Lobe' sprintf('%d',m) '.txt'],...
        AOA_LobePowerSpectrum.(SNames{m}),'delimiter', '\t', 'newline', 'pc');
end
dlmwrite([outputFolder,'OmniPDP' sprintf('%d',CIRIdx) '_' polStr '.txt'],OmniPDP,'delimiter', '\t', 'newline', 'pc');
dlmwrite([outputFolder,'DirectionalPDP' sprintf('%d',CIRIdx) '_' polStr '.txt'],DirPDP,'delimiter', '\t', 'newline', 'pc');
Tra = reshape(X,[],1); Delay = reshape(Y,[],1); traPr = reshape(Pr_H,[],1);
smallScalePDP = [Tra Delay traPr];
clear indNaN; indNaN = find(traPr<=Th);
smallScalePDP(indNaN,2:3) = NaN;
dlmwrite([outputFolder,'SmallScalePDP' sprintf('%d',CIRIdx) '_' polStr '.txt'],smallScalePDP,'delimiter', '\t', 'newline', 'pc');

elseif strcmp(fileType,'MAT File') == true 
    SNames = fieldnames(AOD_LobePowerSpectrum); 
for m = 1:numberOfAODLobes
    save([outputFolder,'AODLobePowerSpectrum' sprintf('%d',CIRIdx) '_' polStr],'AOD_LobePowerSpectrum');
end
clear SNames m; SNames = fieldnames(AOA_LobePowerSpectrum); 
for m = 1:numberOfAOALobes
    save([outputFolder,'AOALobePowerSpectrum' sprintf('%d',CIRIdx) '_' polStr],'AOA_LobePowerSpectrum');
end
Tra = reshape(X,[],1); Delay = reshape(Y,[],1); traPr = reshape(Pr_H,[],1);
smallScalePDP = [Tra Delay traPr];
clear indNaN; indNaN = find(traPr<=Th);
smallScalePDP(indNaN,2:3) = NaN;
save([outputFolder,'OmniPDP' sprintf('%d',CIRIdx) '_' polStr],'OmniPDP');
save([outputFolder,'DirectionalPDP' sprintf('%d',CIRIdx) '_' polStr],'DirPDP');
save([outputFolder,'SmallScalePDP' sprintf('%d',CIRIdx) '_' polStr],'smallScalePDP');
% ChannelImpulseResponse = powerSpectrum;
% save(['CIR' sprintf('%d',CIRIdx)],'ChannelImpulseResponse');
% % save(['H_ensemble' sprintf('%d',CIRIdx)],'H_ensemble');

elseif strcmp(fileType,'Both Text and MAT File') == true
SNames = fieldnames(AOD_LobePowerSpectrum); 
for m = 1:numberOfAODLobes
    dlmwrite([outputFolder,'AODLobePowerSpectrum' sprintf('%d',CIRIdx) '_' polStr '_Lobe' sprintf('%d',m) '.txt'],...
        AOD_LobePowerSpectrum.(SNames{m}),'delimiter', '\t', 'newline', 'pc');
    save([outputFolder,'AODLobePowerSpectrum' sprintf('%d',CIRIdx) '_' polStr],'AOD_LobePowerSpectrum');
end
clear SNames m; SNames = fieldnames(AOA_LobePowerSpectrum); 
for m = 1:numberOfAOALobes
    dlmwrite([outputFolder,'AOALobePowerSpectrum' sprintf('%d',CIRIdx) '_' polStr '_Lobe' sprintf('%d',m) '.txt'],...
        AOA_LobePowerSpectrum.(SNames{m}),'delimiter', '\t', 'newline', 'pc');
    save([outputFolder,'AOALobePowerSpectrum' sprintf('%d',CIRIdx) '_' polStr],'AOA_LobePowerSpectrum');
end
dlmwrite([outputFolder,'OmniPDP' sprintf('%d',CIRIdx) '_' polStr '.txt'],OmniPDP,'delimiter', '\t', 'newline', 'pc');
dlmwrite([outputFolder,'DirectionalPDP' sprintf('%d',CIRIdx) '_' polStr '.txt'],DirPDP,'delimiter', '\t', 'newline', 'pc');
Tra = reshape(X,[],1); Delay = reshape(Y,[],1); traPr = reshape(Pr_H,[],1);
smallScalePDP = [Tra Delay traPr];
clear indNaN; indNaN = find(traPr<=Th);
smallScalePDP(indNaN,2:3) = NaN;
dlmwrite([outputFolder,'SmallScalePDP' sprintf('%d',CIRIdx) '_' polStr '.txt'],smallScalePDP,'delimiter', '\t', 'newline', 'pc');
save([outputFolder,'OmniPDP' sprintf('%d',CIRIdx) '_' polStr],'OmniPDP');
save([outputFolder,'DirectionalPDP' sprintf('%d',CIRIdx) '_' polStr],'DirPDP');
save([outputFolder,'SmallScalePDP' sprintf('%d',CIRIdx) '_' polStr],'smallScalePDP');
end % end of output file type
% Obtain omnidirectional PDP information for this simulation run
OmniPDPInfo(CIRIdx,1:5,PolIdx) = [TRDistance Pr_dBm-polDcm PL_dB+polDcm RMSDelaySpread,KFactor];
if PL_dB > DR
    OmniPDPInfo(CIRIdx,2:5,PolIdx) = NaN;
end
powerSpectrumDB = powerSpectrum;
powerSpectrumDB(:,2) = 10.*log10(powerSpectrumDB(:,2));
if CIRIdx == 1
DirPDPInfo(1:nPath(CIRIdx),1:11,PolIdx) = [CIRIdx*ones(nPath(CIRIdx),1) TRDistance*ones(nPath(CIRIdx),1) powerSpectrumDB PL_dir DirRMSDelaySpread];
else
    DirPDPInfo(sum(nPath(1:CIRIdx-1))+1:sum(nPath(1:CIRIdx)),1:11,PolIdx) = ...
        [CIRIdx*ones(nPath(CIRIdx),1) TRDistance*ones(nPath(CIRIdx),1) powerSpectrumDB PL_dir DirRMSDelaySpread];
end
PL_dir_best(CIRIdx,PolIdx) = min(PL_dir);
if PL_dir_best(CIRIdx,PolIdx) >= DR
    PL_dir_best(CIRIdx,PolIdx) = 0;
end
    end % end of PolIdx
%% Processing bar update
Count = Count+1; Perc=Count/Length; 
    javaMethodEDT('setValue', jBarHandle, Count);
    pause(0.2);
end% end of CIRIdx

if exist('hhandle','var') == 1
delete(hhandle); 
end
delete(txtPb);

%% Plot Fig 6: omni and dir PL scatter plots
for PolIdxx = 1:numPol
    indOmniPL = find(~isnan(OmniPDPInfo(:,3,PolIdxx)));
    IndDirNaN = find(DirPDPInfo(:,4,PolIdxx)<=Th);
    DirPDPInfo(IndDirNaN,3:11,PolIdxx) = NaN;
    indDirPL = find(~isnan(DirPDPInfo(:,10,PolIdxx)));
    omniDist = OmniPDPInfo(indOmniPL,1,PolIdxx); 
    omniPL = OmniPDPInfo(indOmniPL,3,PolIdxx);
    dirDist = DirPDPInfo(indDirPL,2,PolIdxx);
    dirPL = DirPDPInfo(indDirPL,10,PolIdxx);
    if PolIdxx == 1
        FigVisibility = 'on';
    else
        FigVisibility = 'off';
    end

    h7 = plotPL(FigVisibility,FSPL,omniPL,omniDist,dirPL,dirDist,PL_dir_best(:,PolIdxx),f,sceType,envType,d0,theta_3dB_TX,...
        phi_3dB_TX,TX_Dir_Gain_Mat,theta_3dB_RX,phi_3dB_RX,RX_Dir_Gain_Mat,Th);
    saveas(h7,[outputFolder,'PathLossPlot.png']); 
    if strcmp(fileType,'Text File') == true
        % Save OmniPDPInfo as .txt file
        file_name = ['OmniPDPInfo','_',polMod{PolIdxx,2},'.txt'];
        fid = fopen([outputFolder,file_name],'wt');
        fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t',...
            'T-R Separation Distance (m)','Received Power (dBm)','Path Loss (dB)','RMS Delay Spread (ns)','K-Factor (dB)'); 
        fprintf(fid,'\n%15.1f\t%25.1f\t%15.1f\t%15.1f\t%20.1f',OmniPDPInfo(:,:,PolIdxx).'); 
        fclose(fid);
        % Save DirPDPInfo as .txt file
        file_name = ['DirPDPInfo','_',polMod{PolIdxx,2},'.txt'];
        fid = fopen([outputFolder,file_name],'wt');
        fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t',...
            'Simulation Run Number','T-R Separation Distance (m)','Time Delay (ns)','Received Power (dBm)','Phase (rad)',...
            'Azimuth AoD (degree)','Elevation AoD (degree)','Azimuth AoA (degree)','Elevation AoA (degree)',...
            'Path Loss (dB)','RMS Delay Spread (ns)'); 
        fprintf(fid,'\n%15.1f\t%15.1f\t%20.0f\t%17.1f\t%13.1f\t%15.0f\t%17.1f\t%17.1f\t%17.0f\t%17.1f\t%17.1f',...
            DirPDPInfo(:,:,PolIdxx).'); 
        fclose(fid);

    elseif strcmp(fileType,'MAT File') == true 
        omnipdp_content = OmniPDPInfo(:,:,PolIdxx);
        dirpdp_content = DirPDPInfo(:,:,PolIdxx);
        save([outputFolder,'OmniPDPInfo','_',polMod{PolIdxx,2}],'omnipdp_content'); 
        save([outputFolder,'DirPDPInfo','_',polMod{PolIdxx,2}],'dirpdp_content');

    elseif strcmp(fileType,'Both Text and MAT File') == true
            % Save OmniPDPInfo as .txt file
        file_name = ['OmniPDPInfo','_',polMod{PolIdxx,2},'.txt'];
        fid = fopen([outputFolder,file_name],'wt');
        fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t',...
            'T-R Separation Distance (m)','Received Power (dBm)','Path Loss (dB)','RMS Delay Spread (ns)','K-Factor (dB)'); 
        fprintf(fid,'\n%15.1f\t%25.1f\t%15.1f\t%15.1f\t%20.1f',OmniPDPInfo(:,:,PolIdxx).'); 
        fclose(fid);
        % Save DirPDPInfo as .txt file
        file_name = ['DirPDPInfo','_',polMod{PolIdxx,2},'.txt'];
        fid = fopen([outputFolder,file_name],'wt');
        fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t',...
            'Simulation Run Number','T-R Separation Distance (m)','Time Delay (ns)','Received Power (dBm)','Phase (rad)',...
            'Azimuth AoD (degree)','Elevation AoD (degree)','Azimuth AoA (degree)','Elevation AoA (degree)',...
            'Path Loss (dB)','RMS Delay Spread (ns)'); 
        fprintf(fid,'\n%15.1f\t%15.1f\t%20.0f\t%17.1f\t%13.1f\t%15.0f\t%17.1f\t%17.1f\t%17.0f\t%17.1f\t%17.1f',...
            DirPDPInfo(:,:,PolIdxx).'); 
        fclose(fid);
        omnipdp_content = OmniPDPInfo(:,:,PolIdxx);
        dirpdp_content = DirPDPInfo(:,:,PolIdxx);
        save([outputFolder,'OmniPDPInfo','_',polMod{PolIdxx,2}],'omnipdp_content'); 
        save([outputFolder,'DirPDPInfo','_',polMod{PolIdxx,2}],'dirpdp_content');

    end
end % End of PolIdxx

if strcmp(fileType,'Text File') == true
file_name = ['BasicParameters.txt'];
fid = fopen([outputFolder,file_name],'wt');
if strcmp(sceType,'RMa') == true
fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t',...
    'Frequency (GHz)','Bandwidth (MHz)','TXPower (dBm)',...
    'Environment','Scenario','TXHeight',...
    'Pressure (mBar)','Humidity','Temperature (Celsius)','RainRate (mm/hr)','Polarization','Foliage','DistFol (m)','FoliageAttenuation (dB)',...
    'TxArrayType','RxArrayType','#TXElements','#RXElements','TXAziHPBW','TXElvHPBW','RXAziHPBW','RXElvHPBW'); 
fprintf(fid,'\n%12.1f\t%12.0f\t%12.1f\t%12s\t%13s\t%13.2f\t%13.2f\t%12.0f\t%12.1f\t%12.1f\t%12s\t%12s\t%12.1f\t%12.0f\t%12s\t%12s\t%12.0f\t%12.0f\t%12.0f\t%12.0f\t%12.0f\t%12.0f',...
    f,RFBW,TXPower,envType,sceType,h_BS,p,u,temp,RR,Pol,Fol,dFol,folAtt,...
    TxArrayType,RxArrayType,Nt,Nr,theta_3dB_TX,phi_3dB_TX,theta_3dB_RX,phi_3dB_RX);
else
    fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t',...
    'Frequency (GHz)','Bandwidth (MHz)','TXPower (dBm)',...
    'Environment','Scenario',...
    'Pressure (mBar)','Humidity','Temperature (Celsius)','RainRate (mm/hr)','Polarization','Foliage','DistFol (m)','FoliageAttenuation (dB)',...
    'TxArrayType','RxArrayType','#TXElements','#RXElements','TXAziHPBW','TXElvHPBW','RXAziHPBW','RXElvHPBW'); 
fprintf(fid,'\n%12.1f\t%12.0f\t%12.1f\t%12s\t%13s\t%13.2f\t%12.0f\t%12.1f\t%12.1f\t%12s\t%12s\t%12.1f\t%12.0f\t%12s\t%12s\t%12.0f\t%12.0f\t%12.0f\t%12.0f\t%12.0f\t%12.0f',...
    f,RFBW,TXPower,envType,sceType,p,u,temp,RR,Pol,Fol,dFol,folAtt,...
    TxArrayType,RxArrayType,Nt,Nr,theta_3dB_TX,phi_3dB_TX,theta_3dB_RX,phi_3dB_RX);
end
fclose(fid);
elseif strcmp(fileType,'MAT File') == true 
    BasicParameters = struct;
    BasicParameters.Frequency = f; BasicParameters.Bandwidth = RFBW; BasicParameters.TXPower = TXPower;
    BasicParameters.Environment = envType; BasicParameters.Scenario = sceType;
    if strcmp(sceType,'RMa') == true
    BasicParameters.TXHeight = h_BS;
    end
    BasicParameters.Pressure = p; BasicParameters.Humidity = u;
    BasicParameters.Temperature = temp; BasicParameters.RainRate = RR;
%     BasicParameters.Polarization = Pol; 
    BasicParameters.Foliage = Fol;
    BasicParameters.DistFol = dFol; BasicParameters.FoliageAttenuation = folAtt;
    BasicParameters.TxArrayType = TxArrayType; BasicParameters.RxArrayType = RxArrayType;
    BasicParameters.NumberOfTxAntenna = Nt; BasicParameters.NumberOfRxAntenna = Nr;
    BasicParameters.NumberOfTxAntennaPerRow = Wt; BasicParameters.NumberOfRxAntennaPerRow = Wr;
    BasicParameters.TxAntennaSpacing = dTxAnt; BasicParameters.RxAntennaSpacing = dRxAnt; 
    BasicParameters.TxAzHPBW = theta_3dB_TX; BasicParameters.TxElHPBW = phi_3dB_TX; 
    BasicParameters.RxAzHPBW = theta_3dB_RX; BasicParameters.RxElHPBW = phi_3dB_RX;
save([outputFolder,'BasicParameters.mat'],'BasicParameters');
elseif strcmp(fileType,'Both Text and MAT File') == true
    BasicParameters = struct;
    BasicParameters.Frequency = f; BasicParameters.Bandwidth = RFBW; BasicParameters.TXPower = TXPower;
    BasicParameters.Environment = envType; BasicParameters.Scenario = sceType;
    if strcmp(sceType,'RMa') == true
    BasicParameters.TXHeight = h_BS;
    end
    BasicParameters.Pressure = p; BasicParameters.Humidity = u;
    BasicParameters.Temperature = temp; BasicParameters.RainRate = RR;
%     BasicParameters.Polarization = Pol; 
    BasicParameters.Foliage = Fol;
    BasicParameters.DistFol = dFol; BasicParameters.FoliageAttenuation = folAtt;
    BasicParameters.TxArrayType = TxArrayType; BasicParameters.RxArrayType = RxArrayType;
    BasicParameters.NumberOfTxAntenna = Nt; BasicParameters.NumberOfRxAntenna = Nr;
    BasicParameters.NumberOfTxAntennaPerRow = Wt; BasicParameters.NumberOfRxAntennaPerRow = Wr;
    BasicParameters.TxAntennaSpacing = dTxAnt; BasicParameters.RxAntennaSpacing = dRxAnt; 
    BasicParameters.TxAzHPBW = theta_3dB_TX; BasicParameters.TxElHPBW = phi_3dB_TX; 
    BasicParameters.RxAzHPBW = theta_3dB_RX; BasicParameters.RxElHPBW = phi_3dB_RX;
    save([outputFolder,'BasicParameters.mat'],'BasicParameters');
file_name = ['BasicParameters.txt'];
fid = fopen([outputFolder,file_name],'wt');
if strcmp(sceType,'RMa') == true
fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t',...
    'Frequency (GHz)','Bandwidth (MHz)','TXPower (dBm)',...
    'Environment','Scenario','TXHeight',...
    'Pressure (mBar)','Humidity','Temperature (Celsius)','RainRate (mm/hr)','Polarization','Foliage','DistFol (m)','FoliageAttenuation (dB)',...
    'TxArrayType','RxArrayType','#TXElements','#RXElements','TXAziHPBW','TXElvHPBW','RXAziHPBW','RXElvHPBW'); 
fprintf(fid,'\n%12.1f\t%12.0f\t%12.1f\t%12s\t%13s\t%13.2f\t%13.2f\t%12.0f\t%12.1f\t%12.1f\t%12s\t%12s\t%12.1f\t%12.0f\t%12s\t%12s\t%12.0f\t%12.0f\t%12.0f\t%12.0f\t%12.0f\t%12.0f',...
    f,RFBW,TXPower,envType,sceType,h_BS,p,u,temp,RR,Pol,Fol,dFol,folAtt,...
    TxArrayType,RxArrayType,Nt,Nr,theta_3dB_TX,phi_3dB_TX,theta_3dB_RX,phi_3dB_RX);
else
    fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t',...
    'Frequency (GHz)','Bandwidth (MHz)','TXPower (dBm)',...
    'Environment','Scenario',...
    'Pressure (mBar)','Humidity','Temperature (Celsius)','RainRate (mm/hr)','Polarization','Foliage','DistFol (m)','FoliageAttenuation (dB)',...
    'TxArrayType','RxArrayType','#TXElements','#RXElements','TXAziHPBW','TXElvHPBW','RXAziHPBW','RXElvHPBW'); 
fprintf(fid,'\n%12.1f\t%12.0f\t%12.1f\t%12s\t%13s\t%13.2f\t%12.0f\t%12.1f\t%12.1f\t%12s\t%12s\t%12.1f\t%12.0f\t%12s\t%12s\t%12.0f\t%12.0f\t%12.0f\t%12.0f\t%12.0f\t%12.0f',...
    f,RFBW,TXPower,envType,sceType,p,u,temp,RR,Pol,Fol,dFol,folAtt,...
    TxArrayType,RxArrayType,Nt,Nr,theta_3dB_TX,phi_3dB_TX,theta_3dB_RX,phi_3dB_RX);
end
fclose(fid);
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Alternate End %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%% Reset %%%%%%%%%
function Reset_Callback(~,~) 
set(figGUI, 'HandleVisibility', 'off'); close all; set(figGUI, 'HandleVisibility', 'on'); 
% if exist(txtPb) == 0
% delete(txtPb); 
% end

if exist('hhandle','var') == 1
    delete(hhandle); 
end
% [mtree, container] = uitree('v0', 'Root',outputFolder);
% set(container,'Parent',figGUI,'Position',[1070 205 200 230]);
uiwait(gcf);  

nodes = mtree.getSelectedNodes;
if isempty(nodes)
    return
end

node = nodes(1);
outputFolder = node.getValue;

% f = num2str(f); RFBW = num2str(RFBW);
% dmin = num2str(dmin); dmax = num2str(dmax); TXPower = num2str(TXPower);
% p = num2str(p); u = num2str(u); t = num2str(t); RR = num2str(RR); 
% dFol = num2str(dFol); folAtt = num2str(folAtt);
% Nt = num2str(Nt); Nr = num2str(Nr); Wt = num2str(Wt); Wr = num2str(Wr); 
% dTxAnt = num2str(dTxAnt); dRxAnt = num2str(dRxAnt); N = num2str(N);
% h_BS = num2str(h_BS);h_MS = num2str(h_MS);
% theta_3dB_TX = num2str(theta_3dB_TX); phi_3dB_TX = num2str(phi_3dB_TX);
% theta_3dB_RX = num2str(theta_3dB_RX); phi_3dB_RX = num2str(phi_3dB_RX);
% d_co = num2str(d_co);d_co_los = num2str(d_co_los);
% d_update = num2str(d_update);
% movDistance = num2str(movDistance);velocity = num2str(velocity);
% direction = num2str(direction);side_length = num2str(side_length);

%% Panel 1
function scePopup_Callback(source,~) 
    str = source.String;
    val = source.Value;
    switch str{val}
        case 'UMi' 
            sceType = 'UMi';
        case 'UMa' 
            sceType = 'UMa';
        case 'RMa' 
            sceType = 'RMa';
        case 'InH'
            sceType = 'InH';
    end
    if strcmp(sceType,'InH')
        distPopup.Value = 3;
        distPopup_Callback(distPopup);
        set(distPopup,'enable','off');
        txtFreq.String = 'Frequency (0.5-150 GHz)';
        set(txtRain1,'enable','off');
        set(tEditRain,'enable','off');
        set(txtRain2,'enable','off');
        set(txtFol,'enable','off');
        set(folPopup,'enable','off');
        set(txtDistFol1,'enable','off');
        set(dFolEdit,'enable','off');
        set(txtDistFol2,'enable','off');
        set(txtFolAtt1,'enable','off');
        set(folAttEdit,'enable','off');
        set(txtFolAtt2,'enable','off');
        set(o2iLossPopup,'enable','off');
        set(o2iTypePopup,'enable','off');
        set(txtO2I1,'enable','off');
        set(txtO2I2,'enable','off');
        set(txtO2I3,'enable','off');
        set(bg,'SelectedObject',r2);
        scIdc = 'Off';
        set(r1,'enable','off');
        set(r2,'enable','off');
        set(findall(hPanel3, '-property', 'enable'), 'enable', 'off');
    else
        distPopup.Value = 1;
        distPopup_Callback(distPopup);
        set(distPopup,'enable','on');
        txtFreq.String = 'Frequency (0.5-100 GHz)';
        set(txtRain1,'enable','on');
        set(tEditRain,'enable','on');
        set(txtRain2,'enable','on');
        set(txtFol,'enable','on');
        set(folPopup,'enable','on');
        set(txtDistFol1,'enable','on');
        set(dFolEdit,'enable','on');
        set(txtDistFol2,'enable','on');
        set(txtFolAtt1,'enable','on');
        set(folAttEdit,'enable','on');
        set(txtFolAtt2,'enable','on');
        set(o2iLossPopup,'enable','on');
        set(o2iTypePopup,'enable','on');
        set(txtO2I1,'enable','on');
        set(txtO2I2,'enable','on');
        set(txtO2I3,'enable','on');
        set(bg,'SelectedObject',r1);
        scIdc = 'On';
        set(r1,'enable','on');
        set(r2,'enable','on');
        set(findall(hPanel3, '-property', 'enable'), 'enable', 'on');
    end
end % maybe check all inputs here

function bg_Callback(source,event)
    scIdc = event.NewValue.String;
    if strcmp(scIdc,'On')
        set(o2iLossPopup,'enable','off');
        set(o2iTypePopup,'enable','off');
        set(txtO2I1,'enable','off');
        set(txtO2I2,'enable','off');
        set(txtO2I3,'enable','off');
        set(findall(hPanel3, '-property', 'enable'), 'enable', 'on');
    elseif strcmp(scIdc,'Off')
        set(findall(hPanel3, '-property', 'enable'), 'enable', 'off');
        set(o2iLossPopup,'enable','on');
        set(o2iTypePopup,'enable','on');
        set(txtO2I1,'enable','on');
        set(txtO2I2,'enable','on');
        set(txtO2I3,'enable','on');
    end
end

function fEdit_Callback(source,~) 
    f = source.String;
    f = str2double(f);
    if strcmp(sceType, 'InH')
        if f < 0.5 || f > 150
            h1 = msgbox('Frequency exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.',...
                'Error','error');
            waitfor(h1);
            return;
        end
    else 
        if f < 0.5 || f > 100
            h1 = msgbox('Frequency exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.',...
                'Error','error');
            waitfor(h1);
            return;
        end
    end

end  

function bwEdit_Callback(source,~) 
    RFBW = source.String;
    RFBW = str2double(RFBW);
    if RFBW < 0 || RFBW > 800
        h2 = msgbox('RF Bandwidth exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
        waitfor(h2);
        return;
    end
end

function distPopup_Callback(source,~) 
     str = source.String;
     val = source.Value;
     distType = str{val};
end 

function envPopup_Callback(source,~) 
     str = source.String;
         val = source.Value;
         envType = str{val};
end 

function dminEdit_Callback(source,~) 
    dmin = source.String;
    dmin = str2double(dmin);
    if strcmp(distType,'Standard (10-500 m)')
        if dmin < 10 || dmin > 500
            h3 = msgbox('Lower Bound of T-R Distance exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
            waitfor(h3);
            return;
        end
    elseif strcmp(distType,'Indoor (5-50 m)')
        if dmin < 5 || dmin > 50
            h3 = msgbox('Lower Bound of T-R Distance exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
            waitfor(h3);
            return;
        end
    else
        if dmin < 10 || dmin > 10000
            h3 = msgbox('Lower Bound of T-R Distance exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
            waitfor(h3);
            return;
        end
    end
end 

function dmaxEdit_Callback(source,~) 
     dmax = source.String;
     dmax = str2double(dmax);
     if strcmp(distType,'Standard (10-500 m)')
        if dmax < 10 || dmax > 500
            h4 = msgbox('Upper Bound of T-R Distance exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
            waitfor(h3);
            return;
        end
    elseif strcmp(distType,'Indoor (5-50 m)')
        if dmax < 5 || dmax > 50
            h4 = msgbox('Upper Bound of T-R Distance exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
            waitfor(h3);
            return;
        end
    else
        if dmax < 10 || dmax > 10000
            h4 = msgbox('Upper Bound of T-R Distance exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
            waitfor(h3);
            return;
        end
    end
end 

function PtEdit_Callback(source,~) 
    TXPower = source.String;
    TXPower = str2double(TXPower);
    if TXPower < 0 || TXPower > 50
        h6 = msgbox('TX Power exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
        waitfor(h6);
        return;
    end
end 

function pEdit_Callback(source,~) 
    p = source.String;
    p = str2double(p);
end

function uEdit_Callback(source,~) 
    u = source.String;
    u = str2double(u);
    if u < 0 || u > 100
        h8 = msgbox('Humidity exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
        waitfor(h8);
        return;
    end
end 

function tEdit_Callback(source,~) 
    temp = source.String;
    temp = str2double(temp);
end

function RREdit_Callback(source,~) 
    RR = source.String;
    RR = str2double(RR);
    if RR < 0 || RR > 150
        h9 = msgbox('Rain Rate exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
        waitfor(h9);  
        return;
    end
end

function polPopup_Callback(source,~) 
    str = source.String;
    val = source.Value;
    Pol = str{val};
end

function folPopup_Callback(source,~) 
    str = source.String;
    val = source.Value;
    Fol = str{val};
end

function dFolEdit_Callback(source,~)
    dFol = source.String;
    dFol = str2double(dFol);
end

function folAttEdit_Callback(source,~)
    folAtt = source.String;
    folAtt = str2double(folAtt);
end

function o2iLossPopup_Callback(source,~)
    str = source.String;
    val = source.Value;
    o2iLoss = str{val};
end

function o2iTypePopup_Callback(source,~)
    str = source.String;
    val = source.Value;
    o2iType = str{val};
end

function nRun_Callback(source,~) 
     N = source.String;
     N = str2double(N);
end 

function hBS_Callback(source,~) 
     h_BS = source.String;
     h_BS = str2double(h_BS);
     if strcmp(sceType, 'InH')
        if h_BS < 1 || h_BS > 5
            h7 = msgbox('Base Station Height exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
            waitfor(h7);
            return;
        end
    else 
        if h_BS < 10 || h_BS > 150
            h7 = msgbox('Base Station Height exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
            waitfor(h7);
            return;
        end
     end
end

function hMS_Callback(source,~) 
     h_MS = source.String;
     h_MS = str2double(h_MS);
     if strcmp(sceType, 'InH')
        if h_MS < 0.5 || h_MS > 2
            h21 = msgbox('Mobile Device Height exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
            waitfor(h21);
            return;
        end
    else 
        if h_MS < 1 || h_MS > 5
            h21 = msgbox('Mobile Device Height exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
            waitfor(h21);
            return;
        end
     end
end

%% Panel 2 Callbacks
function TxArrayPopup_Callback(source,~) 
     str = source.String; 
     val = source.Value;
     TxArrayType = str{val};
end 

function RxArrayPopup_Callback(source,~) 
     str = source.String; 
     val = source.Value;
     RxArrayType = str{val};
end 

function nTxAnt_Callback(source,~) 
     Nt = source.String; 
     Nt = str2double(Nt);
end

function nRxAnt_Callback(source,~) 
     Nr = source.String;
     Nr = str2double(Nr);
end

function distTxAnt_Callback(source,~) 
     dTxAnt = source.String;
     dTxAnt = str2double(dTxAnt);
     if dTxAnt < 0.1 || dTxAnt > 100
        h11 = msgbox('TX Antenna Spacing exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
        waitfor(h11);
        return;
    end
end

function distRxAnt_Callback(source,~) 
    dRxAnt = source.String;
    dRxAnt = str2double(dRxAnt);
    if dRxAnt < 0.1 || dRxAnt > 100
        h12 = msgbox('RX Antenna Spacing exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
        waitfor(h12);
        return;
    end
end

function nnTxAnt_Callback(source,~) 
     Wt = source.String;
     Wt = str2double(Wt);
end 

function nnRxAnt_Callback(source,~) 
     Wr = source.String; 
     Wr = str2double(Wr);
end

function TxAziBW_Callback(source,~) 
    theta_3dB_TX = source.String;
    theta_3dB_TX = str2double(theta_3dB_TX);
    if theta_3dB_TX < 7 || theta_3dB_TX > 360
        h17 = msgbox('TX Azimuth HPBW exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
        waitfor(h17);
        return;
    end
end

function TxElvBW_Callback(source,~) 
    phi_3dB_TX = source.String;
    phi_3dB_TX = str2double(phi_3dB_TX);
    if phi_3dB_TX < 7 || phi_3dB_TX > 45
        h18 = msgbox('TX Elevation HPBW exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
        waitfor(h18);
        return;
    end
end

function RxAziBW_Callback(source,~) 
    theta_3dB_RX = source.String;
    theta_3dB_RX = str2double(theta_3dB_RX);
    if theta_3dB_RX < 7 || theta_3dB_RX > 360
        h19 = msgbox('RX Azimuth HPBW exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
        waitfor(h19);
        return;
    end
     if strcmp(default,'Yes')
         SEmean_tmp = 10*log10(9.8+180/theta_3dB_RX);
         set(SEmeanEdit,'String',SEmean_tmp);
         
         lambdaShadEdit_tmp = 0.065*theta_3dB_RX+7.425;
         set(lambdaShadEdit,'String',lambdaShadEdit_tmp);
         
         lambdaRiseEdit_tmp = 0.05*theta_3dB_RX+7.35;
         set(lambdaRiseEdit,'String',lambdaRiseEdit_tmp);
     end
end

function RxElvBW_Callback(source,~) 
    phi_3dB_RX = source.String;
    phi_3dB_RX = str2double(phi_3dB_RX);
    if phi_3dB_RX < 7 || phi_3dB_RX > 45
        h20 = msgbox('RX Elevation HPBW exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
        waitfor(h20);
        return;
    end
end

function oftPopup_Callback(source,~) 
     str = source.String;
     val = source.Value;
     fileType = str{val};
end 

%% Panel 3 Callbacks
function d_coEdit_Callback(source,~)
    d_co = source.String;
    d_co = str2double(d_co);
    if mod(d_co, d_update) ~= 0 
        h31 = msgbox('Please set Correlation distance to multiples of Update distance.', 'Error','error');
        waitfor(h31);
        return;
    end
end

function d_co_losEdit_Callback(source,~)
    d_co_los = source.String;
    d_co_los = str2double(d_co_los);
%     if mod(d_co, 1) ~= 0
%         h32 = msgbox('LOS Correlation distance needs to be integer, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
%         waitfor(h32);
%         return;
%     end
end

function transPopup_Callback(source,~) 
     str = source.String;
     val = source.Value;
     transExist = str{val};
end

function trackTypePopup_Callback(source,~)
     str = source.String;
     val = source.Value;
     trackType = str{val};
end 

function d_updateEdit_Callback(source,~)
    d_update = source.String;
    d_update = str2double(d_update);
    if strcmp(trackType,'Linear')
        if mod(d_co, d_update) ~= 0 || mod(movDistance, d_update) ~= 0 
            h33 = msgbox('Correlation distance and Moving distance should be multiples of Update distance.', 'Error','error');
            waitfor(h33);
            return;
        end
    elseif strcmp(trackType,'Hexagon')
        if mod(d_co, d_update) ~= 0 || mod(movDistance, d_update) ~= 0 || mod(side_length, d_update) ~= 0 
            h33 = msgbox('Correlation distance, Moving distance, and Hexagon side length should be multiples of Update distance.', 'Error','error');
            waitfor(h33);
            return;
        end
    end
end

function movDistanceEdit_Callback(source,~)
    movDistance = source.String;
    movDistance = str2double(movDistance);
    if mod(movDistance,d_update) == 0 
        h34 = msgbox('Please set Moving distance to multiples of Update distance.', 'Error','error');
        waitfor(h34);
        return;
    end
end

function velocityEdit_Callback(source,~)
    velocity = source.String;
    velocity = str2double(velocity);
end

function directionEdit_Callback(source,~)
    direction = source.String;
    direction = str2double(direction);
end

function side_lengthEdit_Callback(source,~)
    side_length = source.String;
    side_length = str2double(side_length);
    if mod(side_length,d_update) == 0 
        h35 = msgbox('Please set Hexagon side length to multiples of Update distance.', 'Error','error');
        waitfor(h35);
        return;
    end
end

function orientPopup_Callback(source,~)
     str = source.String;
     val = source.Value;
     orient = str{val};
end 
    
%% Panel 4 Callbacks
function bg2_Callback(source,event)
    hbIdc = event.NewValue.String;
    if strcmp(hbIdc,'On')
        set(findall(hPanel4, '-property', 'enable'), 'enable', 'on');
    elseif strcmp(hbIdc,'Off')
        set(findall(hPanel4, '-property', 'enable'), 'enable', 'off');
    end
end

function defaultPopup_Callback(source,event)
     str = source.String;
     val = source.Value;
     default = str{val};
     if strcmp(default,'Yes')
         set(SEmeanEdit, 'enable', 'off');
         set(lambdaDecayEdit,'enable', 'off');
         set(lambdaShadEdit,'enable', 'off');
         set(lambdaRiseEdit,'enable', 'off');
         set(lambdaUnshadEdit,'enable', 'off');
     elseif strcmp(default,'No')
         set(findall(hPanel4, '-property', 'enable'), 'enable', 'on');
     end
end 

function SEmeanEdit_Callback(source,~)
    SEmean = source.String;
    SEmean = str2double(SEmean);
end

function lambdaDecayEdit_Callback(source,~)
    lambdaDecay = source.String;
    lambdaDecay = str2double(lambdaDecay);
end

function lambdaShadEdit_Callback(source,~)
    lambdaShad = source.String;
    lambdaShad = str2double(lambdaShad);
end

function lambdaRiseEdit_Callback(source,~)
    lambdaRise = source.String;
    lambdaRise = str2double(lambdaRise);
end

function lambdaUnshadEdit_Callback(source,~)
    lambdaUnshad = source.String;
    lambdaUnshad = str2double(lambdaUnshad);
end

%% Extra checklist
if dmin > dmax 
    h5 = msgbox('Lower Bound of T-R Distance exceeds Upper Bound of T-R Distance, please reset either or both parameters on GUI, or modify the source code to realize your goal.', 'Error','error');
    waitfor(h5);
    return;
end
if h_MS > h_BS
    h22 = msgbox('Mobile Device is Higher than Base Station, please reset either or both parameters on GUI, or modify the source code to realize your goal.', 'Error','error');
    waitfor(h22);
    return;
end
if strcmp(Fol,'Yes') == true
    if dFol > dmin
        h10 = msgbox('Distance Within Foliage > Lower Bound of T-R Distance, please reset either or both parameters on GUI, or modify the source code to realize your goal.', 'Error','error');
        waitfor(h10);
        return;
    end
end
if sign(Nt-Wt) == -1
    h13 = msgbox('Wt > Nt, please reset either or both parameters on GUI, or modify the source code to realize your goal.', 'Error','error');
              waitfor(h13);
            return;
end
if sign(Nr-Wr) == -1
    h14 = msgbox('Wr > Nr, please reset either or both parameters on GUI, or modify the source code to realize your goal.', 'Error','error');
              waitfor(h14);
            return;
end
if mod(Nt,Wt) ~= 0
    h15 = msgbox('Wt does not divide Nt, please reset either or both parameters on GUI, or modify the source code to realize your goal.', 'Error','error');
              waitfor(h15);
            return;
end
if mod(Nr,Wr) ~= 0
    h16 = msgbox('Wr does not divide Nr, please reset either or both parameters on GUI, or modify the source code to realize your goal.', 'Error','error');
              waitfor(h16);
            return;
end

if theta_3dB_TX < 7 || theta_3dB_TX > 360
    h17 = msgbox('TX Azimuth HPBW exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
              waitfor(h17);
            return;
end
if phi_3dB_TX < 7 || phi_3dB_TX > 45
    h18 = msgbox('TX Elevation HPBW exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
              waitfor(h18);
            return;
end
if theta_3dB_RX < 7 || theta_3dB_RX > 360
    h19 = msgbox('RX Azimuth HPBW exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
              waitfor(h19);
            return;
end
if phi_3dB_RX < 7 || phi_3dB_RX > 45
    h20 = msgbox('RX Elevation HPBW exceeds the predefined range, please either reset it on GUI or modify the source code to realize your goal.', 'Error','error');
              waitfor(h20);
            return;
end

Length = N; Count = 0; 
jBarHandle = javax.swing.JProgressBar(0,N);
jBarHandle.setStringPainted(true);
jBarHandle.setIndeterminate(false);
[jhandle, hhandle] = javacomponent(jBarHandle);
set(hhandle, 'parent', figGUI, 'Units', 'norm', 'Position', [0.03 0 .45 .02]);
javaMethodEDT('setValue', jBarHandle, Count);
function run_Callback(source,~) 
txtPb = uicontrol('Style','text','Position',[150 13 180 15],'String','Running, please wait...',...
    'BackgroundColor',bgGUI);
set(txtPb,'Enable','on','ForegroundColor',[1 0 0],'Fontweight','bold');
uiresume(gcbf);
end

%% NYUSIM Main Code Restart
%%%%%%%%%%%%%%%%%%%%%%% Alternate  Start %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(scIdc,'On')
%% Constants
d0 = 1; % Free space reference distance in meters
c = physconst('LightSpeed'); % Speed of light in m/s

%% Preparation
% Structure containing generated CIRs
CIR_SISO_Struct = struct; 
CIR_MIMO_Struct = struct;

SEG_SISO_struct = struct;
SEG_MIMO_struct = struct;

% CIR_SISO_EVO = struct;
CIR_MIMO_EVO = struct;
CIR_SISO_EVO_DIR = struct;

% Set plot status
plotStatus = true; 
% Set plot rotation status
plotRotate = false; 
% Determine if spatial plot is needed 
plotSpatial = true;
FigVisibility = 'on';

% scIdc = 'On';
% hbIdc = 'On';

%% Set user trajectory 
% Update distance (usually set to be 1, 0.1, 0.01 m) represents the
% distance interval of two consecutive channel snapshots
% e.g. the UT moves 10 m, update distance is 1 m, then 10 channel snapshots
% are generated in total. 
% d_update = 1;

% User trajectory type: 'Linear' or 'Hexagon'
% linear type is fully realized; hexagon type is almost fully realized
% except the transitions between channel segments. However, both types of
% track can be used to generate spatially correlated channel snapshots
% along the user movement without considering the transitions between
% channel segments.
% trackType = 'Hexagon'; % Linear or Hexagon

% relative initial position of the UT (unit of meter) 
relPos = [0;0;h_MS]; 

% BS position (always at the origin)
TX_Pos = [0;0;h_BS];

% Moving distance (the length of user trajectory) Please use an integer
% movDistance = 41; % Moving distance, unit of meter

% Moving direction where positive x-axis is 0, and positive y-axis is pi/2.
% direction = 45; % Direction of the track, unit of degree

% Set the moving speed unit of meter per second
% velocity = 1;

% Update time is basically update distance divided by velocity
t_update = d_update/velocity;

% The number of channel snapshots corresponding to the user movement
numberOfSnapshot = round(movDistance/d_update);

% Only for hexagon track
% side_length = 10; % side length of the hexagon track
% orient = 'Clockwise';

%%%%% An example about these distances
% A user moves 30 m. The correlation distance is 10 m, and the update
% distance is 1 m. Then, there are 3 segments (corresponding to 3 
% independent channel generations), and there are 10 snapshots in each
% segment. Thus, there are 30 snapshots in total. If the velocity is 10 m/s
% , the update time is 0.1 s, and the total moving duration is 3 s.

%% Large-scale shadow fading correlated map

% Correlation distance of SF (Please use an integer for the correlation distance, like 10, 15, 20)
% d_co = 10;

% The side length of the simulated area. Since the TX (or BS) is always at
% the origin, then here the maps is from -100 to 100
area = ceil((dmax+movDistance)/100*2)*100*2;

%%%%% A new function of generating spatially correlated value of shadow fading
[sfMap,SF] = getSfMap(area,d_co,sceType,envType);

%% Obtain spatially correlated LOS/NLOS condition

% Usually, correlation distances for UMi, UMa, RMa are 15, 50, 60 m.
% d_co_los = 15;

% Granularity of the map
% d_px = 1;

%%%%% A new function of generating spatially correlated value of LOS/NLOS
losMap = getLosMap(area,d_co_los,h_BS,h_MS,sceType);

%% The number of channel snapshots for each channel segment
co_dps = round(d_co/d_update);
t_dps = co_dps*t_update;

%% Channel Segments
% The moving distance may not be the multiplicity of the correlation
% distance, thus the last segment may not have full length

% Note that the envType (LOS or NLOS), sceType (UMi,UMa,RMa) do not
% change in a segment

% Generate the initial T-R separation distance
dini = getTRSep(dmin,dmax);

% Obtain the number of channel segments
numberOfSegments = ceil(movDistance/d_co);

% Obtain the vector of the lengths of channel segments 
lengthOfSegments = [co_dps*ones(1,numberOfSegments-1), int8(mod(movDistance,d_co)/d_update)];
if lengthOfSegments(end) == 0
    lengthOfSegments(end) = d_co/d_update;
end

% Generate segment-wise environment parameters
% The initial T-R separation distance for each segment (the first segment 
% has been determined.)
segDist = zeros(1,numberOfSegments); segDist(1,1) = dini;

% The environment type and scenario type of each segment (the first segment
% has been determined.)
segEnvType = cell(1,numberOfSegments); segEnvType{1,1} = envType;

% The shadow fading 
segSF = zeros(1,numberOfSegments);

% The number of time clusters in each segment (independent among segments)
nTC = zeros(1,numberOfSegments); % # of time clusters in each segment

% For loop for segments
% In each loop, an anchor channel snapshot (large-scale and small-scale 
% parameters) is first generated, then, the spatial consistency procedure
% is used to update the small-scale parameters (delays, angles, powers) of
% the rest snapshots in this segment
for segIdx = 1:numberOfSegments
    %% load channel parameters
    if strcmp(sceType,'UMi') == true && strcmp(envType,'LOS') == true 
    n = 2; SF = 4.0; mu_AOD = 1.9; mu_AOA = 1.8;X_max = 0.2;mu_tau = 123; 
    minVoidInterval = 25;sigmaCluster = 1;Gamma = 25.9; sigmaSubpath = 6; 
    gamma = 16.9; mean_ZOD = -12.6;sigma_ZOD = 5.9; std_AOD_RMSLobeAzimuthSpread = 8.5;
    std_AOD_RMSLobeElevationSpread = 2.5;distributionType_AOD = 'Gaussian'; 
    mean_ZOA = 10.8; sigma_ZOA = 5.3;std_AOA_RMSLobeAzimuthSpread = 10.5;
    std_AOA_RMSLobeElevationSpread = 11.5;distributionType_AOA = 'Laplacian';   
    % UMi NLOS
    elseif strcmp(sceType,'UMi') == true && strcmp(envType,'NLOS') == true
    n = 3.2; SF = 7.0; mu_AOD = 1.5; mu_AOA = 2.1; X_max = 0.5; mu_tau = 83;
    minVoidInterval = 25; sigmaCluster = 3; Gamma = 51.0; sigmaSubpath = 6;
    gamma = 15.5; mean_ZOD = -4.9; sigma_ZOD = 4.5; std_AOD_RMSLobeAzimuthSpread = 11.0;
    std_AOD_RMSLobeElevationSpread = 3.0; distributionType_AOD = 'Gaussian'; 
    mean_ZOA = 3.6; sigma_ZOA = 4.8; std_AOA_RMSLobeAzimuthSpread = 7.5;
    std_AOA_RMSLobeElevationSpread = 6.0; distributionType_AOA = 'Laplacian';
    % UMa LOS
    elseif strcmp(sceType,'UMa') == true && strcmp(envType,'LOS') == true 
    n = 2; SF = 4.0; mu_AOD = 1.9; mu_AOA = 1.8;X_max = 0.2; mu_tau = 123; 
    minVoidInterval = 25; sigmaCluster = 1;Gamma = 25.9; sigmaSubpath = 6; 
    gamma = 16.9; mean_ZOD = -12.6;sigma_ZOD = 5.9; std_AOD_RMSLobeAzimuthSpread = 8.5;
    std_AOD_RMSLobeElevationSpread = 2.5;distributionType_AOD = 'Gaussian'; 
    mean_ZOA = 10.8; sigma_ZOA = 5.3;std_AOA_RMSLobeAzimuthSpread = 10.5;
    std_AOA_RMSLobeElevationSpread = 11.5;distributionType_AOA = 'Laplacian'; 
    % UMa NLOS
    elseif strcmp(sceType,'UMa') == true && strcmp(envType,'NLOS') == true 
    n = 2.9; SF = 7.0; mu_AOD = 1.5; mu_AOA = 2.1; X_max = 0.5; mu_tau = 83;
    minVoidInterval = 25; sigmaCluster = 3; Gamma = 51.0; sigmaSubpath = 6;
    gamma = 15.5; mean_ZOD = -4.9; sigma_ZOD = 4.5; std_AOD_RMSLobeAzimuthSpread = 11.0;
    std_AOD_RMSLobeElevationSpread = 3.0; distributionType_AOD = 'Gaussian'; 
    mean_ZOA = 3.6; sigma_ZOA = 4.8; std_AOA_RMSLobeAzimuthSpread = 7.5;
    std_AOA_RMSLobeElevationSpread = 6.0; distributionType_AOA = 'Laplacian';
    % RMa LOS
    elseif strcmp(sceType,'RMa') == true && strcmp(envType,'LOS') == true
    SF = 1.7; mu_AOD = 1; mu_AOA = 1;X_max = 0.2; mu_tau = 123; 
    minVoidInterval = 25; sigmaCluster = 1;Gamma = 25.9; sigmaSubpath = 6; 
    gamma = 16.9; mean_ZOD = -12.6;sigma_ZOD = 5.9; std_AOD_RMSLobeAzimuthSpread = 8.5;
    std_AOD_RMSLobeElevationSpread = 2.5;distributionType_AOD = 'Gaussian'; 
    mean_ZOA = 10.8; sigma_ZOA = 5.3;std_AOA_RMSLobeAzimuthSpread = 10.5;
    std_AOA_RMSLobeElevationSpread = 11.5;distributionType_AOA = 'Laplacian';
    % RMa NLOS
    elseif strcmp(sceType,'RMa') == true && strcmp(envType,'NLOS') == true
    SF = 6.7; mu_AOD = 1; mu_AOA = 1; X_max = 0.5; mu_tau = 83;
    minVoidInterval = 25; sigmaCluster = 3; Gamma = 51.0; sigmaSubpath = 6;
    gamma = 15.5; mean_ZOD = -4.9; sigma_ZOD = 4.5; std_AOD_RMSLobeAzimuthSpread = 11.0;
    std_AOD_RMSLobeElevationSpread = 3.0; distributionType_AOD = 'Gaussian'; 
    mean_ZOA = 3.6; sigma_ZOA = 4.8; std_AOA_RMSLobeAzimuthSpread = 7.5;
    std_AOA_RMSLobeElevationSpread = 6.0; distributionType_AOA = 'Laplacian';
    end

    % Generate # of TCs,SPs,SLs
    [numberOfTimeClusters,numberOfAOALobes,numberOfAODLobes] = ...
                             getNumClusters_AOA_AOD(mu_AOA,mu_AOD,sceType);
    nTC(segIdx) = numberOfTimeClusters;
    numberOfClusterSubPaths = ...
                  getNumberOfClusterSubPaths(numberOfTimeClusters,sceType);
    nSP = numberOfClusterSubPaths;
    
    % Generate delay info
    rho_mn = getIntraClusterDelays(numberOfClusterSubPaths,X_max,sceType);
    phases_mn = getSubpathPhases(rho_mn);
    tau_n = getClusterExcessTimeDelays(mu_tau,rho_mn,minVoidInterval);
    
    % Gnerate angle info 
    % Angles between [0 360]
    [subpath_AODs, cluster_subpath_AODlobe_mapping] = ...
        getSubpathAngles(numberOfAODLobes,numberOfClusterSubPaths,mean_ZOD,...
        sigma_ZOD,std_AOD_RMSLobeElevationSpread,std_AOD_RMSLobeAzimuthSpread,...
        distributionType_AOD);
    [subpath_AOAs, cluster_subpath_AOAlobe_mapping] = ...
        getSubpathAngles(numberOfAOALobes,numberOfClusterSubPaths,mean_ZOA,...
        sigma_ZOA,std_AOA_RMSLobeElevationSpread,std_AOA_RMSLobeAzimuthSpread,...
        distributionType_AOA);
    % If it is the first channel segment running, the initial location of
    % the UT needs to be found first. 
    if segIdx == 1
        initPos = getInitPos(subpath_AODs,subpath_AOAs,segDist(segIdx),segEnvType{segIdx}, h_MS);
        % side length and orientation will not be used if the track type is
        % linear. 

        if strcmp(orient, 'Clockwise') % orientation of the hexagon track, '0'-counter;'1'-clock
            orientInd = 1;
        elseif strcmp(orient,'Counter')
            orientInd = 0;
        end
        
        [track, v_dir] = getUserTrack(trackType,initPos,movDistance,d_update,direction,side_length,orientInd);
        ss = 1+((1:numberOfSegments)-1)*co_dps;
        segInitPos = track(:,ss); 
        segDist = sqrt(sum((segInitPos-TX_Pos).^2,1));
        if sum(segDist>500) == 0
            DR = 190;
        else
            DR = 220;
        end
        Th = TXPower - DR;
        
        % Obtain LOS/NLOS condition
        for oo = 2:numberOfSegments
           losCon = losMap(round(area/2+segInitPos(2,oo)),round(area/2+segInitPos(1,oo)));
           if losCon == 1
               ttemp = 'NLOS';
           elseif losCon == 0
               ttemp = 'LOS';
           end
           segEnvType{1,oo} = ttemp; 
        end
    end
    % Obtain shadow fading from the map
    segSF(segIdx) = sfMap(round(area/2+segInitPos(2,segIdx)),round(area/2+segInitPos(1,segIdx)));
    
    % Generate total received power
    [PL_dB, Pr_dBm, FSPL, PLE] = getPowerInfo(sceType,envType,f,n,segSF(segIdx),TXPower,...
                                    segDist(segIdx),d0,p,c,u,temp,RR,Pol,Fol,h_BS,folAtt,dFol); 
                                
    % Generate SP powers based on the total received power
    clusterPowers = getClusterPowers(tau_n,Pr_dBm,Gamma,sigmaCluster,Th);
    subpathPowers = ...
      getSubpathPowers(rho_mn,clusterPowers,gamma,sigmaSubpath,segEnvType(segIdx),Th);
    
    % Recover absolute timing
    t_mn = getAbsolutePropTimes(segDist(segIdx),tau_n,rho_mn);
    
    % Collect all channel information into powerSpectrum 
    % Angles between [0 360]
    powerSpectrumOld = getPowerSpectrum(numberOfClusterSubPaths,t_mn,...
                     subpathPowers,phases_mn,subpath_AODs,subpath_AOAs,Th);
    [powerSpectrum,numberOfClusterSubPaths, SubpathIndex] = ...
                                getNewPowerSpectrum(powerSpectrumOld,RFBW);
    % LOS alignment                        
    powerSpectrum = getLosAligned(envType,powerSpectrum);
    powerSpectrumOld = getLosAligned(envType,powerSpectrumOld);      
    
    % Generate a struct foe each independently generated channel segment
    CIR.pathDelays = powerSpectrumOld(:,1);
    pathPower = powerSpectrumOld(:,2);
    clear indNaN; indNaN = find(pathPower<=10^(Th/10));
    pathPower(indNaN,:) = 10^(Th/10);
    CIR.pathPowers = pathPower;
    CIR.pathPhases = powerSpectrumOld(:,3);
    CIR.AODs = powerSpectrumOld(:,4);
    CIR.ZODs = powerSpectrumOld(:,5);
    CIR.AOAs = powerSpectrumOld(:,6);
    CIR.ZOAs = powerSpectrumOld(:,7);
    CIR.frequency = f;
    CIR.TXPower = TXPower;
    CIR.OmniPower = Pr_dBm;
    CIR.OmniPL = PL_dB;
    CIR.TRSep = segDist(segIdx);
    CIR.environment = envType;
    CIR.scenario = sceType;
    CIR.HPBW_TX = [theta_3dB_TX phi_3dB_TX];
    CIR.HPBW_RX = [theta_3dB_RX phi_3dB_RX];  
    CIR.numSP = nSP;
    % SISO CIR is stored
    CIR_SISO_Struct.(['CIR_SISO_',num2str(segIdx)]) = CIR;

    [CIR_MIMO,H,HPowers,HPhases,H_ensemble] = getLocalCIR(CIR,...
        TxArrayType,RxArrayType,Nt,Nr,Wt,Wr,dTxAnt,dRxAnt,RFBW);
    % MIMO CIR is stored
    CIR_MIMO_Struct.(['CIR_MIMO_',num2str(segIdx)]) = CIR_MIMO; 
      
    %% Time evolution
    % In a segment, the channel small-scale information will be updated for
    % each snapshot (or say for each step)
    
    % Here powerSpectrumOld for 800 MHz band width is used to ensure that the
    % number of multipath components in spatial and temporal domain are identical. 
    sc_powerSpectrum = powerSpectrumOld; 
    segTrack = track(:,(segIdx-1)*co_dps+1:(segIdx-1)*co_dps+lengthOfSegments(segIdx));
    segV = v_dir(:,(segIdx-1)*co_dps+1:(segIdx-1)*co_dps+lengthOfSegments(segIdx));
    
    no_snap = lengthOfSegments(segIdx);
    v = [cos(segV);sin(segV);zeros(1,no_snap)];
    r = zeros(3,no_snap);
    RX_Pos = segInitPos(:,segIdx);
    r(:,1) = RX_Pos - TX_Pos;
    
    % Here a geometry-based approach using multiple refleciton surfaces is
    % applied here to update angular information.
    if (strcmp(segEnvType(segIdx),'LOS'))
        no_mpc = size(sc_powerSpectrum,1)-1;
        
        % Initialize LOS and NLOS info in local coordinate system 
        sc_AOA_los = zeros(1,no_snap);sc_AOA_los(1,1) = sc_powerSpectrum(1,6);
        sc_AOD_los = zeros(1,no_snap);sc_AOD_los(1,1) = sc_powerSpectrum(1,4);
        sc_ZOA_los = zeros(1,no_snap);sc_ZOA_los(1,1) = sc_powerSpectrum(1,7);
        sc_ZOD_los = zeros(1,no_snap);sc_ZOD_los(1,1) = sc_powerSpectrum(1,5);
        sc_delay_los = zeros(1,no_snap);sc_delay_los(1,1) = sc_powerSpectrum(1,1);

        sc_AOA_nlos = zeros(no_mpc,no_snap);sc_AOA_nlos(:,1) = sc_powerSpectrum(2:end,6);
        sc_AOD_nlos = zeros(no_mpc,no_snap);sc_AOD_nlos(:,1) = sc_powerSpectrum(2:end,4);
        sc_ZOA_nlos = zeros(no_mpc,no_snap);sc_ZOA_nlos(:,1) = sc_powerSpectrum(2:end,7);
        sc_ZOD_nlos = zeros(no_mpc,no_snap);sc_ZOD_nlos(:,1) = sc_powerSpectrum(2:end,5);
        sc_delay_nlos = zeros(no_mpc,no_snap);sc_delay_nlos(:,1) = sc_powerSpectrum(2:end,1);
        
        % power is updated los and nlos together
        sc_power = zeros(no_mpc+1,no_snap);sc_power(:,1) = sc_powerSpectrum(:,2);
        sc_phase = zeros(no_mpc+1,no_snap);sc_phase(:,1) = sc_powerSpectrum(:,3);
        sc_delay = zeros(no_mpc+1,no_snap);sc_delay(:,1) = sc_powerSpectrum(:,1);
        % Initialize LOS and NLOS info in GCS
        % Convert angles into GCS
        gcs_AOD_los = zeros(1,no_snap); gcs_AOD_los(1,1) = mod(pi/2 - deg2rad(sc_AOD_los(1,1)),2*pi);
        gcs_ZOD_los = zeros(1,no_snap); gcs_ZOD_los(1,1) = pi/2 - deg2rad(sc_ZOD_los(1,1));
        gcs_AOA_los = zeros(1,no_snap); gcs_AOA_los(1,1) = mod(pi/2 - deg2rad(sc_AOA_los(1,1)),2*pi);
        gcs_ZOA_los = zeros(1,no_snap); gcs_ZOA_los(1,1) = pi/2 - deg2rad(sc_ZOA_los(1,1));

        gcs_AOD_nlos = zeros(no_mpc,no_snap); gcs_AOD_nlos(:,1) = mod(pi/2 - deg2rad(sc_AOD_nlos(:,1)),2*pi);
        gcs_ZOD_nlos = zeros(no_mpc,no_snap); gcs_ZOD_nlos(:,1) = pi/2 - deg2rad(sc_ZOD_nlos(:,1));
        gcs_AOA_nlos = zeros(no_mpc,no_snap); gcs_AOA_nlos(:,1) = mod(pi/2 - deg2rad(sc_AOA_nlos(:,1)),2*pi);
        gcs_ZOA_nlos = zeros(no_mpc,no_snap); gcs_ZOA_nlos(:,1) = pi/2 - deg2rad(sc_ZOA_nlos(:,1));
 
        xBern = randi(2,no_mpc,1);
        for t = 2:no_snap
            
            % Update LOS component
            r(:,t) = r(:,t-1) + v(:,t-1)*t_update;
            sc_delay_los(1,t) = norm(r(:,t))/c*1e9;
            
            % delta is the difference term between two snapshots 
            deltaAOD_los = v(:,t-1)'*[-sin(gcs_AOD_los(1,t-1));cos(gcs_AOD_los(1,t-1));0]*t_update;
            gcs_AOD_los(1,t) = gcs_AOD_los(1,t-1) + deltaAOD_los/(c*sc_delay_los(1,t-1)*1e-9*sin(gcs_ZOD_los(1,t-1)));

            deltaZOD_los = v(:,t-1)'*[cos(gcs_ZOD_los(1,t-1))*cos(gcs_AOD_los(1,t-1));cos(gcs_ZOD_los(1,t-1))*sin(gcs_AOD_los(1,t-1));-sin(gcs_ZOD_los(1,t-1))]*t_update;
            gcs_ZOD_los(1,t) = gcs_ZOD_los(1,t-1) + deltaZOD_los/(c*sc_delay_los(1,t-1)*1e-9);

            deltaAOA_los = v(:,t-1)'*[-sin(gcs_AOA_los(1,t-1));cos(gcs_AOA_los(1,t-1));0]*t_update;
            gcs_AOA_los(1,t) = gcs_AOA_los(1,t-1) - deltaAOA_los/(c*sc_delay_los(1,t-1)*1e-9*sin(gcs_ZOA_los(1,t-1)));

            deltaZOA_los = v(:,t-1)'*[cos(gcs_ZOA_los(1,t-1))*cos(gcs_AOA_los(1,t-1));cos(gcs_ZOA_los(1,t-1))*sin(gcs_AOA_los(1,t-1));-sin(gcs_ZOA_los(1,t-1))]*t_update;
            gcs_ZOA_los(1,t) = gcs_ZOA_los(1,t-1) + deltaZOA_los/(c*sc_delay_los(1,t-1)*1e-9);
            
            % Update delay
            azi = gcs_AOA_nlos(:,t-1);
            ele = gcs_ZOA_nlos(:,t-1);
            r_hat = [cos(ele).*sin(azi), cos(ele).*cos(azi), sin(ele)];
            deltaDist = r_hat*v(:,t-1)*t_update;
            sc_delay_nlos(:,t) = sc_delay_nlos(:,t-1)-deltaDist/c*1e9;            
            [sc_tau_n,sc_rho_mn] = getDelayInfo([sc_delay_los(t);sc_delay_nlos(:,t)],nSP);
            
            % Update power
            sfc = sfMap(round(area/2+track(1,t+(segIdx-1)*co_dps)),round(area/2+track(2,t+(segIdx-1)*co_dps)));
            dc = sqrt(sum(track(:,t+(segIdx-1)*co_dps).^2));
            [~, Prc,~,~] = getPowerInfo(sceType,envType,f,n,sfc,TXPower,...
                                    dc,d0,p,c,u,temp,RR,Pol,Fol,h_BS,folAtt,dFol);
            sc_power_cluster = getClusterPowers(sc_tau_n,Prc,Gamma,sigmaCluster,Th);
            power_temp = getSubpathPowers(sc_rho_mn,sc_power_cluster,gamma,sigmaSubpath,segEnvType(segIdx),Th);
            sc_power(:,t) = structToList(power_temp,nSP);
            
            % Update phase
            sc_delay(:,t) = [sc_delay_los(1,t);sc_delay_nlos(:,t)];
            dt_delay = sc_delay(:,t)-sc_delay(:,t-1);
            sc_phase(:,t) = mod(sc_phase(:,t-1) + dt_delay*2*pi*f*1e-3, 2*pi);
            
            % Update NLOS components one by one
            for i_path = 1:no_mpc
            
                tempBern = xBern(i_path);
                deltaRS = gcs_AOA_nlos(i_path,t-1)+(-1)^tempBern*gcs_AOD_nlos(i_path,t-1)+tempBern*pi;
                v_RS = mod(deltaRS+(-1)^tempBern*v(1:2,t-1),2*pi);
                v_RS = [v_RS;0];
                
                deltaAOD = v_RS'*[-sin(gcs_AOD_nlos(i_path,t-1));cos(gcs_AOD_nlos(i_path,t-1));0]*t_update;
                gcs_AOD_nlos(i_path,t) = gcs_AOD_nlos(i_path,t-1) + deltaAOD/(c*sc_delay_nlos(i_path,t-1)*1e-9*sin(gcs_ZOD_nlos(i_path,t-1)));

                deltaZOD = v_RS'*[cos(gcs_ZOD_nlos(i_path,t-1))*cos(gcs_AOD_nlos(i_path,t-1));cos(gcs_ZOD_nlos(i_path,t-1))*sin(gcs_AOD_nlos(i_path,t-1));-sin(gcs_ZOD_nlos(i_path,t-1))]*t_update;
                gcs_ZOD_nlos(i_path,t) = gcs_ZOD_nlos(i_path,t-1) + deltaZOD/(c*sc_delay_nlos(i_path,t-1)*1e-9);

                deltaAOA = v_RS'*[-sin(gcs_AOA_nlos(i_path,t-1));cos(gcs_AOA_nlos(i_path,t-1));0]*t_update;
                gcs_AOA_nlos(i_path,t) = gcs_AOA_nlos(i_path,t-1) - deltaAOA/(c*sc_delay_nlos(i_path,t-1)*1e-9*sin(gcs_ZOA_nlos(i_path,t-1)));

                deltaZOA = v_RS'*[cos(gcs_ZOA_nlos(i_path,t-1))*cos(gcs_AOA_nlos(i_path,t-1));cos(gcs_ZOA_nlos(i_path,t-1))*sin(gcs_AOA_nlos(i_path,t-1));-sin(gcs_ZOA_nlos(i_path,t-1))]*t_update;
                gcs_ZOA_nlos(i_path,t) = gcs_ZOA_nlos(i_path,t-1) + deltaZOA/(c*sc_delay_nlos(i_path,t-1)*1e-9);
                
            end
           
        end
        
        % Change angles back to local coordinate system
        sc_AOD_los = mod(rad2deg(pi/2 - gcs_AOD_los),360);sc_AOD_nlos = mod(rad2deg(pi/2 - gcs_AOD_nlos),360);
        sc_ZOD_los = rad2deg(pi/2 - gcs_ZOD_los);sc_ZOD_nlos = rad2deg(pi/2 - gcs_ZOD_nlos);
        sc_AOA_los = mod(rad2deg(pi/2 - gcs_AOA_los),360);sc_AOA_nlos = mod(rad2deg(pi/2 - gcs_AOA_nlos),360);
        sc_ZOA_los = rad2deg(pi/2 - gcs_ZOA_los);sc_ZOA_nlos = rad2deg(pi/2 - gcs_ZOA_nlos);
        
        % Save updated info of all snapshots
        evoCIR.pathDelays = [sc_delay_los;sc_delay_nlos];
        sc_pathPower = sc_power;
        % Deal with low powers
        for tt = 1:no_snap
            clear indNaN; 
            indNaN = find(sc_pathPower(:,tt)<=10^(Th/10));
            sc_pathPower(indNaN,tt) = 10^(Th/10);
        end
        evoCIR.pathPowers = sc_pathPower;
        evoCIR.pathPhases = sc_phase;
        evoCIR.AODs = [sc_AOD_los;sc_AOD_nlos];
        evoCIR.ZODs = [sc_ZOD_los;sc_ZOD_nlos];
        evoCIR.AOAs = [sc_AOA_los;sc_AOA_nlos];
        evoCIR.ZOAs = [sc_ZOA_los;sc_ZOA_nlos];
        evoCIR.no_snap = no_snap;
        evoCIR.AOA_AOD_mapping = [cluster_subpath_AODlobe_mapping cluster_subpath_AOAlobe_mapping(:,3)];
        CIR_SISO_Struct.(['CIR_SISO_',num2str(segIdx)]).('Evolution') = evoCIR;
        
        
    elseif (strcmp(segEnvType(segIdx),'NLOS'))
        no_mpc = size(sc_powerSpectrum,1);
        sc_AOA_nlos = zeros(no_mpc,no_snap);sc_AOA_nlos(:,1) = sc_powerSpectrum(:,6);
        sc_AOD_nlos = zeros(no_mpc,no_snap);sc_AOD_nlos(:,1) = sc_powerSpectrum(:,4);
        sc_ZOA_nlos = zeros(no_mpc,no_snap);sc_ZOA_nlos(:,1) = sc_powerSpectrum(:,7);
        sc_ZOD_nlos = zeros(no_mpc,no_snap);sc_ZOD_nlos(:,1) = sc_powerSpectrum(:,5);
        sc_delay_nlos = zeros(no_mpc,no_snap);sc_delay_nlos(:,1) = sc_powerSpectrum(:,1);
        sc_power = zeros(no_mpc,no_snap);sc_power(:,1) = sc_powerSpectrum(:,2);  
        sc_phase = zeros(no_mpc,no_snap);sc_phase(:,1) = sc_powerSpectrum(:,3);
        
        gcs_AOD_nlos = zeros(no_mpc,no_snap); gcs_AOD_nlos(:,1) = mod(pi/2 - deg2rad(sc_AOD_nlos(:,1)),2*pi);
        gcs_ZOD_nlos = zeros(no_mpc,no_snap); gcs_ZOD_nlos(:,1) = pi/2 - deg2rad(sc_ZOD_nlos(:,1));
        gcs_AOA_nlos = zeros(no_mpc,no_snap); gcs_AOA_nlos(:,1) = mod(pi/2 - deg2rad(sc_AOA_nlos(:,1)),2*pi);
        gcs_ZOA_nlos = zeros(no_mpc,no_snap); gcs_ZOA_nlos(:,1) = pi/2 - deg2rad(sc_ZOA_nlos(:,1));
        
        xBern = randi(2,no_mpc,1);
        
        for t = 2:no_snap

            % Update delay
            azi = gcs_AOA_nlos(:,t-1);
            ele = gcs_ZOA_nlos(:,t-1);
            r_hat = [cos(ele).*sin(azi), cos(ele).*cos(azi), sin(ele)];
            deltaDist = r_hat*v(:,t-1)*t_update;
            sc_delay_nlos(:,t) = sc_delay_nlos(:,t-1)-deltaDist/c*1e9;            
%             [sc_tau_n,sc_rho_mn] = getDelayInfo([sc_delay_los(t);sc_delay_nlos(:,t)],nSP);
            [sc_tau_n,sc_rho_mn] = getDelayInfo(sc_delay_nlos(:,t),nSP);


            % Update power
            sfc = sfMap(round(area/2+track(1,t+(segIdx-1)*co_dps)),round(area/2+track(2,t+(segIdx-1)*co_dps)));
            dc = sqrt(sum(track(:,t+(segIdx-1)*co_dps).^2));
            [~, Prc,~,~] = getPowerInfo(sceType,envType,f,n,sfc,TXPower,...
                                    dc,d0,p,c,u,temp,RR,Pol,Fol,h_BS,folAtt,dFol);
            sc_power_cluster = getClusterPowers(sc_tau_n,Pr_dBm,Gamma,sigmaCluster,Th);
            power_temp = getSubpathPowers(sc_rho_mn,sc_power_cluster,gamma,sigmaSubpath,segEnvType(segIdx),Th);
            sc_power(:,t) = structToList(power_temp,nSP);
            
            % Update phase
            dt_delay = sc_delay_nlos(:,t)-sc_delay_nlos(:,t-1);
            sc_phase(:,t) = mod(sc_phase(:,t-1) + dt_delay*2*pi*f*1e-3, 2*pi);
            
            % Update angles (NLOS components)
            for i_path = 1:no_mpc

                tempBern = xBern(i_path);
                deltaRS = gcs_AOA_nlos(i_path,t-1)+(-1)^tempBern*gcs_AOD_nlos(i_path,t-1)+tempBern*pi;
                v_RS = mod(deltaRS+(-1)^tempBern*v(1:2,t-1),2*pi);
                v_RS = [v_RS;0];
                
                deltaAOD = v_RS'*[-sin(gcs_AOD_nlos(i_path,t-1));cos(gcs_AOD_nlos(i_path,t-1));0]*t_update;
                gcs_AOD_nlos(i_path,t) = gcs_AOD_nlos(i_path,t-1) + deltaAOD/(c*sc_delay_nlos(i_path,t-1)*1e-9*sin(gcs_ZOD_nlos(i_path,t-1)));

                deltaZOD = v_RS'*[cos(gcs_ZOD_nlos(i_path,t-1))*cos(gcs_AOD_nlos(i_path,t-1));cos(gcs_ZOD_nlos(i_path,t-1))*sin(gcs_AOD_nlos(i_path,t-1));-sin(gcs_ZOD_nlos(i_path,t-1))]*t_update;
                gcs_ZOD_nlos(i_path,t) = gcs_ZOD_nlos(i_path,t-1) + deltaZOD/(c*sc_delay_nlos(i_path,t-1)*1e-9);

                deltaAOA = v_RS'*[-sin(gcs_AOA_nlos(i_path,t-1));cos(gcs_AOA_nlos(i_path,t-1));0]*t_update;
                gcs_AOA_nlos(i_path,t) = gcs_AOA_nlos(i_path,t-1) - deltaAOA/(c*sc_delay_nlos(i_path,t-1)*1e-9*sin(gcs_ZOA_nlos(i_path,t-1)));

                deltaZOA = v_RS'*[cos(gcs_ZOA_nlos(i_path,t-1))*cos(gcs_AOA_nlos(i_path,t-1));cos(gcs_ZOA_nlos(i_path,t-1))*sin(gcs_AOA_nlos(i_path,t-1));-sin(gcs_ZOA_nlos(i_path,t-1))]*t_update;
                gcs_ZOA_nlos(i_path,t) = gcs_ZOA_nlos(i_path,t-1) + deltaZOA/(c*sc_delay_nlos(i_path,t-1)*1e-9);

            end 
        end
        
        % Change angles back to local coordinate system
        sc_AOD_nlos = mod(rad2deg(pi/2 - gcs_AOD_nlos),360);
        sc_ZOD_nlos = rad2deg(pi/2 - gcs_ZOD_nlos);
        sc_AOA_nlos = mod(rad2deg(pi/2 - gcs_AOA_nlos),360);
        sc_ZOA_nlos = rad2deg(pi/2 - gcs_ZOA_nlos);
        
        evoCIR.pathDelays = sc_delay_nlos;
        % Deal with low powers
        for tt = 1:no_snap
            clear indNaN; 
            indNaN = find(sc_power(:,tt)<=10^(Th/10));
            sc_power(indNaN,tt) = 10^(Th/10);
        end
        evoCIR.pathPowers = sc_power;
        evoCIR.pathPhases = sc_phase;
        evoCIR.AODs = sc_AOD_nlos;
        evoCIR.ZODs = sc_ZOD_nlos;
        evoCIR.AOAs = sc_AOA_nlos;
        evoCIR.ZOAs = sc_ZOA_nlos;
        evoCIR.no_snap = no_snap;
        evoCIR.AOA_AOD_mapping = [cluster_subpath_AOAlobe_mapping cluster_subpath_AODlobe_mapping(:,3)];
        CIR_SISO_Struct.(['CIR_SISO_',num2str(segIdx)]).('Evolution') = evoCIR;
        
    end
     
end % End of a channel segment

%% Blockage 
%
% There is another additional feature of NYUSIM using a human blockage
% model which is well explained in 
% G. R. MacCartney, Jr., T. S. Rappaport, and Sundeep Rangan “Rapid Fading 
% Due to Human Blockage in Pedestrian Crowds at 5G Millimeter-Wave 
% Frequencies,” 2017 IEEE Global Communications Conference (GLOBECOM), 
% Singapore, Dec. 2017. https://arxiv.org/pdf/1709.05883.pdf
%
% Basically, the function transforms the saved CIRs into a big struct
% having the size of # of snapshots x 1. Each entry (snapshot) has angle,
% delay, power info.
% CIR_SISO_EVO = getTimeEvolvedChannel(CIR_SISO_Struct,numberOfSegments,lengthOfSegments);

% Obtain the Markov chain of the blockage state during the RX movement,
% where 1 is "unshadowed", 2 is "decay", 3 is "shadowed", 4 is "rise"

% Whether the user uses default relationship between HPBW and transition
% rates or uses customized transition rates. "Yes" corresponds the former 
% while "No" corresponds the latter.
default = 'No';

% Set the length of the Markov Chain 'mcLen'
if t_dps > 10 % unit:s
    mcLen = (t_dps+1)*2e3;
else
    mcLen = 20e3;
end

% Note that the time resolution of Markov chain is always 1 ms.
t_px = 1e-3;
intervalSamples = ceil(t_update/t_px);

for k = 1:numberOfSegments
    tmpCIR = CIR_SISO_Struct.(['CIR_SISO_',num2str(k)]).('Evolution');
    numAOAlobes = max(tmpCIR.('AOA_AOD_mapping')(:,3));
    numAODlobes = max(tmpCIR.('AOA_AOD_mapping')(:,4));
    
    % Generate Markov trace with different states for each AOA and AOD lobe
    % combination.
    for i_aoa = 1:numAOAlobes
        allMPC_AOA = find(tmpCIR.AOA_AOD_mapping(:,3)==i_aoa);
        maxAng = max(CIR_SISO_Struct.(['CIR_SISO_',num2str(k)]).AOAs(allMPC_AOA));
        minAng = min(CIR_SISO_Struct.(['CIR_SISO_',num2str(k)]).AOAs(allMPC_AOA));
        HPBW = maxAng-minAng; % in degree
        if HPBW > 200
            HPBW = minAng+360-maxAng;
        end
        
        for j_aod = 1:numAODlobes
            
            loss = zeros(5,mcLen);
            for m = 1:5 
                if strcmp(default,'Yes')
                    
                    [mc,r] = getMarkovTrace_default(HPBW,mcLen,t_px);
                    [numberOfBlockage, blocksnap] = getBlockageEvent(mc);
                    
                    for bk = 1:numberOfBlockage
                        
                        lengthOfDecay = length(blocksnap.(['b',num2str(bk)]).decay);
                        lengthOfShad = length(blocksnap.(['b',num2str(bk)]).shad);
                        lengthOfRise = length(blocksnap.(['b',num2str(bk)]).rise);

                        % Find the blocked MPCs
                        blockMPC_AOA = find(tmpCIR.AOA_AOD_mapping(:,3)==i_aoa);
                        blockMPC_AOD = find(tmpCIR.AOA_AOD_mapping(:,4)==j_aod);
                        blockMPC = intersect(blockMPC_AOA,blockMPC_AOD);

                        % Add attenuation caused by human blockage events
                        % to the multipath component power
                        % Decay part
                        count_decay = 1;
                        for k_decay = blocksnap.(['b',num2str(bk)]).decay(1):blocksnap.(['b',num2str(bk)]).decay(end)
                            loss(m,k_decay) = r*count_decay/lengthOfDecay;
                            count_decay = count_decay +1;
                        end

                        % Shadow part
                        for k_shad = blocksnap.(['b',num2str(bk)]).shad(1):blocksnap.(['b',num2str(bk)]).shad(end)
                            loss(m,k_shad) = r;
                        end  

                        % Rise part
                        count_rise = 1;
                        for k_rise = blocksnap.(['b',num2str(bk)]).rise(1):blocksnap.(['b',num2str(bk)]).rise(end)
                            loss(m,k_rise) = r*(1-count_rise/lengthOfRise);
                            count_rise = count_rise + 1;
                        end  
                    
                    end % End of blockages for each trace
                    
                    
                elseif strcmp(default,'No')
                    lambdaDecay = 0.21;
                    lambdaShad = 7.88;
                    lambdaRise = 7.70;
                    lambdaUnshad = 7.67;
                    SEmean = 15.8;
                    mc = getMarkovTrace(lambdaDecay,lambdaShad,lambdaRise,lambdaUnshad,mcLen,t_px);
                    r = SEmean; % Let user input positive value
                    
                    [numberOfBlockage, blocksnap] = getBlockageEvent(mc);
                    
                    for bk = 1:numberOfBlockage
                        
                        lengthOfDecay = length(blocksnap.(['b',num2str(bk)]).decay);
                        lengthOfShad = length(blocksnap.(['b',num2str(bk)]).shad);
                        lengthOfRise = length(blocksnap.(['b',num2str(bk)]).rise);

                        % Find the blocked MPCs
                        blockMPC_AOA = find(tmpCIR.AOA_AOD_mapping(:,3)==i_aoa);
                        blockMPC_AOD = find(tmpCIR.AOA_AOD_mapping(:,4)==j_aod);
                        blockMPC = intersect(blockMPC_AOA,blockMPC_AOD);


                        % Decay part
                        count_decay = 1;
                        for k_decay = blocksnap.(['b',num2str(bk)]).decay(1):blocksnap.(['b',num2str(bk)]).decay(end)
                            loss(m,k_decay) = r*count_decay/lengthOfDecay;
                            count_decay = count_decay +1;
                        end

                        % Shadow part
                        for k_shad = blocksnap.(['b',num2str(bk)]).shad(1):blocksnap.(['b',num2str(bk)]).shad(end)
                            loss(m,k_shad) = r;
                        end  

                        % Rise part
                        count_rise = 1;
                        for k_rise = blocksnap.(['b',num2str(bk)]).rise(1):blocksnap.(['b',num2str(bk)]).rise(end)
                            loss(m,k_rise) = r*(1-count_rise/lengthOfRise);
                            count_rise = count_rise + 1;
                        end  
                    
                    end % End of blockages for each trace
                    
                end % End of default on or off
                
            end % End of 5 blockers
            sum_loss = sum(loss,1);
            
%             actual_loss = sum_loss(randi(mcLen,1),1);

            init = randi(999,1);
            for t = 1:lengthOfSegments(k)
                linearLoss = 10^(sum_loss(init+(t-1)*intervalSamples)/10);
                tmpCIR.pathPowers(blockMPC) = tmpCIR.pathPowers(blockMPC)/linearLoss;
            end % End of snapshot
            
        end % End of AOD lobes
        
    end % ENd of AOA lobes

end % End of channel segments

%% Put all snapshots together
CIR_SISO_EVO = getTimeEvolvedChannel(CIR_SISO_Struct,numberOfSegments,lengthOfSegments);

%% Smooth transitions
%
% Note that the blockage part (if enabled) should be run before we do
% transition between segments.
%
% This part is to deal with one problem. Considering the first CIR of each
% segment is independent from each other. Then, the last snapshot in the
% former segment might be very different from the first snapshot in the
% latter segment. Thus, a smooth transition is necessary to be implemented
% in the post processing.
%
% The method is to do cluster birth and death
% - If the # of clusters in the former (denoted as A) is greater than the # of clusters in
% the latter (denoted as B), then one of the clusters of A is dropped in a
% snapshot.
% - If the # of clusters in A is greater than the # of clusters in
% B, then one of the clusters of B is generated in a snapshot
% - if the # of clusters in A is equal the # of clusters in
% B, then one of clusters of A is dropped and one of clusters of B is
% generated in the same snapshot. 
%
% Note that usually, the cluster birth and death starts from the weakest one. 
if strcmp(transExist,'Yes') == 1
    CIR_SISO_EVO = getTransitions(nTC,numberOfSegments,co_dps,CIR_SISO_Struct,CIR_SISO_EVO);
end
TR3D = sqrt(sum((track-TX_Pos).^2));
TR2D = sqrt(sum(track(1:2,:).^2));
omniPL = zeros(numberOfSnapshot,1);
omniPr = zeros(numberOfSnapshot,1);
omniDS = zeros(numberOfSnapshot,1);
KFactor = zeros(numberOfSnapshot,1);

for i_snap = 1:numberOfSnapshot
    
    % Omnidirectional channels
    sdf = sfMap(round(area/2+track(1,i_snap)),round(area/2+track(2,i_snap)));
    [PL_dB, Pr_dBm, FSPL, PLE] = getPowerInfo(sceType,envType,f,n,sdf,TXPower,...
                                    TR2D(i_snap),d0,p,c,u,temp,RR,Pol,Fol,h_BS,folAtt,dFol); 
    omniPL(i_snap,1) = PL_dB;
    omniPr(i_snap,1) = Pr_dBm;
    CIR_tmp = CIR_SISO_EVO.(['Snapshot',num2str(i_snap)]);
    multipathArray = CIR_tmp.pathPowers;
    Pr = 10*log10(multipathArray);
    xmaxInd = find(Pr>Th);
    Pr = Pr(xmaxInd);
    timeArray = CIR_tmp.pathDelays;
    timeArray = timeArray(xmaxInd);
    multipathArray = multipathArray(xmaxInd);
    meanTau = sum(timeArray.*multipathArray)/sum(multipathArray);
    meanTau_Sq = sum(timeArray.^2.*multipathArray)/sum(multipathArray);
    RMSDelaySpread = sqrt(meanTau_Sq-meanTau^2);
    omniDS(i_snap) = RMSDelaySpread;
    KFactor(i_snap) = 10*log10(max(multipathArray)/(sum(multipathArray)-max(multipathArray)));
    
end

%% MIMO CIR for each channel snapshot
for i_snap = 1:numberOfSnapshot
    CIR_tmp = CIR_SISO_EVO.(['Snapshot',num2str(i_snap)]);
    [CIR_MIMO_tmp,~,~,~,~] = getLocalCIR(CIR_tmp,...
        TxArrayType,RxArrayType,Nt,Nr,Wt,Wr,dTxAnt,dRxAnt,RFBW);
    % MIMO CIR is stored
    CIR_MIMO_EVO.(['Snapshot',num2str(i_snap)]) = CIR_MIMO_tmp;
end

%% Directional CIR for each channel snapshot
DirPDPInfo = [];
for i_snap = 1:numberOfSnapshot
    CIR_tmp = CIR_SISO_EVO.(['Snapshot',num2str(i_snap)]);
    ps = [CIR_tmp.pathDelays, CIR_tmp.pathPowers, CIR_tmp.pathPhases,...
        CIR_tmp.AODs, CIR_tmp.ZODs, CIR_tmp.AOAs, CIR_tmp.ZOAs];
    TRd = sqrt(sum(track(1:2,i_snap).^2));
    
    [DirRMSDelaySpread, PL_dir, PLE_dir, Pr_dir] = getDirStat(ps,...
    theta_3dB_TX,phi_3dB_TX,theta_3dB_RX,phi_3dB_RX,TXPower,FSPL,TRd,d0);
    
    % Plot the strongest directional PDP
    [maxP, maxIndex] = max(ps(:,2));
    
    % Angles for use
    theta_TX_d = CIR_tmp.AODs;
    phi_TX_d = CIR_tmp.ZODs;
    theta_RX_d = CIR_tmp.AOAs;
    phi_RX_d = CIR_tmp.ZOAs;
    
    % Get directive antenna gains
    [TX_Dir_Gain_Mat, RX_Dir_Gain_Mat, G_TX, G_RX] = getDirectiveGains(theta_3dB_TX,...
        phi_3dB_TX,theta_3dB_RX,phi_3dB_RX,theta_TX_d(maxIndex),phi_TX_d(maxIndex),...
        theta_RX_d(maxIndex),phi_RX_d(maxIndex),ps);

    % Recover the directional PDP
    [timeArray_Dir, multipathArray_Dir] = getDirPDP(ps,...
        TX_Dir_Gain_Mat,RX_Dir_Gain_Mat);
    
%     Pr_Dir = 10^(sum(multipathArray_Dir)/10);
    meanTau = sum(timeArray_Dir.*multipathArray_Dir)/sum(multipathArray_Dir);
    meanTau_Sq = sum(timeArray_Dir.^2.*multipathArray_Dir)/sum(multipathArray_Dir);
    rmsDS_best = sqrt(meanTau_Sq-meanTau^2);
    DirPDP = [timeArray_Dir, multipathArray_Dir];
    
    CIR_tmp.pathPowers_BestDir = multipathArray_Dir; % Best direction
    CIR_tmp.rmsDS = DirRMSDelaySpread;
    CIR_tmp.PL_dir = PL_dir;
    CIR_tmp.PLE_dir = PLE_dir;
    CIR_tmp.rmsDS_BestDir = rmsDS_best;
    CIR_tmp.Pr_dir = Pr_dir;
    CIR_SISO_EVO_DIR.(['Snapshot',num2str(i_snap)]) = CIR_tmp;
    psDB = ps;
    psDB(:,2) = 10.*log10(psDB(:,2));
    onefill = ones(length(Pr_dir),1);
    DirPDPInfo_temp = [i_snap*onefill,TR3D(i_snap)*onefill,psDB,PL_dir,DirRMSDelaySpread];
    DirPDPInfo = vertcat(DirPDPInfo,DirPDPInfo_temp);
end

%% plot
if plotStatus == true
    %%% Plot 1: Spatially correlated SF map
    h1 = plotSFMap(d_co,area,sfMap,track,sceType,envType,SF,movDistance,velocity,f,dini,FigVisibility);
    %%% Plot 2: Spatially correlated LOS/NLOS map
    h2 = plotLOSMap(d_co_los,area,losMap,track,sceType,envType,movDistance,velocity,f,dini,FigVisibility);
    %%% Plot 3: User track
    h3 = plotUserTrack(area,track,sfMap,sceType,envType,f,SF,dini,movDistance,velocity,FigVisibility);
    %%% Plot 4: Consecutive omnidirectional PDPs
    h4 = plotConPDP(CIR_SISO_EVO,Th,f,sceType,envType,dini,d_update,d_co,movDistance,velocity,FigVisibility);
    %%% Plot 5: Consecutive directional PDPs
    h5 = ...
    plotConDirPDP(CIR_SISO_EVO,theta_3dB_TX,phi_3dB_TX,theta_3dB_RX,phi_3dB_RX,Th,f,sceType,envType,dini,d_update,d_co,movDistance,velocity,FigVisibility);
    
end

%% Processing bar update
Count = Count+1;
javaMethodEDT('setValue', jBarHandle, Count);
pause(0.2);

%% Basic Parameters
BasicParameters = struct;
BasicParameters.Frequency = f; 
BasicParameters.Bandwidth = RFBW; 
BasicParameters.TXPower = TXPower;
BasicParameters.Environment = envType; 
BasicParameters.Scenario = sceType;
BasicParameters.TXHeight = h_BS;
BasicParameters.RXHeight = h_MS;
BasicParameters.Pressure = p; 
BasicParameters.Humidity = u;
BasicParameters.Temperature = temp; 
BasicParameters.RainRate = RR;
BasicParameters.Polarization = Pol; 
BasicParameters.Foliage = Fol;
BasicParameters.DistFol = dFol; 
BasicParameters.FoliageAttenuation = folAtt;

BasicParameters.TxArrayType = TxArrayType; 
BasicParameters.RxArrayType = RxArrayType;
BasicParameters.NumberOfTxAntenna = Nt; 
BasicParameters.NumberOfRxAntenna = Nr;
BasicParameters.NumberOfTxAntennaPerRow = Wt; 
BasicParameters.NumberOfRxAntennaPerRow = Wr;
BasicParameters.TxAntennaSpacing = dTxAnt; 
BasicParameters.RxAntennaSpacing = dRxAnt; 
BasicParameters.TxAzHPBW = theta_3dB_TX; 
BasicParameters.TxElHPBW = phi_3dB_TX; 
BasicParameters.RxAzHPBW = theta_3dB_RX; 
BasicParameters.RxElHPBW = phi_3dB_RX;

BasicParameters.SCenable = scIdc;
BasicParameters.CorrDistanceSF = d_co;
BasicParameters.CorrDistanceLOS = d_co_los;
BasicParameters.TrackType = trackType;
BasicParameters.MovDistance = movDistance;
BasicParameters.MovDirection = direction;
BasicParameters.UpdateDist = d_update;
BasicParameters.Velocity = velocity;

BasicParameters.HBenable = hbIdc;
BasicParameters.HBdefault = default;
BasicParameters.SEMean = SEmean;
BasicParameters.U2Drate = lambdaDecay;
BasicParameters.D2Srate = lambdaShad;
BasicParameters.S2Rrate = lambdaRise;
BasicParameters.R2Urate = lambdaUnshad;

%% Save files
saveas(h1,[outputFolder,'SF_Map.png']);
saveas(h2,[outputFolder,'LOS_Map.png']); 
saveas(h3,[outputFolder,'UserTrack.png']); 
saveas(h4,[outputFolder,'OmniConsecutivePDP.png']);
saveas(h5,[outputFolder,'DirConsecutive.png']);

if strcmp(fileType,'Text File') == true
    for SI = 1:numberOfSnapshot
    CIR_write = CIR_SISO_EVO_DIR.(['Snapshot',num2str(SI)]);
    OmniPDP = [CIR_write.pathDelays, CIR_write.pathPowers, CIR_write.pathPhases,...
       CIR_write.AODs, CIR_write.ZODs, CIR_write.AOAs, CIR_write.ZOAs];
    DirPDP = [CIR_write.pathDelays, CIR_write.pathPowers_BestDir, CIR_write.pathPhases,...
       CIR_write.AODs, CIR_write.ZODs, CIR_write.AOAs, CIR_write.ZOAs];
    dlmwrite([outputFolder,'OmniPDP_Snap' sprintf('%d',SI) '.txt'],OmniPDP,'delimiter', '\t', 'newline', 'pc');
    dlmwrite([outputFolder,'DirectionalPDP_Snap' sprintf('%d',SI) '.txt'],DirPDP,'delimiter', '\t', 'newline', 'pc');
    end
    
    OmniPDPInfo = [TR3D',omniPr,omniPL,omniDS,KFactor];
    OmniPDPInfo(find(omniPL>DR),2:5)= NaN;
    file_name = ['OmniPDPInfo.txt'];
    fid = fopen([outputFolder,file_name],'wt');
    fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t',...
        'T-R Separation Distance (m)','Received Power (dBm)','Path Loss (dB)','RMS Delay Spread (ns)','K-Factor (dB)'); 
    fprintf(fid,'\n%15.1f\t%25.1f\t%15.1f\t%15.1f\t%20.1f',OmniPDPInfo.'); 
    fclose(fid);
    file_name = ['DirPDPInfo.txt'];
    fid = fopen([outputFolder,file_name],'wt');
    fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t',...
    'Simulation Run Number','T-R Separation Distance (m)','Time Delay (ns)','Received Power (dBm)','Phase (rad)',...
    'Azimuth AoD (degree)','Elevation AoD (degree)','Azimuth AoA (degree)','Elevation AoA (degree)',...
    'Path Loss (dB)','RMS Delay Spread (ns)'); 
    fprintf(fid,'\n%15.1f\t%15.1f\t%20.0f\t%17.1f\t%13.1f\t%15.0f\t%17.1f\t%17.1f\t%17.0f\t%17.1f\t%17.1f',DirPDPInfo.');
    fclose(fid);
    
    % Save BasicParameters as .txt file
    struct2File(BasicParameters,[outputFolder,'BasicParameters.txt'],'align',true,'sort',false);

elseif strcmp(fileType,'MAT File') == true 
    for SI = 1:numberOfSnapshot
    CIR_write = CIR_SISO_EVO_DIR.(['Snapshot',num2str(SI)]);
    OmniPDP = [CIR_write.pathDelays, CIR_write.pathPowers, CIR_write.pathPhases,...
       CIR_write.AODs, CIR_write.ZODs, CIR_write.AOAs, CIR_write.ZOAs];
    DirPDP = [CIR_write.pathDelays, CIR_write.pathPowers_BestDir, CIR_write.pathPhases,...
       CIR_write.AODs, CIR_write.ZODs, CIR_write.AOAs, CIR_write.ZOAs];
    save([outputFolder,'OmniPDP_Snap' sprintf('%d',SI)],'OmniPDP');
    save([outputFolder,'DirectionalPDP_Snap' sprintf('%d',SI)],'DirPDP');
    end
    OmniPDPInfo = [TR3D',omniPr,omniPL,omniDS,KFactor];
    OmniPDPInfo(find(omniPL>DR),2:5)= NaN;
    save([outputFolder,'OmniPDPInfo'],'OmniPDPInfo');
    save([outputFolder,'DirPDPInfo'],'DirPDPInfo');    
    
    % Save BasicParameters as .mat file
    save([outputFolder,'BasicParameters.mat'],'BasicParameters');

elseif strcmp(fileType,'Both Text and MAT File') == true
    for SI = 1:numberOfSnapshot
    CIR_write = CIR_SISO_EVO_DIR.(['Snapshot',num2str(SI)]);
    OmniPDP = [CIR_write.pathDelays, CIR_write.pathPowers, CIR_write.pathPhases,...
       CIR_write.AODs, CIR_write.ZODs, CIR_write.AOAs, CIR_write.ZOAs];
    DirPDP = [CIR_write.pathDelays, CIR_write.pathPowers_BestDir, CIR_write.pathPhases,...
       CIR_write.AODs, CIR_write.ZODs, CIR_write.AOAs, CIR_write.ZOAs];
    save([outputFolder,'OmniPDP_Snap' sprintf('%d',SI)],'OmniPDP');
    save([outputFolder,'DirectionalPDP_Snap' sprintf('%d',SI)],'DirPDP');
    dlmwrite([outputFolder,'OmniPDP_Snap' sprintf('%d',SI) '.txt'],OmniPDP,'delimiter', '\t', 'newline', 'pc');
    dlmwrite([outputFolder,'DirectionalPDP_Snap' sprintf('%d',SI) '.txt'],DirPDP,'delimiter', '\t', 'newline', 'pc');
    end
    
    OmniPDPInfo = [TR3D',omniPr,omniPL,omniDS,KFactor];
    OmniPDPInfo(find(omniPL>DR),2:5)= NaN;
    save('OmniPDPInfo','OmniPDPInfo');
    file_name = ['OmniPDPInfo.txt'];
    fid = fopen([outputFolder,file_name],'wt');
    fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t',...
        'T-R Separation Distance (m)','Received Power (dBm)','Path Loss (dB)','RMS Delay Spread (ns)','K-Factor (dB)'); 
    fprintf(fid,'\n%15.1f\t%25.1f\t%15.1f\t%15.1f\t%20.1f',OmniPDPInfo.'); 
    fclose(fid);
    save('DirPDPInfo','DirPDPInfo');
    file_name = ['DirPDPInfo.txt'];
    fid = fopen([outputFolder,file_name],'wt');
    fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t',...
        'Simulation Run Number','T-R Separation Distance (m)','Time Delay (ns)','Received Power (dBm)','Phase (rad)',...
        'Azimuth AoD (degree)','Elevation AoD (degree)','Azimuth AoA (degree)','Elevation AoA (degree)',...
        'Path Loss (dB)','RMS Delay Spread (ns)'); 
    fprintf(fid,'\n%15.1f\t%15.1f\t%20.0f\t%17.1f\t%13.1f\t%15.0f\t%17.1f\t%17.1f\t%17.0f\t%17.1f\t%17.1f',DirPDPInfo.'); 
    fclose(fid);
    
    % Save BasicParameters as .mat file
    save([outputFolder,'BasicParameters.mat'],'BasicParameters');
    % Save BasicParameters as .txt file
    struct2File(BasicParameters,[outputFolder,'BasicParameters.txt'],'align',true,'sort',false);
end

%% Processing bar update
Count = Count+1;
javaMethodEDT('setValue', jBarHandle, Count);
pause(0.2);
if exist('hhandle','var') == 1
delete(hhandle); 
end
delete(txtPb);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif strcmp(scIdc,'Off')

%% Channel Model Parameters
% Free space reference distance in meters
d0 = 1; 
% Speed of light in m/s
c = physconst('LightSpeed');

if strcmp(sceType,'InH') == true && strcmp(envType,'LOS') == true 
% Path loss exponent (PLE)
% Calculation of frequency-depedent PLE for InH LOS scenario since we
% observed that the PLE at 28 GHz is particular low about 1.4. PLE at sub-6
% GHz from the literature is about 1.8, and the PLE measured by NYU at 140
% GHz is 1.75, approximately 1.8. Thus, we applied such two-segement PLE
% calculation across frequencies from 0.5 to 150 GHz.

% PLE
n = calPleLos(f);
% Shadow fading standard deviation in dB
SF = calPar(3,2.9,f); 
% Mean number of time clusters
lambda_C = calPar(3.6,0.9,f);
% Number of cluster subpaths
beta_S = calPar(0.7,1.0,f);
mu_S = calPar(3.7,1.4,f);
SPlimit = round(calPar(35,10,f));
% For indoor scenario, mu_AOD stands for the maximum number of spatial lobes
mu_AOD = round(calPar(3,2,f)); 
% For indoor scenario, mu_AOA stands for the maximum number of spatial lobes
mu_AOA = round(calPar(3,2,f)); 
% For indoor scenario, X_max stands for mu_rho -> intra-cluster delay
X_max = calPar(3.4,1.1,f);
% Mean excess delay in ns
mu_tau = calPar(17.3,14.6,f); 
% Minimum inter-cluster void interval, typically set to 25 ns for outdoor environments
minVoidInterval = 6;
% Per-cluster shadowing in dB
sigmaCluster = calPar(10,9,f);
% Time cluster decay constant in ns
Gamma = calPar(20.7,18.2,f); 
% Per-subpath shadowing in dB
sigmaSubpath = calPar(5,5,f); 
% Subpath decay constant in ns
gamma = calPar(2.0,2.0,f); 
% Mean zenith angle of departure (ZOD) in degrees
mean_ZOD = calPar(-7.3,-6.8,f);
% Standard deviation of the ZOD distribution in degrees
sigma_ZOD = calPar(3.8,4.9,f); 
% Standard deviation of the azimuth offset from the lobe centroid
std_AOD_RMSLobeAzimuthSpread = calPar(20.6,4.8,f);
% Standard deviation of the elevation offset from the lobe centroid
std_AOD_RMSLobeElevationSpread = calPar(15.7,4.3,f);
% A string specifying which distribution to use: 'Gaussian' or 'Laplacian'
distributionType_AOD = 'Gaussian'; 
% Mean zenith angle of arrival (ZOA) in degrees
mean_ZOA = calPar(7.4,7.4,f); 
% Standard deviation of the ZOA distribution in degrees
sigma_ZOA = calPar(3.8,4.5,f);
% Standard deviation of the azimuth offset from the lobe centroid
std_AOA_RMSLobeAzimuthSpread = calPar(17.7,4.7,f);
% Standard deviation of the elevation offset from the lobe centroid
std_AOA_RMSLobeElevationSpread = calPar(14.4,4.4,f);
% A string specifying which distribution to use: 'Gaussian' or 'Laplacian'
distributionType_AOA = 'Gaussian';   
elseif strcmp(sceType,'InH') == true && strcmp(envType,'NLOS') == true
% See the parameter definitions for InH LOS
n = calPar(2.7,2.7,f); 
SF = calPar(9.8,6.6,f); 
lambda_C = calPar(5.1,1.8,f);
beta_S = calPar(0.7,1.0,f);
mu_S = calPar(5.3,1.2,f);
SPlimit = round(calPar(35,10,f));
mu_AOD = round(calPar(3,3,f)); 
mu_AOA = round(calPar(3,2,f));
X_max = calPar(22.7,2.7,f);
mu_tau = calPar(10.9,21.0,f); 
minVoidInterval = 6;
sigmaCluster = calPar(10,10,f);
Gamma = calPar(23.6,16.1,f); 
sigmaSubpath = calPar(6,6,f); 
gamma = calPar(9.2,2.4,f); 
mean_ZOD = calPar(-5.5,-2.5,f);
sigma_ZOD = calPar(2.9,2.7,f); 
std_AOD_RMSLobeAzimuthSpread = calPar(27.1,4.8,f);
std_AOD_RMSLobeElevationSpread = calPar(16.2,2.8,f);
distributionType_AOD = 'Gaussian'; 
mean_ZOA = calPar(5.5,4.8,f); 
sigma_ZOA = calPar(2.9,2.8,f);
std_AOA_RMSLobeAzimuthSpread = calPar(20.3,6.6,f);
std_AOA_RMSLobeElevationSpread = calPar(15.0,4.5,f);
distributionType_AOA = 'Gaussian'; 
% UMi LOS
elseif strcmp(sceType,'UMi') == true && strcmp(envType,'LOS') == true 
% Path loss exponent (PLE)
n = 2; 
% Shadow fading standard deviation in dB
SF = 4.0; 
% Mean angle of departure (AOD)
mu_AOD = 1.9; 
% Mean angle of arrival (AOA)
mu_AOA = 1.8;
% A number between 0 and 1 for generating intra-cluster delays
X_max = 0.2;
% Mean excess delay in ns
mu_tau = 123; 
% Minimum inter-cluster void interval, typically set to 25 ns for outdoor environments
minVoidInterval = 25;
% Per-cluster shadowing in dB
sigmaCluster = 1;
% Time cluster decay constant in ns
Gamma = 25.9; 
% Per-subpath shadowing in dB
sigmaSubpath = 6; 
% Subpath decay constant in ns
gamma = 16.9; 
% Mean zenith angle of departure (ZOD) in degrees
mean_ZOD = -12.6;
% Standard deviation of the ZOD distribution in degrees
sigma_ZOD = 5.9; 
% Standard deviation of the azimuth offset from the lobe centroid
std_AOD_RMSLobeAzimuthSpread = 8.5;
% Standard deviation of the elevation offset from the lobe centroid
std_AOD_RMSLobeElevationSpread = 2.5;
% A string specifying which distribution to use: 'Gaussian' or 'Laplacian'
distributionType_AOD = 'Gaussian'; 
% Mean zenith angle of arrival (ZOA) in degrees
mean_ZOA = 10.8; 
% Standard deviation of the ZOA distribution in degrees
sigma_ZOA = 5.3;
% Standard deviation of the azimuth offset from the lobe centroid
std_AOA_RMSLobeAzimuthSpread = 10.5;
% Standard deviation of the elevation offset from the lobe centroid
std_AOA_RMSLobeElevationSpread = 11.5;
% A string specifying which distribution to use: 'Gaussian' or 'Laplacian'
distributionType_AOA = 'Laplacian';   
% UMi NLOS
elseif strcmp(sceType,'UMi') == true && strcmp(envType,'NLOS') == true
% See the parameter definitions for UMi LOS
n = 3.2; 
SF = 7.0; 
mu_AOD = 1.5; 
mu_AOA = 2.1; 
X_max = 0.5; 
mu_tau = 83;
minVoidInterval = 25; 
sigmaCluster = 3; 
Gamma = 51.0; 
sigmaSubpath = 6;
gamma = 15.5; 
mean_ZOD = -4.9; 
sigma_ZOD = 4.5; 
std_AOD_RMSLobeAzimuthSpread = 11.0;
std_AOD_RMSLobeElevationSpread = 3.0; 
distributionType_AOD = 'Gaussian'; 
mean_ZOA = 3.6; 
sigma_ZOA = 4.8; 
std_AOA_RMSLobeAzimuthSpread = 7.5;
std_AOA_RMSLobeElevationSpread = 6.0; 
distributionType_AOA = 'Laplacian';
% UMa LOS
elseif strcmp(sceType,'UMa') == true && strcmp(envType,'LOS') == true 
% See the parameter definitions for UMi LOS
n = 2; 
SF = 4.0; 
mu_AOD = 1.9; 
mu_AOA = 1.8;
X_max = 0.2; 
mu_tau = 123; 
minVoidInterval = 25; 
sigmaCluster = 1;
Gamma = 25.9; 
sigmaSubpath = 6; 
gamma = 16.9; 
mean_ZOD = -12.6;
sigma_ZOD = 5.9; 
std_AOD_RMSLobeAzimuthSpread = 8.5;
std_AOD_RMSLobeElevationSpread = 2.5;
distributionType_AOD = 'Gaussian'; 
mean_ZOA = 10.8; 
sigma_ZOA = 5.3;
std_AOA_RMSLobeAzimuthSpread = 10.5;
std_AOA_RMSLobeElevationSpread = 11.5;
distributionType_AOA = 'Laplacian'; 
% UMa NLOS
elseif strcmp(sceType,'UMa') == true && strcmp(envType,'NLOS') == true 
% See the parameter definitions for UMi LOS
n = 2.9; 
SF = 7.0; 
mu_AOD = 1.5; 
mu_AOA = 2.1; 
X_max = 0.5; 
mu_tau = 83;
minVoidInterval = 25; 
sigmaCluster = 3; 
Gamma = 51.0; 
sigmaSubpath = 6;
gamma = 15.5; 
mean_ZOD = -4.9; 
sigma_ZOD = 4.5; 
std_AOD_RMSLobeAzimuthSpread = 11.0;
std_AOD_RMSLobeElevationSpread = 3.0; 
distributionType_AOD = 'Gaussian'; 
mean_ZOA = 3.6; 
sigma_ZOA = 4.8; 
std_AOA_RMSLobeAzimuthSpread = 7.5;
std_AOA_RMSLobeElevationSpread = 6.0; 
distributionType_AOA = 'Laplacian';
% RMa LOS
elseif strcmp(sceType,'RMa') == true && strcmp(envType,'LOS') == true
% See the parameter definitions for UMi LOS
SF = 1.7; 
mu_AOD = 1; 
mu_AOA = 1;
X_max = 0.2; 
mu_tau = 123; 
minVoidInterval = 25; 
sigmaCluster = 1;
Gamma = 25.9; 
sigmaSubpath = 6; 
gamma = 16.9; 
mean_ZOD = -12.6;
sigma_ZOD = 5.9; 
std_AOD_RMSLobeAzimuthSpread = 8.5;
std_AOD_RMSLobeElevationSpread = 2.5;
distributionType_AOD = 'Gaussian'; 
mean_ZOA = 10.8; 
sigma_ZOA = 5.3;
std_AOA_RMSLobeAzimuthSpread = 10.5;
std_AOA_RMSLobeElevationSpread = 11.5;
distributionType_AOA = 'Laplacian';
% RMa NLOS
elseif strcmp(sceType,'RMa') == true && strcmp(envType,'NLOS') == true
% See the parameter definitions for UMi LOS
SF = 6.7; 
mu_AOD = 1; 
mu_AOA = 1; 
X_max = 0.5; 
mu_tau = 83;
minVoidInterval = 25; 
sigmaCluster = 3; 
Gamma = 51.0; 
sigmaSubpath = 6;
gamma = 15.5; 
mean_ZOD = -4.9; 
sigma_ZOD = 4.5; 
std_AOD_RMSLobeAzimuthSpread = 11.0;
std_AOD_RMSLobeElevationSpread = 3.0; 
distributionType_AOD = 'Gaussian'; 
mean_ZOA = 3.6; 
sigma_ZOA = 4.8; 
std_AOA_RMSLobeAzimuthSpread = 7.5;
std_AOA_RMSLobeElevationSpread = 6.0; 
distributionType_AOA = 'Laplacian';
end
%% Initialize various settings and parameters
% Determine the dimension of OmniPDPInfo
if strcmp(Pol,'All-Pol')
    numPol = 4;
elseif strcmp(Pol,'Co/X-Pol')
    numPol = 2;
else
    numPol = 1;
end
% Structure containing generated CIRs
CIR_SISO_Struct = struct; 
CIR_MIMO_Struct = struct;
% Set plot status
plotStatus = true; 
% Set plot rotation status
plotRotate = false; 
% Determine if spatial plot is needed 
plotSpatial = true;
% Number of multipath components
nPath = zeros(N,1); 
% Best (i.e., smallest) directional path loss
PL_dir_best = zeros(N,numPol); 
% Directional PDP information
DirPDPInfo = []; 
% Omnidirectional PDP information
OmniPDPInfo = zeros(N,5,numPol);
% Run for each RX location, i.e., each channel realization
for CIRIdx = 1:N
    clear powerSpectrum PL_dir DirRMSDelaySpread TRDistance;

    %% Step 1: Generate T-R Separation distance (m) ranging from dmin - dmax.
    TRDistance = getTRSep(dmin,dmax);
    % Set dynamic range, i.e., maximum possible omnidirectional path loss 
    % in dB, according to T-R separation distance. If T-R separation 
    % distance is no larger than 500 m, then set dynamic range as 190 dB, 
    % otherwise set it to 220 dB.
    if TRDistance <= 500
        % Dynamic range in dB
        DR = 190;
    else
        DR = 220;
    end
    % Received power threshod in dBm
    Th = TXPower - DR;
    
    %% Step 2: Generate the total received omnidirectional power (dBm) and 
    % omnidirectional path loss (dB) 
    % non RMa, i.e., UMi or UMa
    if strcmp(sceType,'RMa') == false
    [Pr_dBm, PL_dB]= getRXPower(f,n,SF*randn,TXPower,TRDistance,d0);
    % RMa LOS
    elseif strcmp(sceType,'RMa') == true && strcmp(envType,'LOS') == true 
        PL_dB = 20*log10(4*pi*d0*f*1e9/c) + 23.1*(1-0.03*((h_BS-35)/35))*log10(TRDistance) + SF*randn;
    % RMa NLOS
    elseif strcmp(sceType,'RMa') == true && strcmp(envType,'NLOS') == true 
        PL_dB = 20*log10(4*pi*d0*f*1e9/c) + 30.7*(1-0.049*((h_BS-35)/35))*log10(TRDistance) + SF*randn;
    end
    
    % O2I penetration loss
    if strcmp(o2iLoss,'Yes')
        [PL_dB,o2iLossValue] = getO2IPL(PL_dB,f,o2iType);
    end
    % Atmospheric attenuation factor
    attenFactor = mpm93_forNYU(f,p,u,temp,RR);
    % Path loss incorporating atmospheric attenuation
    PL_dB = getAtmosphericAttenuatedPL(PL_dB,attenFactor,TRDistance);
    % Incorporating cross-polarization
%     if strcmp(Pol,'X-Pol') == true
%         PL_dB = PL_dB+25;
%     end
    % Incorporating foliage loss
    if strcmp(Fol,'Yes') == true
        PL_dB = getFoliageAttenuatedPL(PL_dB,folAtt,dFol);
    end      
    % Calculate received power based on transmit power and path loss
    Pr_dBm = TXPower - PL_dB;
    % Free space path loss
    FSPL = 20*log10(4*pi*d0*f*1e9/c);


    %% Step 3 and 4: Generate # of time clusters N, and # AOD and AOA 
    % spatial lobes and the number of subpaths per cluster
    
    %%%%%% Change in NYUSIM 3.0 Indoor scenario %%%%%%
    % Distribution of # of time clusters is Poisson for indoor, rather than
    % Uniform for outdoor
    if strcmp(sceType,'InH')
        [numberOfTimeClusters,numberOfAOALobes,numberOfAODLobes] = ...
            getNumClusters_AOA_AOD_Indoor(mu_AOA,mu_AOD,lambda_C);
        numberOfClusterSubPaths = getNumberOfClusterSubPaths_Indoor(...
            numberOfTimeClusters,beta_S,mu_S,SPlimit);
    else
        [numberOfTimeClusters,numberOfAOALobes,numberOfAODLobes] = ...
            getNumClusters_AOA_AOD(mu_AOA,mu_AOD,sceType);
        numberOfClusterSubPaths = getNumberOfClusterSubPaths(...
            numberOfTimeClusters,sceType);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Step 5: Generate the intra-cluster subpath delays rho_mn (ns)
    %%%%%% Change in NYUSIM 3.0 Indoor scenario %%%%%%
    % X_max represents mu_tau for indoor, rather than X_max for outdoor
    rho_mn = getIntraClusterDelays(numberOfClusterSubPaths,X_max,sceType);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Step 6: Generate the phases (rad) for each cluster
    phases_mn = getSubpathPhases(rho_mn);
    
    %% Step 7: Generate the cluster excess time delays tau_n (ns)
    tau_n = getClusterExcessTimeDelays(mu_tau,rho_mn,minVoidInterval);
    
    %% Step 8: Generate temporal cluster powers (mW)
    clusterPowers = getClusterPowers(tau_n,Pr_dBm,Gamma,sigmaCluster,Th);
    
    %% Step 9: Generate the cluster subpath powers (mW)
    subpathPowers = ...
        getSubpathPowers(rho_mn,clusterPowers,gamma,sigmaSubpath,envType,Th);
    
    %% Step 10: Recover absolute propagation times t_mn (ns) of each subpath component
    t_mn = getAbsolutePropTimes(TRDistance,tau_n,rho_mn);
    
    %% Step 11: Recover AODs and AOAs of the multipath components
    [subpath_AODs, cluster_subpath_AODlobe_mappingOld] = ...
        getSubpathAngles(numberOfAODLobes,numberOfClusterSubPaths,mean_ZOD,...
        sigma_ZOD,std_AOD_RMSLobeElevationSpread,std_AOD_RMSLobeAzimuthSpread,...
        distributionType_AOD);
    [subpath_AOAs, cluster_subpath_AOAlobe_mappingOld] = ...
        getSubpathAngles(numberOfAOALobes,numberOfClusterSubPaths,mean_ZOA,...
        sigma_ZOA,std_AOA_RMSLobeElevationSpread,std_AOA_RMSLobeAzimuthSpread,...
        distributionType_AOA);

    %% Step 12: Construct the multipath parameters
    % Delay, Linear Power, Phase, AOD, ZOD, AOA, ZOA
    powerSpectrumOldRaw = getPowerSpectrum(numberOfClusterSubPaths,t_mn,...
        subpathPowers,phases_mn,subpath_AODs,subpath_AOAs,Th);
    % Adjust power spectrum according to RF bandwidth
    [powerSpectrumRaw,numberOfClusterSubPaths,SubpathIndex] = ...
        getNewPowerSpectrum(powerSpectrumOldRaw,RFBW);
    % Change the corresponding time and angle mapping for later lobe
    % spectrum
    cluster_subpath_AODlobe_mapping = cluster_subpath_AODlobe_mappingOld(SubpathIndex-1,:);
    cluster_subpath_AOAlobe_mapping = cluster_subpath_AOAlobe_mappingOld(SubpathIndex-1,:);
    % For LOS environment, adjust subpath AoDs and AoAs such that the AoD
    % and AoA of the LOS component are aligned properly
    powerSpectrumRaw = getLosAligned(envType,powerSpectrumRaw);
    powerSpectrumOldRaw = getLosAligned(envType,powerSpectrumOldRaw);
    %% Compute the Polarization after constructing powerSpectrumOld
    polMod = getPolParameters(Pol,f,envType);
    
    for PolIdx = 1:numPol
    polDcm = polMod{PolIdx,1};
    polStr = polMod{PolIdx,2};
    powerSpectrumOld = powerSpectrumOldRaw;
    powerSpectrum = powerSpectrumRaw;
    powerSpectrumOld(:,2) = powerSpectrumOld(:,2)/db2pow(polDcm);
    powerSpectrum(:,2) = powerSpectrum(:,2)/db2pow(polDcm);

    
    %% Construct the 3-D lobe power spectra at TX and RX
    AOD_LobePowerSpectrum = getLobePowerSpectrum(numberOfAODLobes,...
        cluster_subpath_AODlobe_mapping,powerSpectrum,'AOD');
    AOA_LobePowerSpectrum = getLobePowerSpectrum(numberOfAOALobes,...
        cluster_subpath_AOAlobe_mapping,powerSpectrum,'AOA');
    
    %% Human Blockage
    if strcmp(hbIdc,'On')
        [powerSpectrum,hbLoss] = getHumanBlockageLoss(hbIdc,default,'omni',...
            cluster_subpath_AOAlobe_mapping,cluster_subpath_AODlobe_mapping,...
            powerSpectrum,theta_3dB_RX);
    end
    %% Store CIR parameters
    % Multipath delay
    CIR.pathDelays = powerSpectrum(:,1);
    % Multipath power
    pathPower = powerSpectrum(:,2);
    clear indNaN; indNaN = pathPower<=10^(Th/10);
    pathPower(indNaN,:) = 10^(Th/10);
    CIR.pathPowers = pathPower;
    % Multipath phase
    CIR.pathPhases = powerSpectrum(:,3);
    % Multipath AOD
    CIR.AODs = powerSpectrum(:,4);
    % Multipath ZOD
    CIR.ZODs = powerSpectrum(:,5);
    % Multipath AOA
    CIR.AOAs = powerSpectrum(:,6);
    % Multipath ZOA
    CIR.ZOAs = powerSpectrum(:,7);
    % Various global information for this CIR
    % Carrier frequency
    CIR.frequency = f;
    % Transmit power
    CIR.TXPower = TXPower;
    % Omnidirectional received power in dBm
    CIR.OmniPower = Pr_dBm - polDcm;
    % Omnidirectional path loss in dB
    CIR.OmniPL = PL_dB;
    % T-R separation distance in meters
    CIR.TRSep = TRDistance;
    % Environment, LOS or NLOS
    CIR.environment = envType;
    % Scenario, UMi, UMa, or RMa
    CIR.scenario = sceType;
    % TX HPBW
    CIR.HPBW_TX = [theta_3dB_TX phi_3dB_TX];
    % RX HPBW
    CIR.HPBW_RX = [theta_3dB_RX phi_3dB_RX];
    CIR.polarization = polStr;
    if strcmp(o2iLoss,'Yes')
        CIR.o2iLoss = o2iLossValue;
    end
    if strcmp(hbIdc,'On')
        CIR.HumanBlockageLoss = hbLoss;
    end
    % Store SISO CIR
    CIR_SISO_Struct.(['CIR_SISO_',num2str(CIRIdx)]) = CIR;   
    
    % Calculate and store MIMO CIR 
    [CIR_MIMO,H,HPowers,HPhases,H_ensemble] = getLocalCIR(CIR,...
        TxArrayType,RxArrayType,Nt,Nr,Wt,Wr,dTxAnt,dRxAnt,RFBW);
    CIR_MIMO_Struct.(['CIR_MIMO_',num2str(CIRIdx)]) = CIR_MIMO; 
    H_MIMO = CIR_MIMO.H;
    
    % Show the output figures for the first simulation run
    if CIRIdx == 1 && PolIdx == 1
        FigVisibility = 'on'; 
    else 
        FigVisibility = 'off'; 
    end
%% Plotting    
if plotStatus == true
    AODPower_SphericalSpectrum = getSphericalSpectrum(powerSpectrum,'AOD',Th);
    AOAPower_SphericalSpectrum = getSphericalSpectrum(powerSpectrum,'AOA',Th);
    if plotSpatial == true
        %% Fig1: AOD Spherical Plot
        titleName = ['3-D AOD Power Spectrum - ',num2str(f),' GHz, ',sceType,' ',envType,', ',...
            num2str(TRDistance,'%.1f'),' m T-R Separation'];
        h1 = plotSpherical_Modular(AODPower_SphericalSpectrum,titleName,envType,FigVisibility,Th); 
        
        %% Fig2: AOA Spherical Plot
        titleName = ['3-D AOA Power Spectrum - ',num2str(f),' GHz, ' sceType, ' ' envType, ', ',...
                    num2str(TRDistance,'%.1f'),' m T-R Separation'];
        h2 = plotSpherical_Modular(AOAPower_SphericalSpectrum,titleName,envType,FigVisibility,Th);  
    else
    end
    % Find time and power arrays                
    timeArray = powerSpectrum(:,1); multipathArray = powerSpectrum(:,2); 
    % Calculate the K-factor in dB for either LOS or NLOS
    KFactor = 10*log10(max(multipathArray)/(sum(multipathArray)-max(multipathArray)));

%% Fig3: omnidirectional PDP
if strcmp(o2iLoss,'No')
    o2iType = '';
    o2iLossValue = 0;
end
% PLE
PLE = (PL_dB+polDcm-FSPL)/(10*log10(TRDistance/d0));
h3 = plotPDP(FigVisibility,timeArray,multipathArray,TRDistance,f,sceType,envType,PL_dB,PLE,Th,o2iLoss,o2iType,o2iLossValue);
% Total received power in linear
Pr_Lin = sum(multipathArray);
% Mean time delay
meanTau = sum(timeArray.*multipathArray)/sum(multipathArray);
% Mean squared time delay
meanTau_Sq=sum(timeArray.^2.*multipathArray)/sum(multipathArray);
% RMS delay spread
RMSDelaySpread = sqrt(meanTau_Sq-meanTau^2);
% Create rotational plot
if plotRotate == true
    xlabel('x')
    ylabel('y')
    zlabel('z')
    el = 10;
    aziArray = 0:1:360;
    for index = 1:length(aziArray)
        currentAzi = aziArray(index);
        set(hGca_AOA,'view',[currentAzi el])
        pause(0.01)
    end
else
end

%% Fig4: Directional PDP with the strongest received power
% Find TX-RX combination index with maximum received power
[maxP, maxIndex] = max(powerSpectrum(:,2));

% Desired TX-RX pointing angles
theta_TX_d = powerSpectrum(:,4);
phi_TX_d = powerSpectrum(:,5);
theta_RX_d = powerSpectrum(:,6);
phi_RX_d = powerSpectrum(:,7);

% Number of multiapth components
nPath(CIRIdx) = size(powerSpectrum,1);

% Compute directive gains for each multipath component
PL_dir = zeros(nPath(CIRIdx),1); 

% Directional PLE
PLE_dir = zeros(nPath(CIRIdx),1);

% Directional RMS delay spread
DirRMSDelaySpread = zeros(nPath(CIRIdx),1);
for q = 1:nPath(CIRIdx)
    % See the parameter definitions above
    [TX_Dir_Gain_Mat, RX_Dir_Gain_Mat, G_TX, G_RX] = ...
    getDirectiveGains(theta_3dB_TX,phi_3dB_TX,theta_3dB_RX,phi_3dB_RX,...
    theta_TX_d(q),phi_TX_d(q),theta_RX_d(q),phi_RX_d(q),powerSpectrum);
    [timeArray_Dir, multipathArray_Dir] = getDirPDP(powerSpectrum,...
        TX_Dir_Gain_Mat,RX_Dir_Gain_Mat);
    Pr_Lin_Dir = sum(multipathArray_Dir);
    meanTau = sum(timeArray_Dir.*multipathArray_Dir)/sum(multipathArray_Dir);
    meanTau_Sq=sum(timeArray_Dir.^2.*multipathArray_Dir)/sum(multipathArray_Dir);
    DirRMSDelaySpread(q) = sqrt(meanTau_Sq-meanTau^2);
    % Obtain directional path loss
    PL_dir(q) = TXPower-10*log10(Pr_Lin_Dir)+10*log10(G_TX)+10*log10(G_RX);
    % Obtain directional PLE
    PLE_dir(q) = (PL_dir(q)-FSPL)/(10*log10(TRDistance/d0));
end
Pr_Lin = sum(multipathArray);

% Get directive antenna gains
[TX_Dir_Gain_Mat, RX_Dir_Gain_Mat, G_TX, G_RX] = getDirectiveGains(theta_3dB_TX,...
    phi_3dB_TX,theta_3dB_RX,phi_3dB_RX,theta_TX_d(maxIndex),phi_TX_d(maxIndex),...
    theta_RX_d(maxIndex),phi_RX_d(maxIndex),powerSpectrum);

% Recover the directional PDP
[timeArray_Dir, multipathArray_Dir] = getDirPDP(powerSpectrum,...
    TX_Dir_Gain_Mat,RX_Dir_Gain_Mat);
Pr_Lin_Dir = sum(multipathArray_Dir);
meanTau = sum(timeArray_Dir.*multipathArray_Dir)/sum(multipathArray_Dir);
meanTau_Sq=sum(timeArray_Dir.^2.*multipathArray_Dir)/sum(multipathArray_Dir);

% Dir Human blockage 
if strcmp(hbIdc,'On')
    powerSpectrumDir = horzcat(timeArray_Dir,multipathArray_Dir,powerSpectrum(:,3:7));
    [powerSpectrumDir,hbLossDir] = getHumanBlockageLoss(hbIdc,default,'dir',cluster_subpath_AOAlobe_mapping,...
                                    cluster_subpath_AODlobe_mapping,powerSpectrumDir,theta_3dB_RX);
    timeArray_Dir = powerSpectrumDir(:,1);
    multipathArray_Dir = powerSpectrum(:,2);
end
                    
% Directional PDP
DirPDP = [timeArray_Dir', 10*log10(multipathArray_Dir')];
clear indNaN; indNaN = find(10.*log10(multipathArray_Dir')<=Th);
DirPDP(indNaN,:) = NaN;
h4 = plotDirPDP(FigVisibility,timeArray_Dir,multipathArray_Dir,...
    Th,TRDistance,f,sceType,envType,maxIndex,DirRMSDelaySpread,Pr_Lin_Dir,...
    PL_dir,PLE_dir,theta_3dB_TX,phi_3dB_TX,theta_3dB_RX,phi_3dB_RX,TX_Dir_Gain_Mat,...
    RX_Dir_Gain_Mat,o2iLoss,o2iType,o2iLossValue);

%% Fig5: Small-scale PDPs    
[h5,X,Y,Pr_H] = plotSmallScalePDP(FigVisibility,CIR_MIMO,Nr,Th,TXPower,f,RFBW,...
    sceType,envType,TRDistance);
% Save output figures
saveas(h1,[outputFolder,'AOD_Run',num2str(CIRIdx),'_',polStr,'.png']);
saveas(h2,[outputFolder,'AOA_Run',num2str(CIRIdx),'_',polStr,'.png']); 
saveas(h3,[outputFolder,'OmniPDP_Run',num2str(CIRIdx),'_',polStr,'.png']); 
saveas(h4,[outputFolder,'DirPDP_Run',num2str(CIRIdx),'_',polStr,'.png']);
saveas(h5,[outputFolder,'SmallScalePDP_Run',num2str(CIRIdx),'_',polStr,'.png']);
end

OmniPDP = [timeArray,10.*log10(multipathArray)];
clear indNaN; indNaN = find(10.*log10(multipathArray)<=Th);
OmniPDP(indNaN,:) = NaN;
if CIRIdx > 1
    close(h1); close(h2); close(h3); close(h4); close(h5);
end
%%
if strcmp(fileType,'Text File') == true
SNames = fieldnames(AOD_LobePowerSpectrum); 
for m = 1:numberOfAODLobes
    dlmwrite([outputFolder,'AODLobePowerSpectrum' sprintf('%d',CIRIdx) '_' polStr '_Lobe' sprintf('%d',m) '.txt'],...
        AOD_LobePowerSpectrum.(SNames{m}),'delimiter', '\t', 'newline', 'pc');
end
clear SNames m; SNames = fieldnames(AOA_LobePowerSpectrum); 
for m = 1:numberOfAOALobes
    dlmwrite([outputFolder,'AOALobePowerSpectrum' sprintf('%d',CIRIdx) '_' polStr '_Lobe' sprintf('%d',m) '.txt'],...
        AOA_LobePowerSpectrum.(SNames{m}),'delimiter', '\t', 'newline', 'pc');
end
dlmwrite([outputFolder,'OmniPDP' sprintf('%d',CIRIdx) '_' polStr '.txt'],OmniPDP,'delimiter', '\t', 'newline', 'pc');
dlmwrite([outputFolder,'DirectionalPDP' sprintf('%d',CIRIdx) '_' polStr '.txt'],DirPDP,'delimiter', '\t', 'newline', 'pc');
Tra = reshape(X,[],1); Delay = reshape(Y,[],1); traPr = reshape(Pr_H,[],1);
smallScalePDP = [Tra Delay traPr];
clear indNaN; indNaN = find(traPr<=Th);
smallScalePDP(indNaN,2:3) = NaN;
dlmwrite([outputFolder,'SmallScalePDP' sprintf('%d',CIRIdx) '_' polStr '.txt'],smallScalePDP,'delimiter', '\t', 'newline', 'pc');

elseif strcmp(fileType,'MAT File') == true 
    SNames = fieldnames(AOD_LobePowerSpectrum); 
for m = 1:numberOfAODLobes
    save([outputFolder,'AODLobePowerSpectrum' sprintf('%d',CIRIdx) '_' polStr],'AOD_LobePowerSpectrum');
end
clear SNames m; SNames = fieldnames(AOA_LobePowerSpectrum); 
for m = 1:numberOfAOALobes
    save([outputFolder,'AOALobePowerSpectrum' sprintf('%d',CIRIdx) '_' polStr],'AOA_LobePowerSpectrum');
end
Tra = reshape(X,[],1); Delay = reshape(Y,[],1); traPr = reshape(Pr_H,[],1);
smallScalePDP = [Tra Delay traPr];
clear indNaN; indNaN = find(traPr<=Th);
smallScalePDP(indNaN,2:3) = NaN;
save([outputFolder,'OmniPDP' sprintf('%d',CIRIdx) '_' polStr],'OmniPDP');
save([outputFolder,'DirectionalPDP' sprintf('%d',CIRIdx) '_' polStr],'DirPDP');
save([outputFolder,'SmallScalePDP' sprintf('%d',CIRIdx) '_' polStr],'smallScalePDP');
% ChannelImpulseResponse = powerSpectrum;
% save(['CIR' sprintf('%d',CIRIdx)],'ChannelImpulseResponse');
% % save(['H_ensemble' sprintf('%d',CIRIdx)],'H_ensemble');

elseif strcmp(fileType,'Both Text and MAT File') == true
SNames = fieldnames(AOD_LobePowerSpectrum); 
for m = 1:numberOfAODLobes
    dlmwrite([outputFolder,'AODLobePowerSpectrum' sprintf('%d',CIRIdx) '_' polStr '_Lobe' sprintf('%d',m) '.txt'],...
        AOD_LobePowerSpectrum.(SNames{m}),'delimiter', '\t', 'newline', 'pc');
    save([outputFolder,'AODLobePowerSpectrum' sprintf('%d',CIRIdx) '_' polStr],'AOD_LobePowerSpectrum');
end
clear SNames m; SNames = fieldnames(AOA_LobePowerSpectrum); 
for m = 1:numberOfAOALobes
    dlmwrite([outputFolder,'AOALobePowerSpectrum' sprintf('%d',CIRIdx) '_' polStr '_Lobe' sprintf('%d',m) '.txt'],...
        AOA_LobePowerSpectrum.(SNames{m}),'delimiter', '\t', 'newline', 'pc');
    save([outputFolder,'AOALobePowerSpectrum' sprintf('%d',CIRIdx) '_' polStr],'AOA_LobePowerSpectrum');
end
dlmwrite([outputFolder,'OmniPDP' sprintf('%d',CIRIdx) '_' polStr '.txt'],OmniPDP,'delimiter', '\t', 'newline', 'pc');
dlmwrite([outputFolder,'DirectionalPDP' sprintf('%d',CIRIdx) '_' polStr '.txt'],DirPDP,'delimiter', '\t', 'newline', 'pc');
Tra = reshape(X,[],1); Delay = reshape(Y,[],1); traPr = reshape(Pr_H,[],1);
smallScalePDP = [Tra Delay traPr];
clear indNaN; indNaN = find(traPr<=Th);
smallScalePDP(indNaN,2:3) = NaN;
dlmwrite([outputFolder,'SmallScalePDP' sprintf('%d',CIRIdx) '_' polStr '.txt'],smallScalePDP,'delimiter', '\t', 'newline', 'pc');
save([outputFolder,'OmniPDP' sprintf('%d',CIRIdx) '_' polStr],'OmniPDP');
save([outputFolder,'DirectionalPDP' sprintf('%d',CIRIdx) '_' polStr],'DirPDP');
save([outputFolder,'SmallScalePDP' sprintf('%d',CIRIdx) '_' polStr],'smallScalePDP');
end % end of output file type
% Obtain omnidirectional PDP information for this simulation run
OmniPDPInfo(CIRIdx,1:5) = [TRDistance Pr_dBm-polDcm PL_dB+polDcm RMSDelaySpread,KFactor];
if PL_dB > DR
    OmniPDPInfo(CIRIdx,2:5) = NaN;
end
powerSpectrumDB = powerSpectrum;
powerSpectrumDB(:,2) = 10.*log10(powerSpectrumDB(:,2));
if CIRIdx == 1
DirPDPInfo(1:nPath(CIRIdx),1:11,PolIdx) = [CIRIdx*ones(nPath(CIRIdx),1) TRDistance*ones(nPath(CIRIdx),1) powerSpectrumDB PL_dir DirRMSDelaySpread];
else
    DirPDPInfo(sum(nPath(1:CIRIdx-1))+1:sum(nPath(1:CIRIdx)),1:11,PolIdx) = ...
        [CIRIdx*ones(nPath(CIRIdx),1) TRDistance*ones(nPath(CIRIdx),1) powerSpectrumDB PL_dir DirRMSDelaySpread];
end
PL_dir_best(CIRIdx,PolIdx) = min(PL_dir);
if PL_dir_best(CIRIdx,PolIdx) >= DR
    PL_dir_best(CIRIdx,PolIdx) = 0;
end
    end % end of PolIdx
%% Processing bar update
Count = Count+1; Perc=Count/Length; 
    javaMethodEDT('setValue', jBarHandle, Count);
    pause(0.2);
end% end of CIRIdx

if exist('hhandle','var') == 1
delete(hhandle); 
end
delete(txtPb);

%% Plot Fig 6: omni and dir PL scatter plots
for PolIdxx = 1:numPol
    indOmniPL = find(~isnan(OmniPDPInfo(:,3,PolIdxx)));
    IndDirNaN = find(DirPDPInfo(:,4,PolIdxx)<=Th);
    DirPDPInfo(IndDirNaN,3:11,PolIdxx) = NaN;
    indDirPL = find(~isnan(DirPDPInfo(:,10,PolIdxx)));
    omniDist = OmniPDPInfo(indOmniPL,1,PolIdxx); 
    omniPL = OmniPDPInfo(indOmniPL,3,PolIdxx);
    dirDist = DirPDPInfo(indDirPL,2,PolIdxx);
    dirPL = DirPDPInfo(indDirPL,10,PolIdxx);
    if PolIdxx == 1
        FigVisibility = 'on';
    else
        FigVisibility = 'off';
    end

    h7 = plotPL(FigVisibility,FSPL,omniPL,omniDist,dirPL,dirDist,PL_dir_best(:,PolIdxx),f,sceType,envType,d0,theta_3dB_TX,...
        phi_3dB_TX,TX_Dir_Gain_Mat,theta_3dB_RX,phi_3dB_RX,RX_Dir_Gain_Mat,Th);
    saveas(h7,[outputFolder,'PathLossPlot.png']); 
    if strcmp(fileType,'Text File') == true
        % Save OmniPDPInfo as .txt file
        file_name = ['OmniPDPInfo','_',polMod{PolIdxx,2},'.txt'];
        fid = fopen([outputFolder,file_name],'wt');
        fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t',...
            'T-R Separation Distance (m)','Received Power (dBm)','Path Loss (dB)','RMS Delay Spread (ns)','K-Factor (dB)'); 
        fprintf(fid,'\n%15.1f\t%25.1f\t%15.1f\t%15.1f\t%20.1f',OmniPDPInfo(:,:,PolIdxx).'); 
        fclose(fid);
        % Save DirPDPInfo as .txt file
        file_name = ['DirPDPInfo','_',polMod{PolIdxx,2},'.txt'];
        fid = fopen([outputFolder,file_name],'wt');
        fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t',...
            'Simulation Run Number','T-R Separation Distance (m)','Time Delay (ns)','Received Power (dBm)','Phase (rad)',...
            'Azimuth AoD (degree)','Elevation AoD (degree)','Azimuth AoA (degree)','Elevation AoA (degree)',...
            'Path Loss (dB)','RMS Delay Spread (ns)'); 
        fprintf(fid,'\n%15.1f\t%15.1f\t%20.0f\t%17.1f\t%13.1f\t%15.0f\t%17.1f\t%17.1f\t%17.0f\t%17.1f\t%17.1f',...
            DirPDPInfo(:,:,PolIdxx).'); 
        fclose(fid);

    elseif strcmp(fileType,'MAT File') == true 
        omnipdp_content = OmniPDPInfo(:,:,PolIdxx);
        dirpdp_content = DirPDPInfo(:,:,PolIdxx);
        save([outputFolder,'OmniPDPInfo','_',polMod{PolIdxx,2}],'omnipdp_content'); 
        save([outputFolder,'DirPDPInfo','_',polMod{PolIdxx,2}],'dirpdp_content');

    elseif strcmp(fileType,'Both Text and MAT File') == true
            % Save OmniPDPInfo as .txt file
        file_name = ['OmniPDPInfo','_',polMod{PolIdxx,2},'.txt'];
        fid = fopen([outputFolder,file_name],'wt');
        fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t',...
            'T-R Separation Distance (m)','Received Power (dBm)','Path Loss (dB)','RMS Delay Spread (ns)','K-Factor (dB)'); 
        fprintf(fid,'\n%15.1f\t%25.1f\t%15.1f\t%15.1f\t%20.1f',OmniPDPInfo(:,:,PolIdxx).'); 
        fclose(fid);
        % Save DirPDPInfo as .txt file
        file_name = ['DirPDPInfo','_',polMod{PolIdxx,2},'.txt'];
        fid = fopen([outputFolder,file_name],'wt');
        fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t',...
            'Simulation Run Number','T-R Separation Distance (m)','Time Delay (ns)','Received Power (dBm)','Phase (rad)',...
            'Azimuth AoD (degree)','Elevation AoD (degree)','Azimuth AoA (degree)','Elevation AoA (degree)',...
            'Path Loss (dB)','RMS Delay Spread (ns)'); 
        fprintf(fid,'\n%15.1f\t%15.1f\t%20.0f\t%17.1f\t%13.1f\t%15.0f\t%17.1f\t%17.1f\t%17.0f\t%17.1f\t%17.1f',...
            DirPDPInfo(:,:,PolIdxx).'); 
        fclose(fid);
        omnipdp_content = OmniPDPInfo(:,:,PolIdxx);
        dirpdp_content = DirPDPInfo(:,:,PolIdxx);
        save([outputFolder,'OmniPDPInfo','_',polMod{PolIdxx,2}],'omnipdp_content'); 
        save([outputFolder,'DirPDPInfo','_',polMod{PolIdxx,2}],'dirpdp_content');

    end
end % End of PolIdxx

if strcmp(fileType,'Text File') == true
file_name = ['BasicParameters.txt'];
fid = fopen([outputFolder,file_name],'wt');
if strcmp(sceType,'RMa') == true
fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t',...
    'Frequency (GHz)','Bandwidth (MHz)','TXPower (dBm)',...
    'Environment','Scenario','TXHeight',...
    'Pressure (mBar)','Humidity','Temperature (Celsius)','RainRate (mm/hr)','Polarization','Foliage','DistFol (m)','FoliageAttenuation (dB)',...
    'TxArrayType','RxArrayType','#TXElements','#RXElements','TXAziHPBW','TXElvHPBW','RXAziHPBW','RXElvHPBW'); 
fprintf(fid,'\n%12.1f\t%12.0f\t%12.1f\t%12s\t%13s\t%13.2f\t%13.2f\t%12.0f\t%12.1f\t%12.1f\t%12s\t%12s\t%12.1f\t%12.0f\t%12s\t%12s\t%12.0f\t%12.0f\t%12.0f\t%12.0f\t%12.0f\t%12.0f',...
    f,RFBW,TXPower,envType,sceType,h_BS,p,u,temp,RR,Pol,Fol,dFol,folAtt,...
    TxArrayType,RxArrayType,Nt,Nr,theta_3dB_TX,phi_3dB_TX,theta_3dB_RX,phi_3dB_RX);
else
    fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t',...
    'Frequency (GHz)','Bandwidth (MHz)','TXPower (dBm)',...
    'Environment','Scenario',...
    'Pressure (mBar)','Humidity','Temperature (Celsius)','RainRate (mm/hr)','Polarization','Foliage','DistFol (m)','FoliageAttenuation (dB)',...
    'TxArrayType','RxArrayType','#TXElements','#RXElements','TXAziHPBW','TXElvHPBW','RXAziHPBW','RXElvHPBW'); 
fprintf(fid,'\n%12.1f\t%12.0f\t%12.1f\t%12s\t%13s\t%13.2f\t%12.0f\t%12.1f\t%12.1f\t%12s\t%12s\t%12.1f\t%12.0f\t%12s\t%12s\t%12.0f\t%12.0f\t%12.0f\t%12.0f\t%12.0f\t%12.0f',...
    f,RFBW,TXPower,envType,sceType,p,u,temp,RR,Pol,Fol,dFol,folAtt,...
    TxArrayType,RxArrayType,Nt,Nr,theta_3dB_TX,phi_3dB_TX,theta_3dB_RX,phi_3dB_RX);
end
fclose(fid);
elseif strcmp(fileType,'MAT File') == true 
    BasicParameters = struct;
    BasicParameters.Frequency = f; BasicParameters.Bandwidth = RFBW; BasicParameters.TXPower = TXPower;
    BasicParameters.Environment = envType; BasicParameters.Scenario = sceType;
    if strcmp(sceType,'RMa') == true
    BasicParameters.TXHeight = h_BS;
    end
    BasicParameters.Pressure = p; BasicParameters.Humidity = u;
    BasicParameters.Temperature = temp; BasicParameters.RainRate = RR;
%     BasicParameters.Polarization = Pol; 
    BasicParameters.Foliage = Fol;
    BasicParameters.DistFol = dFol; BasicParameters.FoliageAttenuation = folAtt;
    BasicParameters.TxArrayType = TxArrayType; BasicParameters.RxArrayType = RxArrayType;
    BasicParameters.NumberOfTxAntenna = Nt; BasicParameters.NumberOfRxAntenna = Nr;
    BasicParameters.NumberOfTxAntennaPerRow = Wt; BasicParameters.NumberOfRxAntennaPerRow = Wr;
    BasicParameters.TxAntennaSpacing = dTxAnt; BasicParameters.RxAntennaSpacing = dRxAnt; 
    BasicParameters.TxAzHPBW = theta_3dB_TX; BasicParameters.TxElHPBW = phi_3dB_TX; 
    BasicParameters.RxAzHPBW = theta_3dB_RX; BasicParameters.RxElHPBW = phi_3dB_RX;
save([outputFolder,'BasicParameters.mat'],'BasicParameters');
elseif strcmp(fileType,'Both Text and MAT File') == true
    BasicParameters = struct;
    BasicParameters.Frequency = f; BasicParameters.Bandwidth = RFBW; BasicParameters.TXPower = TXPower;
    BasicParameters.Environment = envType; BasicParameters.Scenario = sceType;
    if strcmp(sceType,'RMa') == true
    BasicParameters.TXHeight = h_BS;
    end
    BasicParameters.Pressure = p; BasicParameters.Humidity = u;
    BasicParameters.Temperature = temp; BasicParameters.RainRate = RR;
%     BasicParameters.Polarization = Pol; 
    BasicParameters.Foliage = Fol;
    BasicParameters.DistFol = dFol; BasicParameters.FoliageAttenuation = folAtt;
    BasicParameters.TxArrayType = TxArrayType; BasicParameters.RxArrayType = RxArrayType;
    BasicParameters.NumberOfTxAntenna = Nt; BasicParameters.NumberOfRxAntenna = Nr;
    BasicParameters.NumberOfTxAntennaPerRow = Wt; BasicParameters.NumberOfRxAntennaPerRow = Wr;
    BasicParameters.TxAntennaSpacing = dTxAnt; BasicParameters.RxAntennaSpacing = dRxAnt; 
    BasicParameters.TxAzHPBW = theta_3dB_TX; BasicParameters.TxElHPBW = phi_3dB_TX; 
    BasicParameters.RxAzHPBW = theta_3dB_RX; BasicParameters.RxElHPBW = phi_3dB_RX;
    save([outputFolder,'BasicParameters.mat'],'BasicParameters');
file_name = ['BasicParameters.txt'];
fid = fopen([outputFolder,file_name],'wt');
if strcmp(sceType,'RMa') == true
fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t',...
    'Frequency (GHz)','Bandwidth (MHz)','TXPower (dBm)',...
    'Environment','Scenario','TXHeight',...
    'Pressure (mBar)','Humidity','Temperature (Celsius)','RainRate (mm/hr)','Polarization','Foliage','DistFol (m)','FoliageAttenuation (dB)',...
    'TxArrayType','RxArrayType','#TXElements','#RXElements','TXAziHPBW','TXElvHPBW','RXAziHPBW','RXElvHPBW'); 
fprintf(fid,'\n%12.1f\t%12.0f\t%12.1f\t%12s\t%13s\t%13.2f\t%13.2f\t%12.0f\t%12.1f\t%12.1f\t%12s\t%12s\t%12.1f\t%12.0f\t%12s\t%12s\t%12.0f\t%12.0f\t%12.0f\t%12.0f\t%12.0f\t%12.0f',...
    f,RFBW,TXPower,envType,sceType,h_BS,p,u,temp,RR,Pol,Fol,dFol,folAtt,...
    TxArrayType,RxArrayType,Nt,Nr,theta_3dB_TX,phi_3dB_TX,theta_3dB_RX,phi_3dB_RX);
else
    fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t',...
    'Frequency (GHz)','Bandwidth (MHz)','TXPower (dBm)',...
    'Environment','Scenario',...
    'Pressure (mBar)','Humidity','Temperature (Celsius)','RainRate (mm/hr)','Polarization','Foliage','DistFol (m)','FoliageAttenuation (dB)',...
    'TxArrayType','RxArrayType','#TXElements','#RXElements','TXAziHPBW','TXElvHPBW','RXAziHPBW','RXElvHPBW'); 
fprintf(fid,'\n%12.1f\t%12.0f\t%12.1f\t%12s\t%13s\t%13.2f\t%12.0f\t%12.1f\t%12.1f\t%12s\t%12s\t%12.1f\t%12.0f\t%12s\t%12s\t%12.0f\t%12.0f\t%12.0f\t%12.0f\t%12.0f\t%12.0f',...
    f,RFBW,TXPower,envType,sceType,p,u,temp,RR,Pol,Fol,dFol,folAtt,...
    TxArrayType,RxArrayType,Nt,Nr,theta_3dB_TX,phi_3dB_TX,theta_3dB_RX,phi_3dB_RX);
end
fclose(fid);
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Alternate End %%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

end

end

