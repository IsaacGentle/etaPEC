function [STF,J,V,exitflag] = modelPEC(light,photoabsorber,electrolysis,varargin)
% Ouptuts the Solar To Fuel efficiency for a given photoelectrochemical
% cell configuration

%% Parse input
defaultPlotSpectrum_wl = false;
defaultPlotSpectrum_eV = false;
defaultPlotOpticalGraph = false;
defaultPlotElectricalGraph = false;
defaultPlotElectricalGraphResult = true;
expectedfsolve_PlotFcn = {'none','optimplotx','optimplotfunccount','optimplotfval','optimplotstepsize','optimplotfirstorderopt'};
p = inputParser;
addRequired(p,'light',@isstruct);
addRequired(p,'photoabsorber',@isstruct);
addRequired(p,'electrolysis',@isstruct);
addParameter(p,'PlotSpectrum_wl',defaultPlotSpectrum_wl,@islogical);
addParameter(p,'PlotSpectrum_eV',defaultPlotSpectrum_eV,@islogical);
addParameter(p,'PlotOpticalGraph',defaultPlotOpticalGraph,@islogical);
addParameter(p,'PlotElectricalGraph',defaultPlotElectricalGraph,@islogical);
addParameter(p,'PlotElectricalGraphResult',defaultPlotElectricalGraphResult,@islogical);
addParameter(p,'fsolve_PlotFcn','none',@(x) any(validatestring(x,expectedfsolve_PlotFcn)));
parse(p,light,photoabsorber,electrolysis,varargin{:});

%% Constants and preliminary calculations
c = 299792458; % [m s-1]
h = 6.626e-34; % [m2 kg s-1]
q = 1.602176565e-19; % [C]
k = 1.38064852e-23; % Boltzmann constant [m2 kg s-2 K-1]

photoabsorber.num = length(find(photoabsorber.branchID)); % Number of photoabsorbers [-]
photoabsorber.ThresholdWl = h*c./photoabsorber.Eg*10^9.*q; % [nm]

%% Calculate light incident to each absorber

calcLight_nameValuePair = {'PlotSpectrum_wl',p.Results.PlotSpectrum_wl, ...
    'PlotSpectrum_eV',p.Results.PlotSpectrum_eV, ...
    'PlotOpticalGraph',p.Results.PlotOpticalGraph};

photoabsorber = calcLight(light,photoabsorber,calcLight_nameValuePair{:});

%% Calculate photoabsorber electrical configuration

% Returns graph structure and the reduced incidence matrix etc.
photoabsorber = calcElectricalConfig(photoabsorber,'PlotElectricalGraph',p.Results.PlotElectricalGraph);

%% Work out voltages
% used to determine maximum open circuit potential and mpp for intial guess

[photoabsorber,electrolysis] = calcVoltages(photoabsorber,electrolysis);

%% Solve system 
% Compare sum of V_oc to voltage required to work out whether electrolysis is
% possible

if photoabsorber.V_oc_total > electrolysis.Voltage % electrolysis possible
    
    % Solve for J and V for each branch
    solvePECsystem_nameValuePair = { ...
        'PlotElectricalGraphResult',p.Results.PlotElectricalGraphResult, ...
        'fsolve_PlotFcn',p.Results.fsolve_PlotFcn};
    [J,V,exitflag] = solvePECsystem(photoabsorber,electrolysis,solvePECsystem_nameValuePair{:});

    % Calculate solar to fuel efficiency
    STF = J*electrolysis.num_electrolysers*electrolysis.E_rxn/light.P_solar;

else % electrolysis not possible (V_oc_total less than needed)
    J = nan;
    for i = 1:photoabsorber.num
        V(i) = nan;
    end
    STF = nan;
    exitflag = 0.5;
end

end