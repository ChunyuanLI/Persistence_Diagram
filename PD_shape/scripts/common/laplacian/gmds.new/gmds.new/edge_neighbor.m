function [idx_n, perm] = edge_neighbor (mesh, idx_t, intersection)

% No intersection
if intersection < 1 | intersection > 3,
    perm = [1 2 3];
    idx_n = 0;
    return;
end

idx_v = mesh.TRIV(idx_t,:);
idx_e = mesh.TRIE(idx_t,:);

% Determine neighbor triangle sharing the edge
idx_e = idx_e(intersection);
idx_n = mesh.ETRI(idx_e,:);
idx_n = setdiff(idx_n, idx_t);

% Boundary
if isnan(idx_n),
    perm = [1 2 3];
    return;
end


idx_vn = mesh.TRIV(idx_n,:);

idx1 = find(idx_vn(1) == idx_v);
idx2 = find(idx_vn(2) == idx_v);
idx3 = find(idx_vn(3) == idx_v);
perm = zeros(3,1);

idx  = setdiff(1:3, [idx1(:); idx2(:); idx3(:)]);

if ~isempty(idx1), perm(1) = idx1; else perm(1) = idx; end
if ~isempty(idx2), perm(2) = idx2; else perm(2) = idx; end
if ~isempty(idx3), perm(3) = idx3; else perm(3) = idx; end

% permutation:
% u' = u(perm)
