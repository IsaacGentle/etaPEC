function editConfigGUI(h)

%% create GUI
h_edit = initGUI();

    function h_edit = initGUI()
        
        % Get app data
        light = getappdata(h.fig_main ,'light');
        photoabsorber = getappdata(h.fig_main ,'photoabsorber');
        electrolysis = getappdata(h.fig_main ,'electrolysis');
        
        % Set up figure
        h_edit.fig = figure('Name','Edit configuration','ToolBar', 'none','MenuBar','none',  ...
            'Resize','off','Position',get(0,'defaultfigureposition'),...
            'CloseRequestFcn',@closeRequest);

        uicontrol('Style','pushbutton','String','Save',...
            'Units','normalized','Position',[0.65,0.05,0.3,0.1], ...
            'Callback',@onReturn);
        
        
        % Light
        uicontrol('Style','text', ...
            'String','Light configuration:',...
            'Units','normalized','Position',[0.05,0.90,0.25,0.05]);
        h_edit.light.config = uicontrol('Style','edit', ...
            'String',num2str(light.config,'%i, '),...
            'Units','normalized','Position',[0.05,0.6,0.25,0.3], ...
            'Max',10);
        
        uicontrol('Style','text', ...
            'String','node photoabsorber ID:',...
            'Units','normalized','Position',[0.05,0.5,0.25,0.05]);
        h_edit.light.nodeID = uicontrol('Style','edit', ...
            'String',num2str(light.nodeID,'%i, '),...
            'Units','normalized','Position',[0.05,0.45,0.25,0.05]);
        
        uicontrol('Style','text', ...
            'String','Node area (relative):',...
            'Units','normalized','Position',[0.05,0.35,0.25,0.05]);
        h_edit.light.Area = uicontrol('Style','edit', ...
            'String',num2str(light.Area,'%i, '),...
            'Units','normalized','Position',[0.05,0.3,0.25,0.05]);
        
        uicontrol('Style','text', ...
            'String','Light spectrum data:',...
            'Units','normalized','Position',[0.05,0.2,0.25,0.05]);
        h_edit.light.filename = uicontrol('Style','edit', ...
            'String',light.filename,...
            'Units','normalized','Position',[0.05,0.15,0.25,0.05]);
        
        
        % photoabsorber
        uicontrol('Style','text', ...
            'String','Photoabsorber configuration:',...
            'Units','normalized','Position',[0.35,0.90,0.25,0.08]);
        h_edit.photoabsorber.config = uicontrol('Style','edit', ...
            'String',num2str(photoabsorber.config,'%i, '),...
            'Units','normalized','Position',[0.35,0.6,0.25,0.3], ...
            'Max',10);
        
        uicontrol('Style','text', ...
            'String','Branch photoabsorber ID:',...
            'Units','normalized','Position',[0.35,0.5,0.25,0.05]);
        h_edit.photoabsorber.branchID = uicontrol('Style','edit', ...
            'String',num2str(photoabsorber.branchID,'%i, '),...
            'Units','normalized','Position',[0.35,0.45,0.25,0.05]);
        
        uicontrol('Style','text', ...
            'String','Bandgap [eV]:',...
            'Units','normalized','Position',[0.35,0.35,0.25,0.05]);
        h_edit.photoabsorber.Eg = uicontrol('Style','edit', ...
            'String',num2str(photoabsorber.Eg,'%.3f, '),...
            'Units','normalized','Position',[0.35,0.3,0.25,0.05]);
        
        uicontrol('Style','text', ...
            'String','f_g:',...
            'Units','normalized','Position',[0.35,0.2,0.25,0.05]);
        h_edit.photoabsorber.f_g = uicontrol('Style','edit', ...
            'String',num2str(photoabsorber.f_g,'%i, '),...
            'Units','normalized','Position',[0.35,0.15,0.25,0.05]);
        
        uicontrol('Style','text', ...
            'String','Temperature:',...
            'Units','normalized','Position',[0.65,0.8,0.25,0.05]);
        h_edit.photoabsorber.T = uicontrol('Style','edit', ...
            'String',num2str(photoabsorber.T),...
            'Units','normalized','Position',[0.65,0.75,0.25,0.05]);
        
        
        % electrolysis
        uicontrol('Style','text', ...
            'String','E_rxn:',...
            'Units','normalized','Position',[0.65,0.65,0.25,0.05]);
        h_edit.electrolysis.E_rxn = uicontrol('Style','edit','String', ...
            num2str(electrolysis.E_rxn),...
            'Units','normalized','Position',[0.65,0.6,0.25,0.05]);
        
        uicontrol('Style','text', ...
            'String','V_o:',...
            'Units','normalized','Position',[0.65,0.5,0.25,0.05]);
        h_edit.electrolysis.V_o = uicontrol('Style','edit','String', ...
            num2str(electrolysis.V_o),...
            'Units','normalized','Position',[0.65,0.45,0.25,0.05]);
        
        uicontrol('Style','text', ...
            'String','num_electrolysers:',...
            'Units','normalized','Position',[0.65,0.35,0.25,0.05]);
        h_edit.electrolysis.num_electrolysers = uicontrol('Style','edit','String', ...
            num2str(electrolysis.num_electrolysers),...
            'Units','normalized','Position',[0.65,0.3,0.25,0.05]);
        
    end

    function onReturn(~,~)
        
        light.filename = h_edit.light.filename.String;
        light.config = str2num(h_edit.light.config.String);
        light.nodeID = str2num(h_edit.light.nodeID.String);
        light.Area = str2num(h_edit.light.Area.String);
        
        photoabsorber.config = str2num(h_edit.photoabsorber.config.String);
        photoabsorber.branchID = str2num(h_edit.photoabsorber.branchID.String);
        photoabsorber.Eg = str2num(h_edit.photoabsorber.Eg.String);
        photoabsorber.f_g = str2num(h_edit.photoabsorber.f_g.String);
        photoabsorber.T = str2num(h_edit.photoabsorber.T.String);
        
        electrolysis.E_rxn = str2num(h_edit.electrolysis.E_rxn.String);
        electrolysis.V_o = str2num(h_edit.electrolysis.V_o.String);
        electrolysis.num_electrolysers = str2num(h_edit.electrolysis.num_electrolysers.String);
        
        setappdata(h.fig_main ,'light',light);
        setappdata(h.fig_main ,'photoabsorber',photoabsorber);
        setappdata(h.fig_main ,'electrolysis',electrolysis);
        
        h_edit.fig.Visible = 'off';
        return_callback = get(h.GUIreturn, 'Callback');
        return_callback()
        close(h_edit.fig);
    end


    function closeRequest(~,~)
        h_edit.fig.Visible = 'off';
        return_callback = get(h.GUIreturn, 'Callback');
        return_callback()
        delete(h_edit.fig);
    end


end