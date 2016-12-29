function f = monthStatsPerLabel(stats, labelNum, labelName, color)

f = figure;
h = bar3(stats);
set(gca, 'fontsize', 14)
xlabel('Sensor','fontsize',14);
ylabel('Month','fontsize',14);
zlabel('Count (hours)','fontsize',14);
title(labelName,'fontsize',14);

for n = 1 : size(stats, 2)
    set(h(n),'FaceColor', color{labelNum});
end
set(h, 'EdgeColor', [107 107 107]/255);

set(gcf,'Units','pixels','Position',[100, 100, 1000, 618]);  % control figure's position
% set(gca,'Units','normalized', 'Position',[0 0 1 1]);  % control axis's position in figure

end