clear;close all;


channel = [3,2,1];
date = '08/08/';
h = 16;
s = '020100';
fileName = ['/Volumes/ssd/sutong-2012-windSpeed/' date sprintf('FS%s_%02d0000.FS', s, h)];
data = csvread(fileName,1,0);


t = 1:size(data,1);
% data = data - repmat(mean(data),[72000,1]);

figure
plot(t,data(:,channel),'linewidth',0.8);
% plot(t,data(:,1),t,data(:,2),t,data(:,3));
xlabel('Time(sec)');
ylabel('Wind Speed (m/s)');
% title(num2str(h));
set(gca, 'fontsize', 16);
%     xlim([0 size(data,1)]);
xlim([0 600]);
set(gca,'Units','normalized', 'Position',[0.08 0.12 0.9 0.82]);  % control axis's position in figure
% set(gca,'Units','normalized', 'OuterPosition',[0 0 1 1]);  % control axis's position in figure
set(gcf,'Units','pixels','Position',[100, 100, 1000, 400]);

%%
folderName = 'plotForPaper';
if ~exist(folderName, 'dir'), mkdir(folderName); end

date = strrep(date, '/', '-');

saveName = ['windSpeed_2012-' date num2str(h,'%02d') '_sens_' s '.png'];
saveas(gcf, [folderName '/' saveName]);