 % NYUSIM_MainCode Version 3.0, developed by:
%
% Shihao Ju, Shu Sun, Mathew Samimi - NYU WIRELESS, March 2021

clear; close all; tic
% Set the current folder as the running folder
runningFolder = pwd; 

%% Input parameters (subject to change per users' own needs)
% Carrier frequency in GHz (0.5-100 GHz)
f = 28; freq = num2str(f);
% RF bandwidth in MHz (0-1000 MHz)
RFBW = 800; 
% Operating scenario, can be UMi (urban microcell),UMa (urban macrocell),
% or RMa (Rural macrocell)
sceType = 'InH'; 
% Operating environment, can be LOS (line-of-sight) or NLOS (non-line-of-sight)
envType = 'LOS'; 
% Minimum and maximum T-R separation distance (10-10,000 m)
dmin = 5; dmax = 50; 
% Transmit power in dBm (0-50 dBm)
TXPower = 10;
% Base station height in meters (10-150 m), only used for the RMa scenario
h_BS = 2.5; 
% Barometric Pressure in mbar (1e-5 to 1013.25 mbar)
p = 1013.25; 
% Humidity in % (0-100%)
u = 50; 
% Temperature in degrees Celsius (-100 to 50 degrees Celsius)
temp = 20;
% Rain rate in mm/hr (0-150 mm/hr)
RR = 0; 
% Polarization (Co-Pol, X-Pol, Co/X-Pol, or All-Pol)
Pol = 'Co-Pol';
% Polarization Indicator
AllPolInd = 1;
% Foliage loss (Yes or No)
Fol = 'No'; 
% Distance within foliage in meters (0-dmin)
dFol = 0; 
% Foliage attenuation in dB/m (0-10 dB/m)
folAtt = 0.4;
% O2I penetration loss indicator, '1' - O2I loss, '0' - no O2I loss
o2iLoss = 'No';
% O2I penetration loss type, 'Low loss' or 'High loss'
o2iType = 'High Loss';
% Number of receiver locations, which is also the number of simulation runs (1-10,000)
N = 2; 
% Transmit array type (ULA or URA)
TxArrayType = 'ULA'; 
% Receive array type (ULA or URA)
RxArrayType = 'ULA'; 
% Number of transmit antenna elements (1-128)
Nt = 16; 
% Number of receive antenna elements (1-64)
Nr = 4; 
% Transmit antenna spacing in wavelengths (0.1-100)
dTxAnt = 0.5; 
% Receive antenna spacing in wavelengths (0.1-100)
dRxAnt = 0.5;
% Number of transmit antenna elements per row for URA
Wt = 4; 
% Number of receive antenna elements per row for URA
Wr = 2; 
% Transmit antenna azimuth half-power beamwidth (HPBW)in degrees (7-360 degrees)
theta_3dB_TX = 10; 
% Transmit antenna elevation HPBW in degrees (7-45 degrees)
phi_3dB_TX = 10;
% Receive antenna azimuth HPBW in degrees (7-360 degrees)
theta_3dB_RX = 10; 
% Receive antenna elevation HPBW in degrees (7-45 degrees)
phi_3dB_RX = 10;

%%% New Parameter for Cross-polarization simulations

%%% Create an output folder 
if exist('NYUSIM_OutputFolder','dir')==0 
    mkdir NYUSIM_OutputFolder
end
%%% Channel Model Parameters
% Free space reference distance in meters
d0 = 1; 
% Speed of light in m/s
c = physconst('LightSpeed');

%%%%%% Change in NYUSIM 3.0 %%%%%%
% Input channel parameters for indoor scenario will be considered
% frequency-depedent since the large span of the two measured frequencies,
% 28 GHz and 140 GHz. The frequency dependency is realized in the function
% calPar.m, where a linear interpolation is used for frequencies between 28
% GHz and 140 GHz while paramater values for frequencies below 28 GHz and
% above 140 GHz are equal to those values at 28 GHz and 140 GHz,
% respectively. More explanation can be found in the NYUSIM 3.0 User Manual.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set channel parameters according to the scenario
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
    hbIdc = 'Off';
    default = 'Yes';
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
    powerSpectrumDir = horzcat(timeArray_Dir,multipathArray_Dir,powerSpectrumOld(:,3:7));
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
saveas(h1,['./NYUSIM_OutputFolder/AOD_Run',num2str(CIRIdx),'_',polStr,'.png']);
saveas(h2,['./NYUSIM_OutputFolder/AOA_Run',num2str(CIRIdx),'_',polStr,'.png']); 
saveas(h3,['./NYUSIM_OutputFolder/OmniPDP_Run',num2str(CIRIdx),'_',polStr,'.png']); 
saveas(h4,['./NYUSIM_OutputFolder/DirPDP_Run',num2str(CIRIdx),'_',polStr,'.png']);
saveas(h5,['./NYUSIM_OutputFolder/SmallScalePDP_Run',num2str(CIRIdx),'_',polStr,'.png']);
end

%%
OmniPDP = [timeArray,10.*log10(multipathArray)];
clear indNaN; indNaN = find(10.*log10(multipathArray)<=Th);
OmniPDP(indNaN,:) = NaN;
% Close the figure files for all simulation runs except the first one
if CIRIdx > 1
    close(h1); close(h2); close(h3); close(h4); close(h5);
end
%%% Save output data on directional information in both .txt and .mat
%%% formats for each simulation run
SNames = fieldnames(AOD_LobePowerSpectrum); 
for m = 1:numberOfAODLobes
    dlmwrite(['./NYUSIM_OutputFolder/AODLobePowerSpectrum' sprintf('%d',CIRIdx) '_' polStr '_Lobe' sprintf('%d',m) '.txt'],...
        AOD_LobePowerSpectrum.(SNames{m}),'delimiter', '\t', 'newline', 'pc');
    save(['./NYUSIM_OutputFolder/AODLobePowerSpectrum' sprintf('%d',CIRIdx),'_',polStr],'AOD_LobePowerSpectrum');
end
clear SNames m; SNames = fieldnames(AOA_LobePowerSpectrum); 
for m = 1:numberOfAOALobes
    dlmwrite(['./NYUSIM_OutputFolder/AOALobePowerSpectrum' sprintf('%d',CIRIdx) '_' polStr '_Lobe' sprintf('%d',m) '.txt'],...
        AOA_LobePowerSpectrum.(SNames{m}),'delimiter', '\t', 'newline', 'pc');
    save(['./NYUSIM_OutputFolder/AOALobePowerSpectrum' sprintf('%d',CIRIdx),'_',polStr],'AOA_LobePowerSpectrum');
end
dlmwrite(['./NYUSIM_OutputFolder/OmniPDP' sprintf('%d',CIRIdx) '_' polStr '.txt'],OmniPDP,'delimiter', '\t', 'newline', 'pc');
dlmwrite(['./NYUSIM_OutputFolder/DirectionalPDP' sprintf('%d',CIRIdx) '_' polStr '.txt'],DirPDP,'delimiter', '\t', 'newline', 'pc');
Tra = reshape(X,[],1); Delay = reshape(Y,[],1); traPr = reshape(Pr_H,[],1);
smallScalePDP = [Tra Delay traPr];
clear indNaN; indNaN = find(traPr<=Th);
smallScalePDP(indNaN,2:3) = NaN;
dlmwrite(['./NYUSIM_OutputFolder/SmallScalePDP' sprintf('%d',CIRIdx) '_' polStr '.txt'],smallScalePDP,'delimiter', '\t', 'newline', 'pc');
save(['./NYUSIM_OutputFolder/OmniPDP' sprintf('%d',CIRIdx),'_',polStr],'OmniPDP');
save(['./NYUSIM_OutputFolder/DirectionalPDP' sprintf('%d',CIRIdx),'_',polStr],'DirPDP');
save(['./NYUSIM_OutputFolder/SmallScalePDP' sprintf('%d',CIRIdx),'_',polStr],'smallScalePDP');
% Obtain omnidirectional PDP information for this simulation run
OmniPDPInfo(CIRIdx,1:5,PolIdx) = [TRDistance Pr_dBm-polDcm PL_dB+polDcm RMSDelaySpread,KFactor];
if PL_dB > DR
    OmniPDPInfo(CIRIdx,2:5,PolIdx) = NaN;
end
% Convert the received power from linear to dB
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
end % end of CIRIdx
%%
for PolIdxx = 1:numPol
% Find the index of omnidirectional path loss no larger than the dynamic
% range
indOmniPL = find(~isnan(OmniPDPInfo(:,3,PolIdxx)));
% Find the index of directional path loss larger than the dynamic range
IndDirNaN = find(DirPDPInfo(:,4,PolIdxx)<=Th);
DirPDPInfo(IndDirNaN,3:11,PolIdxx) = NaN;
indDirPL = find(~isnan(DirPDPInfo(:,10,PolIdxx)));
% if numel(indOmniPL) ~= 0
% T-R separation distance
omniDist = OmniPDPInfo(indOmniPL,1,PolIdxx); 
% Omnidirectional path loss
omniPL = OmniPDPInfo(indOmniPL,3,PolIdxx);
% end
% T-R separation distance
dirDist = DirPDPInfo(indDirPL,2,PolIdxx);
% Directional path loss
dirPL = DirPDPInfo(indDirPL,10,PolIdxx);
% Smallest directional path loss
% PL_dir_best = PL_dir_best(indDirPL);
%%% Plot omnidirectional and directional path loss for all continuous
%%% simulation runs performed
if PolIdxx == 1
    FigVisibility = 'on';
else
    FigVisibility = 'off';
end
h7 = plotPL(FigVisibility,FSPL,omniPL,omniDist,dirPL,dirDist,PL_dir_best(:,PolIdxx),f,sceType,envType,d0,theta_3dB_TX,...
    phi_3dB_TX,TX_Dir_Gain_Mat,theta_3dB_RX,phi_3dB_RX,RX_Dir_Gain_Mat,Th);
saveas(h7,['./NYUSIM_OutputFolder/PathLossPlot','_',polMod{PolIdxx,2},'.png']); 
%%% Save output data on omnidirectional information in both .txt and .mat
%%% formats for all continuous simulation runs performed
omnipdp_content = OmniPDPInfo(:,:,PolIdxx);
save(['./NYUSIM_OutputFolder/OmniPDPInfo','_',polMod{PolIdxx,2}],'omnipdp_content'); 
%%% Save output data on directional information in both .txt and .mat
%%% formats for all continuous simulation runs performed
dirpdp_content = DirPDPInfo(:,:,PolIdxx);
save(['./NYUSIM_OutputFolder/DirPDPInfo','_',polMod{PolIdxx,2}],'dirpdp_content');

% Save OmniPDPInfo as .txt file
file_name = ['OmniPDPInfo','_',polMod{PolIdxx,2},'.txt'];
fid = fopen(['./NYUSIM_OutputFolder/',file_name],'wt');
fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t',...
    'T-R Separation Distance (m)','Received Power (dBm)','Path Loss (dB)','RMS Delay Spread (ns)','K-Factor (dB)'); 
fprintf(fid,'\n%15.1f\t%25.1f\t%15.1f\t%15.1f\t%20.1f',OmniPDPInfo(:,:,PolIdxx).'); 
fclose(fid);
% Save DirPDPInfo as .txt file
file_name = ['DirPDPInfo','_',polMod{PolIdxx,2},'.txt'];
fid = fopen(['./NYUSIM_OutputFolder/',file_name],'wt');
fprintf(fid, '%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t%12s\t',...
    'Simulation Run Number','T-R Separation Distance (m)','Time Delay (ns)','Received Power (dBm)','Phase (rad)',...
    'Azimuth AoD (degree)','Elevation AoD (degree)','Azimuth AoA (degree)','Elevation AoA (degree)',...
    'Path Loss (dB)','RMS Delay Spread (ns)'); 
fprintf(fid,'\n%15.1f\t%15.1f\t%20.0f\t%17.1f\t%13.1f\t%15.0f\t%17.1f\t%17.1f\t%17.0f\t%17.1f\t%17.1f',...
    DirPDPInfo(:,:,PolIdxx).'); 
fclose(fid);
end % End of PolIdxx

% Basic channel parameters; the parameters have the same definitions as the input parameters
BasicParameters = struct;
BasicParameters.Frequency = f; 
BasicParameters.Bandwidth = RFBW; 
BasicParameters.TXPower = TXPower;
BasicParameters.Environment = envType; 
BasicParameters.Scenario = sceType;
if strcmp(sceType,'RMa') == true
    BasicParameters.TXHeight = h_BS;
end
BasicParameters.Pressure = p; 
BasicParameters.Humidity = u;
BasicParameters.Temperature = temp; 
BasicParameters.RainRate = RR;
% BasicParameters.Polarization = Pol; 
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
% Save BasicParameters as .mat file
save('./NYUSIM_OutputFolder/BasicParameters.mat','BasicParameters');
% Save BasicParameters as .txt file
file_name = 'BasicParameters.txt';
fid = fopen(['./NYUSIM_OutputFolder/',file_name],'wt');
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
%%%
toc