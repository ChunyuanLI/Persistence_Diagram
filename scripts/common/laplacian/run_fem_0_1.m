function [shape]= run_fem_0_1(shape, max_num_evecs, fem_deg, pth_mat)

shape.shape0 = run_fem_d_n(shape.shape0, max_num_evecs, fem_deg);
display('done fem shape0');

shape.shape1 = run_fem_d_n(shape.shape1, max_num_evecs, fem_deg);
display('done fem shape1');

save([pth_mat, shape.name, '_fem'], 'shape');

end % function run_fem_0_1

