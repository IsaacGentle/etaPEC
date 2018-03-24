function photoabsorber = calcLight(light,photoabsorber,varargin)
% Calculate the light falling on each photoabsorber based on the optical
% configuration

%% Parse input
defaultPlotSpectrum_wl = false;
defaultPlotSpectrum_eV = false;
defaultPlotOpticalGraph = false;
p = inputParser;
addRequired(p,'light',@isstruct);
addRequired(p,'photoabsorber',@isstruct);
addParameter(p,'PlotSpectrum_wl',defaultPlotSpectrum_wl,@islogical);
addParameter(p,'PlotSpectrum_eV',defaultPlotSpectrum_eV,@islogical);
addParameter(p,'PlotOpticalGraph',defaultPlotOpticalGraph,@islogical);
parse(p,light,photoabsorber,varargin{:});

%% Set up directed graph structure
% Light source is at node 1, subsquent nodes are the photo-absorbers

% Optical connections - source target
s = light.config(:,1);
t = light.config(:,2);

% Split fraction for branch from previous node
w = light.config(:,3);

% Branch area concentration
w2 = light.Area(s)./light.Area(t);

% Set up directed graph structure
G = digraph(s,t);

% Find order of as digraph may rearrange order of the source and target
% values
graphOrder = findedge(G,s,t);

% Add split fraction and area concentration to edge weight 
G.Edges.SplitFrac = w(graphOrder);
G.Edges.AreaConc = w2(graphOrder)';

%% Calculate light spectrum at each node

% Topological order of directed acyclic graph
nodeTopoSort = toposort(G);

% Preallocate size of nodeLight variables
for i = 1:length(nodeTopoSort)
    NodeLight_after{i} = zeros(size(light.photon_flux_eV));
    NodeLight_before{i} = NodeLight_after{i};
end

% Step through topological sort order
i = 0;
for node = nodeTopoSort
    i = i + 1;
    
    if i == 1 % Then first node, which means input light
       NodeLight_after{i} = light.photon_flux_eV;
    else
        % Add up previous light contributions
        preIDs = predecessors(G,node);
        
        % step through all edges which end in the node investigated
        for preID = preIDs'
            idxOut = findedge(G,preID,node); % Find edge id for edge being investigated
            
            % Fraction of light from previous node that reaches photoabsorber at node
            SplitFrac = G.Edges.SplitFrac(idxOut);
            
            % Fraction of light from previous node that reaches photoabsorber at node
            AreaConc = G.Edges.AreaConc(idxOut);
            
            % Get photoabsorber id at current node
            photoabsorberID = light.nodeID(node);
            
            % Calculate the light reaching the node (photoabsorber is just before node)
            NodeLight_before{node} = NodeLight_before{node} + NodeLight_after{preID}*SplitFrac*AreaConc;
            
        end
        
        % Calculate the light just after node (after it has passed through the photobsorber)
        trueMatrix = light.photon_energy_eV < photoabsorber.Eg(photoabsorberID); % true if energy is greater than bandgap
        NodeLight_after{node}(trueMatrix) = NodeLight_before{node}(trueMatrix);
        
    end
    
end

%% Calculate light falling on each photoabsorber

for node = nodeTopoSort(2:end)
    photoabsorberID = light.nodeID(node);
    photoabsorberLight{photoabsorberID} = NodeLight_before{node};
end

%% Assign to results to output
photoabsorber.Light = photoabsorberLight;
photoabsorber.photon_energy_eV = light.photon_energy_eV;
% Areas for all photoabsorbers normalised to input area
photoabsorber.Area = light.Area(2:end)./light.Area(1);

%% Plot figures (if called for)

% plot diagraph
if p.Results.PlotOpticalGraph
    for i = 1:length(G.Edges.SplitFrac)
        labelTextEdge{i} = [num2str(G.Edges.SplitFrac(i))];
    end
    
    for i = 1:length(light.nodeID)
        labelTextNode{i} = ['[',num2str(light.nodeID(i)),'] A = ',num2str(light.Area(i))];
    end
    
    figure('Name','Optical directed graph','NumberTitle','off');
    h = plot(G);
    h.NodeColor = 'r';
    labeledge(h,s,t,labelTextEdge) % this doesn't take into account that edges may be muddled up by digraph % FIX THIS
    labelnode(h,1:length(light.nodeID),labelTextNode)
    
end


% Plot light falling on each photoabsorber (photon_flux_eV)
if p.Results.PlotSpectrum_eV
    figure('Name','Photoabsorber light','NumberTitle','off'); hold on
    for i = 1:length(photoabsorberLight)
        plot(light.photon_energy_eV,photoabsorberLight{i})
        legendEntries{i} = num2str(i);
    end
    legend(legendEntries)
    xlabel('Photon energy [eV]')
    ylabel('Photon flux [m^{-2} eV^{-1}]')
end

% Plot light falling on each photoabsorber (Irradience_wl)
if p.Results.PlotSpectrum_wl
    
    c = 299792458; % Speed of light [m s-1]
    h = 6.62607004e-34; % Planck constant [m2 kg s-1]
    q = 1.602176565e-19; % Elementary charge [C]
    
    figure('Name','Photoabsorber light','NumberTitle','off'); hold on
    for i = 1:length(photoabsorberLight)
        photoabsorberLight_wl = photoabsorberLight{i}.* ...
            light.photon_energy_eV.*q./(1e-9*q.*light.wl.^2/(h*c)); % [W m-2 nm-1]
        
        plot(light.wl,photoabsorberLight_wl)
        legendEntries{i} = num2str(i);
    end
    legend(legendEntries)
    xlabel('Photon energy [nm]')
    ylabel('Photon flux [W m^{-2} nm^{-1}]')
end

end