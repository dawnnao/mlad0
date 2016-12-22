clear;clc;close all;

pathRoot = '/Volumes/midDisk/hangzhouwan-2016Q1-tidy/netmanager_b';
% pathRoot = 'G:/hangzhouwan-2016Q1-tidy/netmanager_b';

dateStart = '2016-01-01';
dateEnd = '2016-01-01';
sensorTrainRatio = 10/100;
sensorPSize = 20;
step = 1;

%%
for sensorNum = 26:27
    psppTest(pathRoot,sensorNum,dateStart,dateEnd,[],sensorPSize,step);
end

