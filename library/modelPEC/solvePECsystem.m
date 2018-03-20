function [J,V,exitflag] = solvePECsystem(photoabsorber,electrolysis,varargin)


%% Parse input
defaultPlotElectricalGraphResult = true;
expectedfsolve_PlotFcn = {'none','optimplotx','optimplotfunccount','optimplotfval','optimplotstepsize','optimplotfirstorderopt'};
p = inputParser;
addRequired(p,'photoabsorber',@isstruct);
addRequired(p,'electrolysis',@isstruct);
addParameter(p,'PlotElectricalGraphResult',defaultPlotElectricalGraphResult,@islogical);
addParameter(p,'fsolve_PlotFcn','none',@(x) any(validatestring(x,expectedfsolve_PlotFcn)));
parse(p,photoabsorber,electrolysis,varargin{:});

%% 

if photoabsorber.num == 1 % Single absorber so no need to solve simultaneous eq.
    
    % Calculate current density
    J = current_PV(electrolysis.Voltage,photoabsorber,1);
    V = electrolysis.Voltage;
    
    if p.Results.PlotElectricalGraphResult
        figure;
        h2 = plot(photoabsorber.G,'Layout','layered','Direction','right');
        labeledge(h2,1:2,[J,J])
        labelnode(h2,1:2,[0,electrolysis.Voltage])
    end
      
    exitflag = 1;
    
else % 2+ absorbers so fsolve required

    % scaling factors for units
    sf.i = max(photoabsorber.J_g.*photoabsorber.Area);
    sf.v = electrolysis.Voltage;
    sf.e = sf.v; % must be the same as units same
    
    % Set up function for root finding 
    fun = @(x) eqSys(x,electrolysis,photoabsorber,sf);
    
    options = optimoptions(@fsolve);
    fsolve_PlotFcn_list = {[],@optimplotx,@optimplotfunccount,@optimplotfval,@optimplotstepsize,@optimplotfirstorderopt};
    fsolve_PlotFcn_index = find(contains(expectedfsolve_PlotFcn,p.Results.fsolve_PlotFcn));
    options.PlotFcn = fsolve_PlotFcn_list{fsolve_PlotFcn_index};
    options.Display = 'off'; % iter
    options.MaxFunctionEvaluations = 1600;
    options.Algorithm = 'trust-region-dogleg';
%     'OutputFcn', @(x,optimValues,state) outfun(x,optimValues,state,photoabsorber,J_g,sf,GUI.Handle));
    
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
%     photoabsorber.e_guess

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
    
    if p.Results.PlotElectricalGraphResult
        figure;
        h2 = plot(photoabsorber.G,'Layout','layered','Direction','right');
        labeledge(h2,1:b,x(1:b)*sf.i)
        labelnode(h2,1:n,[0,e])
        for m = 1:b
            if v_branches(m)<0
                [sOut,tOut] = findedge(photoabsorber.G,m);
                highlight(h2,sOut,tOut,'EdgeColor','r','LineWidth',1.5)
            end
        end
    end

end



end