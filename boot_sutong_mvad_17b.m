clear;clc;close all;

readRoot = 'C:/dataArchiveTemp/Sutong';
saveRoot = 'E:/results/adi';

% readRoot = 'E:/dataArchive/Sutong';
% saveRoot = 'C:/Users/Owner/Documents/GitHub/adi/case';

% saveRoot = 'F:/adi/case';

% readRoot = '/Volumes/bigDisk/sutong-2012-tidy';
% saveRoot = '/Volumes/bigDisk';

% readRoot = '/Users/zhiyitang/Programming/data/Sutong';
% saveRoot = '/Users/zhiyitang/Programming/results/adi';

% readRoot = '/Volumes/ssd/sutong-2012-tidy';
% saveRoot = '/Users/tangzhiyi/Documents/MATLAB/adi/case';

% for n = 1 : 38, sensorNum{n} = n; end
sensorNum = [1:38];
dateStart = '2012-01-01';
dateEnd = '2012-12-31';
sensorTrainRatio = 3/100;
sensorPSize = 10;
step = [3 4 5];
% labelName = {'1-normal','2-missing','3-minor','4-outlier','5-square','6-trend up','7-trend down','8-trend random'};
% seed = 2; % for random number generation
maxEpoch = [300 500];

%%
for seed =  [6]%1 : 20
    sensor = mvad2(readRoot, saveRoot, sensorNum, dateStart, dateEnd, ...
                   sensorTrainRatio, sensorPSize, step, [], seed, maxEpoch);
end

