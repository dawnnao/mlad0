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
set(gca, 'fontsize', 18, 'fontname', 'Times New Roman', 'fontweight', 'bold');
xlabel('Sensor');
ylabel('Month');
ylim([0,13]);
set(gca,'ytick', [2:2:12]);
zlabel('Count (hours)');
hTitle = title(labelName);
set(hTitle,'Position',[27 -15 16]);

%%

for n = 1 : size(stats, 2)
    set(h(n),'FaceColor', color{labelNum});
end
set(h, 'EdgeColor', [150 150 150]/255);

set(gcf,'Units','pixels','Position',[100, 100, 1200, 700]);  % control figure's position
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