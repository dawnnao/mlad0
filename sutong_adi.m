clear;clc;close all;

pathRoot = '/Volumes/midDisk/sutong-2012-tidy';
% pathRoot = 'G:/sutong-2012-tidy';

sensorNum = [3 4];
dateStart = '2012-01-01';
dateEnd = '2012-01-01';
sensorTrainRatio = 30/100;
sensorPSize = 10;
step = [2 3];

%%
sensor = adi(pathRoot,sensorNum,dateStart,dateEnd,sensorTrainRatio,sensorPSize,step);

