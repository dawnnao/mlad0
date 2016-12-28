clear;clc;close all;

pathRoot = '/Volumes/midDisk/hangzhouwan-2016Q1-tidy/netmanager_b';
% pathRoot = 'F:\hangzhouwan-2016Q1-tidy\netmanager_b';

sensorNum = [1];
dateStart = '2016-01-01';
dateEnd = '2016-01-1';
sensorTrainRatio = 40/100;
% sensorPSize = 10;
labelName = {'1-normal','2-outlier','3-minor'};

% %% []
% sensor = adi(pathRoot,sensorNum,dateStart,dateEnd,sensorTrainRatio,[]);
% 
% %% s1
% step = [1];
% sensor = adi(pathRoot,sensorNum,dateStart,dateEnd,[],[], step);
% 
%% s2
% sensorTrainRatio = 20/100;
step = [2 3];
sensor = adi(pathRoot,sensorNum,dateStart,dateEnd,sensorTrainRatio,[],step,labelName);

% %% s3
% step = [3];
% sensor = adi(pathRoot,sensorNum,dateStart,dateEnd,[],[], step);
