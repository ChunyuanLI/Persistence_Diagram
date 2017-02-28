function [idx_n, perm] = vertex_neighbor (mesh, idx_t, vertex)


% No intersection
if vertex < 1 | vertex > 3 | length(vertex) ~= 1,
    perm = [1 2 3];
    idx_n = 0;
    return;
end

idx_v = mesh.TRIV(idx_t,:);
idx_v = idx_v(vertex);

idx_n1 = find(mesh.TRIV(:,1) == idx_v);
idx_n2 = find(mesh.TRIV(:,2) == idx_v);
idx_n3 = find(mesh.TRIV(:,3) == idx_v);

idx_n1 = setdiff(idx_n1, idx_t);
idx_n2 = setdiff(idx_n2, idx_t);
idx_n3 = setdiff(idx_n3, idx_t);

idx_n = [idx_n1(:); idx_n2(:); idx_n3(:)];

idx = setdiff(1:3, vertex);

perm1 = zeros(1,3);
perm1(1) = vertex;
perm1(2) = idx(1);
perm1(3) = idx(2);

perm2 = zeros(1,3);
perm2(2) = vertex;
perm2(1) = idx(1);
perm2(3) = idx(2);

perm3 = zeros(1,3);
perm3(3) = vertex;
perm3(1) = idx(1);
perm3(2) = idx(2);

perm = [repmat(perm1, [length(idx_n1) 1]) ; repmat(perm2, [length(idx_n2) 1]) ; repmat(perm3, [length(idx_n3) 1])];



