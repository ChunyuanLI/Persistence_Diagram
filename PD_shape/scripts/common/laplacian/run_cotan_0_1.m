function [shape]= run_cotan_0_1(shape, max_num_evecs, pth_mat)
% function [shape]= run_cotan_0_1(shape, max_num_evecs, pth_mat)
% geodesic, cotangent, euclidean
mesh0 = struct('X', shape.shape0.X, 'Y', shape.shape0.Y, 'Z', shape.shape0.Z, 'TRIV', shape.shape0.TRIV);
mesh1 = struct('X', shape.shape1.X, 'Y', shape.shape1.Y, 'Z', shape.shape1.Z, 'TRIV', shape.shape1.TRIV);

% geodisic
[shape.shape0.g.evecs, shape.shape0.g.evals] = main_mshlp('geodesic', mesh0, max_num_evecs);
display('done geo shape0');

[shape.shape1.g.evecs, shape.shape1.g.evals] = main_mshlp('geodesic', mesh1, max_num_evecs);
display('done geo shape1');

% contangent
[shape.shape0.c.evecs, shape.shape0.c.evals] = main_mshlp('cotangent', mesh0, max_num_evecs);
display('done cot shape0');

[shape.shape1.c.evecs, shape.shape1.c.evals] = main_mshlp('cotangent', mesh1, max_num_evecs);
display('done cot shape1');

% euclidean
[shape.shape0.e.evecs, shape.shape0.e.evals] = main_mshlp('euclidean', mesh0, max_num_evecs);
display('done euc shape0');

[shape.shape1.e.evecs, shape.shape1.e.evals] = main_mshlp('euclidean', mesh1, max_num_evecs);
display('done euc shape1');

save([pth_mat, shape.name, '_ceg'], 'shape');

end % function run_cotan_0_1

