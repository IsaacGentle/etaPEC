function ParameterSweep(h_edit,h)

h_wait = waitbar(0); tic

% Get options data
options = getappdata(h.fig_main ,'options');

if h_edit.SuppressPlots.Value
    options.PlotSpectrum_wl = false;
    options.PlotSpectrum_eV = false;
	options.PlotOpticalGraph = false;
    options.PlotElectricalGraph = false;
    options.PlotElectricalGraphResult = false;
    options.fsolve_PlotFcn = 'none';
end

options_fieldnames = fieldnames(options);
options_values = struct2cell(options);
for i = 1:length(options_fieldnames)
    options_NameValuePair{2*i-1} = options_fieldnames{i};
    options_NameValuePair{2*i+0} = options_values{i};
end

options_loadLight = getappdata(h.fig_main, 'options_loadLight');
options_ll_fieldnames = fieldnames(options_loadLight);
options_ll_values = struct2cell(options_loadLight);
for i = 1:length(options_ll_fieldnames)
    options_ll_NameValuePair{2*i-1} = options_ll_fieldnames{i};
    options_ll_NameValuePair{2*i+0} = options_ll_values{i};
end


% Get parameter sweep data
N = h_edit.NumParameters.Value;

for i = 1:3
    if i <= N
        values{i} = h_edit.xyzvalues{i}.String;
        labels{i} = h_edit.xyzlabel{i}.String;
    else
        values{i} = '0'; labels{i} = '';
    end
end

%
x_all = eval(values{1});
y_all = eval(values{2});
z_all = eval(values{3});

% 
light.filename = h_edit.light.filename.String;
light = loadLightData(light,options_ll_NameValuePair{:});
light.config = str2num(h_edit.light.config.String);
light.nodeID = str2num(h_edit.light.nodeID.String);
Area = @(x,y,z) eval(['[',h_edit.light.Area.String,']']);

photoabsorber.config = str2num(h_edit.photoabsorber.config.String);
photoabsorber.branchID = str2num(h_edit.photoabsorber.branchID.String);
Eg = @(x,y,z) eval(['[',h_edit.photoabsorber.Eg.String,']']);
f_g = @(x,y,z) eval(['[',h_edit.photoabsorber.f_g.String,']']);
T = @(x,y,z) eval(['[',h_edit.photoabsorber.T.String,']']);

E_rxn = @(x,y,z) eval(['[',h_edit.electrolysis.E_rxn.String,']']);
V_o = @(x,y,z) eval(['[',h_edit.electrolysis.V_o.String,']']);
num_electrolysers = @(x,y,z) eval(['[',h_edit.electrolysis.num_electrolysers.String,']']);

% 
siz = [length(x_all),length(y_all),length(z_all)];
% 
for ind = 1:prod(siz)
    [xi,yi,zi] = ind2sub(siz,ind);
    x = x_all(xi);
    y = y_all(yi);
    z = z_all(zi);
    XX(xi,yi,zi) = x_all(xi);
    YY(xi,yi,zi) = y_all(yi);
    ZZ(xi,yi,zi) = z_all(zi);
    
    % 
    light.Area = Area(x,y,z);
    photoabsorber.Eg = Eg(x,y,z);
    photoabsorber.f_g = f_g(x,y,z);
    photoabsorber.T = T(x,y,z);
    electrolysis.E_rxn = E_rxn(x,y,z);
    electrolysis.V_o = V_o(x,y,z);
    electrolysis.num_electrolysers = num_electrolysers(x,y,z);
    
    XYZ3D(:,ind) = [x,y,z];
    switch h_edit.PECorPV.Value
        case 1 % Then model PEC
            [STF(xi,yi,zi),~,~,exitflag(xi,yi,zi)] =  ...
                modelPEC(light,photoabsorber,electrolysis,options_NameValuePair{:});
        case 2 % Model PV at mpp
            [STF(xi,yi,zi),~,~,exitflag(xi,yi,zi)] =  ...
                modelPV_mpp(light,photoabsorber,electrolysis,options_NameValuePair{:});
    end
    STF_3D(ind) = STF(xi,yi,zi);

    waitbar(ind/prod(siz),h_wait)
end

figure(10);
if h_edit.HoldOn.Value
    hold on;
end
switch N
    case 1
        plot(XX,STF*100)
        xlabel(labels{1})
        ylabel('STF [%]')
%         figure;
%         plot(XX,exitflag)
    case 2
        surf(XX,YY,STF*100)
        xlabel(labels{1})
        ylabel(labels{2})
        zlabel('STF [%]')
        figure;
        surf(XX,YY,exitflag)
    case 3
%         STF_3D(isnan(STF_3D)) = 0.000001;
%         STF_3D(STF_3D<=0) = 0.0000001;
%         scatter3(XYZ3D(1,:),XYZ3D(2,:),XYZ3D(3,:),100*STF_3D,STF_3D)
        errordlg('Sorry, display of this is yet to be implemented')
%         slice(XX,YY,ZZ,STF*100,[1],[1],[1])
        xlabel(labels{1})
        ylabel(labels{2})
        zlabel(labels{3})
end

close(h_wait); toc

%% Save data

[file,path,indx] = uiputfile('.csv');
if indx ~= 0
    save_filename = fullfile(path,file);
    switch N
        case 1
            M_data(:,1) = reshape(XX,[],1);
            M_data(:,2) = reshape(STF*100,[],1);
        case 2
            M_data(:,1) = reshape(XX,[],1);
            M_data(:,2) = reshape(YY,[],1);
            M_data(:,3) = reshape(STF*100,[],1);
        case 3
            M_data(:,1) = reshape(XX,[],1);
            M_data(:,2) = reshape(YY,[],1);
            M_data(:,3) = reshape(YY,[],1);
            M_data(:,4) = reshape(STF*100,[],1);
    end
    csvwrite(save_filename,M_data);
end
    
end