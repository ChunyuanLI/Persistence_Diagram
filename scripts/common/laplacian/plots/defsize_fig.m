function [] = defsize_fig(fig)
if (nargin < 1)
    fig = gcf;
end
set(fig,'Units','normalized','Position',[0.2805, 0.3463, 0.4375, 0.5250]); % default size
