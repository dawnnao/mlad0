clear;clc;close all;


readRoot = 'H:/sutong-2012-tidy';
saveRoot = 'F:/adi/case';

% saveRoot = 'F:/adi/case';

% readRoot = '/Volumes/bigDisk/sutong-2012-tidy';
% saveRoot = '/Volumes/bigDisk';

% readRoot = '/Volumes/ssd/sutong-2012-tidy';
% saveRoot = '/Users/tangzhiyi/Documents/MATLAB/adi/case';

% for n = 1 : 38, sensorNum{n} = n; end
sensorNum = [32];
dateStart = '2012-01-01';
dateEnd = '2012-01-02';
sensorTrainRatio = 1/100;
sensorPSize = 10;
step = [1];
% labelName = {'1-normal','2-missing','3-minor','4-outlier','5-square','6-trend up','7-trend down','8-trend random'};

%%
sensor = mvad(readRoot, saveRoot, sensorNum, dateStart, dateEnd, ...
            sensorTrainRatio, sensorPSize, step, []);

