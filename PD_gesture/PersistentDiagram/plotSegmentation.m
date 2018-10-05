%% display surface colored by the different clusters
function plotSegmentation(image, vertices,forest)
    
    figure
    imshow(image);
    hold on

    num_vertices = length(vertices);
    num_trees = length(forest);
    
    
    for id_tree = 1:num_trees
        tree = forest{id_tree};
        num_node = length(tree);
        
        
        p = plot(vertices(tree,1),vertices(tree,2),'.',...
                'MarkerSize',12);
        color = [rand, rand,rand];% rand(1,3)*rand(1); %(id_tree/num_trees)*
        
        set(p,'MarkerEdgeColor',color,...
                'MarkerFaceColor',color,'Color',color);
    end
    

    %plot(row_idx,col_idx(row_idx),'ro');

end