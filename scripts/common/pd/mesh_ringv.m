function ringv = mesh_ringv(vertices,faces)

% mesh_ringv - compute the 1 ring of each vertex in a triangulation.
%
%   ringv = mesh_ringv(vertices,faces);
%
%   ringv{i} returns the set of vertices that are adjacent to vertex i.
%
%===============
% Example usage:
%===============
% clear all; close all;
% load mesh2D;
% [vertices,faces] = mesh_subdivide(vertices,faces,1);
% A = mesh_adjacency(vertices,faces);
% set(patch('Vertices', vertices,'faces',faces),'facecolor',[.9 .9 .9],'EdgeColor',[.4 .4 .4]);
% hold on; plotnetwork(A,vertices,1);
% ringv = mesh_ringv(vertices,faces);
% i = 16; %vertex i
% mesh_highlight(A,vertices,[i ringv{i}],'r'); 
% figure;
% set(patch('Vertices', vertices,'faces',faces),'facecolor',[.9 .9 .9],'EdgeColor',[.4 .4 .4]);
% hold on; gplot(A,vertices,'b'); 
% plot(vertices(:,1),vertices(:,2),'ro','LineWidth',2,'MarkerEdgeColor',...
%   'k','MarkerFaceColor','g','MarkerSize',5);
% mesh_highlight(A,vertices,[i ringv{i}],'r');
% vi = vertices(ringv{i},:);
% hold on; plot(vi(:,1),vi(:,2),'ro','LineWidth',2,'MarkerEdgeColor','b','MarkerFaceColor',[.8 .8 .8],...
%                'MarkerSize',8);
% hold on; plot(vertices(i,1),vertices(i,2),'ro','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','y',...
%                'MarkerSize',8);

if nargin<1
    help mesh_ringv
    return
end

m = length(vertices);
A = mesh_adjacency(vertices,faces);
d = sum(A);
[r,c] = find(A); 
ringv = mat2cell(r.',1,d); %=mat2cell(r.',1,histc(c,1:size(A,1)))

% or using (but slower code)
% [i,j,v] = find(A);
% % create empty cell array
% ringv{m} = [];
% for k = 1:length(i)
%     ringv{i(k)}(end+1) = j(k);
% end