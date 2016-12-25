function f = monthStatsPerLabel(stats, labelNum, labelName)

color= {[129 199 132]/255;
        [244 67 54]/255;  
        [121 85 72]/255;  
        [255 112 67]/255; 
        [33 150 243]/255; 
        [171 71 188]/255; 
        [255 235 59]/255; 
        [168 168 168]/255};

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