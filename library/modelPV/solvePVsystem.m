function [PV_eff,J,V,exitflag] = solvePVsystem(light,photoabsorber,electrolysis,varargin)


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
    J = current_PV(photoabsorber.V_mpp_graphBranch(1),photoabsorber,1);
    V = photoabsorber.V_mpp_graphBranch(1);
    
    if p.Results.PlotElectricalGraphResult
        figure;
        h2 = plot(photoabsorber.G,'Layout','layered','Direction','right');
        labeledge(h2,1:2,[J,J])
        labelnode(h2,1:2,[0,photoabsorber.V_mpp_graphBranch(1)])
    end
      
    PV_eff = J*V/light.P_solar;
    exitflag = 1;
    
else % 2+ absorbers so fsolve required
    
    options = optimoptions(@fsolve);
    fsolve_PlotFcn_list = {[],@optimplotx,@optimplotfunccount,@optimplotfval,@optimplotstepsize,@optimplotfirstorderopt};
    fsolve_PlotFcn_index = find(contains(expectedfsolve_PlotFcn,p.Results.fsolve_PlotFcn));
    options.PlotFcn = fsolve_PlotFcn_list{fsolve_PlotFcn_index};
    options.Display = 'off'; % iter
    options.MaxFunctionEvaluations = 1600;
    options.Algorithm = 'trust-region-dogleg';
    %     'OutputFcn', @(x,optimValues,state) outfun(x,optimValues,state,photoabsorber,J_g,sf,GUI.Handle));
    
    [V_mpp, F_mpp] = fminsearch( ...
        @(V) PV_efficiency_minfun(V, light,photoabsorber,electrolysis,options), ...
        photoabsorber.V_oc_total);
    
    % Temp. fix
    PV_eff = -F_mpp;
    V = V_mpp;
    J = -1;
    exitflag = 1;
    
%     if p.Results.PlotElectricalGraphResult
%         figure;
%         h2 = plot(photoabsorber.G,'Layout','layered','Direction','right');
%         labeledge(h2,1:b,x(1:b)*sf.i)
%         labelnode(h2,1:n,[0,e])
%         for m = 1:b
%             if v_branches(m)<0
%                 [sOut,tOut] = findedge(photoabsorber.G,m);
%                 highlight(h2,sOut,tOut,'EdgeColor','r','LineWidth',1.5)
%             end
%         end
%     end

end



end