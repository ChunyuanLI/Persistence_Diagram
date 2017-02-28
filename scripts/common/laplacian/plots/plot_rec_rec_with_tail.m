clear; clc; close all;

% rec with tail shape
rec_with_tail = struct('type', 'rec_with_tail', 'dx', 1, 'dy', 1, ...
    'x0_rec', 1, 'x1_rec', 50, ...
    'y0_rec', 1, 'y1_rec', 50, ...
    'x0_tail', 41, 'x1_tail', 50, ...
    'y0_tail', 51, 'y1_tail', 70);

% sphere shape
% shape = struct('type', 'sphere', 'r', 1, 'n_recurse', 4);

% rec shape
rec = struct('type', 'rec', 'x0_rec', 1, 'x1_rec', 52, 'dx', 1, 'y0_rec', 1, 'y1_rec', 52, 'dy', 1);

rec_with_tail = calc_mesh(rec_with_tail);
rec = calc_mesh(rec);

fem(rec_with_tail, 'dirichlet');
fem(rec_with_tail, 'neumann');
fem(rec, 'dirichlet');
fem(rec, 'neumann');

clear; clc; close all;

load('rec_dirichlet');
load('rec_neumann');
load('rec_with_tail_dirichlet')
load('rec_with_tail_neumann');

% plot the eigs limits
figure; grid on; hold on;
k = length(rec_with_tail_dirichlet.evals);
plot(1:k, rec_with_tail_dirichlet.evals','-b.');

k = length(rec_with_tail_neumann.evals);
plot(1:k, rec_with_tail_neumann.evals','-g.');
plot(1:k, 4*pi*[1:k]/rec_with_tail_neumann.ar, 'r');

xlabel('n');
legend('rec with tail dirichlet \lambda_n', 'rec with tail neumann \lambda_n', '4*\pi*n/area')
title('F.E.M');

k = [1:5, 10, 20, 40, 80, 120, 160, 200];
for i=1:length(k)
    figure;

    subplot(2, 2, 1);
    trisurf(rec_with_tail_dirichlet.TRIV, ...
        rec_with_tail_dirichlet.X(:), rec_with_tail_dirichlet.Y(:), rec_with_tail_dirichlet.Z(:), ...
        rec_with_tail_dirichlet.evecs(:,k(i)));
    colorbar; view([0 90]); shading interp;  axis image; axis off; colormap hot;
    title(sprintf('Eigenfunction %d, rec with tail dirichlet', k(i)));

    subplot(2, 2, 2);
    trisurf(rec_with_tail_neumann.TRIV, ...
        rec_with_tail_neumann.X(:), rec_with_tail_neumann.Y(:), rec_with_tail_neumann.Z(:), ...
        rec_with_tail_neumann.evecs(:,k(i)));
    colorbar; view([0 90]); shading interp;  axis image; axis off; colormap hot;
    title(sprintf('Eigenfunction %d, rec with tail neumann', k(i)));

    subplot(2, 2, 3);
    trisurf(rec_dirichlet.TRIV, ...
        rec_dirichlet.X(:), rec_dirichlet.Y(:), rec_dirichlet.Z(:), ...
        rec_dirichlet.evecs(:,k(i)));
    colorbar; view([0 90]); shading interp;  axis image; axis off; colormap hot;
    title(sprintf('Eigenfunction %d, rec dirichlet', k(i)));

    subplot(2, 2, 4);
    trisurf(rec_neumann.TRIV, ...
        rec_neumann.X(:), rec_neumann.Y(:), rec_neumann.Z(:), ...
        rec_neumann.evecs(:,k(i)));
    colorbar; view([0 90]); shading interp;  axis image; axis off; colormap hot;
    title(sprintf('Eigenfunction %d, rec neumann', k(i)));
end
