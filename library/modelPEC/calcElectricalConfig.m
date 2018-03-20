function photoabsorber = calcElectricalConfig(photoabsorber,varargin)
% Description here

%% Parse input
defaultPlotElectricalGraph = false;
p = inputParser;
addRequired(p,'photoabsorber',@isstruct);
addParameter(p,'PlotElectricalGraph',defaultPlotElectricalGraph,@islogical);
parse(p,photoabsorber,varargin{:});

%%

s = photoabsorber.config(:,1);
t = photoabsorber.config(:,2);

G = digraph(s,t);
n = numnodes(G);
G = addedge(G,n,1); % add electrolyser edge
b = numedges(G);

% Digraph reorders the edges so we need to know which PV is where in
% G.Edges table
photoabsorber.graphOrder = findedge(G,s,t); % branchID = idxOut(photoabsorber number)
photoabsorber.graphBranchID = photoabsorber.branchID(photoabsorber.graphOrder); % Photoabsorber number for each branch

IncidenceMat = incidence(G);

A = -IncidenceMat(2:end,:);

photoabsorber.A = A;
photoabsorber.n = n;
photoabsorber.b = b;
photoabsorber.G = G;


if p.Results.PlotElectricalGraph
    figure;
    h = plot(G,'Layout','layered','Direction','right');
    labeledge(h,1:b-1,photoabsorber.graphBranchID)
    labeledge(h,b,'Electrolyer(s)')
    labelnode(h,1:n,'')
end

end