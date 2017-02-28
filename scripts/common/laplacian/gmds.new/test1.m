clear; clc; close all;
load victoria0;
shape = surface;

src = repmat(Inf,length(shape.X),1);
src([1 1000]) = 0;
d = fastmarch(shape.TRIV, shape.X, shape.Y, shape.Z, src, set_options('mode', 'single'));

figure(1);
trisurf(shape.TRIV, shape.X, shape.Y, shape.Z,d); axis image; axis off;
shading interp; lighting phong; camlight head; colorbar;

figure(2);
[shape1,edges] = geodesic_contour(shape, d, 10);
trisurf(shape1.TRIV, shape1.X, shape1.Y, shape1.Z, shape1.tri_labels);
axis image; axis off; shading flat; lighting phong; camlight head; colorbar;

figure(3);
shape1.TRIV = shape1.TRIV(shape1.tri_labels==0,:);
trisurf(shape1.TRIV, shape1.X, shape1.Y, shape1.Z);
axis image; axis off; shading flat; lighting phong; camlight head; colorbar;




