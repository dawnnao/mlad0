function f = monthStatsPerSensor(stats, sensor, labelName, color)

f = figure;
h = bar3(stats);
set(gca, 'fontsize', 14)
xlabel('Type');
ylabel('Month');
zlabel('Count (hours)');
title(sprintf('Sensor%02d', sensor));
legend(labelName);
view(45, 30);

for n = 1 : length(labelName)
    set(h(n),'FaceColor', color{n});
end
set(h, 'EdgeColor', [107 107 107]/255);

set(gcf,'Units','pixels','Position',[100, 100, 1000, 618]);  % control figure's position
% set(gca,'Units','normalized', 'Position',[0 0 1 1]);  % control axis's position in figure

end