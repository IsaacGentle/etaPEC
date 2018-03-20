function updateDiagraphs(h)

% Load data
light = getappdata(h.fig_main ,'light');
photoabsorber = getappdata(h.fig_main ,'photoabsorber');
electrolysis = getappdata(h.fig_main ,'electrolysis');

%% Plot optical diagraph

% source target
s = light.config(:,1);
t = light.config(:,2);
% Split fraction for branch from previous node
w = light.config(:,3);
% Branch area concentration
w2 = light.Area(s)./light.Area(t);
G = digraph(s,t);
graphOrder = findedge(G,s,t);
G.Edges.SplitFrac = w(graphOrder);
G.Edges.AreaConc = w2(graphOrder)';
% plot diagraph
for i = 1:length(G.Edges.SplitFrac)
%         labelTextEdge{i} = ['f = ',num2str(G.Edges.SplitFrac(i)),', c = ',num2str(G.Edges.AreaConc(i))];
    labelTextEdge{i} = [num2str(G.Edges.SplitFrac(i))];
end
for i = 1:length(light.nodeID)
    labelTextNode{i} = ['[',num2str(light.nodeID(i)),'] A = ',num2str(light.Area(i))];
end

h_optical = plot(h.ax_optical,G,'Layout','layered','Direction','down');
h_optical.NodeColor = 'r';
labeledge(h_optical,s,t,labelTextEdge)
labelnode(h_optical,1:length(light.nodeID),labelTextNode)
set(h.ax_optical, 'XTickLabel',[])
set(h.ax_optical, 'YTickLabel',[])
set(h.ax_optical, 'XTick',[])
set(h.ax_optical, 'YTick',[])


%% Plot electrical diagraph

s = photoabsorber.config(:,1);
t = photoabsorber.config(:,2);

G = digraph(s,t);
n = numnodes(G);
G = addedge(G,n,1); % add electrolyser edge
b = numedges(G);

% % Digraph reorders the edges so we need to know which PV is where in
% % G.Edges table
photoabsorber.graphOrder = findedge(G,s,t); % branchID = idxOut(photoabsorber number)
photoabsorber.graphBranchID = photoabsorber.branchID(photoabsorber.graphOrder); % Photoabsorber number for each branch

h_electrical = plot(h.ax_electrical,G,'Layout','layered','Direction','right');
labeledge(h_electrical,1:b-1,photoabsorber.graphBranchID)
labeledge(h_electrical,b,'Electrolyer(s)')
labelnode(h_electrical,1:n,'')
set(h.ax_electrical, 'XTickLabel',[])
set(h.ax_electrical, 'YTickLabel',[])
set(h.ax_electrical, 'XTick',[])
set(h.ax_electrical, 'YTick',[])

end