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
set(gca, 'fontsize', 26, 'fontname', 'Times New Roman', 'fontweight', 'bold')
axisX = xlabel('Anomaly Pattern');
axisY = ylabel('Month');
ylim([0,13]);
zlabel('Count (hours)');
hTitle = title(sprintf('Channel %02d', sensor));
% set(hTitle,'Position',[-5 3 440]);
set(hTitle,'Position',[-7.5 4.4 483.7]);


set(axisX,'Rotation', -28);
set(axisY,'Rotation', 28);

% pTitle = get(hTitle,'Position');
% set(hTitle,'Position',[pTitle(1) pTitle(2)+0.3 pTitle(3)])

% legend(labelName);
view(45, 30);

for n = 1 : length(labelName)
    set(h(n),'FaceColor', color{n});
end
set(h, 'EdgeColor', [107 107 107]/255);

set(gcf,'Units','pixels','Position',[100, 100, 900, 800]);  % control figure's position
% set(gca,'Units','normalized', 'Position',[0 0 1 1]);  % control axis's position in figure

% minimize white space
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

end