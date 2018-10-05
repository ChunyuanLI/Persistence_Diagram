%% find the root of the current node in the forest
function [mother_tree,root,root_func] = findRoot(current_node,forest,func)
    
    mother_tree = [];
    num_trees = size(forest,1);
    for i = 1:num_trees
        tree = forest{i};
        
        ID = find(tree==current_node);
        if length(ID)~=0
            mother_tree = tree;
            mother_tree_func = func(mother_tree); 
            [root_func, root2] = max(mother_tree_func);
            root = mother_tree(root2);
        else
            
%             str = sprintf('Can not find the root of vetex %d, whose function value is %d', current_node,func(current_node));
%             disp(str)
        end

    end 
    
    
    num_mother_tree = size(mother_tree,1);
    if num_mother_tree == 0
        disp('Cannot assign vertex to any tree in the forest')
    end
end