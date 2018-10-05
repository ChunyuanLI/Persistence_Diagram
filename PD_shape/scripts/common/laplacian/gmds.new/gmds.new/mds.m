% mds    Multidimensional scaling
%
% Usage:
%
%  X = mds(D,options)
%  [X,hist] = mds(D,options)
%
% Description: 
% 
%  Finds a configuration of points in Euclidean space with distances 
%  approximating the input matrix of distances D by solving a multidimensional 
%  scaling problem by SMACOF algorithm with vector extrapolation. 
%
% Input:  
% 
%  D       - symmetric matrix of distances
%  options - structure of options created using set_options and containing
%            the following fields: 
%             options.X0      - initialization, matrix of size N*dim (default: randn(N,dim))
%             options.dim     - embedding dimension
%                               NOTE: either dim or x0 must be set 
%             options.iter    - number of iterations in SMACOF method/
%                               internal iterations in RRE method (default: 25)
%             options.cycles  - number of cycles in RRE method (default: 5)
%             options.rtol    - relative stress change tolerance (default: 0.01)
%             options.atol    - absolute stress tolerance (default: 0)
%             options.method  - algorithm [smacof | rre] (default: rre)
%             options.display - level of display [cycle | iter] 
%                               (default: iter)
%
% Output:
%
%  X       - configuration of points in Euclidean space
%  hist    - history structure containing the following fields:
%             hist.s          - vector of stress values per iteration
%             hist.time       - vector of iteration duration in seconds
%
% References:
%
% [1] G. Rosman, A. M. Bronstein, M. M. Bronstein, R. Kimmel, 
% "Topologically constrained isometric embedding", 
% Proc. Conf. on Machine Learning and Pattern Recognition (MLPR), 2006.
%
% [2] A. M. Bronstein, M. M. Bronstein, R. Kimmel, 
% "Numerical geometry of non-rigid shapes", Springer, 2007.
%
% TOSCA = Toolbox for Surface Comparison and Analysis
% Web: http://tosca.cs.technion.ac.il
% Version: 0.9
%
% (C) Copyright Michael Bronstein, 2007
% All rights reserved.
%
% License:
%
% ANY ACADEMIC USE OF THIS CODE MUST CITE THE ABOVE REFERENCES. 
% ANY COMMERCIAL USE PROHIBITED. PLEASE CONTACT THE AUTHORS FOR 
% LICENSING TERMS. PROTECTED BY INTERNATIONAL INTELLECTUAL PROPERTY 
% LAWS AND PATENTS PENDING.

function [X,hist] = mds(D,options)

% check input correctness
if size(D,1) ~= size(D,2),
    error('Matrix D must be square, exiting.')     
end

% initialization
if ~isfield(options,'X0')
   if isfield(options,'dim')
      options.X0 = randn(size(D,1),options.dim);
   else
      error('Unknown initialization/dimension, exiting. Set dim or x0.') 
   end
end

% set defauls
if ~isfield(options,'cycles'),
   options.cycles = 5; 
end

if ~isfield(options,'rtol'),
   options.rtol = 0.01; 
end

if ~isfield(options,'atol'),
   options.atol = 0; 
end

if ~isfield(options,'method'),
   options.method = 'rre'; 
end

if ~isfield(options,'iter'),
   switch lower(options.method), 
       case 'rre', 
           options.iter = 10; 
       case 'smacof',
           options.iter = 50; 
   end
end


if ~isfield(options,'display'),
   options.display = 'iter'; 
end


% set flags
if nargout == 2,
    HISTORY = 1;
else
    HISTORY = 0;
end


% print
if strcmp(lower(options.display),'iter') | strcmp(lower(options.display),'cycle')
    fprintf(1,'Solving MDS problem of size %dx%d\nEmbedding dimension: %d\nMethod: %s\n',...
            size(D,1),size(D,1),size(options.X0,2),options.method) 
end


% start optimization
switch lower(options.method),
   case 'rre'      % vector extrapolation using RRE
        if HISTORY,
            [X,hist] = smacof_rre(D,options.X0,options.cycles,options.iter,...
                                 options.display,options.rtol,options.atol);
        else
            X = smacof_rre(D,options.X0,options.cycles,options.iter,...
                           options.display,options.rtol,options.atol);
        end
   case 'smacof'   % SMACOF
        if HISTORY,
            [X,hist] = smacof(D,options.X0,options.iter,...
                              options.display,options.rtol,options.atol);
        else
            X = smacof(D,options.X0,options.iter,...
                       options.display,options.rtol,options.atol);
        end
   otherwise
      error('Invalid method, exiting. Use method=smacof|rre.')
end

