clear;clc;close all;

pathRoot = '/Volumes/bigDisk/sutong-2012-tidy';
% pathRoot = '/Users/tangzhiyi/Documents/MATLAB/2016';

sensorNum = 27;
dateStart = '2016-01-01';
dateEnd = '2016-01-01';
sensorTrainRatio = 50/100;
sensorPSize = 20;
step = 1;

%%
sensor = spp(pathRoot,sensorNum,dateStart,dateEnd,sensorTrainRatio,sensorPSize,step);
