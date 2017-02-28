function visualize_shape(shape, tx, ux)

N = length(tx);
rand('seed', 0);
cmap = hsv(N); 
perm = randperm(N);

    % Compute distance map from sample on the shape.
    D = zeros(length(shape.X), length(tx));
    X = zeros(3, length(tx));
    for k=1:length(tx),
        u = repmat(Inf, [length(shape.X) 1]);
        v = shape.TRIV(tx(k),:);
        XX = [shape.X(v(:)) shape.Y(v(:)) shape.Z(v(:))]';
        x = XX*[ux(k,:), 1-sum(ux(k,:))]';
        X(:,k) = x;
        u(v) = sqrt(sum((XX - repmat(x, [1 3])).^2, 1));        
        D(:,k) = fastmarch(shape.TRIV, shape.X, shape.Y, shape.Z, u, set_options('mode', 'single'));
    end

    % Visualize Voronoi map
    [vor, edges] = voronoi_tessellation1(shape, [], D);
    trisurf(vor.TRIV, vor.X, vor.Y, vor.Z, perm(vor.tri_labels));
    hold on;
    h = line(edges.X, edges.Y, edges.Z);
    set(h, 'Color', [0 0 0]);
    h = plot3(X(1,:), X(2,:), X(3,:), 'ok');
    set(h,'MarkerSize', 5, 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0 0]);
    hold off;
    axis image; axis off; shading flat; lighting phong; 
    colormap(cmap);
    view([-15 25]);
    camlight head;
    caxis([1 N]);