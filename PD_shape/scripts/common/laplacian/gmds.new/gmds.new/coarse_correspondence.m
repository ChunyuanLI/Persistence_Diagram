% coarse_correspondence    Finds coarse intrinsic correspondence between two surfaces
%
% Usage:
%
%  [ref_x, ref_y] = coarse_correspondence (surface_x, surface_y, [ncorr], [R], [p], [opt])
%
% Description:
%  
%  Computes a coarse intrinsic correspondence between surface X and surface 
%  Y using a greedy pairing algorithm. Since the surface X is embedded into
%  surface Y, X can be a subset of Y.
%
% Input: 
% 
%  surface_x - representation of the surface X returned by the function
%              initi_surface.
%  surface_y - representation of the surface Y returned by the function
%              initi_surface.
%  ncorr     - coarse correspondence size (default: 8)
%  R         - subsampling radius of the surface Y in multiples of the
%              diameter (default: 0.1)
%  p         - p in Lp used to measure distortion (default: 2)
%  opt       - (optional) settings
%               .verbose - Verbosity level (default: 1)
%                          0 - no display
%                          1 - display progress
%               .bnb     - Run branch & bound algorithm (default: 1)
%
% Output: 
%
%  ref_x     - indices of ncorr points on X.
%  ref_y     - indices of the corresponding points on Y.
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

function [ref_x, ref_y] = coarse_correspondence (surface_x, surface_y, ncorr, R, p, opt);

% Parameters
if nargin < 3,  ncorr = 8;      end
if nargin < 4,  R = 0.1;        end
if nargin < 5,  p = 2;          end
if nargin < 6,  opt = [];       end

if ~isfield(opt,'verbose'),     opt.verbose = 1;  else   verbose = opt.verbose;	end
if ~isfield(opt,'bnb'),         opt.bnb = 1;      end


N = ncorr;

if opt.verbose > 0, fprintf(1,'Coarse correspondence\n'); end
if opt.verbose > 0, fprintf(1,'Subsampling surface X...\t'); end

% Subsample X
[m,i] = max(surface_x.D);
[diam_x,j] = max(m); i = i(j);
[idx_x,rad_x] = farthest_point_sample(surface_x, 'size', N, j);

if opt.verbose > 0, fprintf(1,'points = %-4d  radius = %-8.6f\n', length(idx_x), rad_x(end)); end
if opt.verbose > 0, fprintf(1,'Subsampling surface Y...\t'); end

% Subsample Y
[m,i] = max(surface_y.D);
[diam_y,j] = max(m); i = i(j);
[idx_y,rad_y] = farthest_point_sample(surface_y, 'radius', R*surface_y.diam, j);

M = length(idx_y);

if opt.verbose > 0, fprintf(1,'points = %-4d  radius = %-8.6f\n', length(idx_y), rad_y(end)); end


if opt.verbose > 0, fprintf(1,'Computing best correspondence...\n'); end

% Find best correspondence in Y for the pair of most distant points in X.
dx = surface_x.D(idx_x(1),idx_x(2));
dis = abs(surface_y.D(idx_y(1:M),idx_y(1:M)) - dx);
[dis,i] = min(dis);
[dis,j] = min(dis); i = i(j);
i = idx_y(i);
j = idx_y(j);

% The correspondence can be permuted, try finding the best third point and
% resolve permutation.
k = 3;

% First possibility {y_i, y_j}
dx = surface_x.D(idx_x(k),idx_x(1:k-1));
dy = surface_y.D(idx_y(1:M),[i j]);
d = (repmat(dx,[size(dy,1) 1]) - dy);
if p < Inf,
    d = sum(abs(d).^2,2);
else
    d = max(d,[],2);
end
[d1,ii] = min(d);
idx_dst1 = [i; j; idx_y(ii)];

% Second possibility {y_j, y_i}
dx = surface_x.D(idx_x(k),idx_x(1:k-1));
dy = surface_y.D(idx_y(1:M),[j i]);
d = (repmat(dx,[size(dy,1) 1]) - dy);
if p < Inf,
    d = sum(abs(d).^2,2);
else
    d = max(d,[],2);
end
[d2,ii] = min(d);
idx_dst2 = [j; i; idx_y(ii)];

% Select the permutation giving minimum distortion
[d,i] = min([d1 d2]);
idx_dst = [idx_dst1(:) idx_dst2(:)];
idx_dst = idx_dst(:,i);

% Greedy algorithm to select the remaining points
idx_src = idx_x(1:N);
for k=4:N,
    dx = surface_x.D(idx_x(k),idx_x(1:k-1));
    dy = surface_y.D(idx_y(1:M),idx_dst);
    d = (repmat(dx,[size(dy,1) 1]) - dy);
    if p < Inf,
        d = sum(abs(d).^p,2);
    else
        d = max(d,[],2);
    end
    %d = max(abs(d),[],2);
    [d,i] = min(d);
    idx_dst = [idx_dst(:); idx_y(i)];
end

ref_x = idx_src;
ref_y = idx_dst;

% Run B&B
if opt.bnb,

    dx = surface_x.D(ref_x,ref_x);
    dy = surface_y.D(ref_y,ref_y);
    bound = max(max(abs(dx-dy)));

    if opt.verbose > 0, fprintf(1,'Running B&B algorithm, bound = %8.6f...\n', bound); end

    C = repmat(idx_y(:)', [length(ref_x) 1]);
    [d, ref_y_, bound] = bnb (0, [], ref_x, C, bound, surface_x.D(ref_x,ref_x), surface_y.D);
    if length(ref_y_) == length(ref_y),
        ref_y = ref_y_;
    end
end

if opt.verbose > 0, fprintf(1,'Corresponding points\t\t%-4d\nL%d distortion\t\t\t\t%-8.6f\n\n', length(ref_x), p, d); end
    



