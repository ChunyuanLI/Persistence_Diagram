function [nrm] = norm_row(M)
% M is an m x n matrix;
% nrm is an m x 1 vector. nrm(i) the norm of M(i, :)

nrm =  sqrt(norm2_row(M));

