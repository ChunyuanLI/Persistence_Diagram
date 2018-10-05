function [] = plot_evecs(shape, eig_idx, lb_param)
figure;
num_sub_plots = length(eig_idx);
num_rows = round(sqrt(num_sub_plots));
num_cols = ceil(num_sub_plots / num_rows);
switch(lb_param)
    case('dir')
        evecs = shape.d.evecs;
    case('neu')
        evecs = shape.n.evecs;
    case('cot')
        evecs = shape.c.evecs;        
    otherwise
        assert(0);
end
for i=1:num_sub_plots
    subplot(num_rows, num_cols, i);
    trisurf_shape(shape, evecs(:,eig_idx(i)));
    title(sprintf('evec %d, %s', eig_idx(i), lb_param));
    caxis([min(evecs(:,eig_idx(i))), max(evecs(:,eig_idx(i)))]);
end
end % function plot_evecs
