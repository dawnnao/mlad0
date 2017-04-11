clear;clc;close all;


readRoot = 'G:/sutong-2012-tidy';
saveRoot = 'F:/adi';

% readRoot = '/Volumes/bigDisk/sutong-2012-tidy';
% saveRoot = '/Volumes/bigDisk';

% readRoot = '/Volumes/ssd/sutong-2012-tidy';
% saveRoot = '/Users/tangzhiyi/Documents/MATLAB/adi/case';

% for n = 1 : 38, sensorNum{n} = n; end
sensorNum = [1:38];
dateStart = '2012-01-01';
dateEnd = '2012-12-31';
sensorTrainRatio = 20/100;
sensorPSize = 10;
step = [5];

%%
sensor = mvad(readRoot, saveRoot, sensorNum, dateStart, dateEnd, ...
            sensorTrainRatio, sensorPSize, step, []);

