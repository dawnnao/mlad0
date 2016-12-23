clear;clc;close all;

pathRoot = '/Volumes/midDisk/hangzhouwan-2016Q1-tidy/netmanager_b';

sensorNum = [27];
dateStart = '2016-01-01';
dateEnd = '2016-01-03';
sensorTrainRatio = 30/100;
sensorPSize = 10;
step = [2 3];

%%
sensor = psppTest2(pathRoot,sensorNum,dateStart,dateEnd,sensorTrainRatio,sensorPSize, step);

% sensor = pspp([], sensorNum, dateStart, dateEnd, sensorTrainRatio, sensorPSize, step);

