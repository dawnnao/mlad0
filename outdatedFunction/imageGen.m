function [sensorImage, width, height] = imageGen(sensorNum, sensorData, path, prefix)
% DESCRIPTION:
%   This is a subfuntion of pspp.m, to generate images of raw data in user
%   specified folder and display progress in command window.

% OUTPUTS:
%   sensorImage (cell) - image vector in column. Each sensor's image vector
%   array is a cell
%   width (double) - image width (pixel)
%   height (double) - image height (pixel)
% 
% INPUTS:
%   sensorNum (double) - column nubmer of sensor in mat file of raw data
%   sensorData (cell) - raw data in column. Each sensor's data is a cell
%   path (char) - images' storage location
%   prefix (char) - image file name prefix

% AUTHOR:
%   Zhiyi Tang
%   tangzhi1@hit.edu.cn
%   Center of Structural Monitoring and Control
% 
% DATE CREATED:
%   2016/12/19

figure
for n = 1 : size(sensorData, 2)
    ticRemain = tic;
    plot(sensorData(:,n),'color','k');
    set(gcf,'Units','pixels','Position',[100 100 100 100]);  % control figure's position
    set(gca,'Units','normalized', 'Position',[0 0 1 1]);  % control axis's position in figure
    set(gca,'visible','off');
    xlim([0 size(sensorData,1)]);
    fprintf('\nGenerating sensor-%02d images...\nTotal: %d  Now: %d', ...
        sensorNum, size(sensorData, 2), n)
    pathAll = [path '/' prefix num2str(n) '.png'];
    saveas(gcf,pathAll);
    img = imread(pathAll);
    img = rgb2gray(img);
    sensorImage(:,n) = im2double(img(:));
    tocRemain = toc(ticRemain);
    tRemain = tocRemain * (size(sensorData, 2) - n);
    [hours, mins, secs] = sec2hms(tRemain);
    fprintf('  About %02dh%02dm%05.2fs left.\n', hours, mins, secs)
end
imageInfo = imfinfo(pathAll);
width = imageInfo.Width;
height = imageInfo.Height;
close all

end
