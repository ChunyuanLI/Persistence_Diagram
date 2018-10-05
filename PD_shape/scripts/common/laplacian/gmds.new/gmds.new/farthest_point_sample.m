% farthest_point_sample    Farthest point surface sampling
%
% Usage:
%
%  [idx, rad] = farthest_point_sample (surface, 'size', ns, src, idx0)
%  [idx, rad] = farthest_point_sample (surface, 'radius', rs, src, idx0)
%
% Description:
%  
%  Creates a uniform sub-sampling of a triangular mesh using the farthest
%  point strategy.
%
% Input: 
%
%  surface  - surface representation created by the function init_surface.
%  stop     - stopping criterion, can be one of the following:
%              'size' - produces a sampling of size specified by ns.
%              'radius' - produces a sampling of radius specified by rs.
%  ns       - number of samples to produce in the sub-sampling.
%  rs       - target radius of the sub-sampling.
%  src      - list of indices, containing the initial set of samples.
%             (default: first sample is selected to maximize the distance)
%  idx0     - list of indices to exclude from the sampling.
%             (default: [])
%
% Output:
%
%  idx      - list of indices of the produced sample points
%  rad      - sampling radius; rad(i) = radius of the set idx(1:i).
%
% TOSCA = Toolbox for Surface Comparison and Analysis
% Web: http://tosca.cs.technion.ac.il
% Version: 0.9
%
% (C) Copyright Alex Bronstein, 2004-2007. All rights reserved.

function [idx, rad] = farthest_point_sample (surface, stop, crit, src, idx0)

if nargin < 4 | isempty(src),
    [m,i] = max(surface.D);
    [diam,j] = max(m); i = i(j);
    src = j;
end

N = length(surface.X);
if strcmpi(stop, 'size'),
    ns = crit;
    rs = 0;
elseif strcmpi(stop, 'radius'),
    rs = crit;
    ns = N;
else
    error('Stopping criterion must be either "size" or "radius".\n Type help farthest_point_sample for more information.\n');
end

idx = zeros(N,1);
rad = zeros(N,1);
idx(1:length(src)) = src;

d = surface.D(src,:);
d = min(d,[],1);

rad(1:length(src)-1) = Inf;
rad(length(src)) = max(d);

if nargin >= 5 & ~isempty(idx0),
    %surface.D(idx0,:) = 0;
    %surface.D(:,idx0) = 0;
else
    idx0 = [];
end

for i=length(src)+1:N,
    if i > ns | rad(i-1) <= rs, break; end  
    d_ = d;
    d_(idx0) = 0;
    [d_,j] = max(d_);
    idx(i) = j;
    d = [d; surface.D(idx(i),:)];
    d = min(d,[],1);
    rad(i) = max(d);
end

if i > ns | rad(i-1) <= rs,  
    rad = rad(1:i-1);
    idx = idx(1:i-1);
end

