function [] = dbg_laplace_eigs(evals, evecs, shape)
    assert(strcmp(shape.type, 'rec'));
    assert(shape.dx == shape.dy);
    num_rows = (shape.y1_rec - shape.y0_rec) / shape.dy + 1;
    num_cols = (shape.x1_rec - shape.x0_rec) / shape.dx + 1;

for i=1:length(evals)
    V =  evecs(:, i);
    %figure; surf(X(:), Y(:), Z(:), V(:));

    V = reshape(V, num_rows, num_cols);
    laplace_kernel = [
        0, 1, 0;
        1, -4, 1;
        0, 1, 0]/(shape.dx^2);
    laplace_V = conv2(V, laplace_kernel, 'valid');
    V([1, end], :) = []; V(:, [1, end]) = [];
    subplot(2,2,1);
%    imagesc(evals(i) * V); title('\lambda * V'); colorbar; impixelinfo;
    imagesc(-evals(i) * V); title('\lambda * V'); colorbar; impixelinfo;    
    subplot(2,2,2);
    imagesc(laplace_V); title('V_x_x + V_y_y'); colorbar; impixelinfo;
    
    subplot(2,2,3);
    abs_diff = abs(laplace_V + evals(i) * V);
    max_abs_diff = max(abs_diff(:))
    imagesc(abs_diff); title('|V_x_x + V_y_y + \lambda * V|'); colorbar; impixelinfo;    
    pause;
end
