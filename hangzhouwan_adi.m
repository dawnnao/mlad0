clear;clc;close all;

% pathRoot = '/Volumes/midDisk/hangzhouwan-2016Q1-tidy/netmanager_b';
pathRoot = 'F:\hangzhouwan-2016Q1-tidy\netmanager_b';

sensorNum = [27];
dateStart = '2016-01-01';
dateEnd = '2016-01-01';
sensorTrainRatio = 50/100;
sensorPSize = 10;
step = [3];

%%
sensor = adi(pathRoot,sensorNum,dateStart,dateEnd,sensorTrainRatio,sensorPSize, step);

% sensor = pspp([], sensorNum, dateStart, dateEnd, sensorTrainRatio, sensorPSize, step);

