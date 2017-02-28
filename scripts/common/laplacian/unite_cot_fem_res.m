clear; clc;
% unite cot and fem results
%file_names = {'elephant_01_01', 'elephant_01_02', 'elephant_01_04', 'elephant_01_08', 'elephant_01_16'};
%pth_mat = 'C:\work\ShapeGoogle\laplacian\data\shapes\elephant\mat\';

%file_names = {'sphere_01_01', 'sphere_01_04', 'sphere_01_16'};
file_names = {'armadillo_01_01', 'armadillo_01_08'};

fem_deg = 1;
name = 'armadillo';

pth_mat = sprintf(['C:\\work\\ShapeGoogle\\scripts\\common\\data\\shapes\\' name '\\deg' '%d' '\\mat\\'], fem_deg);

if 1
    for i=1:length(file_names)
        i
        %load([pth_mat, file_names{i} '_cot']);
        load([pth_mat, file_names{i} '_ceg']);
        shape_ceg = shape;

        load([pth_mat, file_names{i}, '_fem']);
        %load([pth_mat, file_names{i}, '']);

        shape.shape0.c = shape_ceg.shape0.c;
        shape.shape1.c = shape_ceg.shape1.c;

        shape.shape0.e = shape_ceg.shape0.e;
        shape.shape1.e = shape_ceg.shape1.e;

        shape.shape0.g = shape_ceg.shape0.g;
        shape.shape1.g = shape_ceg.shape1.g;

        save([pth_mat, shape.name], 'shape');

    end
end

if(0)
    for i=1:length(file_names)
        i
        load([pth_mat, file_names{i}, '']);
        shape.shape0 = rmfield(shape.shape0, {'c', 'e', 'g'});
        shape.shape1 = rmfield(shape.shape1, {'c', 'e', 'g'});
        save([pth_mat, shape.name], 'shape');
    end
end