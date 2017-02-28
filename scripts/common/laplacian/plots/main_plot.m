function [] = main_plot(file_name, t, params)
% K is a struct with fields: d0, n0 and optional fields d1, n1
% params.type = 'orig', 'holes', 'log10_orig'
% parmas.caxis = 'tight', 'same'

if(isfield(params, 'pth_mat'))
    load([params.pth_mat file_name]);
else
    load(file_name);
end

[shape, TRIV, X, Y, Z] = get_type_xyz(shape, params.type);

K = calc_kxx(t, shape, {'d', 'n'});
[c_d, c_n] = calc_c(K, params.type);

num_rows = 2;
num_cols = length(t);
hndl = zeros(num_rows, num_cols);

figure;
for j=1:num_cols    
    i = 1;
    params.ttl = sprintf('t=%d', t(j));
    hndl(i,j) = my_plot(TRIV, X, Y, Z, c_d, i, j, num_rows, num_cols, params);
    
    i = 2;
    params.ttl = '';
    hndl(i,j) = my_plot(TRIV, X, Y, Z, c_n, i, j, num_rows, num_cols, params);
end

adjust_caxis(params, c_d, c_n, hndl);
file_name = [file_name, '_', params.type, '_',  params.caxis];
save_fig(file_name, params.pth_png);

%close all;
end %function main_plot

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [shape, TRIV, X, Y, Z] = get_type_xyz(shape, type)

switch(type)
    case('orig')
        do_intersect_shape = 0;
        s = 0;
    case('log10_orig')
        do_intersect_shape = 0;
        s = 0;
    case('holes')
        do_intersect_shape = 0;
        s = 1;            
    case('err')
        do_intersect_shape = 1;
        s = 0;
    case('log_err')
        do_intersect_shape = 1;
        s = 0;        
    otherwise
        assert(0);
end

if(isfield(shape, 'shape1') && do_intersect_shape)
    % remove boundary from shape1 since HKS(boundary = 0).
    boundary_idx = calc_shape_boundary(shape.shape1);
    shape.shape1 = vertex_remove(shape.shape1, boundary_idx);
    shape.shape1.d.evecs(boundary_idx ,:) = [];
    shape.shape1.n.evecs(boundary_idx ,:) = [];    
    
    update_fields = {'d.evecs', 'n.evecs'};
    shape.shape0 = intersect_shape(shape.shape0, shape.shape1, update_fields);
end

if(s == 0)
    TRIV = shape.shape0.TRIV;
    X = shape.shape0.X;
    Y = shape.shape0.Y;
    Z = shape.shape0.Z;
else
    assert(s == 1);
    TRIV = shape.shape1.TRIV;
    X = shape.shape1.X;
    Y = shape.shape1.Y;
    Z = shape.shape1.Z;
end
        
end %function get_type_xyz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [hndl]=my_plot(TRIV, X, Y, Z, c, i, j, num_rows, num_cols, params)

margin_h = 0.15/(num_rows-1);
top_space_h = margin_h;
bot_space_h = margin_h;
margin_w = 0.15/(num_cols-1);
cbar_w = 0.007;
right_space_w = 0.07;
left_space_w = margin_w;

if (isfield(params, 'caxis') && strcmp(params.caxis, 'same'))
    num_cbar = 1;
else
    num_cbar = num_cols;
end

w = (1-(num_cols-1)*margin_w - right_space_w - left_space_w -num_cbar*cbar_w)/num_cols;
h = (1-(num_rows-1)*margin_h - top_space_h - bot_space_h)/num_rows;

if(num_cbar > 1)
    left = left_space_w + (margin_w + w + cbar_w) * (j-1);
else
    left = left_space_w + (margin_w + w) * (j-1);
end
bot = bot_space_h + (margin_h + h)*(num_rows-i);
hndl=subplot('Position',[left, bot, w, h]);

my_trisurf(TRIV, X, Y, Z, c(:, j), params);
colormap(my_cmap);

title(params.ttl, 'Interpreter', 'none');

if ((num_cbar > 1) || (j == num_cols))
    cbar_axes=colorbar('location', 'EastOutside');
    if((num_cbar > 1))
        set(cbar_axes, 'Position', [left + w, bot, cbar_w, h]);
    else
        cbar_bot = margin_h;
        cbar_h = 1-2*margin_h;
        set(cbar_axes, 'Position', [left + w, cbar_bot, cbar_w, cbar_h]);
    end
end
% if(j == 1)
%     zlbl = {'Dirichlet', 'Neumann'};
%     zlabel(zlbl{i});
% end

end % function my_plot

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [c_d, c_n] = calc_c(K, type)
switch(type)
    case('orig')
        c_d = K.d0;
        c_n = K.n0;
    case('log10_orig')
        c_d = log10(K.d0);
        c_n = log10(K.n0);            
    case('holes')
        c_d = K.d1;
        c_n = K.n1;
    case('err')
        c_d = 1 - min(K.d1./ K.d0, K.d0./ K.d1);
        c_n = 1 - min(K.n1./ K.n0, K.n0./ K.n1);
    case('log_err')
        c_d = log10(1 - min(K.d1./ K.d0, K.d0./ K.d1));
        c_n = log10(1 - min(K.n1./ K.n0, K.n0./ K.n1));        
    otherwise
        assert(0);
end
end % function calc_c
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = adjust_caxis(params, c_d, c_n, hndl)
if (isfield(params, 'caxis'))
    switch(params.caxis)
        case('tight')
            for j=1:size(hndl,2)
                subplot(hndl(1, j));
                caxis([min(c_d(:, j)), max(c_d(:, j))]);                
                subplot(hndl(2, j));
                caxis([min(c_n(:, j)), max(c_n(:, j))]);
            end
        case('same')
            min_c = min([c_d(:); c_n(:)]);
            max_c = max([c_d(:); c_n(:)]);
            mn = min_c;
            mx = max_c;
%             if(~isempty(caxis_cen))
%                 d = max(max_c - caxis_cen, caxis_cen - min_c);
%                 mn = caxis_cen - d;
%                 mx = caxis_cen + d;
%             else
%                 mn = min_c;
%                 mx = max_c;
%             end
            for i=1:numel(hndl)
                subplot(hndl(i));
                caxis([mn, mx]);
            end
%         case('symmetric')
%             assert(~isempty(caxis_cen));
%             for j=1:size(hndl,2)
%                 subplot(hndl(1, j));
%                 mn = min(c_d(:, j));
%                 mx = max(c_d(:, j));
%                 d = max(mx - caxis_cen, caxis_cen - mn);
%                 caxis([caxis_cen - d, caxis_cen + d]);
%                 subplot(hndl(2, j));
%                 mn = min(c_n(:, j));
%                 mx = max(c_n(:, j));
%                 d = max(mx - caxis_cen, caxis_cen - mn);
%                 caxis([caxis_cen - d, caxis_cen + d]);
%             end
        otherwise
            assert(0);
            
    end
end
end % function adjust_caxis

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
