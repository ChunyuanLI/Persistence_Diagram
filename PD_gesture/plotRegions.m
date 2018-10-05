%% display surface colored by the different clusters
function plotRegions(X,Y,C)
    
    figure
%     imshow(image);
%     hold on

    colormap('Jet');
    color = C;
    
    colorSize = size(color);
    if isequal(colorSize,[1 3]) || ischar(color),
        color = repmat(color,length(x),1);
    elseif any(colorSize == 1),
        color = color(:);
    end
    
    x_max = max(X);
    x_min = min(X);
    x_gap = x_max - x_min;
    
    y_max = max(Y);
  
    Y = y_max - Y+1 ;
    y_max = max(Y);
    y_min = min(Y);
    y_gap = y_max - y_min;
    
    [gap, idx] = max([x_gap,y_gap]);
    
    for i=1:length(X),

            marker = '.';
            h(i) = patch('xdata',X(i),'ydata',Y(i),...
                 'linestyle','none','facecolor','none',...
                 'markersize',18, ...
                 'marker',marker);
                    
             c = color(i);
             set(h(i),'cdata',c,'edgecolor','flat','markerfacecolor','flat');
    end
    
    axis([x_min-gap/3 x_min+4*gap/3 y_min-gap/3 y_min+4*gap/3])
    colorbar;
end
