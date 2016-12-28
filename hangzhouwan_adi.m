clear;clc;close all;

pathRoot = '/Volumes/midDisk/hangzhouwan-2016Q1-tidy/netmanager_b';
% pathRoot = 'F:\hangzhouwan-2016Q1-tidy\netmanager_b';

sensorNum = [1 8 2];
dateStart = '2016-01-01';
dateEnd = '2016-01-01';
sensorTrainRatio = 40/100;
% sensorPSize = 10;
step = [];
labelName = {'1-normal','2-outlier','3-minor'};

sensor = adi(pathRoot,sensorNum,dateStart,dateEnd,sensorTrainRatio,[],step,[]);



