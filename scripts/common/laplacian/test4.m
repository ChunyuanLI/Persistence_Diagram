clear; clc; fclose all; close all;
dbstop if error;
dbstop if warning;

name = 'armadillo';
cam_up = [0 0 1];
cam_pos = [232 -725 -40];

% name = 'elephant';
% cam_up = [0, 1, 0]; cam_pos = [1325.12 64.5386 2.48589];

% name = 'sphere';
% cam_up = [0 0 1]; cam_pos = [1500 880 0];

num_holes = 1;
hole_size = [1, 8];
t = [50, 200, 800, 3200];
num_smpl = 200;
fem_deg = 1;

params.axis = 'same';
%lb_params = {'n', 'c', 'e', 'g'};
%clrs = {'r', 'c', 'm', 'g'};

lb_params = {'d', 'n'};
%lb_params = {'d', 'n', 'c', 'e', 'g'};
clrs = {'b', 'r', 'c', 'm', 'g'};

pth_mat = sprintf(['C:\\work\\ShapeGoogle\\scripts\\common\\data\\shapes\\' name '\\deg' '%d' '\\mat\\'], fem_deg);
pth_png = sprintf(['C:\\work\\ShapeGoogle\\scripts\\common\\data\\shapes\\' name '\\deg' '%d' '\\png\\'], fem_deg);
%% calc err_
% sampled error
for p=1:length(lb_params)
    err_.(lb_params{p}) = zeros(num_smpl, length(t), length(hole_size));
end

% sampled distance
d_ = zeros(num_smpl, length(hole_size));

bound_len = zeros(1, length(hole_size));

load(name);
shape_orig = shape;

params.colorbar = '';
params.camup = cam_up;
params.campos = cam_pos;

for i=1:length(hole_size)
    file_name = sprintf('%s_%02d_%02d', name, num_holes, hole_size(i));
    clear shape; load([pth_mat file_name]);

    % calc the distance to the boundary
    d = calc_shape0_d(shape, shape_orig);
        
    [shape.shape0, v_remove_idx] = intersect_shape(shape.shape0, shape.shape1);

    d(v_remove_idx) = [];
    
    for p=1:length(lb_params)
        shape.shape0.(lb_params{p}).evecs(v_remove_idx, :) = [];
    end
    
    d = d - min(d);
    min_d = min(d);
    max_d = max(d);

%     figure; trisurf(shape.shape0.TRIV, shape.shape0.X, shape.shape0.Y, shape.shape0.Z, d);
%     title('d');
%     shading interp; lighting phong; camlight head; material dull; axis image; axis off;

    % calc err
    K = calc_kxx(t, shape, lb_params);
    for p=1:length(lb_params)
        err.(lb_params{p}) = 1 - min(K.([lb_params{p}, '1'])./K.([lb_params{p}, '0']), K.([lb_params{p}, '0'])./K.([lb_params{p}, '1']));
    end    
    
    
%     max_ratio = 1 - min(abs([...
%         [K.d0(:)./K.n0(:); abs(K.n0(:)./K.d0(:))], ...
%         [K.d0(:)./K.c0(:); abs(K.c0(:)./K.d0(:))], ...
%         [K.n0(:)./K.c0(:); abs(K.c0(:)./K.n0(:))]]))

    % calc sampled err

    % calc weights
    num_vert = length(shape.shape1.X);
    s = tri_area(shape.shape1);
    F = tri2vert(shape.shape1.TRIV, num_vert) / 3;
    w = F * s;

    % calc the smooth weighted error at each distance
    bin_width = max_d/(num_smpl - 1);
    d_(:, i) = [0:bin_width:max_d]';

    vrnc = ( bin_width / 2.4 ) ^ 2; % variance
    M = repmat(d_(:, i), 1, num_vert) - repmat(d', num_smpl, 1);
    M = exp(-(M .^ 2) / (2 * vrnc) );

    Mw = repmat(M * w, 1, length(t));
    w = repmat(w, 1, length(t));
    
    for p=1:length(lb_params)
        err_.(lb_params{p})(1:num_smpl, 1:length(t), i) = (M * (w .* err.(lb_params{p}))) ./ Mw;
    end

    [not_used, bound_len(i)] = calc_shape_boundary(shape.shape1);
end

%% calc log_err_
for p=1:length(lb_params)
    log_err_.(lb_params{p}) = log(err_.(lb_params{p}));
end

%% my_trisurf for each lb_param
if(0)
for p=1:length(lb_params)
    figure;
    num_rows = 2;
    num_cols = length(t);
    for j=1:length(t)
        % no hole
        subplot(num_rows, num_cols, j);
        my_trisurf(shape.shape0.TRIV, shape.shape0.X, shape.shape0.Y, shape.shape0.Z, K.([lb_params{p} '0'])(:, j), params);
        title(sprintf([lb_params{p} ', orig, t = %d'], t(j)));

        % with hole
        subplot(num_rows, num_cols, j + num_cols);
        my_trisurf(shape.shape0.TRIV, shape.shape0.X, shape.shape0.Y, shape.shape0.Z, K.([lb_params{p} '1'])(:, j), params);
        title(sprintf([lb_params{p} ', hole, t = %d'], t(j)));        
    end
    set(gcf, 'name', lb_params{p});
end
end
%% plot log hist
num_tick= 5;
figure;
num_rows = length(hole_size);
num_cols = length(t);
i0 = 5;
if(strcmp(params.axis, 'same'))
    max_y = -10e6;
    min_y =  10e6;
    for p=1:length(lb_params)
        max_y = max([max_y; max(max(max(log_err_.(lb_params{p})(i0:end, :, :))))]);
        min_y = min([min_y; min(min(min(log_err_.(lb_params{p})(i0:end, :, :))))]);
    end
    max_x = max(d_(:));
end

k = 1;
for i=1:length(hole_size)
    for j=1:length(t)
        subplot(num_rows, num_cols, k); k = k + 1;
        for p=1:length(lb_params)
            semilogy(d_(i0:end, i), log_err_.(lb_params{p})(i0:end, j, i), [clrs{p} '-'], 'LineWidth',2); hold on;
        end
        %grid on; 
        
        if(i == 1)
            title(sprintf('t = %d', t(j)));
        end
        if(j == 1)
            ylabel(sprintf('b_l_e_n = %d', round(bound_len(i))));
        end
        %legend(lb_params);
        switch(params.axis)
            case ('tight')
                axis tight;
            case('same')
                xlim([0, max_x]);
                ylim([min_y, max_y]);
        end
        
        set_num_tick(num_tick);
        if(j ~= 1)
            set(gca, 'YTickLabel', '');
        end
        if(i ~= length(hole_size))
            set(gca, 'XTickLabel', '');
        end        
    end
end

lb_params = char(lb_params);
clrs = char(clrs);
file_name = ['log_err_' params.axis '_' lb_params' '_' clrs'];
save_fig(file_name, pth_png);


%%

%
% figure;
% log_err_.n = log(err_.n);
% log_err_.d = log(err_.d);
% markers = 'so^p*x';
% num_rows = length(hole_size);
% num_cols = 1;
% k = 1;
% max_y = max([log_err_.n(:); log_err_.d(:)]);
% min_y = min([log_err_.n(:); log_err_.d(:)]);
% max_x = max(d_(:));
% lgnd = cell(2*length(t), 1);
% for i=1:length(hole_size)
%     subplot(num_rows, num_cols, k); k = k + 1;
%     for j=1:length(t)
%         plot(d_(:, i), log_err_.n(:, j, i), ['r-' markers(j)], 'LineWidth',2, 'MarkerSize', 5, 'MarkerFaceColor', 'r'); hold on;
%         plot(d_(:, i), log_err_.d(:, j, i), ['b-' markers(j)], 'LineWidth',2, 'MarkerSize', 5, 'MarkerFaceColor', 'b'); hold on;
%
%         title(sprintf('bound len = %d', round(bound_len(i))));
%         xlabel('d');
%         ylabel('log err');
%         xlim([0, max_x]);
%         ylim([min_y, max_y]);
%         lgnd{2*j -1} = sprintf('t=%d, neu', t(j));
%         lgnd{2*j} = sprintf('t=%d, dir', t(j));
%     end
%     legend(lgnd);
% end
