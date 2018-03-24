function PEC_device_efficiency_GUI()

% create GUI

h = initGUI();

    function h = initGUI()

        h.fig_main = figure('Name','PEC_device_efficiency GUI',  ...
            'Visible','off', 'MenuBar','none','ToolBar', 'none', ...
            'Resize','off','Position',get(0,'defaultfigureposition'));

        h.ax_optical = axes('Parent',h.fig_main, ...
            'XTick',[], 'YTick',[], 'Box','on', ...
            'Units','normalized', 'Position',[0.05 0.35 0.4 0.3]);
        h.ax_electrical = axes('Parent',h.fig_main, ...
            'XTick',[], 'YTick',[], 'Box','on', ...
            'Units','normalized', 'Position',[0.05 0.65 0.4 0.3]);
        uicontrol('Style','text', ...
            'String','Optical:','BackgroundColor','w',    ...
            'Units','normalized','Position',[0.06,0.61,0.08,0.03]);
        uicontrol('Style','text', ...
            'String','Electrical:','BackgroundColor','w',    ...
            'Units','normalized','Position',[0.06,0.91,0.1,0.03]);
        
        uicontrol('Style','text', ...
            'String','Message:',...
            'Units','normalized','Position',[0.55,0.35,0.4,0.05]);
        h.Message = uicontrol('Style','text', ...
            'String','Welcome to the PEC_device_efficiency graphical user interface',...
            'Units','normalized','Position',[0.55,0.05,0.4,0.3],...
            'BackgroundColor','w');
         uicontrol('Style','pushbutton','String','copy',...
            'Units','normalized','Position',[0.85,0.05,0.1,0.05], ...
            'Callback',@CopyToClipboard_callback);
        

        uicontrol('Style','pushbutton','String','Edit configuration',...
            'Units','normalized','Position',[0.05,0.25,0.4,0.1], ...
            'Callback',@Edit_callback);
        uicontrol('Style','pushbutton','String','Load config.',...
            'Units','normalized','Position',[0.05,0.15,0.2,0.1],...
            'Callback',@Load_callback);
        uicontrol('Style','pushbutton','String','Save config.',...
            'Units','normalized','Position',[0.25,0.15,0.2,0.1],...
            'Callback',@Save_callback);
        uicontrol('Style','pushbutton','String','Options',...
            'Units','normalized','Position',[0.05,0.05,0.4,0.1],...
            'Callback',@Options_callback);
        uicontrol('Style','pushbutton','String','PEC model',...
            'Units','normalized','Position',[0.55,0.85,0.4,0.1],...
            'callback',@PECmodel_callback);
        uicontrol('Style','pushbutton','String','PV model (max. power point)',...
            'Units','normalized','Position',[0.55,0.75,0.4,0.1],...
            'Callback',@PVmodel_callback);
        uicontrol('Style','pushbutton','String','Parameter sweep',...
            'Units','normalized','Position',[0.55,0.6,0.4,0.1],...
            'Callback',@Parameter_sweep_callback);
        uicontrol('Style','pushbutton','String','Optimise',...
            'Units','normalized','Position',[0.55,0.45,0.4,0.1],...
            'Callback',@Optimise_callback);
        h.GUIreturn = uicontrol('Style','Text','Units','normalized', ...
            'Position',[0,0,0,0],'Callback',@GUIreturn_callback);
        
        
        
        
        % Default
        light.filename = 'AM15G.csv';
        light = loadLightData(light);
        light.config = [1,2,1];
        light.nodeID = [0,1];
        light.Area = [1,1];
        photoabsorber.config = [1,2];
        photoabsorber.branchID = [1];
        photoabsorber.Eg = [1.6];
        photoabsorber.f_g = [1];
        photoabsorber.T = 298.15;
        electrolysis.E_rxn = 1.23;
        electrolysis.V_o = 0.0;
        electrolysis.num_electrolysers = 1;
        
        options = struct('PlotSpectrum_wl',false,'PlotSpectrum_eV',false,...
            'PlotOpticalGraph',false,'PlotElectricalGraph',false,...
            'PlotElectricalGraphResult',true, ...
            'fsolve_PlotFcn','none');
        
        options_loadLight = struct('Interpolation','on','Spacing',0.1, ...
            'Method', 'linear','P_solarMethod','integrate','P_solar',1000);
         
        setappdata(h.fig_main ,'light',light);
        setappdata(h.fig_main ,'photoabsorber',photoabsorber);
        setappdata(h.fig_main ,'electrolysis',electrolysis);
        setappdata(h.fig_main ,'options',options);
        setappdata(h.fig_main ,'options_loadLight',options_loadLight);
        
        updateDiagraphs(h);
        
        % Make the UI visible.
        h.fig_main.Visible = 'on';
        
    end


%% Callback functions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function Edit_callback(~,~)
        h.fig_main.Visible = 'off';
        editConfigGUI(h);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function GUIreturn_callback(~,~)
        h.fig_main.Visible = 'on';
        
        light = getappdata(h.fig_main ,'light');
        photoabsorber = getappdata(h.fig_main ,'photoabsorber');
        electrolysis = getappdata(h.fig_main ,'electrolysis');
        
        options_loadLight = getappdata(h.fig_main, 'options_loadLight');
        options_ll_fieldnames = fieldnames(options_loadLight);
        options_ll_values = struct2cell(options_loadLight);
        for i = 1:length(options_ll_fieldnames)
            options_ll_NameValuePair{2*i-1} = options_ll_fieldnames{i};
            options_ll_NameValuePair{2*i+0} = options_ll_values{i};
        end

        light = loadLightData(light,options_ll_NameValuePair{:});
        setappdata(h.fig_main ,'light',light);
        
        error = checkInput(light,photoabsorber,electrolysis);
        if error.flag == 1
            h_error = errordlg(error.str);
            waitfor(h_error)
            Edit_callback();
        end
        h.Message.String = 'Input passed...';
        
        updateDiagraphs(h);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function Load_callback(~,~)
        
        light = getappdata(h.fig_main ,'light');
        photoabsorber = getappdata(h.fig_main, 'photoabsorber');
        electrolysis = getappdata(h.fig_main, 'electrolysis');
        options = getappdata(h.fig_main, 'options');
        options_loadLight = getappdata(h.fig_main, 'options_loadLight');
        
        uiopen('load')
        
        options_ll_fieldnames = fieldnames(options_loadLight);
        options_ll_values = struct2cell(options_loadLight);
        for i = 1:length(options_ll_fieldnames)
            options_ll_NameValuePair{2*i-1} = options_ll_fieldnames{i};
            options_ll_NameValuePair{2*i+0} = options_ll_values{i};
        end
        light = loadLightData(light,options_ll_NameValuePair{:});
        
        setappdata(h.fig_main ,'light',light);
        setappdata(h.fig_main, 'photoabsorber',photoabsorber);
        setappdata(h.fig_main, 'electrolysis',electrolysis);
        setappdata(h.fig_main, 'options',options);
        setappdata(h.fig_main, 'options_loadLight',options_loadLight);
        
        updateDiagraphs(h);
        
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function Save_callback(~,~)
        light = getappdata(h.fig_main ,'light');
        photoabsorber = getappdata(h.fig_main, 'photoabsorber');
        electrolysis = getappdata(h.fig_main, 'electrolysis');
        options = getappdata(h.fig_main, 'options');
        options_loadLight = getappdata(h.fig_main, 'options_loadLight');
        
        uisave({'light','photoabsorber','electrolysis','options','options_loadLight'});
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function PECmodel_callback(~,~)
        
        light = getappdata(h.fig_main ,'light');
        photoabsorber = getappdata(h.fig_main, 'photoabsorber');
        electrolysis = getappdata(h.fig_main, 'electrolysis');
        options = getappdata(h.fig_main, 'options');
        
        h.Message.String = ['Calculating PEC efficiency', newline, ...
            'Please wait...'];
        
        options_fieldnames = fieldnames(options);
        options_values = struct2cell(options);
        for i = 1:length(options_fieldnames)
            options_NameValuePair{2*i-1} = options_fieldnames{i};
            options_NameValuePair{2*i+0} = options_values{i};
        end
        
        [STF,J,V,exitflag] = modelPEC(light,photoabsorber,electrolysis,options_NameValuePair{:});
        
        if exitflag > 0
            h.Message.String = ['STF eff. = ',num2str(STF*100),' %'];
        else
            h.Message.String = 'fsolve failed to find solution';
        end
        
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function CopyToClipboard_callback(~,~)
        clipboard('copy',h.Message.String)
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function Options_callback(~,~)
        h.fig_main.Visible = 'off';
        editOptionsGUI(h);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function PVmodel_callback(~,~)
        light = getappdata(h.fig_main ,'light');
        photoabsorber = getappdata(h.fig_main, 'photoabsorber');
        electrolysis = getappdata(h.fig_main, 'electrolysis');
        options = getappdata(h.fig_main, 'options');
        
        h.Message.String = ['Calculating PEC efficiency', newline, ...
            'Please wait...'];
        
        options_fieldnames = fieldnames(options);
        options_values = struct2cell(options);
        for i = 1:length(options_fieldnames)
            options_NameValuePair{2*i-1} = options_fieldnames{i};
            options_NameValuePair{2*i+0} = options_values{i};
        end
        
        [STF,J,V,exitflag] = modelPV_mpp(light,photoabsorber,electrolysis,options_NameValuePair{:});
        
        if exitflag > 0
            h.Message.String = ['PV (mpp) eff. = ',num2str(STF*100),' %'];
        else
            h.Message.String = 'fsolve failed to find solution';
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function Parameter_sweep_callback(~,~)
        Parameter_sweep_GUI(h);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function Optimise_callback(~,~)
        Optimise_GUI(h);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




end