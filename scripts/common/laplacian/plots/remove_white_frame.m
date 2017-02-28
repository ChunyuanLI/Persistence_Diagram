function remove_white_frame(file_name)
% function remove_white_frame(file_name)
% remove white rows and columns from file_name and overwrites the file_name
% file_name should include the path and the format

fmt = file_name((end-2):end);
M = imread(file_name, fmt);

m = M ~= 255;
m = any(m, 3);

% remove white rows from
r = any(m,2);
i1 = find(r, 1, 'first');
i2 = find(r, 1, 'last');

% remove white columns
c = any(m,1);
j1 = find(c, 1, 'first');
j2 = find(c, 1, 'last');

M_new = M(i1:i2, j1:j2, :);

display(sprintf('remove_white_frame removed %d rows and %d columns', size(M,1) - size(M_new, 1), size(M,2) - size(M_new, 2)));
imwrite(M_new, file_name, fmt);
