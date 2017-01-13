function sensor = spp(pathRoot, sensorNum, dateStart, dateEnd, sensorTrainRatio, sensorPSize, step)
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
%   sensor.date (structure) - date information per hour
%   sensor.data (cell) - sensor data
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
%   sensorNum (double) - column numer of sensor
%   dateStart (char) - start date of data, input format: 'yyyy-mm-dd'
%   dateEnd (char) - end date of data, input format: 'yyyy-mm-dd'
%   sensorTrainRatio (double) - ratio to make man-labeled data set
%   sensorPSize (double) - data points in a packet in wireless transmission
%                          (if a packet loses in transmission, all points
%                           within become outliers)
%   step - step that starts at, including: 1.dataRead  2.traningSetMake
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
%   0.1
% 
% AUTHOR:
%   Zhiyi Tang
%   tangzhi1@hit.edu.cn
%   Center of Structural Monitoring and Control
% 
% DATE CREATED:
%   2016/12/09

% set input defaults:
if ~exist('sensorTrainRatio', 'var'), sensorTrainRatio = 5/100; end
if ~exist('sensorPSize', 'var'), sensorPSize = 10; end
if ~exist('step', 'var'), step = 1; end

%% pass variables
sensor.num = sensorNum;
date.start = dateStart;
date.end = dateEnd;
sensor.trainRatio{sensor.num} = sensorTrainRatio;
sensor.pSize = sensorPSize;

%% 0 generate file and folder names
dirName.home = sprintf('sensor_%02d_%s--%s', sensor.num, date.start, date.end);
if ~exist(dirName.home,'dir'), mkdir(dirName.home); end

dirName.all = [dirName.home '/all'];
if ~exist(dirName.all,'dir'), mkdir(dirName.all); end

dirName.file = sprintf('sensor_%02d_%s--%s.mat', sensor.num, date.start, date.end);

%% 1 read data
if step == 1
t(1) = tic;

dirName.formatIn = 'yyyy-mm-dd';
date.serial.start = datenum(date.start, dirName.formatIn);  % day numbers from year 0000
date.serial.end   = datenum(date.end, dirName.formatIn);

% read data from mat file
[sensor.data{sensor.num}, sensor.date.vec{sensor.num}, sensor.date.serial{sensor.num}] = ...
    readIn(pathRoot, sensor.num, date.serial.start, date.serial.end);
temp.size.col = size(sensor.data{sensor.num},2);

% plot
sensor.image{sensor.num} = imageGen(sensor.num, sensor.data{sensor.num}, [dirName.all '/all_']);
temp.size.image = sqrt(size(sensor.image{sensor.num},1));

% check sensor.image is full filled or not
fprintf('\n\n\nCheck images generation ...\n')
fprintf('=0 for all done :)\n>0 for omit something :(\nResult: %d\n', ...
    sum(sum(isnan(sensor.image{sensor.num}))))

% work flow status
sensor.status{sensor.num} = {'1.dataRead' '2.traningSetMake' '3.dataClassify'...
         '4.outlierRemove' '5.compressSensingRecover'; 0 0 0 0 0};
sensor.status{sensor.num}(2,1) = {1};

elapsedTime(1) = toc(t(1)); [hours, mins, secs] = sec2hms(elapsedTime(1));
fprintf('\nSTEP1:\nSensor-%02d data reading completes, using %02d:%02d:%05.2f .', ...
    sensor.num, hours, mins, secs)
% ask go on or stop
head = 'Continue to step2, label some data for building neural networks?';
tail = 'Continue to manually make training set...';
go = request(head, tail, GetFullPath(dirName.home), dirName.file, 'y');
if strcmp(go,'n') || strcmp(go,'no'), return; end

end

%% 2 manually make training set
if step == 1 || step == 2
t(2) = tic;
if step == 2
    newP{1} = sensor.trainRatio{sensor.num};
    newP{2} = sensor.pSize;
    newP{3} = step;
    load([dirName.home '/' dirName.file]);
    sensor.trainRatio{sensor.num} = newP{1};
    sensor.pSize =  newP{2};
    step = newP{3};
    clear newP
end
seed = 1;
temp.man = 0;
while temp.man == 0
    sensor.label.manual{sensor.num} = zeros(6,temp.size.col);
    % randomization
    rng(seed,'twister');
    sensor.random = randperm(temp.size.col);
    
    % manually label
    sensor.trainSetSize = floor(sensor.trainRatio{sensor.num} * temp.size.col);
    figure
    n = 1;
    while n <= sensor.trainSetSize
        sensor.label.manual{sensor.num}(:,sensor.random(n)) = zeros(6,1);  % initialize for re-label
        plot(sensor.data{sensor.num}(:,sensor.random(n)),'color','k');
        set(gcf,'Units','pixels','Position',[100 100 300 300]);  % control figure's position
        set(gca,'Units','normalized', 'Position',[0.1300 0.1100 0.7750 0.8150]);  % control axis's position in figure
%         set(gca,'visible','off');
        xlim([0 size(sensor.data{sensor.num},1)]);
        fprintf('\nSensor-%02d trainning set size: %d  Now: %d\n', sensor.num, sensor.trainSetSize, n)
        prompt = 'Data type:\n1-normal      2-missing    3-outlier\n4-outrange    5-drift      6-trend interference\n0-redo previous\nInput: ';
        classify = input(prompt,'s');
        classify = str2double(classify);  % filter charactor input
        if classify <= 6 && classify >= 1
            sensor.label.manual{sensor.num}(classify,sensor.random(n)) = 1;
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
    sensor = rmfield(sensor, 'random');
    
    % count manual label results
    for n = 1:6
        count.label{n} = find(sensor.label.manual{sensor.num}(n,:));
        temp.label{n}.data{sensor.num} = sensor.data{sensor.num}(:,count.label{n});
    end
    
    % save manual label results
    labelName = {'1-normal','2-missing','3-outlier','4-outrange','5-drift','6-trend'};
    fprintf('\n\n\n\n\n\nCurrent existing data type:\n')
    for n = 1:6
        if size(temp.label{n}.data{sensor.num},2) > 0
%             fprintf('%d-%s\n', n, labelName{n})
            fprintf('%s\n', labelName{n})
            dirName.label{n}.manual = [dirName.home '/' labelName{n} '/manual'];
            if ~exist(dirName.label{n}.manual,'dir'), mkdir(dirName.label{n}.manual); end
            dirName.label{n}.net = [dirName.home '/' labelName{n} '/neuralNet'];
            if ~exist(dirName.label{n}.net,'dir'), mkdir(dirName.label{n}.net); end
        end
    end
    
    % re-label check
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
            temp.man = 1;
        else
            fprintf('Invalid input! Please re-input.\n')
        end
    end
end

% plot training set samples
for l = 1:6
    temp.label{l}.image{sensor.num} = [];
    figure
    for n = 1:size(temp.label{l}.data{sensor.num},2)
        ticRemain = tic;
        fprintf('\nGenerating sensor-%02d images for %d-%s data in training set...\nNow: %d  Total: %d  ',...
            sensor.num, l, labelName{l}, n, size(temp.label{l}.data{sensor.num},2))
        plot(temp.label{l}.data{sensor.num}(:,n),'color','k');
        set(gcf,'Units','pixels','Position',[100 100 100 100]);  % control figure's position
        set(gca,'Units','normalized', 'Position',[0 0 1 1]);  % control axis's position in figure
        set(gca,'visible','off');
        xlim([0 size(temp.label{l}.data{sensor.num},1)]);
        saveas(gcf,[dirName.label{l}.manual sprintf('/%s_', labelName{l}) num2str(count.label{l}(n)) '.png']);
        img = imread([dirName.label{l}.manual sprintf('/%s_', labelName{l}) num2str(count.label{l}(n)) '.png']);
        img = rgb2gray(img);
        temp.label{l}.image{sensor.num}(:,n) = im2double(img(:));
        tocRemain = toc(ticRemain);
        tRemain = tocRemain * (size(temp.label{l}.data{sensor.num},2) - n);
        [hours, mins, secs] = sec2hms(tRemain);
        fprintf('About %02dh%02dm%05.2fs left.\n', hours, mins, secs)
    end
    close
end

% update sensor.status
sensor.status{sensor.num}(2,2) = {1};

elapsedTime(2) = toc(t(2)); [hours, mins, secs] = sec2hms(elapsedTime(2));
fprintf('\n\n\nSTEP2:\nSensor-%02d training set making completes, using %02d:%02d:%05.2f .\n', ...
    sensor.num, hours, mins, secs)

head = 'Continue to step3, automatically train neural network and do classification now?';
tail = 'Continue to automatically train neural network and do classification...';
go = request(head, tail, GetFullPath(dirName.home), dirName.file, 'y');
if strcmp(go,'n') || strcmp(go,'no'), return; end

end

%% 3 train network and do classification
if step == 1 || step == 2 || step == 3
t(3) = tic;
if step == 3
    newP{1} = sensor.trainRatio{sensor.num};
    newP{2} = sensor.pSize;
    newP{3} = step;
    load([dirName.home '/' dirName.file]);
    sensor.trainRatio{sensor.num} = newP{1};
    sensor.pSize =  newP{2};
    step = newP{3};
    clear newP
end
dirName.net = [dirName.home '/net'];
if ~exist(dirName.net,'dir'), mkdir(dirName.net); end

feature.image = [];
feature.label.manual = [];
for n = 1:6
    feature.image = [feature.image temp.label{n}.image{sensor.num}];
    feature.label.manual = [feature.label.manual sensor.label.manual{sensor.num}(:,count.label{n})];
end

% randomization
rng(seed,'twister');
randp = randperm(size(feature.image,2));
feature.image = feature.image(:, randp);
feature.label.manual = feature.label.manual(:, randp);

% train neural net work
% choose a training function
% for a list of all training functions type: help nntrain
% 'trainlm' is usually fastest
% 'trainbr' takes longer but may be better for challenging problems
% 'trainscg' uses less memory, suitable in low memory situations, default
trainFcn = 'trainscg';  % scaled conjugate gradient backpropagation.

% create a pattern recognition network
hiddenLayerSize = 20;                % set hidden layer size (node quantity)
sensor.neuralNet{sensor.num} = patternnet(hiddenLayerSize, trainFcn);

% setup division of data for training, validation, testing
sensor.neuralNet{sensor.num}.divideParam.trainRatio = 70/100;
sensor.neuralNet{sensor.num}.divideParam.valRatio = 15/100;
sensor.neuralNet{sensor.num}.divideParam.testRatio = 15/100;

% train network
[sensor.neuralNet{sensor.num},sensor.trainRecord{sensor.num}] = ...
    train(sensor.neuralNet{sensor.num},feature.image,feature.label.manual);
nntraintool close

% neural net, and view it
temp.jFrame = view(sensor.neuralNet{sensor.num});
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

plotperform(sensor.trainRecord{sensor.num});
saveas(gcf,[dirName.net '/netPerform.png']);
close
clear h jpanel
temp = rmfield(temp, {'jFrame', 'hFig'});

% use net to do classification
sensor.label.neuralNet{sensor.num} = vec2ind(sensor.neuralNet{sensor.num}(sensor.image{sensor.num}));

% sensor.count.good{sensor.num} = find(sensor.label.neuralNet{sensor.num}(:,:) == 1);
% sensor.count.bad{sensor.num} = find(sensor.label.neuralNet{sensor.num}(:,:) == 2);

for l = 1:6
    sensor.count{l}{sensor.num} = find(sensor.label.neuralNet{sensor.num}(:,:) == l);
end

% images of classification results
figure
for n = 1 : temp.size.col
    ticRemain = tic;
    set(gcf,'Units','pixels','Position',[100 100 100 100]);  % control figure's position
    set(gca,'Units','normalized', 'Position',[0 0 1 1]);  % control axis's position in figure
    set(gca,'visible','off');
    temp.image = reshape(sensor.image{sensor.num}(:,n),[temp.size.image temp.size.image]);
    imshow(temp.image)
    fprintf('\nGenerating sensor-%02d images...  Total: %d  Now: %d', ...
        sensor.num ,temp.size.col, n)
    fprintf('  %s', labelName{sensor.label.neuralNet{sensor.num}(n)})
    saveas(gcf,[dirName.label{sensor.label.neuralNet{sensor.num}(n)}.net ...
        sprintf('/%s_', labelName{sensor.label.neuralNet{sensor.num}(n)}) num2str(n) '.png']);
    tocRemain = toc(ticRemain);
    tRemain = tocRemain * (temp.size.col - n);
    [hours, mins, secs] = sec2hms(tRemain);
    fprintf('  About %02dh%02dm%05.2fs left.\n', hours, mins, secs)
end
close

% plot panorama
panorama(sensor.date.serial{sensor.num}, sensor.label.neuralNet{sensor.num});
fprintf('\nSenor-%02d data classification panorama is saved in:\n%s\n', ...
    sensor.num, GetFullPath(dirName.home))
% fprintf('\nPress anykey to continue.\n')
% pause
saveas(gcf,[dirName.home '/' dirName.home '_panorama_beforeClean.png']);
close

% update sensor.status
sensor.status{sensor.num}(2,3) = {1};

elapsedTime(3) = toc(t(3)); [hours, mins, secs] = sec2hms(elapsedTime(3));
fprintf('\n\n\nSTEP3:\nClassification completes, using %02d:%02d:%05.2f .\n', ...
    hours, mins, secs)

head = 'Continue to step4, automatically remove outliers?';
tail = 'Continue to automatically remove outliers...';
go = request(head, tail, GetFullPath(dirName.home), dirName.file, 'y');
if strcmp(go,'n') || strcmp(go,'no'), return; end

end

%% 4 clean outliers
if step == 1 || step == 2 || step == 3 || step == 4
t(4) = tic;
if step == 4
    newP{1} = sensor.trainRatio{sensor.num};
    newP{2} = sensor.pSize;
    newP{3} = step;
    load([dirName.home '/' dirName.file]);
    sensor.trainRatio{sensor.num} = newP{1};
    sensor.pSize =  newP{2};
    step = newP{3};
    clear newP
end
dirName.outlierCleaned = [dirName.home '/outlierCleaned'];
if ~exist(dirName.outlierCleaned,'dir'), mkdir(dirName.outlierCleaned); end

figure
n = 1;
out.dotCount = 0;
out.pieceCount = 0;
while n <= temp.size.col       
    if sensor.label.neuralNet{sensor.num}(n) == 3  % 3-outlier
        ticRemain = tic;
        % hour location
        out.dotCount = out.dotCount + 1;
        [out.date, out.hour] = colLocation(n, date.start);
        fprintf('\n\n\nSensor-%02d:\nCount maximum as outlier.\n\n', sensor.num)
        fprintf('Data:\nDate:  %s  %02d:00-%02d:00  hour%d (from %s 00:00)\n\n', ...
            out.date, out.hour, out.hour+1, n, date.start)

        % outlier location
        [out.value, out.index] = max(abs(sensor.data{sensor.num}(:,n)));
        fprintf('Outlier:\nPosition: %d-%d\nValue: %d\nCount: %d (packet size: %d)\n\n', ...
            out.index, out.index+sensor.pSize-1, out.value, out.dotCount*sensor.pSize, sensor.pSize)

        % remove outlier
        sensor.data{sensor.num}(out.index:out.index+sensor.pSize-1, n) = 0;  % update sensor.data
        fprintf('Outliers are replaced by 0.\n')
        fprintf('Continue deleting outliers...\n\n')

        plot(sensor.data{sensor.num}(:,n),'color','k');
        set(gcf,'Units','pixels','Position',[100 100 100 100]);  % control figure's position
        set(gca,'Units','normalized', 'Position',[0 0 1 1]);  % control axis's position in figure
        set(gca,'visible','off');
        xlim([0 size(sensor.data{sensor.num},1)]);

        % save fixed data plot
        saveas(gcf,[dirName.outlierCleaned '/outlierCleaned_' num2str(n) '.png']);
        temp.image = imread([dirName.outlierCleaned '/outlierCleaned_' num2str(n) '.png']);
        temp.image = rgb2gray(temp.image);
        temp.image = im2double(temp.image(:));
        sensor.image{sensor.num}(:,n) = temp.image;  % update sensor.image
        temp.classify = vec2ind(sensor.neuralNet{sensor.num}(sensor.image{sensor.num}(:,n)));
        sensor.label.neuralNet{sensor.num}(n) = temp.classify;  % update sensor.label.neuralNet
%         nPrevious = n;
        if temp.classify == 1
            out.pieceCount = out.pieceCount + 1;
            sensor.label.neuralNet{sensor.num}(n) = temp.classify;
            fprintf('\n\nOutliers cleaned!\n%d outliers are in the data piece.\n%d data pieces remain to clean.\n', ...
                out.dotCount*sensor.pSize, length(sensor.count{3}{sensor.num})-out.pieceCount)
            tocRemain = toc(ticRemain);
            tRemain = tocRemain * out.dotCount * (length(sensor.count{3}{sensor.num})-out.pieceCount);
            [hours, mins, secs] = sec2hms(tRemain);
            fprintf('%02dh%02dm%05.2fs estimated time left.\n', hours, mins, secs)
%             fprintf('Press anykey to continue.\n')
%             pause
            out.dotCount = 0;
            n = n + 1;
%         elseif temp.classify == 2
%             fprintf('Continue deleting outlier...\n\n')
        end
%         if n ~= nPrevious
%             out.dotCount = 0;
%         end
    else
        n = n + 1;
    end

    if n == temp.size.col+1
        elapsedTime(4) = toc(t(4));
        [hours, mins, secs] = sec2hms(elapsedTime(4));
        fprintf('\n\n\n\n\n\nSTEP4:\nSensor-%02d outlier cleaning done, using %02d:%02d:%05.2f .\n', ...
            sensor.num, hours, mins, secs)
        fprintf('%d data pieces cleaned.\n', length(sensor.count{3}{sensor.num}))
    end
end
close

% update sensor.status
sensor.status{sensor.num}(2,4) = {1};
fprintf('\nSaving results...\nLocation: %s\n', GetFullPath(dirName.home))
if exist([dirName.home '/' dirName.file], 'file'), delete([dirName.home '/' dirName.file]); end
save([dirName.home '/' dirName.file])
fprintf('\nFinish!\n')
close all
end

end
