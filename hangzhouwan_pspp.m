clear;clc;close all;

pathRoot = '/Volumes/midDisk/hangzhouwan-2016Q1-tidy/netmanager_b';

sensorNum = [27 28];
dateStart = '2016-01-31';
dateEnd = '2016-02-01';
sensorTrainRatio = 30/100;
sensorPSize = 10;
step = [3];

%%
sensor = ad(pathRoot,sensorNum,dateStart,dateEnd,sensorTrainRatio,sensorPSize, step);

% sensor = pspp([], sensorNum, dateStart, dateEnd, sensorTrainRatio, sensorPSize, step);

