clear;clc;close all;

pathRoot = '/Volumes/midDisk/hangzhouwan-2016Q1-tidy/netmanager_b';
saveRoot = '/Users/tangzhiyi/Documents/MATLAB/adi/case';

sensorNum = {1,4};
dateStart = '2016-01-01';
dateEnd = '2016-01-01';
sensorTrainRatio = 50/100;
% sensorPSize = 10;
step = [5];
% labelName = {'1-normal','2-outlier','3-minor'};

sensor = mvad(pathRoot, saveRoot, sensorNum, dateStart, dateEnd, ...
                sensorTrainRatio, [], step, []);



