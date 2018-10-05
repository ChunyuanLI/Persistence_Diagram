function A = mesh_adjacency(vertices,faces)

% compute the adjacency matrix of a triangle mesh.
% A = mesh_adjacency(vertices,faces);
% A_{ii}= 0 and A_{ij}=1 if i~j
%
% Example usage:
% ==============
% load bunny.mat;
% A = mesh_adjacency(vertices,faces);
% spy(A);

if nargin<1
    help mesh_adjacency
    return
end


m = length(vertices);
edgelist = [[faces(:,1),faces(:,2)];[faces(:,1),faces(:,3)];[faces(:,2),faces(:,3)]]; 
edgelist = unique(sort(edgelist,2),'rows'); 

A = sparse(edgelist(:,1),edgelist(:,2),1,m,m); 
 
A = A + A'; 