function J = current_PV(V,photoabsorber,pvID)

% J = currentDensity(V,E_g,photon_energy_eV,photon_flux_eV,T,f_g,J_g)
% photoabsorber.E_g

%% Constants
c = 299792458; % Speed of light [m s-1]
h = 6.626e-34; % Planck constant [m2 kg s-1]
q = 1.602176565e-19; % Elementary charge [C]
k = 1.38064852e-23; % Boltzmann constant [m2 kg s-2 K-1]
g = photoabsorber.f_g*2*pi/(c^2*h^3);

%% Calculate current density

% switch photoabsorber.model{pvID}
%     case 'IdealDiode'
        CurrentDensity = photoabsorber.J_g(pvID) - photoabsorber.J_o(pvID)*(exp(V*q/(k*photoabsorber.T))-1);
% end

%% Calculate current per unit input area

J = CurrentDensity*photoabsorber.Area(pvID);

end