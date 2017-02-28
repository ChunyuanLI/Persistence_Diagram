function [] = save_fig(file_name, pth_name, fig)
if (nargin < 3)
    fig = gcf;
    if(nargin < 2)
        pth_name = '';
    end
end
% max_fig(fig);
set(fig,'Color', [1 1 1]);
set(fig, 'name', file_name);

fig = myaa;
set(fig, 'name', file_name);

saveas(fig, fullfile(pth_name, file_name), 'png');

remove_white_frame(fullfile(pth_name, [file_name '.png']));
