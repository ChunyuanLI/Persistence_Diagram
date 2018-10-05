clear; clc; fclose all; close all;
dbstop if error;
dbstop if warning;

max_num_evecs = 200;

num_holes = 1;
%hole_size = [1,2,4,8];
hole_size = 1;
fem_deg = 1;
do_refine = 0;
t=[50, 200, 800, 3200];

%name = 'bunny';
%load(name);

% name = 'victoria';
% load(name);
% shape = surface; clear surface;
% src_idx = 1;

% name = 'rec_with_tail';
% rec_with_tail = struct('type', name, 'dx', 1, 'dy', 1, ...
%     'x0_rec', 1, 'x1_rec', 25, ...
%     'y0_rec', 1, 'y1_rec', 25, ...
%     'x0_tail', 21, 'x1_tail', 25, ...
%     'y0_tail', 26, 'y1_tail', 35);
% shape = calc_mesh(rec_with_tail);
% src_idx = 1;

% name = 'sphere';
% shape.r = 100;
% shape.n_recurse = 4;
% shape = calc_mesh(shape);
% src_idx = 1;
% shape.cam_pos = [1500 880 0];
% shape.cam_up = [0 0 1];

% name = 'elephant';
% load(name);
% shape.cam_up = [0, 1, 0]; shape.cam_pos = [1325.12 64.5386 2.48589];
% src_idx = 14750; %15600 15000;

name = 'armadillo';
load(name);
src_idx = 11700; % 9700;

num_vert = length(shape.X);
%src_idx = ceil(rand(1, max(num_holes)) * num_vert);
%src_idx = round([1:num_holes]*num_vert/(num_holes+1));

shape.name = name;
shape.fem_deg = fem_deg;

pth_mat = sprintf(['C:\\work\\ShapeGoogle\\scripts\\common\\data\\shapes\\' shape.name '\\deg' '%d' '\\mat\\'], fem_deg);
pth_png = sprintf(['C:\\work\\ShapeGoogle\\scripts\\common\\data\\shapes\\' shape.name '\\deg' '%d' '\\png\\'], fem_deg);

shape_orig = shape;

for nh=1:length(num_holes)
    for hs=1:length(hole_size)

        display(sprintf('num_holes = %d / %d, hole_size = %d / %d', nh, length(num_holes), hs, length(hole_size)));
        shape = shape_orig;

        shape.src0 = src_idx(1:num_holes(nh));
        shape.hole_size = hole_size(hs);
        
        shape = make_holes(shape);

        if(fem_deg == 1 && do_refine)
            shape.shape0 = refine_mesh(shape.shape0, 2);
            shape.shape1 = refine_mesh(shape.shape1, 2);
        end

        %run_fem_0_1(shape, max_num_evecs, fem_deg, pth_mat);
                
        %run_cotan_0_1(shape, max_num_evecs, pth_mat);
        
        if(1)
            params = struct('camup', shape.cam_up, 'campos', shape.cam_pos, 'pth_mat', pth_mat, 'pth_png', pth_png);
            
            params.type = 'orig';  params.caxis = 'tight'; main_plot(shape.name, t, params);
            params.type = 'holes'; params.caxis = 'tight'; main_plot(shape.name, t, params);
            params.type = 'err'; params.caxis = 'same'; main_plot(shape.name, t, params);
        end
        display('done main_plot');

        display('-------------------------------------------------------');
    end
end

