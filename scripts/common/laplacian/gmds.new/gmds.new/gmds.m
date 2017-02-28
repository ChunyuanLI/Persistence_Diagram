% gmds    Generalized multidimensional scaling solver
%
% Usage:
%
%  [tx, ux, ty, uy, f, rmsdist, maxdist, locdist] = 
%      gmds (surface_x, surface_y, [m], [levels], [p], [ref_x], [ref_y], [opt])
%
% Description:
%  
%  Computes the intrinsic correspondence between surface X and surface 
%  Y by solving the generalized multidimensional scaling (GMDS) problem. 
%  The solver uses a multi-resolution approach and is initialized by a 
%  coarse correspondence provided as ref_x and ref_y. 
%
% Input: 
% 
%  surface_x - representation of the surface X returned by the function
%              initi_surface.
%  surface_y - representation of the surface Y returned by the function
%              initi_surface.
%  m         - sample size (default: 50)
%  levels    - number of levels in the multi-resolution hierarchy. 
%              (default: adjusted according to m).
%  p         - p in Lp used to measure distortion (default: 2)
%              For p other than 2, the iteratively reweighted least squares
%              (IRLS) solver will be used.
%  ref_x     - indices of initial points on X.
%              (default: computed using coarse_correspondence).
%  ref_y     - indices of the corresponding initial points on Y.
%              (default: computed using coarse_correspondence).
%  opt       - (optional) settings
%               .verbose - Verbosity level (default: 1)
%                          0 - no display
%                          1 - display progress
%               .irlsiter - number of IRLS iterations (default: 25)
%                          valid only for p other than 2.
%               .minirlsrelchange - minimum relative stress change used
%                          as stopping condition in the IRLS solver.
%                          (default: 0.001)
%               .extiter  - number of iteration used to refine the set of 
%                           points on X in addition to refining that on Y.
%                           (default: 2)
%               .minextrelchange - minimum relative stress change to stop
%                           the iterative refinement of the set of points on X
%                           (default: 0.001)
%               .maxiter  - maximum number of iterations (default: 1000)
%               .mingrad  - minimum gradient norm (default: 1e-8)
%
% Output: 
%
%  tx, ux    - barycentric representation of a set of m points on X
%              tx - triangle index
%              ux - mx3 matrix, specifying the barycentric coordinates of
%                   the point relative to the corresponding triangle. 
%  ty, uy    - barycentric representation of the corresponding set of m
%              points on Y
%  f         - final stress value
%  rmddist   - final RMD distortion of the correspondence
%  maxdist   - final Linf distortion of the correspondence
%  locdist   - local distortion, an mxm matrix containing the distortions
%              |d_X(x_i,x_j) - d_Y(y_i,y_j)| as its elements.
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
% (C) Copyright Alex Bronstein, 2005-2007. All rights reserved.
%
% License:
%
% ANY ACADEMIC USE OF THIS CODE MUST CITE THE ABOVE REFERENCES. 
% ANY COMMERCIAL USE PROHIBITED. PLEASE CONTACT THE AUTHORS FOR 
% LICENSING TERMS. PROTECTED BY INTERNATIONAL INTELLECTUAL PROPERTY 
% LAWS AND PATENTS PENDING.

function [tx, ux, ty, uy, f, rmsdist, maxdist, locdist] = gmds (surface_x, surface_y, m, levels, p, ref_x, ref_y, opt)

if nargin < 3 | isempty(m),  m = 50;         end
if nargin < 4 | isempty(levels),
    if m < 10,
        levels = 1; 
    else
        levels = round(1.1*log2(m)); 
    end
end
if nargin < 5 | isempty(p),  p = 2;          end
if nargin < 8,  opt = [];       end

if ~isfield(opt,'verbose'),             verbose   = 1;              else    verbose = opt.verbose;                      end    

if ~isfield(surface_x, 'D') | ~isfield(surface_y, 'D'),
    error('Uninitialized surfaces. Use init_surface.');
end

if nargin < 7 | (nargin >= 7 & (length(ref_x) < 3 | length(ref_y) < 3)),  
    if nargin >= 7 & (length(ref_x) < 3 | length(ref_y)),
        warning('|ref_x|,|ref_y| < 3. Using coarse_correspondence to initialize GMDS.');
    end
    [ref_x, ref_y] = coarse_correspondence (surface_x, surface_y, 8, 0.2, p, opt);
end

if verbose >= 1,
   fprintf(1, 'Generalized Multidimensional Scaling Solver\n'); 
   fprintf(1, 'Samples    \t%-4d\n', m); 
   fprintf(1, 'Levels     \t%-4d\n', levels);
   fprintf(1, 'Distortion \tL%d\n', p); 
   fprintf(1, 'Solving...\n');
end


opt.verbose = 0;

% Prepare multi-resolution grid hierarchy
bottom_level = length (ref_x);
if levels > 1, 
    factorm = exp(log(m/bottom_level)/(levels-1));
    ms = round(bottom_level.*factorm.^[0:levels-1]);
    ms(levels) = m;
else
    ms = m;
end
% Output: ms - vector of m numbers containing the sizes of each grid in the
% hierarcy.


% Sample X at full resolution
idxv_x = farthest_point_sample(surface_x, 'size', m, ref_x);
tx = zeros(length(idxv_x),1);
ux = zeros(length(idxv_x),3);
for v = 1:length(tx),
    tx(v) = surface_x.VTRI{idxv_x(v)}(1);
    idxv = surface_x.TRIV(tx(v),:);
    idxv = find(idxv == idxv_x(v));
    ux(v,idxv) = 1;
end
ux = ux(:,1:2);
% Output: tx,ux - barycentric coordinates of m points on X.


% Produce initial sampling of Y
idxv_y = ref_y;
ty = zeros(length(idxv_y),1);
uy = zeros(length(idxv_y),3);
for v = 1:length(ty),
    ty(v) = surface_y.VTRI{idxv_y(v)}(1);
    idxv = surface_y.TRIV(ty(v),:);
    idxv = find(idxv == idxv_y(v));
    uy(v,idxv) = 1;
end
uy = uy(:,1:2);
% Output: ty,uy - barycentric coordinates of bottom_level points on Y.


fs = zeros(length(ms),1);


% 
res = 1;
m = ms(res);
W = ones(m,m);
if verbose >= 1, fprintf(1,' Level %-3d:\t points = %-4d \t', res, m); end

    [tx_, ux_, ty, uy, f, normg, iter, locdist] = minimize_stress_irls (surface_x, surface_x, surface_y, surface_y, tx(1:m), ux(1:m,:), ty, uy, W, p, opt);
    tx(1:m) = tx_;
    ux(1:m,:) = ux_;
    f = f/sum(W(:));
    fs(res) = f;
    rmsdist = locdist;
    rmsdist = sqrt(mean(rmsdist(:)));    
    if verbose >= 1, fprintf(1,'   stress = %8.6f \t RMS = %8.6f \t iter = %-4d\n', f, rmsdist, iter); end

for res = 2:length(ms),
    m = ms(res);
    [ty, uy] = geodesic_interp (surface_x, surface_y, tx(1:m), ux(1:m,1:2), ty, uy);
    
    W = ones(m,m);
    if verbose >= 1, fprintf(1,' Level %-3d:\t points = %-4d \t', res, m); end
    [tx_, ux_, ty, uy, f, normg, iter, locdist] = minimize_stress_irls (surface_x, surface_x, surface_y, surface_y, tx(1:m), ux(1:m,:), ty, uy, W, p, opt);
    tx(1:m) = tx_;
    ux(1:m,:) = ux_;
    f = f/sum(W(:));
    fs(res) = f;
    rmsdist = locdist;
    rmsdist = sqrt(mean(rmsdist(:)));    
    if verbose >= 1, fprintf(1,'   stress = %8.6f \t RMS = %8.6f \t iter = %-4d\n', f, rmsdist, iter); end

end


if verbose >= 1,
    maxdist = sqrt(max(locdist(:)));
    fprintf(1, 'Optimization terminated.\n');
    fprintf(1, 'RMS distortion  = %8.6f \t %.4f*diam(X) \t %.4f*diam(Y)\n', rmsdist, rmsdist/surface_x.diam, rmsdist/surface_y.diam);
    fprintf(1, 'Max. distortion = %8.6f \t %.4f*diam(X) \t %.4f*diam(Y)\n\n', maxdist, maxdist/surface_x.diam, maxdist/surface_y.diam); 
end



