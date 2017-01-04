clear;clc;close all;

readRoot = '/Volumes/midDisk/hangzhouwan-2016Q1-tidy/netmanager_b';
saveRoot = '/Users/tangzhiyi/Documents/MATLAB/adi/case';
sensorNum = {1};
dateStart = '2016-01-01';
dateEnd = '2016-01-01';
sensorTrainRatio = 80/100;
% sensorPSize = 10;
step = [1];
% labelName = {'1-normal','2-outlier','3-minor'};

sensor = adidnn(readRoot, saveRoot, sensorNum, dateStart, dateEnd, ...
                sensorTrainRatio,[], step,[]);



