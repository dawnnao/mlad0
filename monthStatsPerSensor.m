function f = monthStatsPerSensor(stats, sensor, labelName, color)
% DESCRIPTION:
%   This is a subfunction of mvad.m, to auto-draw bar plot

% AUTHOR:
%   Zhiyi Tang
%   tangzhi1@hit.edu.cn
%   Center of Structural Monitoring and Control
% 
% DATE CREATED:
%   12/10/2016  

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

set(gcf,'Units','pixels','Position',[100, 100, 1000, 800]);  % control figure's position
% set(gca,'Units','normalized', 'Position',[0 0 1 1]);  % control axis's position in figure

end