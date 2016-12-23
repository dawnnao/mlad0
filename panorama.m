function panorama(xSerial, yLabel, yStr)
% DESCRIPTION:
%   This is a subfunction for spp.m, to plot a panorama about data quality.
%   Green is for good, red is for bad. Time precision is hour, which means
%   if an hour's data is red, there is at least one bad data point.

% OUTPUTS:
%   an ultra wide figure, no variable output
% 
% INPUTS:
%   xSerial (double) - serial date array for plot xlabel
%   yLabel (duble) - data classification array (1 for good, 2 for bad)

% EDITION:
%   0.1
% 
% AUTHOR:
%   Zhiyi Tang
%   tangzhi1@hit.edu.cn
%   Center of Structural Monitoring and Control
% 
% DATE CREATED:
%   2016/12/10

%%
interval = xSerial(end) - xSerial(end-1);
plotx = [xSerial; xSerial(end)+interval];

ploty = zeros(8, size(yLabel, 2));

for l = 1:8
    ploty(l, find(yLabel == l)) = 1;
end

zeroSet = [2 3; 3 1; 1 2];
for n = 1:3
    plotyTri{n} = ploty;  % intiallize
    plotyTri{n}(:, zeroSet(n,1):3:end) = 0;
    plotyTri{n}(:, zeroSet(n,2):3:end) = 0;
    plotyTempa = [plotyTri{n} zeros(8,1)];
    plotyTempb = [zeros(8,1) plotyTri{n}];  % move one point to right
    plotyTri{n} = plotyTempa + plotyTempb;  % combine
    plotyTri{n}(find(plotyTri{n} == 0)) = NaN;
    clear plotyTempa plotyTempb
end

%%
% RGB color
color.label{1} = [129 199 132]/255;  % 1-normal     green
color.label{2} = [244 67 54]/255;    % 2-outlier    red
color.label{3} = [121 85 72]/255;    % 3-square     brown
color.label{4} = [255 112 67]/255;   % 4-missing    orange
color.label{5} = [33 150 243]/255;   % 5-trend      blue
color.label{6} = [171 71 188]/255;   % 6-drift      purple
color.label{7} = [255 235 59]/255;   % 7-bias       yellow
color.label{8} = [168 168 168]/255;  % 8-cutoff     gray
color.axis = [107 107 107]/255;

figure
for l = 1:8
    for n = 1:3
        area(plotx, plotyTri{n}(l,:), ...
            'edgecolor', 'none', 'facecolor', color.label{l}, 'facealpha', 0.5); % , 'facealpha', 0.5
        hold on
    end
end
ax = gca;
xlim([plotx(1) plotx(end)]);

%% make label and tick
ax.XTick = plotx;
xLabel = cell(size(plotx));
bigTick = zeros(size(plotx));
for n = 1 : length(plotx)
    if mod(n,12) == 1
%         xLabel{n} = datestr(plotx(n), 15);
        bigTick(n) = 0.14;
    end
    
    if mod(n,24) == 1
        xLabel{n} = datestr(plotx(n), 'mm-dd ddd HH:MM');
        bigTick(n) = 0.2;
    end
    
%     if mod(n,168) == 1
%         xLabel{n} = datestr(plotx(n), 'yyyy-mm-dd HH:MM');
%     end
end

%% axis control
stem(plotx, bigTick, 'linewidth', 1, 'marker', 'none', 'color', color.axis);
hold off
box off
ax.XTickLabel = xLabel;
ax.XTickLabelRotation = 12;  % rotation
ax.XColor = color.axis;
ax.YColor = color.axis;
ax.YTick = [];
ax.YLabel.String = yStr;
ax.YLabel.FontSize = 16;

%% size control
fig = gcf;
fig.Units = 'normalized';
fig.Position = [0 0.85 1 0.15];  % control figure's position
% set(gcf,'color','w');
fig.Color = 'w';
ax.Units = 'normalized';
ax.Position = [0.055 0.25 0.94 0.72];  % control ax's position in figure

fprintf('\nPanorama''s legend:\ngreen-normal   gray-missing   orange-outlier\n')
fprintf('red-outrange   purple-drift   blue-trend\n')
end



