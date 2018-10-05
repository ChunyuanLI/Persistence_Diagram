% init_surface    Initializes a surface representation structure
%
% Usage:
%
%  [surface] = init_surface (TRIV, X, Y, Z, [opt])
%  [surface] = init_surface (surface, [opt])
%
% Description:
%  
%  Creates an internal representation of a surface for subsequent use 
%  by the TOSCA functions.
%
% Input: 
%
%  TRIV    - ntx3 triangulation matrix with 1-based indices (as the one
%            returned by the MATLAB function delaunay).
%  X,Y,Z   - vectors with nv vertex coordinates.
%  surface - alternative way to specify the mesh as a struct, having .TRIV,
%            .X, .Y, and .Z as its fields.
%  opt     - (optional) settings
%             .verbose - Verbosity level (default: 1)
%                        0 - no display
%                        1 - display progress and surface parameters
%
% Output:
%
%  surface - surface representation structure, comprising the following
%            fields:
%   .X,.Y,.Z - vertex coordinates
%   .E       - list of edges, each row corresponding to a pair of vertices
%              defining an edge
%   .TRIV    - triangulation by vertex matrix, each row corresponds to a 
%              triangle represented by three vertices [v1 v2 v3]
%   .TRIE    - triangulation by edge matrix, each row corresponds to a
%              triangle represented by three edges [e1 e2 e3]
%   .ETRI    - list of edge sharings, each row represents two triangle
%              indices sharing the same edge from .E; one of the entries
%              set to NaN denotes a boundary edge.
%   .VTRI    - cell array containing the list of triangles sharing a
%              mesh vertex.
%   .ADJV    - cell array containing the list of adjacent vertices for
%              each mesh vertex.
%   .D       - full matrix of geodesic distances between the points
%   .diam    - the mesh diameter (maximum geodesic distance)
%   .nv      - number of vertices
%   .nt      - number of triangles
%   .ne      - number of edges
%   .genus   - mesh genus
%
% References:
%
% [1] A. M. Bronstein, M. M. Bronstein, R. Kimmel, "Generalized multidimensional 
%     scaling: a framework for isometry-invariant partial surface matching", 
%     Proc. National Academy of Sciences (PNAS), Vol. 103/5, pp. 1168-1172, 
%     January 2006.
% 
% [2] A. M. Bronstein, M. M. Bronstein, R. Kimmel, "Efficient computation of
%     isometry-invariant distances between surfaces", SIAM Journal of 
%     Scientific Computing, Vol. 28/5, pp. 1812-1836, 2006.
%
% [3] A. M. Bronstein, M. M. Bronstein, R. Kimmel, "Calculus of non-rigid
%     surfaces for geometry and texture manipulation", IEEE Trans. 
%     Visualization and Computer Graphics.
%
% TOSCA = Toolbox for Surface Comparison and Analysis
% Web: http://tosca.cs.technion.ac.il
% Version: 0.9
%
% (C) Copyright Alex Bronstein, 2007. All rights reserved.
%
% License:
%
% ANY ACADEMIC USE OF THIS CODE MUST CITE THE ABOVE REFERENCES. 
% ANY COMMERCIAL USE PROHIBITED. PLEASE CONTACT THE AUTHORS FOR 
% LICENSING TERMS. PROTECTED BY INTERNATIONAL INTELLECTUAL PROPERTY 
% LAWS AND PATENTS PENDING.


function surface = init_surface (TRIV, X, Y, Z, opt)

% Constants
MAX_VERT_COUNT = 4000;


if nargin >= 4,
    surface = [];
    surface.X = X;
    surface.Y = Y;
    surface.Z = Z;
    surface.TRIV = TRIV;
    if nargin < 5, opt = []; end
else
    surface = TRIV;
    X = surface.X;
    Y = surface.Y;
    Z = surface.Z;
    TRIV = surface.TRIV;
    if nargin < 2, opt = []; else opt = X; end
end



% Options
if ~isfield(opt,'verbose'),     opt.verbose = 1;  else   verbose = opt.verbose;	end

if length(X) > MAX_VERT_COUNT,
    error(sprintf('Current version of TOSCA can only work with meshes having less than %d vertices.\nUse remesh to reduce the vertex count.\n', MAX_VERT_COUNT));
end


% Initialize mesh structures

if opt.verbose > 0, fprintf(1,'Surface initialization\n'); end


if opt.verbose > 0, fprintf(1,'Computing mesh structures...\n'); end

% Reset mesh structures
surface.TRIE = [];
surface.ETRI = [];

% Create the edges structure
E = sort([TRIV(:,2) TRIV(:,3); TRIV(:,1) TRIV(:,3); TRIV(:,1) TRIV(:,2)],2);
[E,i,j] = unique(E,'rows');
surface.E = E;

% Create the triangle-by-edge structure
surface.TRIE = [j(1:end/3) j(end/3+1:2*end/3) j(2*end/3+1:end)];

% Create neighbouring triangles structure for each edge
% TO DO: more efficient C implementation!
surface.ETRI = zeros(length(E),2);
for e=1:length(E),
    idx = find(surface.TRIE(:,1) == e | surface.TRIE(:,2) == e | surface.TRIE(:,3) == e)';
    if length(idx(:))==1,
        idx = [idx(:); NaN];
    end
    idx = idx(1:2);
    surface.ETRI(e,:) = idx(:)';
end

% Create neighboring triangles structure for each vertex
% TO DO: more efficient C implementation!
surface.VTRI = cell(length(surface.X),1);
surface.ADJV = cell(length(surface.X),1);
for v = 1:length(surface.X),
    surface.VTRI{v} = find(surface.TRIV(:,1) == v | surface.TRIV(:,2) == v | surface.TRIV(:,3) == v);
    surface.ADJV{v} = setdiff(unique(surface.TRIV(surface.VTRI{v},:)), v);
end


% Initialize embedding structures
if opt.verbose > 0, fprintf(1,'Computing intrinsic geometry...\n'); end

% Compute geodesic distances
surface.D      = fastmarch (surface);
surface.diam   = max(surface.D(:));

% Compute mesh quantities
surface.nv    = length(X);
surface.nt    = size(TRIV,1);
surface.ne    = length(E);
surface.genus = 1-0.5*(surface.nv-surface.ne+surface.nt);

if opt.verbose > 0,
    fprintf(1,'Vertices\t\t%d\n',   surface.nv);
    fprintf(1,'Faces   \t\t%d\n',   surface.nt);
    fprintf(1,'Edges   \t\t%d\n',   surface.ne);
    fprintf(1,'Genus   \t\t%.1f\n', surface.genus);
    fprintf(1,'Diameter\t\t%d\n\n',   surface.diam);
end









