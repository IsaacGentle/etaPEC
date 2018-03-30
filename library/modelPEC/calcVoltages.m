function [photoabsorber,electrolysis] = calcVoltages(photoabsorber,electrolysis)
% This function calculates the OCP and MPP for the system of photoabsorbers

%% Constants
c = 299792458; % [m s-1]
h = 6.626e-34; % [m2 kg s-1]
q = 1.602176565e-19; % [C]
k = 1.38064852e-23; % Boltzmann constant [m2 kg s-2 K-1]

%% Calculate minimum voltage required to split water
electrolysis.Voltage = electrolysis.E_rxn*electrolysis.num_electrolysers + electrolysis.V_o;


%% Calculate OCP and MPP voltages for each of the branches

% Set up maximum power point function
function x = findMaxPowerPoint(V,photoabsorber,pvID)
    J = current_PV(V,photoabsorber,pvID);
    P = J*V;
    x = -P;
end

% For every photoabsorber calculate the OCP and the MPP
for i = 1:photoabsorber.num
    
    % Quick approximation for V_oc
    g = photoabsorber.f_g(i)*2*pi/(c^2*h^3);
    Eg = photoabsorber.Eg(i);
    
    % Generation current
    fun_g = @(Eg) interp1(photoabsorber.photon_energy_eV,photoabsorber.Light{i},Eg,'linear');
    
    if Eg<photoabsorber.photon_energy_eV(1) && Eg>photoabsorber.photon_energy_eV(end)
        photoabsorber.J_g(i) = q*integral(fun_g,Eg,photoabsorber.photon_energy_eV(1));
    else
        photoabsorber.J_g(i) = 0;
    end
    
    % Recombination current
    fun_r = @(E) E.^2./(exp(E/(k*photoabsorber.T))-1);
    photoabsorber.J_o(i) = q*g*integral(@(E)fun_r(E),Eg*q,10*q);
    
    if Eg<photoabsorber.photon_energy_eV(1) && Eg>photoabsorber.photon_energy_eV(end)
        V_oc(i) = (k*photoabsorber.T/q)*log(photoabsorber.J_g(i)/photoabsorber.J_o(i) + 1);
    else
        V_oc(i) = 0;
    end
        
    % Crude approximation of max power point as guess
    V_mpp_crude(i) = 0.9*V_oc(i); 
    

    V_mpp(i) = fminsearch(@(V) findMaxPowerPoint(V,photoabsorber,i), ...
        V_mpp_crude(i));
    J_mpp(i) = current_PV(V_mpp(i),photoabsorber,i);
    
end

% For every branch
for i = 1:photoabsorber.b-1
    if photoabsorber.branchID(i) > 0
        V_oc_branch(i) = V_oc(photoabsorber.branchID(i));
        V_mpp_branch(i) = V_mpp(photoabsorber.branchID(i));
        J_mpp_branch(i) = J_mpp(photoabsorber.branchID(i));
    else
        % no photoabsorber on this banch so
        V_oc_branch(i) = 0;
        V_mpp_branch(i) = 0;
        J_mpp_branch(i) = 0;
    end
end

% Calculate the maximum V_oc that that system is capable of
s = photoabsorber.config(:,1);
t = photoabsorber.config(:,2);
G_V_oc = digraph(s,t,V_oc_branch);
n = numnodes(G_V_oc);
[~,photoabsorber.V_oc_total] = shortestpath(G_V_oc,1,n);

% Put these in the right order
photoabsorber.V_oc_graphBranch = V_oc_branch(photoabsorber.graphOrder);
photoabsorber.V_mpp_graphBranch = V_mpp_branch(photoabsorber.graphOrder);
photoabsorber.J_mpp_graphBranch = J_mpp_branch(photoabsorber.graphOrder);


end