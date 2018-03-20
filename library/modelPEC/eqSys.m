function F = eqSys(x,electrolysis,photoabsorber,sf)

% A = incidence matrix
% n = number of nodes
% b = number of branches

% Unpack variables (x) into currents (i), branch voltages (v), node
% potentials (e) 
n = photoabsorber.n;
b = photoabsorber.b;
i = x(1:b)';
v = x(b+1:2*b)';
e = x(2*b+1:end)';

% KCL
F(1:n-1) = photoabsorber.A*i;

% KVL
F(n:n+b-1) = v - photoabsorber.A'*e;

% Branch equations
% If PV then make i = J_PV(v)
% If no PV then make v = 0
% If electrolyser then v = V_electrolyser
for m = 1:b-1
    if photoabsorber.graphBranchID(m)>0
        
        pvID = photoabsorber.graphBranchID(m);
        
        i_pv = current_PV(-v(m)*sf.v,photoabsorber,pvID)/sf.i;
        
        F(n+b+m-1) = i(m) - i_pv;
%         disp(['i = ',num2str(i(m)),', i_pv = ',num2str(i_pv)])
    else
        F(n+b+m-1) = v(m);
    end
end

F(n+2*b-1) = v(end) - electrolysis.Voltage/sf.v;

end