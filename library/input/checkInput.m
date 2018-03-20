function error = checkInput(light,photoabsorber,electrolysis)

% Check existance of variables
a(1) = exist('light');
a(2) = exist('photoabsorber');
a(3) = exist('electrolysis');
a(4) = isfield(light, 'config');
a(5) = isfield(light, 'nodeID');
a(6) = isfield(light, 'Area');
a(7) = isfield(photoabsorber, 'config');
a(8) = isfield(photoabsorber, 'branchID');
a(9) = isfield(photoabsorber, 'Eg');
a(10) = isfield(photoabsorber, 'f_g');
a(11) = isfield(photoabsorber, 'T');
a(12) = isfield(electrolysis, 'E_rxn');
a(13) = isfield(electrolysis, 'num_electrolysers');
a(14) = isfield(electrolysis, 'V_o');

if ~all(a)
    error.flag = 1;
    error.str = 'Missing input variable';
    return
end

%% Check light input

% Check light
b(1) = isfield(light, 'photon_energy_eV');
b(2) = isfield(light, 'photon_flux_eV');
b(3) = isfield(light, 'P_solar');
if ~all(b)
    error.flag = 1;
    error.str = 'Missing calculated light variables returned by loadLightData';
    return
end

% Check nodeID
if light.nodeID(1) ~= 0
    error.flag = 1;
    error.str = 'nodeID(1) must be equal to 0';
    return
end
% if sum(light.nodeID) ~= factorial(length(light.nodeID)-1)
%     error.flag = 1;
%     error.str = 'nodeID(2:end) cannot have repeating numbers and must contain a permutation of 1,2,3,...,N_photo.';
%     return
% end
if length(light.nodeID)  ~= length(light.Area)
    error.flag = 1;
    error.str = 'nodeID and Area must be the same length';
    return
end

% Check all fractions sum to 1
s = light.config(:,1);  % Source node
t = light.config(:,2); % Target node
w = light.config(:,3); % Split fraction for branch from previous node
G = digraph(s,t); % Generate digraph structure
nn = numnodes(G);
A = sparse(s,t,w,nn,nn);
if sum((and(sum(A,2)~=0,sum(A,2)~=1)))>0
    error.flag = 1;
    error.str = 'check fractions in light configurations';
    return
end

% Check concentration
w2 = light.Area(s)./light.Area(t);
if max(w2)>46200
    error.flag = 1;
    error.str = 'Configuration exceeds maximum concentration. Check specified areas';
    return
end


%% All inputs are checked and they passed! :)

error.flag = 0;
error.str = '';
end