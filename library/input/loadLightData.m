function light = loadLightData(light,varargin)
% This function takes an input spectral data and processes it
% Filename must refer to a .csv file where the first column is the
% wavelength in [nm] and the second is the spectral irradience in
% [W m-2 nm-1]

%% Parse input
defaultInterpolation = 'on';
defaultSpacing = 0.1;
defaultMethod = 'linear';
defaultP_solarMethod = 'integrate';
expectedInterpolation = {'on','off'};
expectedMethod = {'linear','nearest','next','previous','pchip','cubic','v5cubic','makima','spline'};
expectedP_solarMethod = {'integrate','define'};
p = inputParser;
addRequired(p,'light',@isstruct);
addParameter(p,'Interpolation',defaultInterpolation,@(x) any(validatestring(x,expectedInterpolation)));
addParameter(p,'Spacing',defaultSpacing,@(x) isnumeric(x) && isscalar(x) && (x > 0));
addParameter(p,'Method',defaultMethod,@(x) any(validatestring(x,expectedMethod)));
addParameter(p,'P_solarMethod',defaultP_solarMethod,@(x) any(validatestring(x,expectedP_solarMethod)));
addParameter(p,'P_solar',-1,@(x) isnumeric(x) && isscalar(x) && x>0)
parse(p,light,varargin{:});

%% Load data from .csv file

% Load data
M = csvread(light.filename);

% Extract data from resulting matrix
wl = M(:,1); % [nm]
I_wl = M(:,2); % [W m-2 nm-1]

% If interpolation is turned on (by default) then interpolate spectral
% irradience
if strcmp(p.Results.Interpolation,'on')
    wl_new =wl(1):p.Results.Spacing:wl(end);
    I_wl_new = interp1(wl,I_wl,wl_new,p.Results.Method);
    wl = wl_new';
    I_wl = I_wl_new';
end
light.wl = wl;
light.I_wl = I_wl;

% Convert wavelength from nm to m
wl_SI = wl/1e9; % [m]

% Constants
c = 299792458; % Speed of light [m s-1]
h = 6.62607004e-34; % Planck constant [m2 kg s-1]
q = 1.602176565e-19; % Elementary charge [C]

% Calculate photon energy in both [J] and [eV]
photon_energy = h*c./wl_SI; % [J]
light.photon_energy_eV = photon_energy/q; % [eV]

% Calculate the spectral irradience per eV [W m-2 eV-1]
I_eV = I_wl*1e-9*q.*wl.^2/(h*c);

% Calculate the photon flux per nm and per eV
photon_flux_wl = I_wl./photon_energy;
light.photon_flux_eV = I_eV./photon_energy;

% Check to see whether P_solar has been specified
if strcmp(p.Results.P_solarMethod,'integrate')
    % Calculate the incident solar power by integrating solar spectrum
    light.P_solar = trapz(wl,I_wl);
else
    % User specified
	light.P_solar = p.Results.P_solar;
end

end