function sensor = psppTest(pathRoot, sensorNum, dateStart, dateEnd, sensorTrainRatio, sensorPSize, step)
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
%   0.2
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
if ~exist('step', 'var') || isempty(step), step = 1; end

%% pass variables
sensor.num = sensorNum;
date.start = dateStart;
date.end = dateEnd;
for n = 1 : length(sensor.num)
    sensor.trainRatio(sensor.num(n)) = sensorTrainRatio;
end
sensor.pSize = sensorPSize;

%% 0 generate file and folder names
sensorStr = tidyName(abbr(sensor.num));

dirName.home = sprintf('%s--%s_sensor%s', date.start, date.end, sensorStr);
dirName.file = [dirName.home '.mat'];

if ~exist(dirName.home,'dir')
    mkdir(dirName.home);
else
    if step == 1
        a = 0;
        n = 2;
        while a == 0
            temp = [dirName.home sprintf(' %d', n)];
            if ~exist(temp,'dir'), dirName.home = temp; mkdir(dirName.home); a = 1;
            else n = n + 1; end
        end
        clear temp
    end
end

for s = sensor.num
    dirName.sensor{s} = [dirName.home sprintf('/sensor%02d', s)];
    if ~exist(dirName.sensor{s},'dir'), mkdir(dirName.sensor{s}); end
end

%% 1 read data
if step == 1
for s = sensor.num
    t(1) = tic;
    
    dirName.formatIn = 'yyyy-mm-dd';
    date.serial.start = datenum(date.start, dirName.formatIn);  % day numbers from year 0000
    date.serial.end   = datenum(date.end, dirName.formatIn);
    
    % plot from mat file
    dirName.all{s} = [dirName.sensor{s} '/0-all'];
    if ~exist(dirName.all{s},'dir'), mkdir(dirName.all{s}); end
    
    [~, sensor.date.vec{s}, sensor.date.serial{s}] = ...
        glance(pathRoot, s, date.serial.start, date.serial.end, dirName.all{s}, '0-all_');
    util.hours = size(sensor.date.vec{s}, 1);
    
    elapsedTime(1) = toc(t(1)); [hours, mins, secs] = sec2hms(elapsedTime(1));
    fprintf('\nSTEP1:\nSensor-%02d data images generation completes, using %02d:%02d:%05.2f .\n', ...
        s, hours, mins, secs)
    
    % work flow status
    sensor.status{s} = {'1.dataGlance' '2.traningSetMake' '3.dataClassify'...
             '4.outlierRemove' '5.compressSensingRecover'; 0 0 0 0 0};
    sensor.status{s}(2,1) = {1};
end

% ask go on or stop
head = 'Continue to step2, label some data for building neural networks?';
tail = 'Continue to manually make training set...';
savePath = GetFullPath(dirName.home);
fileName = dirName.file;
preset = 'n';
fprintf('\n%s\n', head)
rightInput = 0;
while rightInput == 0
    if ~exist('preset', 'var'), preset = []; end
    if strcmp(preset, 'y')  || strcmp(preset, 'yes')
        go = 'y';
    elseif strcmp(preset, 'n')  || strcmp(preset, 'no')
        go = 'n';
    else
        prompt = 'y(yes)/n(no): ';
        go = input(prompt,'s');
    end

    if strcmp(go,'y') || strcmp(go,'yes')
        rightInput = 1;
        fprintf('\n%s\n\n\n', tail)
    elseif strcmp(go,'n') || strcmp(go,'no')
        rightInput = 1;
        fprintf('\nSaving results...\nLocation: %s\n', savePath)
        if exist([savePath '/' fileName], 'file')
            delete([savePath '/' fileName]);
        end
        save([savePath '/' fileName], '-v7.3')
        fprintf('\nFinish! Check data status in sensor.status .\n')
        return
    else
        fprintf('Invalid input! Please re-input.\n')
    end
end
pause(2)
clear head tail savePath fileName preset

end

%% 2 manually make training set
if step == 1 || step == 2
% update new parameters
if step == 2
    for s = sensor.num
        newP{1,s} = sensor.trainRatio(s);
    end
    newP{2,1} = sensor.pSize;
    newP{3,1} = step;
    load([dirName.home '/' dirName.file]);
    for s = sensor.num
        sensor.trainRatio(s) = newP{1,s};
    end
    sensor.pSize =  newP{2,1};
    step = newP{3,1};
    clear newP
end
t(2) = tic;
seed = 1;  %intialize
goNext = 0;
while goNext == 0
    % randomization
    rng(seed,'twister');
    sensor.random = randperm(util.hours);
    for s = sensor.num
        sensor.label.manual{s} = zeros(6,util.hours);
        % manually label
        sensor.trainSetSize(s) = floor(sensor.trainRatio(s) * util.hours);
        figure
        n = 1;
        while n <= sensor.trainSetSize(s)
            sensor.label.manual{s}(:,sensor.random(n)) = zeros(6,1);  % initialize for re-label
            plot(sensor.data{s}(:,sensor.random(n)),'color','k');
            set(gcf,'Units','pixels','Position',[100 100 300 300]);  % control figure's position
            set(gca,'Units','normalized', 'Position',[0.1300 0.1100 0.7750 0.8150]);  % control axis's position in figure
            xlim([0 size(sensor.data{s},1)]);
            fprintf('\nSensor-%02d trainning set size: %d  Now: %d\n', s, sensor.trainSetSize(s), n)
            prompt = 'Data type:\n1-normal      2-missing    3-outlier\n4-outrange    5-drift      6-trend\n0-redo previous\nInput: ';
            classify = input(prompt,'s');
            classify = str2double(classify);  % filter charactor input
            if classify <= 6 && classify >= 1
                sensor.label.manual{s}(classify,sensor.random(n)) = 1;
                n = n + 1;
            elseif classify == 0
                if n > 1
                    fprintf('\nRedo previous one.\n')
                    n = n - 1;
                else fprintf('\nThis is already the first!\n')
                end
            else
                fprintf('\n\n\n\n\n\nInvalid input! Input 1-6 for labelling, 0 for redoing previous one.\n')
            end
        end
        close
        % count manual label results
        for l = 1:6
            count.label{l,s} = find(sensor.label.manual{s}(l,:));
            manual.label{l}.data{s} = sensor.data{s}(:,count.label{l,s});
        end
    end
    
    % save manual label results
    sensor.label.name = {'1-normal','2-missing','3-outlier','4-outrange','5-drift','6-trend'};
    fprintf('\n\n\n\n\n\nCurrent existing data type:\n')
    % display existing data type(s) and creat folder(s)
    for l = 1:6
        sumParal = 0;
        for ss = sensor.num
            sumParal = sumParal + size(manual.label{l}.data{ss},2);
            if size(manual.label{l}.data{ss},2) > 0
                dirName.label.manual{l,ss} = [dirName.sensor{ss} '/' sensor.label.name{l} '/manual'];
                if ~exist(dirName.label.manual{l,ss},'dir'), mkdir(dirName.label.manual{l,ss}); end
                dirName.label.net{l,ss} = [dirName.sensor{ss} '/' sensor.label.name{l} '/neuralNet'];
                if ~exist(dirName.label.net{l,ss},'dir'), mkdir(dirName.label.net{l,ss}); end
            end
        end
        if sumParal > 0
            fprintf('%s\n', sensor.label.name{l})
        end
    end
    % re-label check
    sensor = rmfield(sensor, 'random');
    elapsedTime(2) = toc(t(2));
    [hours, mins, secs] = sec2hms(elapsedTime(2));
    fprintf('\nYou used %02d:%02d:%05.2f to label data.\n', hours, mins, secs)
    fprintf('\nGo to next step, or re-random sampling and re-label data\nfor any missing types?\n')
    rightInput = 0;
    while rightInput == 0
        prompt = 'g(go)/r(redo): ';
        go = input(prompt,'s');
        if strcmp(go,'r') || strcmp(go,'redo')
            rightInput = 1;
            seed = seed + 1;
%             t = tic;
        elseif strcmp(go,'g') || strcmp(go,'go')
            rightInput = 1;
            goNext = 1;
        else
            fprintf('Invalid input! Please re-input.\n')
        end
    end
end

% plot training set samples
ticRemain = tic;
c = 0; % total count
for s = sensor.num
    for l = 1:6
        manual.label{l}.image{s} = [];
        figure
        for n = 1:size(manual.label{l}.data{s},2)
            c = c + 1;
            fprintf('\nGenerating sensor-%02d images for %s data in training set...\nNow: %d  Total: %d  ',...
                s, sensor.label.name{l}, n, size(manual.label{l}.data{s},2))
            plot(manual.label{l}.data{s}(:,n),'color','k');
            set(gcf,'Units','pixels','Position',[100 100 100 100]);  % control figure's position
            set(gca,'Units','normalized', 'Position',[0 0 1 1]);  % control axis's position in figure
            set(gca,'visible','off');
            xlim([0 size(manual.label{l}.data{s},1)]);
            saveas(gcf,[dirName.label.manual{l,s} sprintf('/%s_', sensor.label.name{l}) num2str(count.label{l,s}(n)) '.png']);
            img = imread([dirName.label.manual{l,s} sprintf('/%s_', sensor.label.name{l}) num2str(count.label{l,s}(n)) '.png']);
            img = rgb2gray(img);
            manual.label{l}.image{s}(:,n) = im2double(img(:));
            tocRemain = toc(ticRemain);
            tRemain = tocRemain * (sensor.trainSetSize(s)*length(sensor.num) - c) / c;
            [hours, mins, secs] = sec2hms(tRemain);
            fprintf('About %02dh%02dm%05.2fs left.\n', hours, mins, secs)
        end
        close
    end
    % update sensor.status
    sensor.status{s}(2,2) = {1};
end

elapsedTime(2) = toc(t(2)); [hours, mins, secs] = sec2hms(elapsedTime(2));
fprintf('\n\n\nSTEP2:\nSensor(s) training set making completes, using %02d:%02d:%05.2f .\n', ...
    hours, mins, secs)

% ask go on or stop
head = 'Continue to step3, automatically train neural network and do classification now?';
tail = 'Continue to automatically train neural network and do classification...';
savePath = GetFullPath(dirName.home);
fileName = dirName.file;
preset = [];
fprintf('\n%s\n', head)
rightInput = 0;
while rightInput == 0
    if ~exist('preset', 'var'), preset = []; end
    if strcmp(preset, 'y')  || strcmp(preset, 'yes')
        go = 'y';
    elseif strcmp(preset, 'n')  || strcmp(preset, 'no')
        go = 'n';
    else
        prompt = 'y(yes)/n(no): ';
        go = input(prompt,'s');
    end

    if strcmp(go,'y') || strcmp(go,'yes')
        rightInput = 1;
        fprintf('\n%s\n\n\n', tail)
    elseif strcmp(go,'n') || strcmp(go,'no')
        rightInput = 1;
        fprintf('\nSaving results...\nLocation: %s\n', savePath)
        if exist([savePath '/' fileName], 'file')
            delete([savePath '/' fileName]);
        end
        save([savePath '/' fileName], '-v7.3')
        fprintf('\nFinish! Check data status in sensor.status .\n')
        return
    else
        fprintf('Invalid input! Please re-input.\n')
    end
end
pause(2)
clear head tail savePath fileName preset

end

%% 3 train network and do classification
if step == 1 || step == 2 || step == 3
% update new parameters
if step == 3
    for s = sensor.num
        newP{1,s} = sensor.trainRatio(s);
    end
    newP{2,1} = sensor.pSize;
    newP{3,1} = step;
    load([dirName.home '/' dirName.file]);
    for s = sensor.num
        sensor.trainRatio(s) = newP{1,s};
    end
    sensor.pSize =  newP{2,1};
    step = newP{3,1};
    clear newP
end
t(3) = tic;
dirName.net = [dirName.home '/net'];
if ~exist(dirName.net,'dir'), mkdir(dirName.net); end

feature.image = [];
feature.label.manual = [];

% add a sensor loop!!!!!!!!!!!!!!!!!!!!!!!!!
for s = sensor.num
    for l = 1:6
        feature.image = [feature.image manual.label{l}.image{s}];  % modify here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        feature.label.manual = [feature.label.manual sensor.label.manual{s}(:,count.label{l,s})];  % modify here !!!!!!!!!!!!!!!!!!!!!!!
    end
end

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% randomization
rng(seed,'twister');
randp = randperm(size(feature.image,2));
feature.image = feature.image(:, randp);
feature.label.manual = feature.label.manual(:, randp);

for s = sensor.num(1)
    % train neural net work
    % choose a training function
    % for a list of all training functions type: help nntrain
    % 'trainlm' is usually fastest
    % 'trainbr' takes longer but may be better for challenging problems
    % 'trainscg' uses less memory, suitable in low memory situations, default
    trainFcn = 'trainscg';  % scaled conjugate gradient backpropagation.
    % create a pattern recognition network
    hiddenLayerSize = 20;                % set hidden layer size (node quantity)
    sensor.neuralNet{s} = patternnet(hiddenLayerSize, trainFcn);
    % setup division of data for training, validation, testing
    sensor.neuralNet{s}.divideParam.trainRatio = 70/100;
    sensor.neuralNet{s}.divideParam.valRatio = 15/100;
    sensor.neuralNet{s}.divideParam.testRatio = 15/100;
    % train network
    [sensor.neuralNet{s},sensor.trainRecord{s}] = ...
        train(sensor.neuralNet{s},feature.image,feature.label.manual);
%     nntraintool close

    % neural net, and view it
    temp.jFrame = view(sensor.neuralNet{s});
    % create it in a MATLAB figure
    temp.hFig = figure('Menubar','none', 'Position',[100 100 565 166]);
    jpanel = get(temp.jFrame,'ContentPane');
    [~,h] = javacomponent(jpanel);
    set(h, 'units','normalized', 'position',[0 0 1 1]);
    % close java window
    temp.jFrame.setVisible(false);
    temp.jFrame.dispose();
    % print to file
    set(temp.hFig, 'PaperPositionMode', 'auto');
    saveas(temp.hFig, [dirName.net '/netArchitecture.png']);
    % close figure
    close(temp.hFig)

    plotperform(sensor.trainRecord{s});
    saveas(gcf,[dirName.net '/netPerform.png']);
    close
    clear h jpanel
    temp = rmfield(temp, {'jFrame', 'hFig'});
end
% copy to every sensor
for s = sensor.num(2:end)
    sensor.neuralNet{s} = sensor.neuralNet{sensor.num(1)};
    sensor.trainRecord{s} = sensor.trainRecord{sensor.num(1)};
end

% classification
for s = sensor.num
    sensor.label.neuralNet{s} = vec2ind(sensor.neuralNet{s}(sensor.image{s}));
    for l = 1:6
        sensor.count{l,s} = find(sensor.label.neuralNet{s}(:,:) == l);
    end
end

% generate realated folder(s)
for s = sensor.num
    for l = 1:6
        if ~isempty(sensor.count{l,s})
            dirName.label.net{l,s} = [dirName.sensor{s} '/' sensor.label.name{l} '/neuralNet'];
            if ~exist(dirName.label.net{l,s},'dir'), mkdir(dirName.label.net{l,s}); end
        end
    end
end

% images of classification results
for s = sensor.num
    figure
    for n = 1 : util.hours
        ticRemain = tic;
        set(gcf,'Units','pixels','Position',[100 100 100 100]);  % control figure's position
        set(gca,'Units','normalized', 'Position',[0 0 1 1]);  % control axis's position in figure
        set(gca,'visible','off');
        temp.image = reshape(sensor.image{s}(:,n),[util.imageHeight util.imageWidth]);
        imshow(temp.image)
        fprintf('\nGenerating sensor-%02d images...  Total: %d  Now: %d', ...
            s ,util.hours, n)
        fprintf('  %s', sensor.label.name{sensor.label.neuralNet{s}(n)})
        saveas(gcf,[dirName.label.net{sensor.label.neuralNet{s}(n), s} ...
            sprintf('/%s_', sensor.label.name{sensor.label.neuralNet{s}(n)}) num2str(n) '.png']);
        tocRemain = toc(ticRemain);
        tRemain = tocRemain * (util.hours - n);
        [hours, mins, secs] = sec2hms(tRemain);
        fprintf('  About %02dh%02dm%05.2fs left.\n', hours, mins, secs)
    end
    close
    temp = rmfield(temp, 'image');
end

% plot panorama
for s = sensor.num
    panorama(sensor.date.serial{s}, sensor.label.neuralNet{s});
    fprintf('\nSenor-%02d data classification panorama is saved in:\n%s\n', ...
        s, GetFullPath(dirName.home))
    fprintf('\nPress anykey to continue.\n')
    pause
    dirName.panorama{s} = [sprintf('sensor_%02d_%s--%s', s, date.start, date.end) '_raw_panorama.png'];
    saveas(gcf,[dirName.home '/' dirName.panorama{s}]);
    close
    % update sensor.status
    sensor.status{s}(2,3) = {1};
end

elapsedTime(3) = toc(t(3)); [hours, mins, secs] = sec2hms(elapsedTime(3));
fprintf('\n\n\nSTEP3:\nClassification completes, using %02d:%02d:%05.2f .\n', ...
    hours, mins, secs)

% ask go on or stop
head = 'Continue to step4, automatically remove outliers?';
tail = 'Continue to automatically remove outliers...';
savePath = GetFullPath(dirName.home);
fileName = dirName.file;
preset = [];
fprintf('\n%s\n', head)
rightInput = 0;
while rightInput == 0
    if ~exist('preset', 'var'), preset = []; end
    if strcmp(preset, 'y')  || strcmp(preset, 'yes')
        go = 'y';
    elseif strcmp(preset, 'n')  || strcmp(preset, 'no')
        go = 'n';
    else
        prompt = 'y(yes)/n(no): ';
        go = input(prompt,'s');
    end

    if strcmp(go,'y') || strcmp(go,'yes')
        rightInput = 1;
        fprintf('\n%s\n\n\n', tail)
    elseif strcmp(go,'n') || strcmp(go,'no')
        rightInput = 1;
        fprintf('\nSaving results...\nLocation: %s\n', savePath)
        if exist([savePath '/' fileName], 'file')
            delete([savePath '/' fileName]);
        end
        save([savePath '/' fileName], '-v7.3')
        fprintf('\nFinish! Check data status in sensor.status .\n')
        return
    else
        fprintf('Invalid input! Please re-input.\n')
    end
end
pause(2)
clear head tail savePath fileName preset

end

%% 4 clean outliers
if step == 1 || step == 2 || step == 3 || step == 4
% update new parameters
if step == 4
    for s = sensor.num
        newP{1,s} = sensor.trainRatio(s);
    end
    newP{2,1} = sensor.pSize;
    newP{3,1} = step;
    load([dirName.home '/' dirName.file]);
    for s = sensor.num
        sensor.trainRatio(s) = newP{1,s};
    end
    sensor.pSize =  newP{2,1};
    step = newP{3,1};
    clear newP
end
t(4) = tic;
dirName.outlierCleaned = [dirName.home '/outlierCleaned'];
if ~exist(dirName.outlierCleaned,'dir'), mkdir(dirName.outlierCleaned); end

figure
n = 1;
out.dotCount = 0;
out.pieceCount = 0;
while n <= util.hours       
    if sensor.label.neuralNet{s}(n) == 3  % 3-outlier
        ticRemain = tic;
        % hour location
        out.dotCount = out.dotCount + 1;
        [out.date, out.hour] = colLocation(n, date.start);
        fprintf('\n\n\nSensor-%02d:\nCount maximum as outlier.\n\n', s)
        fprintf('Data:\nDate:  %s  %02d:00-%02d:00  hour%d (from %s 00:00)\n\n', ...
            out.date, out.hour, out.hour+1, n, date.start)

        % outlier location
        [out.value, out.index] = max(abs(sensor.data{s}(:,n)));
        fprintf('Outlier:\nPosition: %d-%d\nValue: %d\nCount: %d (packet size: %d)\n\n', ...
            out.index, out.index+sensor.pSize-1, out.value, out.dotCount*sensor.pSize, sensor.pSize)

        % remove outlier
        sensor.data{s}(out.index:out.index+sensor.pSize-1, n) = 0;  % update sensor.data
        fprintf('Outliers are replaced by 0.\n')
        fprintf('Continue deleting outliers...\n\n')

        plot(sensor.data{s}(:,n),'color','k');
        set(gcf,'Units','pixels','Position',[100 100 100 100]);  % control figure's position
        set(gca,'Units','normalized', 'Position',[0 0 1 1]);  % control axis's position in figure
        set(gca,'visible','off');
        xlim([0 size(sensor.data{s},1)]);

        % save fixed data plot
        saveas(gcf,[dirName.outlierCleaned '/outlierCleaned_' num2str(n) '.png']);
        temp.image = imread([dirName.outlierCleaned '/outlierCleaned_' num2str(n) '.png']);
        temp.image = rgb2gray(temp.image);
        temp.image = im2double(temp.image(:));
        sensor.image{s}(:,n) = temp.image;  % update sensor.image
        temp.classify = vec2ind(sensor.neuralNet{s}(sensor.image{s}(:,n)));
        sensor.label.neuralNet{s}(n) = temp.classify;  % update sensor.label.neuralNet
%         nPrevious = n;
        if temp.classify == 1
            out.pieceCount = out.pieceCount + 1;
            sensor.label.neuralNet{s}(n) = temp.classify;
            fprintf('\n\nOutliers cleaned!\n%d outliers are in the data piece.\n%d data pieces remain to clean.\n', ...
                out.dotCount*sensor.pSize, length(sensor.count{3,s})-out.pieceCount)
            tocRemain = toc(ticRemain);
            tRemain = tocRemain * out.dotCount * (length(sensor.count{3,s})-out.pieceCount);
            [hours, mins, secs] = sec2hms(tRemain);
            fprintf('%02dh%02dm%05.2fs estimated time left.\n', hours, mins, secs)
            pause(2.5)
%             fprintf('Press anykey to continue.\n')
%             pause
            out.dotCount = 0;
            n = n + 1;
%         elseif temp.classify == 2
%             fprintf('Continue deleting outlier...\n\n')
        end
    else
        n = n + 1;
    end

    if n == util.hours+1
        elapsedTime(4) = toc(t(4));
        [hours, mins, secs] = sec2hms(elapsedTime(4));
        fprintf('\n\n\n\n\n\nSTEP4:\nSensor-%02d outlier cleaning done, using %02d:%02d:%05.2f .\n', ...
            s, hours, mins, secs)
        fprintf('%d data pieces cleaned.\n', length(sensor.count{3,s}))
    end
end
close

% update sensor.status
sensor.status{s}(2,4) = {1};
fprintf('\nSaving results...\nLocation: %s\n', GetFullPath(dirName.home))
if exist([dirName.home '/' dirName.file], 'file'), delete([dirName.home '/' dirName.file]); end
save([dirName.home '/' dirName.file])
fprintf('\nFinish!\n')
close all
end

end
