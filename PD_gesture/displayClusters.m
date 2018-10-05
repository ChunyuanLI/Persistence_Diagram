%% display surface colored by the different clusters
function displayClusters(vertices,forest,Duration,func)
    num_vertices = length(vertices);
    color = zeros(num_vertices,1);
    num_trees = length(forest);
    
    vertex_peak = Duration(:,1);
    
    Duration0 = [];
    for id_tree = 1:num_trees
        tree = forest{id_tree};
        num_node = length(tree);
        
        tree_func = func(tree);
        [~,id] = max(tree_func);
        id_vertex = tree(id);
        idx = find(vertex_peak == id_vertex);
        Duration0 = [Duration0;Duration(idx,:)];
        
        color(tree,1) = Duration(idx,4);
    end
    %plotPD(Duration0);
    
%     min_coordinate = 0;
%     max_coordinate = 3.5;   
%     plotPD(Duration,min_coordinate,max_coordinate);
    % color = idx;
    X = vertices(:,1);
    Y = vertices(:,2);
    plotRegions(X,Y,color);
%    plotSegmentation(Gray, vertices,forest,color);
end