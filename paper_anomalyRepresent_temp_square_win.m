clear;close all;clc

date = '07/15/';
h = 3;
str = 'WD0802';
sens = [11];
% sens = [25];
% sens = [1:12];


n = 1;
for m = sens
    fileName = ['/Volumes/bigDisk/sutong-2012-temp/混凝土构件/辅桥北主墩处箱梁/2012/' date sprintf('%s%02d_%02d0000.txt', str, m, h)];
    data{n} = csvread(fileName,0,0);
    n = n + 1;
end
data = cell2mat(data);

T = 3600/length(data);
t = T : T : 3600;

figure
plot(t,data,'linewidth',0.8);
% plot(t,data(:,1),t,data(:,2),t,data(:,3));
xlabel('Time(sec)');
strY = sprintf('Temp (%cC)', char(176));
ylabel(strY);
% title(num2str(h));

% for m = 1 : length(sens)
%     strLegend{m} = num2str(sens(m));
% end
% legend(strLegend);

set(gca, 'fontsize', 16);
xlim([0 3600]);
set(gca,'Units','normalized', 'Position',[0.08 0.12 0.9 0.82]);  % control axis's position in figure
% set(gca,'Units','normalized', 'OuterPosition',[0 0 1 1]);  % control axis's position in figure
set(gcf,'Units','pixels','Position',[100, 100, 1000, 400]);

%%
folderName = 'plotForPaper';
if ~exist(folderName, 'dir'), mkdir(folderName); end

date = strrep(date, '/', '-');

saveName = ['temp_2012-' date num2str(h,'%02d') '_sens_' str tidyName(abbr(sens)) '.png'];
saveas(gcf, [folderName '/' saveName]);