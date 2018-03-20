function F = PV_efficiency_minfun(LoadVoltage, light,photoabsorber,electrolysis,options)
% Minimisation function to calculate the PV_efficiency at maximum power
% point

electrolysis.Voltage = LoadVoltage;

% scaling factors for units
sf.i = max(photoabsorber.J_g.*photoabsorber.Area);
sf.v = electrolysis.Voltage;
sf.e = sf.v; % must be the same as units same

% Set up function for root finding 
fun = @(x) eqSys(x,electrolysis,photoabsorber,sf);

% Construct intial guess
i_guess = [photoabsorber.J_mpp_graphBranch,max(photoabsorber.J_mpp_graphBranch)];
v_guess = [-photoabsorber.V_mpp_graphBranch,electrolysis.Voltage]';

% Best guess for e
s = photoabsorber.config(:,1); % Source
t = photoabsorber.config(:,2); % Target
G_e = digraph(s,t); % Acyclic graph (without electrolyser link)
IncidenceMat_e = incidence(G_e);
A2 = -IncidenceMat_e(2:end,:);
fun_eGuess = @(e) -photoabsorber.V_mpp_graphBranch' - A2'*e; % Minimise residuals from this function
options_lsqnonlin = optimoptions(@lsqnonlin,'Display','off');
e_guess = lsqnonlin(fun_eGuess,repmat(1,numnodes(G_e)-1,1),[],[],options_lsqnonlin);

% scale intial guess
x0 = [i_guess/sf.i,v_guess'/sf.v,e_guess'/sf.e];

% Solve for x, F(x) = 0
[x,fval,exitflag,output,JAC] = fsolve(fun,x0,options);

% Unscale x and extract data (J and v)    
b = photoabsorber.b;
n = photoabsorber.n;
J = x(b)*sf.i;
v_branches = -x(b+1:2*b)*sf.v;
e = x(2*b+1:end)*sf.e;
for m = 1:photoabsorber.num
    branch_num = find(photoabsorber.branchID == m);
    V(m) = v_branches(branch_num);
end


P_eff = J(end)*LoadVoltage/light.P_solar; % Power
F = -P_eff;

end