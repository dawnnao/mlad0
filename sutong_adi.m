clear;clc;close all;

% pathRoot = '/Volumes/midDisk/sutong-2012-tidy';
pathRoot = 'G:/sutong-2012-tidy';

for n = 1 : 38, sensorNum{n} = n; end
% sensorNum = [1:38];
dateStart = '2012-01-01';
dateEnd = '2012-12-31';
sensorTrainRatio = 3/100;
sensorPSize = 10;
step = [3];

%%
sensor = adidnn(pathRoot,sensorNum,dateStart,dateEnd,sensorTrainRatio, sensorPSize,step);

