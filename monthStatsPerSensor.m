function f = monthStatsPerSensor(stats, sensor, labelName, color)

f = figure;
h = bar3(stats);
xlabel('Type');
ylabel('Month');
zlabel('Count (hours)');
title(sprintf('Sensor%02d', sensor));
legend(labelName)

for n = 1 : 9
    set(h(n),'FaceColor', color{n});
end
set(h, 'EdgeColor', [107 107 107]/255);
set(gca, 'fontsize', 10)

end