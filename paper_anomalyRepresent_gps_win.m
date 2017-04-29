clear;close all;clc


channel = [1,2,3];
date = '01/04/';
h = 11;
s = '±±Ëþ';
fileName = ['G:/sutong-2012-gps/' date sprintf('%s.txt', s)];
% data = csvread(fileName,0,2,[0,2,100,4]);

fid = fopen(fileName);
raw = textscan(fid, '%{yyyy-MM-dd HH:mm:ss}D %s %f %f %f %f %s', 'Delimiter', ',');
fclose(fid);
data = cell2mat(raw(1,3:5));

sect = (3600*12+1:3600*13);
t = 1:length(sect);
data = data(sect,:);
data = data - repmat(mean(data),[3600,1]);

figure
plot(t,data(:,channel),'linewidth',0.8);
% plot(t,data(:,1),t,data(:,2),t,data(:,3));
xlabel('Time(sec)');
ylabel('GPS data (m)');
% title(num2str(h));
xlim([0 size(data,1)]);

set(gca,'fontname', 'Times New Roman','fontweight','bold');
set(gca, 'fontsize', 14);
set(gca,'Units','normalized', 'Position',[0.09 0.21 0.9 0.7]);  % control axis's position in figure
% set(gca,'Units','normalized', 'OuterPosition',[0 0 1 1]);  % control axis's position in figure
set(gcf,'Units','pixels','Position',[100, 100, 1000, 300]);

% set(gca,'Units','normalized', 'Position',[0.08 0.12 0.9 0.82]);  % control axis's position in figure
% % set(gca,'Units','normalized', 'OuterPosition',[0 0 1 1]);  % control axis's position in figure
% set(gcf,'Units','pixels','Position',[100, 100, 1000, 400]);

%%
folderName = 'plotForPaper';
if ~exist(folderName, 'dir'), mkdir(folderName); end

date = strrep(date, '/', '-');

saveName = ['gps_2012-' date num2str(h,'%02d') '_sens_' s '.emf'];
saveas(gcf, [folderName '/' saveName]);