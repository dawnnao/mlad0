clear;clc;close all;

% pathRoot = '/Volumes/midDisk/hangzhouwan-2016Q1-tidy/netmanager_b';
pathRoot = 'F:\hangzhouwan-2016Q1-tidy\netmanager_b';

sensorNum = [1:55];
dateStart = '2016-01-01';
dateEnd = '2016-03-31';
sensorTrainRatio = 3/100;
sensorPSize = 10;
step = [2];

%%
sensor = adi(pathRoot,sensorNum,dateStart,dateEnd,sensorTrainRatio,sensorPSize, step);

% sensor = pspp([], sensorNum, dateStart, dateEnd, sensorTrainRatio, sensorPSize, step);

