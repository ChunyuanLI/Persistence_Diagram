function [LeefItem,LeefTable,Durations,Merged_forest] = persistence_computing(vertices,ringv,scalar_value, tau)

    num_trees_initial = 0;

    num_vertices = length(vertices);

    S = scalar_value;
    
    [~,num_bit] = size(S);

    Durations = {};
    
    for id_S = 1:1:num_bit
         
        func = S(:,id_S);
        % plotMesh(vertices,faces,color);   
    
    %% Persistence using DT
    % normalize the value between [0,1]
%     vv = func;
%     func = (vv-min(vv))./(max(vv)-min(vv));

    % sort the function value
    [sorted_func,IX] = sort(func,1,'descend');

    
    %% first run : (Mode-seeking)
    forest = {};   
    num_old_forest = count_nodes(forest);
    for id = 1:num_vertices
    % while length(IX) ~= 0
        id;
        current_node = IX(id);
        current_func = func(current_node);
        
        neighbs = ringv{current_node};
        neighbs_func = func(neighbs);
       
        idx = find(neighbs_func == max(neighbs_func));
        C = max(neighbs_func);

        
        if C <= current_func
           %  i is declared a peak 
           tree =  current_node;
           forest = [forest;{tree}];
        else 
           %  connecting i to its neighbor with highest f
           
           % in case there are more than one neigh with the same max value
           num_same_max = length(idx);
                if num_same_max > 1
                    stop = 1;
                end
            for id_neigh = 1:num_same_max
  
            I = idx(id_neigh);
    
            highest_neighb = neighbs(I);
           
            %  assign
            [forest] = connect2cluster(current_node,highest_neighb,forest);                      
            end
        end
        
        
        num_new_forest = count_nodes(forest);
            
        if num_new_forest ~= num_old_forest+1
            disp('Failed to find the tree');
            %Updated_forest = [Updated_forest;{highest_neighb}];
        end
        num_old_forest = num_new_forest;
        
    end
    
    forest;
    % displayClusters(vertices,faces,forest);
    
    %% initialize duration (birth and death) of clusters
    num_clusters = length(forest);
    Duration = zeros(num_clusters,4);
    
    for id_cluster = 1:num_clusters
        d_tree = forest{id_cluster};
        d_tree_func = func(d_tree); 
        [root_func, root2] = max(d_tree_func);
        Duration(id_cluster,2) = root_func;
        Duration(id_cluster,1) = d_tree(root2);   
    end
    
    InfiniteTau = 100;
    [Merged_forest,Duration,AugOriginalForest,LeefTable]  = ForestMerge(forest,func,ringv,InfiniteTau,Duration);
    
    death = Duration(:,3);
    if length(death) ~= 1
        min_death = min(death(2:end,1));
        idx = find(death == 0);
    else
        idx = 1;
        min_death = death(1,1);
    end
    Duration(idx,3) = min_death;
    
    Duration(:,4) = Duration(:,2) - Duration(:,3);

    
    %% Second run : (Merging)
    % TAU = [0,0.13];
    for i_tau = 1:1 %1:6
        tau_thred =  tau; %TAU(i_tau);
        [Merged_forest,Duration,AugOriginalForest,LeefTable]  = ForestMerge(forest,func,ringv,tau_thred,Duration);
%        displayClusters(vertices,Merged_forest,Duration,func);
    end
    
    Durations = [Durations;{Duration}];
%    plotPD(Duration);
%     plotMesh(vertices,faces,color);  
    
    num_trees = length(Merged_forest);
    
    if num_trees_initial <= num_trees
       Final_forest = Merged_forest;
       num_trees_initial = num_trees;
       idx_Final_forest = id_S;
    end
    
    end
       
    
    % Binary Tree Construction
%     InfiniteTau = 2;
%     [Merged_forest,AugOriginalForest,LeefTable] = FormBinaryTree(Final_forest,func,ringv,InfiniteTau);
    
    LeefItem = AugOriginalForest;
    
end %end of fucntion
   

%% connect the current point to its peak in the cluster
function [Updated_forest] = connect2cluster(current_node,highest_neighb,forest)

    Updated_forest = forest;
    
    num_trees = size(forest,1);
    for i = 1:num_trees
        tree = forest{i};
        
        ID = find(tree==highest_neighb);
        if length(ID)~=0
            tree = [tree,current_node];
            Updated_forest{i} = tree;
        end
    end 
%     
%     if count_nodes(forest) == count_nodes(Updated_forest)
%         disp('Failed to find the tree');
%         Updated_forest = [Updated_forest;{highest_neighb}];
%     end
    
end

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

%% merge two trees in the forest
function [Updated_forest,AugOriginalForest,LeefTable,parents_root] = MergeTrees(root_observation, root_target, forest,AugOriginalForest,LeefTable,func)
    
    Updated_forest = {};
    num_trees = length(forest);
    
    [num_AugOF,~ ] = size(LeefTable);
    idx_observation = vertice2LeefIdx(root_observation,AugOriginalForest);
    idx_target = vertice2LeefIdx(root_target,AugOriginalForest); 
    new_Leef = [num_AugOF+1,idx_observation,idx_target];
    LeefTable = [LeefTable;new_Leef];

    for i = 1:num_trees
        tree = forest{i};
        
        ID = find(tree==root_observation);
        if length(ID)~=0
            father_tree = tree;
            father_tree_func = func(father_tree); 
            [~, root2] = max(father_tree_func);
            father_root = father_tree(root2);
        end
    end
    
    for i = 1:num_trees
        mother_tree = forest{i};
        
        mother_tree_func = func(mother_tree); 
        [root_func, root2] = max(mother_tree_func);
        mother_root = mother_tree(root2);
            
        switch(mother_root) 
            case root_observation
                Updated_forest;
            case root_target
                
%                 L = length(parents_tree);
%                 L_unique = length(unique(parents_tree));
                if father_root ~= root_target
                    parents_tree = [mother_tree,father_tree];
                    parents_tree_func = func(parents_tree); 
                    [~, root2] = max(parents_tree_func);
                    parents_root = parents_tree(root2);
                    
                    Updated_forest = [Updated_forest;{parents_tree}];
                    
                    
                    AugOriginalForest = [AugOriginalForest;{parents_tree}];
                else
                    % disp('redundant element occurs.'); 
                    Updated_forest = [Updated_forest;{father_tree}];                    
                end
            otherwise
                Updated_forest = [Updated_forest;{mother_tree}];
        end
    end
    
     num = count_nodes(forest);
     Updated_num = count_nodes(Updated_forest);
     
     if num ~= Updated_num
          disp('Merging Error: Number of nodes is changed')
     end
end



%% display surface colored by the different clusters
function num = count_nodes(forest)
    num_trees = length(forest);

    vertices_list = [];
    for id_tree = 1:num_trees
        tree = forest{id_tree};
        vertices_list = [vertices_list,tree];
    end
    unique_vertices_list = unique(vertices_list);
    
    num = size(unique_vertices_list,2);

end

function [vertices_list ,unique_vertices_list] = nodes_list_recovery(forest)
    num_trees = length(forest);
    vertices_list = [];
    for id_tree = 1:num_trees
        tree = forest{id_tree};
        vertices_list = [vertices_list,tree];
    end
    unique_vertices_list = unique(vertices_list);
end

function [Merged_forest,Duration,AugOriginalForest,LeefTable] = ForestMerge(forest,func,ringv,tau,Duration)
    
    num_vertices = length(func);   

    num_trees = length(forest);
    
    LeefTable = zeros(num_trees,3);
    LeefTable(:,1) = 1:num_trees;
    AugOriginalForest = forest;
    
    
    
    [sorted_func,ID] = sort(func,1,'descend');
    
    IX = ID;
    
    Merged_forest = forest;
    for id = 1:num_vertices
    % while length(IX) ~= 0
        id;
        current_node = IX(id);
        current_func = func(current_node);
        persistence_func = current_func + tau;
        
        
        neighbs = ringv{current_node};
        neighbs_func = func(neighbs);
        
        
        idx = find(neighbs_func>=current_func);

        num_higher_neighbs = length(idx);
        if num_higher_neighbs ~= 0
           
            [mother_tree_current,root_current,root_func_current] = findRoot(current_node,Merged_forest,func);
            
            for j = 1:num_higher_neighbs
                higher_neighb = neighbs(idx(j));
                [mother_tree_neigh,root_neigh,root_func_neigh] = findRoot(higher_neighb,Merged_forest,func);
   
                if root_current ~= root_neigh
                    if root_func_current <= min(root_func_neigh,persistence_func)
                        % merge current tree to higher neighb tree 
                        [Merged_forest ,AugOriginalForest,LeefTable,parents_root] = ...
                            MergeTrees(root_current, root_neigh, Merged_forest,AugOriginalForest,LeefTable,func);
                        
                        [death_idx] = root2Table(root_current,Duration);
                        Duration(death_idx,3) = current_func;

                        
                        if parents_root ~= root_current
                            root_current = parents_root;
                        end
                        num = count_nodes(Merged_forest);
                    else
                    if root_func_neigh <= min(root_func_current,persistence_func)
                        % merge neighb tree to current tree
                        [Merged_forest,AugOriginalForest,LeefTable] = ...
                            MergeTrees(root_neigh, root_current, Merged_forest,AugOriginalForest,LeefTable,func);
                        [death_idx] = root2Table(root_neigh,Duration);
                        Duration(death_idx,3) = current_func;
                        num = count_nodes(Merged_forest);
                    end
                    end
                    
%                     if num ~= num_vertices
%                         stop = 1; 
%                     end
                    
                end
                

                     
                end
                
            end
    end
        
    Merged_forest;
end
    
    
function [Merged_forest,AugOriginalForest,LeefTable] = FormBinaryTree(forest,func,ringv,tau)
    
    num_vertices = length(func);   

    num_trees = length(forest);
    
    LeefTable = zeros(num_trees,3);
    LeefTable(:,1) = 1:num_trees;
    AugOriginalForest = forest;
    
    
    
    [sorted_func,ID] = sort(func,1,'descend');
    
    IX = ID;
    
    Merged_forest = forest;
    for id = 1:num_vertices
    % while length(IX) ~= 0
        id;
        current_node = IX(id);
        current_func = func(current_node);
        persistence_func = current_func + tau;
        
        
        neighbs = ringv{current_node};
        neighbs_func = func(neighbs);
        
        
        idx = find(neighbs_func>=current_func);

        num_higher_neighbs = length(idx);
        if num_higher_neighbs ~= 0
           
            [mother_tree_current,root_current,root_func_current] = findRoot(current_node,Merged_forest,func);
            
            for j = 1:num_higher_neighbs
                higher_neighb = neighbs(idx(j));
                [mother_tree_neigh,root_neigh,root_func_neigh] = findRoot(higher_neighb,Merged_forest,func);
   
                if root_current ~= root_neigh
                    if root_func_current <= min(root_func_neigh,persistence_func)
                        % merge current tree to higher neighb tree 
                        [Merged_forest ,AugOriginalForest,LeefTable,parents_root] = ...
                            MergeTrees(root_current, root_neigh, Merged_forest,AugOriginalForest,LeefTable,func);
                        

                        
                        if parents_root ~= root_current
                            root_current = parents_root;
                        end
                        num = count_nodes(Merged_forest);
                    end
                    if root_func_neigh <= min(root_func_current,persistence_func)
                        % merge neighb tree to current tree
                        [Merged_forest,AugOriginalForest,LeefTable] = ...
                            MergeTrees(root_neigh, root_current, Merged_forest,AugOriginalForest,LeefTable,func);

                        num = count_nodes(Merged_forest);
                    end
                end
                     
                end
                
            end
    end
        
    Merged_forest;
    end


    function [idx] = root2Table(root,Duration)
        idx = 0;
        num_duration = size(Duration,1);
        for i = 1:num_duration
            idx_root = Duration(i,1);
            if root == idx_root
                idx = i;
            end
        end
    end
    

    
    
    
function [idx] = vertice2LeefIdx(ver,AugOriginalForest)
        idx = 0;
        num_AugOF= size(AugOriginalForest,1);
        
        for i = num_AugOF:-1:1
            ind = find(AugOriginalForest{i} == ver);
            if length(ind)~=0
                idx = i;
                break;
            end
        end
end



