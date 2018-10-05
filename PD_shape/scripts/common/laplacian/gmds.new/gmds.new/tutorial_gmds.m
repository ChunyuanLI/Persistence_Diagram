
% Find correspondence between two Tosca meshes 
load tosca;

tosca_x = remesh(tosca1, set_options('vertices',1000));
tosca_y = remesh(tosca2, set_options('vertices',1000));

[tosca_x] = init_surface (tosca_x);
[tosca_y] = init_surface (tosca_y);

N = 50;
[tx, ux, ty, uy, f, rmsdist, maxdist, local_stress] = gmds (tosca_x, tosca_y, N);

figure(1); visualize_shape(tosca_x, tx, ux);
figure(2); visualize_shape(tosca_y, ty, uy);
    
