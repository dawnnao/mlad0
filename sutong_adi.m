clear;clc;close all;


readRoot = 'G:/sutong-2012-tidy';
saveRoot = 'F:/adi';

% readRoot = '/Volumes/bigDisk/sutong-2012-tidy';
% saveRoot = '/Volumes/bigDisk';

% readRoot = '/Volumes/ssd/sutong-2012-tidy';
% saveRoot = '/Users/tangzhiyi/Documents/MATLAB/adi/case';

% for n = 2 : 2, sensorNum{n} = n; end
sensorNum = [1];
dateStart = '2012-01-01';
dateEnd = '2012-01-07';
sensorTrainRatio = 20/100;
sensorPSize = 10;
step = [2];

%%
sensor = adidnn(readRoot, saveRoot, sensorNum, dateStart, dateEnd, ...
            sensorTrainRatio, sensorPSize, step, []);

