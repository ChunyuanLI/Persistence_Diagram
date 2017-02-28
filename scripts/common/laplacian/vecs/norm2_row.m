function [nrm2] = norm2_row(M)
% M is an m x n matrix;
% nrm is an m x 1 vector. nrm(i) the norm of M(i, :)

nrm2 =  dot(M, M, 2);
