close all;
clear all;
clc

% fprintf('Initial device temperature = %0.0f degC\n',Tinit)
% fprintf('Ambient temperature = %0.0f degC\n',Twater)

%Drive parameters
 


VDC=1450;     % DC Voltage 
VLLrms=715/1;
fout=60;      % Fundamental frequency 
PF= 1;        % Power factor
fsw=45*fout;     % Switching frequency 57*50 @ Discharge ;45*60@ Charge
Irms=3658;    % Fundamental RMS current 
Pout=sqrt(3)*VLLrms*Irms*PF ;% Power calculations 
leadlag=1; %1 for voltage leads current, -1 for voltage lags current
Wn = 2*pi*fout;


Filter.C = 55.7e-6;
Filter.R =22e-3;
Filter.L =72e-6/2;
Filter.Lr = 0.5e-3*0.5;
n_ss_cycles =1;
% open('FLEXINVERTER_3LNPP_GF_R00.slx')
% plsteadystate('FLEXINVERTER_3LNPP_FilterDesign_R00/steadystate',...
%             'TimeSpan',1/fout,...
%             'TStart',0,...
%             'Tolerance',1e-4,...
%             'MaxIter',20,...
%             'Display','iteration',...
%             'HiddenStates','error',...
%             'FinalStateName','xSteadyState',...
%             'NCycles',n_ss_cycles);
%    
%% RIU Transformer : LV to MV Transformer 6%SC
TF.S                = 4.7e6/(6.9/100);       %[kVA] grid short circuit power
TF.XR               = 10;          % X/R short circuit ratio
TF.Z                = VLLrms^2/TF.S;
TF.L                = (1/Wn)*((TF.Z*TF.XR)/(sqrt(1+TF.XR^2)));
TF.R                =  Wn *TF.L/TF.XR;
%% High Voltage TF parameters : MV to HV Transformer 12% SC

HV_TF.S                = 4.7e6/(12/100);       %[kVA] grid short circuit power
HV_TF.XR               = 10;          % X/R short circuit ratio
HV_TF.Z                = VLLrms^2/HV_TF.S;
HV_TF.L                = (1/Wn)*((HV_TF.Z*HV_TF.XR)/(sqrt(1+HV_TF.XR^2)));
HV_TF.R                =  Wn*HV_TF.L/HV_TF.XR;



%% Grid Parameters 
SCR = 2500*1; %20;% 1.5; % Grid short circuit ratio; all simulation run for 20

Supply_Impedance_Ratio = 7; % X_grid by R_gird
Zg = VLLrms /(sqrt(3)*Irms*SCR);
Lg = (1/(Wn))*((Zg*Supply_Impedance_Ratio)/(sqrt(1+Supply_Impedance_Ratio^2)));
Lg_MicroH = Lg * 1000000;
Rg = Wn * Lg/Supply_Impedance_Ratio;
Rg_mhm=Rg * 1000; 
No_CAP = 6;
Grid_side_inductance    = Lg+HV_TF.L+TF.L;
L_effective             = (Grid_side_inductance*Filter.L)/(Grid_side_inductance+Filter.L);
F_res                   = 1/(2*pi*sqrt(L_effective*Filter.C*No_CAP*3));

BattSeries.R        = 1*10e-3; % typical 100e-3
DC.C                = 1.2e-3*18*2; % Half 
SlowDisCharging.R   = 65e3; % Check once again in SLD

Diode_Ron           = 1e-3;
IGBT_Ron            = 1e-3;
Ton_Delay           = 3e-6; % Dead Time 
PE_Delay            = 1;    % as of know , it is keeping for 1 ( adding delay in Pulses )

ESL                 = 60e-9;  % Equivalent Series inductance of DC Capacitor  
ESR                 = 1.2e-3;  % Equivalent Series inductance of DC Capacitor 

DC.ESL              = ESL/(18*2); % Effective ESL
DC.ESR              = ESR/(18*2); % Effective ESR

Delay = 0.86e-3;

Time_Sq = [0 (1/(2*fout)) (1/fout)]; 

% Harmonic PCC point is on LV Side and HV Side TF: Completed
% Resonance frequency 
% current ripple @ PE 
% Current harmonics 
% Resonance frequency 
% Power
%% 60Hz Simulations 
% 0.76 theta @ Charge 900VAC & -0.78 @ Discharge, 1400VDC , 2659 :SCR 25 
%0.8 theta @ Charge 990VAC & -0.83 @ Discharge, 1400VDC , 2659 :SCR 25

%0.66 theta @ Charge 900VAC & -0.68 @ Discharge, 1400VDC , 2659 :SCR 2500 
%0.xx theta @ Charge 990VAC & -0.xx @ Discharge, 1400VDC , 2659 :SCR 2500

%2.52 theta @ Charge 900VAC & -2.55 @ Discharge, 1400VDC , 2659 :SCR 1.5 
%0.xx theta @ Charge 990VAC & -0.xx @ Discharge, 1400VDC , 2659 :SCR 1.5

%% MVA2_60Hz Simulation 
% 35C :-1.205 theta for Discharge , 690VAC , 1265V( 1310VDC @ Battery
% terminal) and -1.23 @ 1125V( 1165VDC) ;  -1.25 @ 980 ( 1040VDC)
% 40C : -1.16 theta for Discharge , 690VAC , 1265V( 1310VDC @ Battery
% terminal) and -1.18 @ 1125V( 1165VDC) ;  -1.18 @ 980 ( 1040VDC)
% 45C :
% 50C :

%% 50Hz simulation 
% 0.875 Theta for charging @900VAC,1400VDC,2659A & DIcharging -0.903 @
% SCR-25 ; 0.875 theta @ Charging GD PWM.. 
% 0.92 Theta for charging @ 990VAC ,1400VDC,2657A & -0.96@ SCR-25
% 0.92 Theta @ Charge GD PWM

% 0.74 Theta for charging @900VAC,1400VDC,2659A & DIcharging -0.77 @ SCR-2500
% 0.738 Theta @ GD PWM Charge_DC Bal & 0.755 @ GD No DC
% 0.79 Theta for charging @ 990VAC ,1400VDC,2657A & -0.84@ SCR-2500
% 0.79 Theta @ GD DC_Bal &0.80 @GD No Bal

% 2.97 Theta for charging @900VAC,1400VDC,2659A & DIcharging -3.03 @ SCR-1.5 
%3.035 Theta for charging @ 990VAC ,1400VDC,2657A & -3.10@ SCR-1.5

