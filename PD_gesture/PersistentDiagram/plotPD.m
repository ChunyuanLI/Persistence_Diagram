function plotPD(Duration,min_coordinate,max_coordinate)

        [m,~] = size(Duration);
        birth = Duration(:,2);
        death = Duration(:,3);
        figure
%         plot(birth,death,'.r',...
%                 'MarkerEdgeColor','r',...
%                 'MarkerFaceColor','r',...
%                 'MarkerSize',5)
            
        hh = plot(birth,death,'ko','MarkerFaceColor',[.49 1 .63],'MarkerSize',10);
        hold on; 
        
%         min_coordinate = min([birth;death]);
%         max_coordinate = max([birth;death]);
        
        x= min_coordinate:0.01:max_coordinate;
        y = x;
        plot(x,y,'LineWidth',1,'MarkerEdgeColor','b',...
                'MarkerFaceColor','b')
        
        axis([min_coordinate max_coordinate min_coordinate max_coordinate])
        xlabel('Birth','fontsize',12)
        ylabel('Death','fontsize',12)
        %title('Persistence Diagram')
        set(gca,'fontsize',12);
        hold off
        
 end