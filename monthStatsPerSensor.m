function monthStatsPerSensor(stats, sensor, labelName)

color= {[129 199 132]/255;
        [244 67 54]/255;  
        [121 85 72]/255;  
        [255 112 67]/255; 
        [33 150 243]/255; 
        [171 71 188]/255; 
        [255 235 59]/255; 
        [168 168 168]/255};

figure
h = bar3(stats);
xlabel('Type');
ylabel('Month');
zlabel('Count (hours)');
title(sprintf('Sensor%02d', sensor));
legend(labelName)

for n = 1 : 8
    set(h(n),'FaceColor', color{n});
end
set(h, 'EdgeColor', [107 107 107]/255);
set(gca, 'fontsize', 13)

end