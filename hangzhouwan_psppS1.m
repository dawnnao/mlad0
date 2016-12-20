clear;clc;close all;

pathRoot = '/Volumes/midDisk/hangzhouwan-2016Q1-tidy/netmanager_b';
% pathRoot = 'G:/hangzhouwan-2016Q1-tidy/netmanager_b';

dateStart = '2016-02-28';
dateEnd = '2016-02-29';
sensorTrainRatio = 10/100;
sensorPSize = 20;
step = 1;

%%
for sensorNum = 1:1
    pspp(pathRoot,sensorNum,dateStart,dateEnd,[],sensorPSize,step);
end

