function Optimise_GUI(h)


%% create GUI
h_edit = initGUI();

    function h_edit = initGUI()
        
        % Get app data
        light = getappdata(h.fig_main ,'light');
        photoabsorber = getappdata(h.fig_main ,'photoabsorber');
        electrolysis = getappdata(h.fig_main ,'electrolysis');
        options = getappdata(h.fig_main ,'options');
        options_loadLight = getappdata(h.fig_main, 'options_loadLight');
        
        % Set up figure
        defaultPos = get(0,'defaultfigureposition');
        h_edit.fig = figure('Name','Optimise GUI','ToolBar', 'none','MenuBar','none',  ...
            'Resize','off','Position',defaultPos);

        % Title
        uicontrol('Style','text', ...
            'String','Optimise for STF efficiency [%]:',...
            'HorizontalAlignment','center',...
            'Units','normalized','Position',[0.333,0.85,0.333,0.05]);
        
        % Initial guess
        uicontrol('Style','text', ...
            'String','Initial guess:',...
            'Units','normalized','Position',[0.05,0.60,0.25,0.05]);
        
        uicontrol('Style','text', ...
            'String','Bandgap [eV]:',...
            'Units','normalized','Position',[0.35,0.65,0.25,0.05]);
        h_edit.photoabsorber.Eg = uicontrol('Style','edit', ...
            'String',num2str(photoabsorber.Eg,'%.3f, '),...
            'Units','normalized','Position',[0.35,0.6,0.25,0.05]);
        
        uicontrol('Style','text', ...
            'String','Number of electrolysers:',...
            'Units','normalized','Position',[0.65,0.65,0.25,0.05]);
        h_edit.electrolysis.num_electrolysers = uicontrol('Style','edit','String', ...
            num2str(electrolysis.num_electrolysers),...
            'Units','normalized','Position',[0.65,0.6,0.25,0.05]);
        
        % Optimise
        uicontrol('Style','pushbutton','String','Optimise',...
            'Units','normalized','Position',[0.65,0.35,0.3,0.1], ...
            'Callback',@onOptimise);
         uicontrol('Style','text', ...
            'String','Optimise for:',...
            'Units','normalized','Position',[0.15,0.375,0.2,0.05]);
        Type_list = {'E_g','N_elec','Eg AND N_elec'};
        h_edit.Type = uicontrol('Style','popupmenu', ...
            'String',Type_list,'Value',1,...
            'Units','normalized','Position',[0.35,0.375,0.2,0.05]);
        
        
        % Output
        uicontrol('Style','text', ...
            'String','Output (careful, a local maximum may have been found):',...
            'Units','normalized','Position',[0.25,0.25,0.5,0.05]);
        
        uicontrol('Style','text', ...
            'String','STF [%]:',...
            'Units','normalized','Position',[0.05,0.15,0.25,0.05]);
        h_edit.STF_output = uicontrol('Style','edit', ...
            'String','-',...
            'Units','normalized','Position',[0.05,0.1,0.25,0.05]);
        
        uicontrol('Style','text', ...
            'String','Bandgap [eV]:',...
            'Units','normalized','Position',[0.35,0.15,0.25,0.05]);
        h_edit.Eg_output = uicontrol('Style','edit', ...
            'String','-',...
            'Units','normalized','Position',[0.35,0.1,0.25,0.05]);
        
        uicontrol('Style','text', ...
            'String','Number of electrolysers:',...
            'Units','normalized','Position',[0.65,0.15,0.25,0.05]);
        h_edit.num_electrolysers_output = uicontrol('Style','edit', ...
            'String', '-',...
            'Units','normalized','Position',[0.65,0.1,0.25,0.05]);
        
        h_edit.SuppressPlots = uicontrol('Style','checkbox','String','Suppress plots',...
            'Value',1,'Units','normalized','Position',[0.4,0.45,0.2,0.1]);
        
    end

    function onOptimise(~,~)
        
        % Get app data
        light = getappdata(h.fig_main ,'light');
        photoabsorber = getappdata(h.fig_main ,'photoabsorber');
        electrolysis = getappdata(h.fig_main ,'electrolysis');
        options = getappdata(h.fig_main ,'options');
        options_loadLight = getappdata(h.fig_main, 'options_loadLight');
        
        if h_edit.SuppressPlots.Value
            options.PlotSpectrum_wl = false;
            options.PlotSpectrum_eV = false;
            options.PlotOpticalGraph = false;
            options.PlotElectricalGraph = false;
            options.PlotElectricalGraphResult = false;
            options.fsolve_PlotFcn = 'none';
        end
        
        % Get initial guess
        photoabsorber.Eg = str2num(h_edit.photoabsorber.Eg.String);
        electrolysis.num_electrolysers = str2num(h_edit.electrolysis.num_electrolysers.String);
        
        
        function F = objFun_maxSTH(Eg,num_electrolysers,light,photoabsorber,electrolysis,options)
            photoabsorber.Eg = Eg;
            electrolysis.num_electrolysers = num_electrolysers;
            
            options_fieldnames = fieldnames(options);
            options_values = struct2cell(options);
            for i = 1:length(options_fieldnames)
                options_NameValuePair{2*i-1} = options_fieldnames{i};
                options_NameValuePair{2*i+0} = options_values{i};
            end
            [STF,~,~,~] = modelPEC(light,photoabsorber,electrolysis,options_NameValuePair{:});
            if isnan(STF)
                F = 0;
            else
                F = -STF;
            end
        end
        function F = objFun_maxSTH_EgNelec(x,light,photoabsorber,electrolysis,options)
            photoabsorber.Eg = x(1:length(photoabsorber.config));
            electrolysis.num_electrolysers = x(end);
            
            options_fieldnames = fieldnames(options);
            options_values = struct2cell(options);
            for i = 1:length(options_fieldnames)
                options_NameValuePair{2*i-1} = options_fieldnames{i};
                options_NameValuePair{2*i+0} = options_values{i};
            end
            [STF,~,~,~] = modelPEC(light,photoabsorber,electrolysis,options_NameValuePair{:});
            if isnan(STF)
                F = 0;
            else
                F = -STF;
            end
        end
        
        
        switch h_edit.Type.Value
            case 1 % Eg
                fun = @(Eg) objFun_maxSTH( ...
                    Eg, ...
                    electrolysis.num_electrolysers, ...
                    light,photoabsorber,electrolysis,options);
                options_fmin = optimset('PlotFcns',@optimplotfval); %@optimplotx
                tic
                [Eg_opt,F_opt,exitflag] = fminsearch(fun,photoabsorber.Eg,options_fmin);
                toc
                h_edit.STF_output.String = num2str(-F_opt*100);
                h_edit.Eg_output.String = num2str(Eg_opt);
                h_edit.num_electrolysers_output.String = '-';
                
            case 2 % N_elec
                fun = @(N_elec) objFun_maxSTH( ...
                    photoabsorber.Eg, ...
                    N_elec, ...
                    light,photoabsorber,electrolysis,options);
                options_fmin = optimset('PlotFcns',@optimplotfval); %@optimplotx
                tic
                [N_elec_opt,F_opt,exitflag] = fminsearch(fun,electrolysis.num_electrolysers,options_fmin);
                toc
                h_edit.STF_output.String = num2str(-F_opt*100);
                h_edit.Eg_output.String = '-';
                h_edit.num_electrolysers_output.String = num2str(N_elec_opt);
                
                
            case 3 % Eg AND N_elec
                fun = @(x) objFun_maxSTH_EgNelec( ...
                    x, ...
                    light,photoabsorber,electrolysis,options);
                options_fmin = optimset('PlotFcns',@optimplotfval); %@optimplotx
                tic
                [x_opt,F_opt,exitflag] = fminsearch(fun,[photoabsorber.Eg,electrolysis.num_electrolysers],options_fmin);
                toc
                Eg_opt = x_opt(1:end-1);
                N_elec_opt = x_opt(end);
                h_edit.STF_output.String = num2str(-F_opt*100);
                h_edit.Eg_output.String = num2str(Eg_opt);
                h_edit.num_electrolysers_output.String = num2str(N_elec_opt);
                
        end
        
    end


end


% options = optimset('PlotFcns',@optimplotfval); %@optimplotx
% [N_elec_opt,~,exitflag] = fminsearch(@(N_elec) objFun_maxSTH_Nelec(N_elec,light,photoabsorber,electrolysis),electrolysis.num_electrolysers,options);
% 
% GUI.OnOff = 1;
% GUI.Handle = handles.axes3;
% GUI.PlotFcn = 0;
% electrolysis.num_electrolysers = N_elec_opt;
% [STH_opt,~,~] = modelPEC(light,photoabsorber,electrolysis,false,GUI);
% close(h_wait)
% 
% edit14_Handle = findobj('Tag', 'edit14');
% if exitflag > 0
%     set(edit14_Handle, 'string',['STH_opt = ',num2str(STH_opt*100),' % at N_elec = ',num2str(N_elec_opt),' which is ',num2str(electrolysis.E_rxn*N_elec_opt + electrolysis.V_o),' V'])
% else
%     set(edit14_Handle, 'fminsearch failed to find solution')
% end


% function F = objFun_maxSTH(Eg,light,photoabsorber,electrolysis)
% 
% photoabsorber.Eg = Eg;
% 
% 
% GUI.OnOff = 0;
% GUI.PlotFcn = 0;
% 
% [STH,J,V] = modelPEC(light,photoabsorber,electrolysis,false,GUI);
% 
% if isnan(STH)
%     F = 0;
% else
%     F = -STH;
% end
% 
% end