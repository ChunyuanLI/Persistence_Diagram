function [] = set_num_tick(num_tick)
y_scale = get(gca, 'YScale');
y_lim = get(gca, 'YLim');
tt = ((0:(num_tick - 1)) / (num_tick - 1));

switch(y_scale)
    case('linear')
        y_tick = y_lim(1) + ((y_lim(2)-y_lim(1)).* tt(:));
    case('log')
        y_tick = y_lim(1) * ((y_lim(2)/y_lim(1)).^ tt(:));
        y_tick = sign(y_tick) .* 10.^(round(log10(abs(y_tick))));
        y_tick = unique(y_tick);
    otherwise
        assert(0);
end

set(gca, 'YTick', y_tick);
y_tick_lbl = num2str(y_tick, 2);
set(gca, 'YTickLabel', y_tick_lbl);
set(gca, 'YTickLabelMode', 'auto');
set(gca, 'YMinorTick', 'off');

