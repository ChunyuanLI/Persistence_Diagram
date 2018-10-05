function  Persistence_Analysis()

    clear
    clc

    OFFDIRs = 'C:\Users\MeshPool\Dropbox\Research\Mesh_Retrieval\Reeb\Data_SHREC_2011\';
    EigenDIRs = 'C:\Users\MeshPool\Dropbox\Research\Mesh_Retrieval\Reeb\Eigen_SHREC_2011\';
    TreeDIRs = 'C:\Users\MeshPool\Dropbox\Research\Mesh_Retrieval\Reeb\Tree_SHREC_2011_Max\';

    imgs = dir([OFFDIRs,'*.mat']);
    eigens = dir([EigenDIRs,'*.mat']);
    trees = dir([TreeDIRs,'*.mat']);
    N_file = length(trees);
  
   load('GroundTruth_SHREC2011.mat');
   [num_obj, num_class] = size(GroundTruth);
    % GroundTruth();
%     ceataur =  [137;30;50;124;290;]+1;
%     horse   =  [473;344;201;403;226;]+1;
% 
%     small_dataset = [ceataur;horse];    
%     N_file = length(small_dataset);
%     
    
%     load('SHREC2011_HKS_Vocabulary_L2_32.mat');
%     k = 32;
%     [m,n] = size(DD);
%     theta = zeros(m,n);
%     for mm = 1:m
%         theta(mm,IDX(mm)) = 1;
%     end
    
    num_tier = 6;
    
    D_cell = cell(N_file,N_file);
    
    Num_Parts = zeros(num_obj, num_class);
    
for n = 1:num_obj
    for m =   1:num_class
       nn = GroundTruth(n,m)+1;
    % nn = n; %small_dataset(n);
    load([TreeDIRs,trees(nn).name]);
    LeefTables_A = LeefTable; LeefItem_A = LeefItem; 
    ringv = mesh_ringv(vertices,faces);
    
    nodes = find(LeefTables_A(:,2)==0);
    num_nodes = nodes(end);
    Adj_M = zeros(num_nodes,num_nodes);
    
    for c = 1:num_nodes
    c_ring = cell2mat( ringv(LeefItem{c}));
    for n = 1:num_nodes
        n_ring = cell2mat( ringv(LeefItem{n}));
        % check neighboring
        
        if c ~= n
        temp = intersect(c_ring, n_ring);
        % In case there is neighbour between two component
        if length(temp)>0
            % connect the componets represented index
            Adj_M(c,n) = 1;
        end
        end
    end
    end
    
seg = meaningful
correspondence

% bottleneck distance

    
    Adj_M;
    
    
    
    
    
    for i = 1:num_nodes
        for j = 1:num_nodes
            ver_in_i = LeefItem{i};
            ver_in_j = LeefItem{j};
            for idx_ring = 1:length(ver_in_i)
                temp_ring = ringv{idx_ring};
                if length(intersect(temp_ring,ver_in_j)) > 0
                    Adj_M(i,j) = 1;
                    Adj_M(j,i) = 1;
                    break;
                end
            end
            
            for idx_ring = 1:length(ver_in_j)
                temp_ring = ringv{idx_ring};
                if length(intersect(temp_ring,ver_in_i))> 0
                    Adj_M(i,j) = 1;
                    Adj_M(j,i) = 1;
                    break;
                end
            end
            
        end
    end
    Adj_M;
    
    % state_A = [theta(Length_Vectors(nn):Length_Vectors(nn+1)-1,:)];
    
    Root_A = LeefTables_A(end,:);
    
    % num = count_nodes(forest)
    
    Num_Parts(n, m) = num_leef_A;
    end
  
end
  

end


function [CorrespondencePair, DistancePair] = findPairCorrespd(Pair,state_A,LeefItem_A,state_B,LeefItem_B)

D = zeros(2,2);
DistancePair = zeros(1,2);

for i = 1:2
    for j = 1:2
        idx_A = Pair(i,1);
        idx_B = Pair(j,2);
        d = ID2distance(idx_A,state_A,LeefItem_A, idx_B,state_B,LeefItem_B);
        D(i,j) = d; 
    end
end

subsum1 = D(1,1)+D(2,2);
subsum2 = D(2,1)+D(1,2);
%[C,I] = min(subsum1,subsum2,1);

if subsum1 < subsum2
    CorrespondencePair = Pair;
    DistancePair = [D(1,1),D(2,2)];
else
    CorrespondencePair = [Pair(:,1),flipud(Pair(:,2))];
    DistancePair = [D(1,2),D(2,1)];
end

end


function [d] = ID2distance(idx_A,state_A,LeefItem_A, idx_B,state_B,LeefItem_B)

k = 32;

if idx_A == 0
       FA = zeros(1,k);
       FB = sum(state_B(LeefItem_B{idx_B},:),1);
else
    
   if idx_B == 0
       FA = sum(state_A(LeefItem_A{idx_A},:),1);
       FB = zeros(1,k);
   else
       FA = sum(state_A(LeefItem_A{idx_A},:),1);
       FB = sum(state_B(LeefItem_B{idx_B},:),1);
   end
    
end

% FA = FA./(repmat (sum(FA,2),1,k)+eps);
% FB = FB./(repmat (sum(FB,2),1,k)+eps);

d = sum(abs((FA-FB).^2/(FA+FB)));   

end
 




function [ num_tier, distance]= find_children_to_compare(num_tier,distance,...
                                          i_travel_A,LeefTables_A,state_A,LeefItem_A,...
                                          i_travel_B,LeefTables_B,state_B,LeefItem_B)

    i_parent_A = LeefTables_A(i_travel_A,1);
    i_left_A = LeefTables_A(i_travel_A,2);
    i_right_A = LeefTables_A(i_travel_A,3);

    i_parent_B = LeefTables_B(i_travel_B,1);
    i_left_B = LeefTables_B(i_travel_B,2);
    i_right_B = LeefTables_B(i_travel_B,3);
    
    distance_parent = ID2distance(i_parent_A,state_A,LeefItem_A, i_parent_B,state_B,LeefItem_B);
           
    % Leaf of Tree A is empty
    if i_left_A == 0 && i_left_B ~= 0
        
         Pair = [i_parent_A,i_left_B;...
                    i_parent_A,i_right_B]; 
 
    else
    % Leaf of Tree B is empty
        if i_left_B == 0 && i_left_A ~= 0
            
                  Pair = [i_left_A,i_parent_B;...
                            i_right_A,i_parent_B]; 

        else
    % Leaf of Tree A and Tree B are full
            	Pair = [i_left_A,i_left_B;...
                    i_right_A,i_right_B];
          
        end
    end
    
    num_Nonzeros = find(Pair~=0);
    if length(num_Nonzeros)
        
    [CorrespondencePair, DistancePair] = findPairCorrespd(Pair,state_A,LeefItem_A,state_B,LeefItem_B);
    distance_children = sum(DistancePair);
    distance = distance + (distance_parent - distance_children).*2^(num_tier); 
    
    
    temp_num_tier = num_tier + 1;
    [ num_tier, distance]= find_children_to_compare(temp_num_tier,distance,...
                                          CorrespondencePair(1,1),LeefTables_A,state_A,LeefItem_A,...
                                          CorrespondencePair(1,2),LeefTables_B,state_B,LeefItem_B);
                                      
    [ num_tier, distance]= find_children_to_compare(temp_num_tier,distance,...
                                          CorrespondencePair(2,1),LeefTables_A,state_A,LeefItem_A,...
                                          CorrespondencePair(2,2),LeefTables_B,state_B,LeefItem_B);
                                      
                                    
                                   
    else
        
        distance = distance + distance_parent * 2^num_tier;
    end
    
end


function [ num_tier, distance]= find_balanced_children_to_compare(num_tier,distance,BalancedTier,...
                                          i_travel_A,LeefTables_A,state_A,LeefItem_A,...
                                          i_travel_B,LeefTables_B,state_B,LeefItem_B)

    i_parent_A = LeefTables_A(i_travel_A,1);
    i_left_A = LeefTables_A(i_travel_A,2);
    i_right_A = LeefTables_A(i_travel_A,3);

    i_parent_B = LeefTables_B(i_travel_B,1);
    i_left_B = LeefTables_B(i_travel_B,2);
    i_right_B = LeefTables_B(i_travel_B,3);
    
    distance_parent = ID2distance(i_parent_A,state_A,LeefItem_A, i_parent_B,state_B,LeefItem_B);
           
    % Leaf of Tree A is empty
    if i_left_A == 0 && i_left_B ~= 0
        
         Pair = [i_parent_A,i_left_B;...
                    i_parent_A,i_right_B]; 
 
    else
    % Leaf of Tree B is empty
        if i_left_B == 0 && i_left_A ~= 0
            
                  Pair = [i_left_A,i_parent_B;...
                            i_right_A,i_parent_B]; 

        else
            
            if i_left_B ~= 0 && i_left_A ~= 0
    % Leaf of Tree A and Tree B are full
            	Pair = [i_left_A,i_left_B;...
                    i_right_A,i_right_B];
                
            else
    % Leaf of Tree A and Tree B are empty
            	Pair = [i_left_A,i_left_B;...
                    i_right_A,i_right_B];
        
            end
          
        end
    end
    
    num_zeros = find(Pair==0);
    
    if num_tier == BalancedTier
        distance = distance + distance_parent; % * 2^num_tier;
        return;
    else
        if length(num_zeros) == 4 
        
             Pair = [i_parent_A,i_parent_B;...
                    i_parent_A,i_parent_B];
        end 
            
    [CorrespondencePair, DistancePair] = findPairCorrespd(Pair,state_A,LeefItem_A,state_B,LeefItem_B);
    distance_children = sum(DistancePair);
    % distance = distance + (distance_children - distance_parent).*2^(num_tier); 
   
    temp_num_tier = num_tier + 1;
    [ num_tier, distance1]= find_balanced_children_to_compare(temp_num_tier,distance,BalancedTier,...
                                          CorrespondencePair(1,1),LeefTables_A,state_A,LeefItem_A,...
                                          CorrespondencePair(1,2),LeefTables_B,state_B,LeefItem_B);
                                      
    [ num_tier, distance2]= find_balanced_children_to_compare(temp_num_tier,distance,BalancedTier,...
                                          CorrespondencePair(2,1),LeefTables_A,state_A,LeefItem_A,...
                                          CorrespondencePair(2,2),LeefTables_B,state_B,LeefItem_B);
      distance = distance + distance1 + distance2 ;
     return;
    end
    
end 

%% display surface colored by the different clusters
function displayClusters(vertices,faces,forest)
    num_vertices = length(vertices);
    color = zeros(num_vertices,1);
    num_trees = length(forest);
    
    for id_tree = 1:num_trees
        tree = forest{id_tree};
        num_node = length(tree);
        color(tree,1) = id_tree;
    end
    
    % color = idx;
    plotMesh(vertices,faces,color);
end

%% display surface colored by the different clusters
function num = count_nodes(forest)
    num_trees = length(forest);
    num = 0;
    for id_tree = 1:num_trees
        tree = forest{id_tree};
        num_node = length(tree);
        num = num + num_node;
    end
end
