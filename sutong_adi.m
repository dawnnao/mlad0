clear;clc;close all;

% readRoot = '/Volumes/midDisk/sutong-2012-tidy';
readRoot = 'G:/sutong-2012-tidy';
saveRoot = 'F:/adi';
for n = 1 : 38, sensorNum{n} = n; end
% sensorNum = [1:38];
dateStart = '2012-01-01';
dateEnd = '2012-12-31';
sensorTrainRatio = 3/100;
sensorPSize = 10;
step = [5];

%%
sensor = adidnn(readRoot, saveRoot, sensorNum, dateStart, dateEnd, ...
            sensorTrainRatio, sensorPSize, step, []);

