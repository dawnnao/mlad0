function sensor = adi3p5(~, sensorNum, dateStart, dateEnd, sensorTrainRatio, sensorPSize, step, labelName)
% DESCRIPTION:
%   This is a smart pre-processing(spp) function for bridge's structural
%   health monitoring data. The work flow is: read tidy data -> assist user
%   label partial data to make a training set -> automatically train a
%   neural network and classify all data -> automatically remove bad data ->
%   automatically recover data using Group Compress Sensing.

% OUTPUTS:
%   sensor (structure):
%   sensor.num (double) - column number in the inputted tidy data
%   sensor.trainRatio (cell) - ratio to make man-labeled data set
%   sensor.pSize (double) - data points in a packet in wireless transmission
%                           (if a packet loses in transmission, all points
%                            within become outliers)
%   sensor.data (cell) - sensor raw data
%   sensor.date (structure) - date information per hour
%   sensor.image (cell) - image vector of data per hour
%   sensor.status (cell) - work flow status
%   sensor.label (structure) - label of data to indicate good or bad
%   sensor.trainSetSize (double) - size of training set
%   sensor.neuralNet (cell) - neural network variable
%   sensor.trainRecord (cell) - train record
%   sensor.count (structure) - position of good data and bad data
% 
% INPUTS:
%   pathRoot (char) - data folder¡®s absolute path
%   sensorNum (double) - column nubmer of sensor in mat file of raw data. 
%                        Multiple numbers in a vector are supported
%   dateStart (char) - start date of data, input format: 'yyyy-mm-dd'
%   dateEnd (char) - end date of data, input format: 'yyyy-mm-dd'
%   sensorTrainRatio (double) - ratio to make man-labeled data set
%   sensorPSize (double) - data points in a packet in wireless transmission
%                          (if a packet loses in transmission, all points
%                           within become outliers)
%   step - step that starts at, including: 1.dataGlance  2.traningSetMake
%          3.dataClassify  4.outlierRemove  5.compressSensingRecover
%          (same as sensor.status)
% 
% DEFAULT VALUES:
%   sensorTrainRatio = 5/100
%   sensorPSize = 10
%   step = 1
% 
% DATA FORMAT:
%   Each mat file contains an hour data for all sensors, and each sensor's
%   signal is a column vector. For example, 10 sensors, all with a 1Hz
%   sampling frequency, there would be a 3600*10 array, named 'data'.
%   Folder frame should be like this:
%   -- 2016
%      |
%       - 2016-01-01
%         |
%          - 2016-01-01 00-VIB.mat
%          - 2016-01-01 01-VIB.mat
%          - 2016-01-01 02-VIB.mat
%          .
%          .
%          .
%          - 2016-01-01 23-VIB.mat
%       - 2016-01-02
%       - 2016-01-03
%       .
%       .
%       .
%       - 2016-12-31
%   Subfolder and mat file's name should strictly follow the format above.
% 
% CAUTION:
%   spp.m uses subfunction: colLocation.m, panorama.m, GetFullPath.m and
%   sec2hms.m. Insure they are there in the working directory.

% EDITION:
%   0.4
% 
% AUTHOR:
%   Zhiyi Tang
%   tangzhi1@hit.edu.cn
%   Center of Structural Monitoring and Control
% 
% DATE CREATED:
%   2016/12/09

% set input defaults:
if ~exist('sensorTrainRatio', 'var') || isempty(sensorTrainRatio), sensorTrainRatio = 5/100; end
if ~exist('sensorPSize', 'var') || isempty(sensorPSize), sensorPSize = 10; end
if ~exist('step', 'var'), step = []; end
if ~exist('labelName', 'var') || isempty(labelName)
    labelName = {'1-normal','2-outlier','3-minor','4-missing','5-trend','6-drift','7-bias','8-cutoff','9-square'};
end

%% common variables
labelTotal = length(labelName);
if ~iscell(sensorNum), sensorNum = {sensorNum}; end
groupTotal = length(sensorNum(:));
sensor.numVec = [];
for g = 1 : groupTotal, sensor.numVec = [sensor.numVec sensorNum{g}(:)']; end
sensorTotal = length(sensor.numVec);
color= {[129 199 132]/255;    % 1-normal     green
        [244 67 54]/255;      % 2-outlier    red
        [121 85 72]/255;      % 3-minor      brown
        [255 112 67]/255;     % 4-missing    orange
        [33 150 243]/255;     % 5-trend      blue
        [171 71 188]/255;     % 6-drift      purple
        [255 235 59]/255;     % 7-bias       yellow
        [168 168 168]/255;    % 8-cutoff     gray
        [50 50 50]/255;       % 9-square     black
        [0 121 107]/255;      % for custom   dark green
        [24 255 255]/255;     % for custom   high-light blue
        [118 255 3]/255;      % for custom   high-light green
        [255 255 0]/255;      % for custom   high-light yellow
        [50 50 50]/255};      % for custom   dark green

%% pass parameters to variables inside
sensor.num = sensorNum;
date.start = dateStart;
date.end = dateEnd;
for s = 1 : sensorTotal
    sensor.trainRatio(sensor.numVec(s)) = sensorTrainRatio;
end
sensor.pSize = sensorPSize;
sensor.label.name = labelName;

%% 0 generate file and folder names
sensorStr = tidyName(abbr(sensor.numVec));
dirName.home = sprintf('%s--%s_sensor%s', date.start, date.end, sensorStr);
dirName.file = [dirName.home '.mat'];

if ~exist(dirName.home,'dir'), mkdir(dirName.home); end
for g = 1 : groupTotal
    for s = sensor.num{g}
        dirName.sensor{s} = [dirName.home sprintf('/sensor%02d', s)];
        if ~exist(dirName.sensor{s},'dir'), mkdir(dirName.sensor{s}); end
    end
end

%% 3 train network and do classification
if ismember(3, step) || isempty(step)
% update new parameters and load training sets
% if ~isempty(step) && step(1) == 3
%     for s = sensor.numVec
%         newP{1,s} = sensor.trainRatio(s);
%     end
%     newP{2,1} = sensor.pSize;
%     newP{3,1} = step;
%     dirName.mat = [GetFullPath(dirName.home) '/trainingSetMat'];
%     
%     for g = 1 : groupTotal
%         for s = sensor.num{g}
%             dirName.matPart{s} = [dirName.mat sprintf('/sensor%02d.mat', s)];
%             if ~exist(dirName.matPart{s}, 'file')
%                 fprintf('\nCAUTION:\nSensor-%02d traning set not found! Ignored it.\n', s)
%                 index = find(sensor.num{g} == s);
%                 sensor.num{g}(index) = [];
%             else
%                 load(dirName.matPart{s});
%                 sensor.label.manual{s} = labelTemp;
%                 for l = 1 : labelTotal
%                     manual.label{l}.image{s} = manualTemp{l};
%                     count.label{l,s} = countTemp{l};
%                 end
%                 clear labelTemp manualTemp countTemp
%             end
%         end
%     end
%     % update
%     sensor.numVec = [];
%     for g = 1 : groupTotal, sensor.numVec = [sensor.numVec sensor.num{g}(:)']; end
%     if isempty(sensor.numVec)
%         fprintf('\nCAUTION:\nNo training set found in\n%s\n', dirName.mat)
%         fprintf('Need to make trainning set (step2) first.\nFinish.\n')
%         return
%     end
%     
%     for s = sensor.numVec
%         sensor.trainRatio(s) = newP{1,s};
%     end
%     sensor.pSize =  newP{2,1};
%     step = newP{3,1};
%     clear newP
% end
t(3) = tic;
% dirName.formatIn = 'yyyy-mm-dd';
% date.serial.start = datenum(date.start, dirName.formatIn);  % day numbers from year 0000
% date.serial.end   = datenum(date.end, dirName.formatIn);
% hourTotal = (date.serial.end-date.serial.start+1)*24;
% 
% dirName.net = [dirName.home '/net'];
% if ~exist(dirName.net,'dir'), mkdir(dirName.net); end

% fprintf('\nData combining...\n')
% for g = 1 : groupTotal
%     feature{g}.image = [];
%     feature{g}.label.manual = [];
%     for s = sensor.num{g}
%         for l = 1 : labelTotal
%             feature{g}.image = [feature{g}.image manual.label{l}.image{s}];  % modify here!
%             feature{g}.label.manual = [feature{g}.label.manual sensor.label.manual{s}(:,count.label{l,s})];  % modify here!
%         end
%     end
% end
% 
% seed = 1;
% rng(seed,'twister');
% fprintf('\nTraining...\n')
% for g = 1 : groupTotal
%     randp{g} = randperm(size(feature{g}.image,2));  % randomization
%     feature{g}.image = feature{g}.image(:, randp{g});
%     feature{g}.label.manual = feature{g}.label.manual(:, randp{g});
%     for s = sensor.num{g}(1)
%         % train neural net work
%         % choose a training function
%         % for a list of all training functions type: help nntrain
%         % 'trainlm' is usually fastest
%         % 'trainbr' takes longer but may be better for challenging problems
%         % 'trainscg' uses less memory, suitable in low memory situations, default
%         trainFcn = 'trainscg';  % scaled conjugate gradient backpropagation.
%         % create a pattern recognition network
%         hiddenLayerSize = 20;                % set hidden layer size (node quantity)
%         sensor.neuralNet{s} = patternnet(hiddenLayerSize, trainFcn);
%         % setup division of data for training, validation, testing
%         sensor.neuralNet{s}.divideParam.trainRatio = 70/100;
%         sensor.neuralNet{s}.divideParam.valRatio = 15/100;
%         sensor.neuralNet{s}.divideParam.testRatio = 15/100;
%         % train network
%         [sensor.neuralNet{s},sensor.trainRecord{s}] = ...
%             train(sensor.neuralNet{s}, feature{g}.image, feature{g}.label.manual); % problem here !!!
%         nntraintool close
% 
%         % neural net, and view it
%         temp.jFrame = view(sensor.neuralNet{s});
%         % create it in a MATLAB figure
%         temp.hFig = figure('Menubar','none', 'Position',[100 100 565 166]);
%         jpanel = get(temp.jFrame,'ContentPane');
%         [~,h] = javacomponent(jpanel);
%         set(h, 'units','normalized', 'position',[0 0 1 1]);
%         % close java window
%         temp.jFrame.setVisible(false);
%         temp.jFrame.dispose();
%         % print to file
%         set(temp.hFig, 'PaperPositionMode', 'auto');
%         saveas(temp.hFig, [dirName.net '/netArchitecture.png']);
%         % close figure
%         close(temp.hFig)
% 
%         plotperform(sensor.trainRecord{s});
%         saveas(gcf,[dirName.net '/netPerform.png']);
%         close
%         clear h jpanel
%         temp = rmfield(temp, {'jFrame', 'hFig'});
%     end
%     % copy to every sensor
%     if length(sensor.num{g} > 1)
%         for s = sensor.num{g}(2:end)
%             sensor.neuralNet{s} = sensor.neuralNet{sensor.num{g}(1)};
%             sensor.trainRecord{s} = sensor.trainRecord{sensor.num{g}(1)};
%         end
%     end
% 
%     % classification
%     fprintf('\nDetecting...\n')
%     [labelTempNeural, countTempNeural, dateVec, dateSerial] = ...
%         classifierMulti(pathRoot, sensor.num{g}, date.serial.start, date.serial.end, ...
%         dirName.home, sensor.label.name, sensor.neuralNet); % give all nn, need to check
%     % to avoid overwritten by next group
%     for s = sensor.num{g}
%         sensor.label.neuralNet{s} = labelTempNeural{s};
%         for l = 1 : labelTotal
%             sensor.count{l,s} = countTempNeural{l,s};
%         end
%         sensor.date.vec{s} = dateVec;
%         sensor.date.serial{s} = dateSerial;
%     end
%     clear labelTempNeural countTempNeural
%     fprintf('\nGroup %d done.\n\n\n', g)
% end

labelNameTemp = sensor.label.name;
savePath = [GetFullPath(dirName.home) '/' dirName.file];
load(savePath)
sensor.label.name = labelNameTemp;

% plot panorama
dirName.plotPano = [dirName.home '/plot/panorama'];
if ~exist(dirName.plotPano, 'dir'), mkdir(dirName.plotPano); end
for s = sensor.numVec
    panorama(sensor.date.serial{s}, sensor.label.neuralNet{s}, sprintf('Sensor%02d', s), color(1:labelTotal));
    dirName.panorama{s} = [sprintf('%s--%s_sensor_%02d', date.start, date.end, s) '_anomalyDetectionPanorama.png'];
    saveas(gcf,[dirName.plotPano '/' dirName.panorama{s}]);
    fprintf('\nSenor-%02d anomaly detection panorama file location:\n%s\n', ...
        s, GetFullPath([dirName.plotPano '/' dirName.panorama{s}]))
%     fprintf('\nPress anykey to continue.\n')
    pause(1.5)
    close
    % update sensor.status
    sensor.status{s}(2,3) = {1};
end

% % plot monthly stats per sensor
% dirName.plotSPS = [dirName.home '/plot/statsPerSensor'];
% if ~exist(dirName.plotSPS, 'dir'), mkdir(dirName.plotSPS); end
% for s = sensor.numVec
%     for n = 1 : 12
%         for l = 1 : labelTotal
%             aim = find(sensor.date.vec{s}(:,2) == n);
%             sensor.statsPerSensor{s}(n, l) = length(find(sensor.label.neuralNet{s}(aim) == l));
%         end
%     end
%     monthStatsPerSensor(sensor.statsPerSensor{s}, s, sensor.label.name, color);
%     dirName.statsPerSensor{s} = [sprintf('%s--%s_sensor_%02d', date.start, date.end, s) '_anomalyStats.png'];
%     saveas(gcf,[dirName.plotSPS '/' dirName.statsPerSensor{s}]);
%     fprintf('\nSenor-%02d anomaly stats bar-plot file location:\n%s\n', ...
%         s, GetFullPath([dirName.plotSPS '/' dirName.statsPerSensor{s}]))
% %     fprintf('\nPress anykey to continue.\n')
%     pause(1.5)
%     close
% end

% % plot anomaly space-time distribution per type
% dirName.plotSPT = [dirName.home '/plot/statsPerType'];
% if ~exist(dirName.plotSPT, 'dir'), mkdir(dirName.plotSPT); end
% for l = 1 : labelTotal
%    for s = sensor.numVec
%        for n = 1 : 12
%            aim = find(sensor.date.vec{s}(:,2) == n);
%            sensor.statsPerLabel{l}(n, s) = length(find(sensor.label.neuralNet{s}(aim) == l));
%        end
%    end
%    if sum(sum(sensor.statsPerLabel{l})) > 0
%         monthStatsPerLabel(sensor.statsPerLabel{l}, l, sensor.label.name{l}, color);
%         dirName.statsPerLabel{l} = [sprintf('%s--%s_sensor%s_anomalyStats_%s.png', ...
%             date.start, date.end, sensorStr, sensor.label.name{l})];
%         saveas(gcf,[dirName.plotSPT '/' dirName.statsPerLabel{l}]);
%         fprintf('\n%s anomaly stats bar-plot file location:\n%s\n', ...
%             sensor.label.name{l}, GetFullPath([dirName.plotSPT '/' dirName.statsPerLabel{l}]))
% %         fprintf('\nPress anykey to continue.\n')
%         pause(1.5)
%         close
%     end
% end

% % plot sensor-type bar stats
% dirName.plotSum = [dirName.home '/plot/statsSumUp'];
% if ~exist(dirName.plotSum, 'dir'), mkdir(dirName.plotSum); end
% for s = sensor.numVec
%    for l = 1 : labelTotal
%        statsSum(s, l) = length(find(sensor.label.neuralNet{s} == l));
%    end
% end
% 
% if ~isempty(statsSum(1,1)) && size(statsSum, 1) == 1
%     statsSum(2,1:labelTotal) = 0;
% end
% 
% figure
% h = bar(statsSum, 'stacked');
% xlabel('Sensor');
% ylabel('Count (hours)');
% legend(sensor.label.name);
% lh=findall(gcf,'tag','legend');
% set(lh,'location','northeastoutside');
% title(sprintf('%s--%s', date.start, date.end));
% grid on
% for n = 1 : labelTotal
%     set(h(n),'FaceColor', color{n});
% end
% set(gca, 'fontsize', 12);
% 
% dirName.statsSum = sprintf('%s--%s_sensor%s_anomalyStats.png', ...
%     date.start, date.end, sensorStr);
% saveas(gcf,[dirName.plotSum '/' dirName.statsSum]);
% fprintf('\nSum-up anomaly stats image file location:\n%s\n', ...
%     GetFullPath([dirName.plotSum '/' dirName.statsSum]))
% pause(1.5)
% close
% 
% % crop legend to panorama's folder
% img = imread([dirName.plotSum '/' dirName.statsSum]);
% if ispc
%     imgLegend = imcrop(img, [646.5 42.5 172 264]);
% elseif ismac
% %     imgLegend = imcrop(img, [660.5 42.5 160 229]);
%     imgLegend = imcrop(img, [882.5 57.5 204 280]);
% end
% figure, imshow(imgLegend)
% saveas(gcf, [dirName.plotPano '/legend.png']); close

elapsedTime(3) = toc(t(3)); [hours, mins, secs] = sec2hms(elapsedTime(3));
fprintf('\n\n\nSTEP3:\nAnomaly detection completes, using %02dh%02dm%05.2fs .\n', ...
    hours, mins, secs)

% ask go on or stop
head = 'Continue to step4, automatically remove outliers?';
tail = 'Continue to automatically remove outliers...';
savePath = [GetFullPath(dirName.home) '/' dirName.file];
fprintf('\nSaving results...\nLocation: %s\n', savePath)
if exist(savePath, 'file'), delete(savePath); end
save(savePath, '-v7.3')
if isempty(step)
    rightInput = 0;
    while rightInput == 0
        fprintf('\n%s\n', head)
        prompt = 'y(yes)/n(no): ';
        go = input(prompt,'s');
        if strcmp(go,'y') || strcmp(go,'yes')
            rightInput = 1; fprintf('\n%s\n\n\n', tail)
        elseif strcmp(go,'n') || strcmp(go,'no')
            rightInput = 1; fprintf('\nFinish.\n'), return
        else fprintf('Invalid input! Please re-input.\n')
        end
    end
elseif step == 3, fprintf('\nFinish.\n'), return
elseif ismember(4, step), fprintf('\n%s\n\n\n', tail)
end
pause(0.5)
clear head tail savePath

end

end
