function draw_cm(mat,tick,num_class)
%%
%  Matlab code for visualization of confusion matrix;
%  Parameters£ºmat: confusion matrix;
%              tick: name of each class, e.g. 'class_1' 'class_2'...
%              num_class: number of class
%
%  Author£º Page( Ø§×Ó)  
%           Blog: www.shamoxia.com;  
%           QQ:379115886;  
%           Email: peegeelee@gmail.com
%%
imagesc(1:num_class,1:num_class,mat);            %# in color
colormap(flipud(gray));  %# for gray; black for large value.

textStrings = num2str(mat(:),'%0.0f');  
textStrings = strtrim(cellstr(textStrings));
for i = 1:100
    text0 = textStrings{i};
    if strcmp(text0,'0')
        textStrings{i} = '';
    end
end
[x,y] = meshgrid(1:num_class); 
hStrings = text(x(:),y(:),textStrings(:), 'HorizontalAlignment','center','FontSize',15);
midValue = mean(get(gca,'CLim')); 
textColors = repmat(mat(:) > midValue,1,3); 
set(hStrings,{'Color'},num2cell(textColors,2));  %# Change the text colors

xlabel('Predicted Class','fontsize',12);
ylabel('Actual Class','fontsize',12);

set(gca,'xticklabel',tick,'XAxisLocation','top');
set(gca, 'XTick', 1:num_class, 'YTick', 1:num_class,'fontsize',12,'TightInset',5);
set(gca,'yticklabel',tick);
rotateXLabels(gca, 0 );% rotate the x tick



