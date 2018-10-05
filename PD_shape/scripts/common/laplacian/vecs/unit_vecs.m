function [M] = unit_vecs(M, dim)
% function [M] = unit_vecs(M, dim)
% if dim == 1, the function normalizes the rows of M
% if dim == 2, the function normalizes the columns of M

n = sqrt(sum(M.^2, dim));

switch(dim)
    case(1)
        M = M ./ repmat(n, size(M, 1), 1);
    case(2)
        M = M ./ repmat(n, 1, size(M, 2));
    otherwise
        assert(0);
end
