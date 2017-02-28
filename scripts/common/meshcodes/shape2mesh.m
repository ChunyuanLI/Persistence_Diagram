function [vertices, faces] = shape2mesh(shape)

% transform shape () to mesh (vertices and faces)

faces = shape.TRIV;
vertices = [shape.X, shape.Y, shape.Z];



end