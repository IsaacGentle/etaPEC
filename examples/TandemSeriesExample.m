%% Example script
% Modelling a tandem PEC device with one electrolyser. Electrically in
% series and optically in series.

%% Preliminaries
clear
clc
addpath(genpath('..')); % Add folders above so it can access the functions from the library

%% Configuration

% Light
light.filename = 'AM15G.csv'; % This file is found in the data folder
options_loadLight = {'Interpolation','on', ...
                     'Spacing',0.1, ...
                     'Method', 'linear', ...
                     'P_solarMethod', 'integrate'}; % These are optional name pair options
light = loadLightData(light,options_loadLight{:});
light.config = [ ...
    1,2,1;
    2,3,1];
light.nodeID = [0,1,2]; % 
light.Area = [1,1,1]; % Area (relative) of each node

% Photoabosorber information
photoabsorber.config = [1,2;2,3];
photoabsorber.branchID = [1 2]; % Photoabsorber ID for each branch specified in .config
photoabsorber.Eg = [1.6,0.5,]; % Bandgap(s) [eV]
photoabsorber.f_g = [2,1]; % Geometric factor
photoabsorber.T = 298.15; % Device temperature [K]

% Electrolysis information
electrolysis.E_rxn = 1.23; % Cell potential [V]
electrolysis.num_electrolysers = 1; % Number of electroylsers
electrolysis.V_o = 0.0; % Voltage overpotential [V]


%% Run modelPEC script

options = {'PlotSpectrum_wl',false, ...
            'PlotSpectrum_eV',true,...
            'PlotOpticalGraph',true, ...
            'PlotElectricalGraph',true,...
            'PlotElectricalGraphResult',true, ...
            'fsolve_PlotFcn','none'}; % These are optional name pair options

[STF,J,V,exitflag] = modelPEC(light,photoabsorber,electrolysis,options{:});
 
disp(['STF eff. = ',num2str(STF*100),' %'])