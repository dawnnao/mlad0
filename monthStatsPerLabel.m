function f = monthStatsPerLabel(stats, labelNum, labelName, color)
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
xlabel('Sensor','fontsize',14);
ylabel('Month','fontsize',14);
zlabel('Count (hours)','fontsize',14);
title(labelName,'fontsize',14);

for n = 1 : size(stats, 2)
    set(h(n),'FaceColor', color{labelNum});
end
set(h, 'EdgeColor', [107 107 107]/255);

set(gcf,'Units','pixels','Position',[100, 100, 1200, 700]);  % control figure's position
% set(gca,'Units','normalized', 'Position',[0 0 1 1]);  % control axis's position in figure

end