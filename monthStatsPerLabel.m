function f = monthStatsPerLabel(stats, labelNum, labelName, color)

f = figure;
h = bar3(stats);
xlabel('Sensor');
ylabel('Month');
zlabel('Count (hours)');
title(labelName);

for n = 1 : size(stats, 2)
    set(h(n),'FaceColor', color{labelNum});
end
set(h, 'EdgeColor', [107 107 107]/255);
set(gca, 'fontsize', 7)

end