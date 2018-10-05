function plot_roc(ROC, XFORM);

STYLE = {[1 0 0],'-';
         [0 1 0],'-';
         [0 0 1],'-';
         [0 1 1],'-';
         [1 0 0],':';
         [0 1 0],':';
         [0 0 1],':';
         [0 1 1],':';
         [1 0 0],'--';
         [0 1 0],'--';
         [0 0 1],'--';
         [0 1 1],'--';
         [1 0 0],'-.';
         [0 1 0],'-.';
         [0 0 1],'-.';
         [0 1 1],'-.';
         };

clf;
h = [];
for k=1:length(ROC),
    h(k) = semilogx(ROC{k}(:,1), 1-ROC{k}(:,2));
    j = mod(k-1,size(STYLE,1))+1;
    set(h(k), 'Color', STYLE{j,1}, 'LineStyle',STYLE{j,2}, 'LineWidth',1);
    hold on;
end
hold off;
axis([1e-3 1 0 1]);
set(h(end),'LineWidth', 2, 'Color', [0 0 0], 'LineStyle','-');
legend(XFORM, 'Location', 'SouthEast');
xlabel('FPR');
ylabel('TPR');
