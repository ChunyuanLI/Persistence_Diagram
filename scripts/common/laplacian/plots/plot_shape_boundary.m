function [] = plot_shape_boundary(shape)
boundary_idx = calc_shape_boundary(shape);
c = zeros(size(shape.X));
c(boundary_idx) = 1;
figure; my_trimesh(shape.TRIV, shape.X, shape.Y, shape.Z);
hold on;
plot3(shape.X(boundary_idx), shape.Y(boundary_idx), shape.Z(boundary_idx), 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'k');
title('mesh without boundary');

figure; my_trisurf(shape.TRIV, shape.X, shape.Y, shape.Z, c);

end % function plot_shape_holes

