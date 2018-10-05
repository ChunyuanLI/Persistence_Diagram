function shape = mesh2shape(vertices, faces)


% transform mesh (vertices and faces) to shape ()

% shape = cell();

shape.TRIV = faces;

shape.X = vertices(:,1);
shape.Y = vertices(:,2);
shape.Z = vertices(:,3);


%
shape.nv = size(vertices,1);
shape.nt = size(faces,1);

% A = triangulation2adjacency(face,vertices);
% shape.ne = size(find(A~=0))/2;

end