function sensor = adidnn(readRoot, saveRoot, sensorNum, dateStart, dateEnd, sensorTrainRatio, sensorPSize, step, labelName)
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
color= {[132 198 134]/255;    % 1-normal     green
%         [129 199 132]/255;    % 1-normal     green
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

% pass parameters to variables inside
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
if groupTotal == sensorTotal
    netLayout = '_parallel';
elseif groupTotal == 1
    netLayout = '_fusion';
elseif groupTotal > 1 && groupTotal < sensorTotal
    netLayout = '_customGroups';
end

dirName.home = sprintf('%s/%s--%s_sensor%s%s', saveRoot, date.start, date.end, sensorStr, netLayout);
dirName.file = sprintf('%s--%s_sensor%s%s.mat', date.start, date.end, sensorStr, netLayout);
dirName.status = sprintf('%s--%s_sensor%s%s_status.mat', date.start, date.end, sensorStr, netLayout);

if ~exist(dirName.home,'dir'), mkdir(dirName.home); end
for g = 1 : groupTotal
    for s = sensor.num{g}
        dirName.sensor{s} = [dirName.home sprintf('/sensor%02d', s)];
        if ~exist(dirName.sensor{s},'dir'), mkdir(dirName.sensor{s}); end
    end
end

%% 1 glance at data
if ismember(1, step) || isempty(step)
for g = 1 : groupTotal
    for s = sensor.num{g}
        t(1) = tic;

        dirName.formatIn = 'yyyy-mm-dd';
        date.serial.start = datenum(date.start, dirName.formatIn);  % day numbers from year 0000
        date.serial.end   = datenum(date.end, dirName.formatIn);

        % plot from mat file
        dirName.all{s} = [dirName.sensor{s} '/0-all'];
        if ~exist(dirName.all{s},'dir'), mkdir(dirName.all{s});
        else
            if ~isempty(ls(dirName.all{s}))
                fprintf('\n%s\n\nFolder is already there and not empty, continue?\n', dirName.all{s})
                rightInput = 0;
                while rightInput == 0
                    prompt = 'y(yes)/n(no): ';
                    go = input(prompt,'s');
                    if strcmp(go,'y') || strcmp(go,'yes')
                        rightInput = 1;
                        fprintf('\nContinue...\n')
                    elseif strcmp(go,'n') || strcmp(go,'no')
                        rightInput = 1;
                        fprintf('\nFinish.\n')
                        return
                    else
                        fprintf('Invalid input! Please re-input.\n')
                    end
                end
            end
        end

        [~, sensor.date.vec{s}, sensor.date.serial{s}] = ...
            glance(readRoot, s, date.serial.start, date.serial.end, dirName.all{s}, '0-all_');
    %     util.hours = size(sensor.date.vec{s}, 1);

        elapsedTime(1) = toc(t(1)); [hours, mins, secs] = sec2hms(elapsedTime(1));
        fprintf('\nSTEP1:\nSensor-%02d data plot completes, using %02d:%02d:%05.2f .\n', ...
            s, hours, mins, secs)
    end
end

% update work flow status
sensor.status{s} = {'1-Glance' '2-Label' '3-Train' '4-Detect' '5-Inspect' ...
                     ; 0 0 0 0 0};
sensor.status{s}(2,1) = {1};
status = sensor.status{s};
savePath = [GetFullPath(dirName.home) '/' dirName.status];
if exist(savePath, 'file'), delete(savePath); end
save(savePath, '-v7.3')

% ask go on or stop
head = 'Continue to step2, label some data for building neural networks?';
tail = 'Continue to manually make training set...';
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
elseif step == 1, fprintf('\nFinish.\n'), return
elseif ismember(2, step), fprintf('\n%s\n\n\n', tail)
end
pause(0.5)
clear head tail

end

%% 2 manually make training set
if ismember(2, step) || isempty(step)
dirName.mat = [GetFullPath(dirName.home) '/trainingSetMat'];
if exist(dirName.mat,'dir')
    check = ls(dirName.mat);
    if ispc, check(1:4) = []; end
    if ~isempty(check)
        fprintf('\nCAUTION:\n%s\nTraining set folder is already there and not empty, continue?\n', dirName.mat)
        rightInput = 0;
        while rightInput == 0
            prompt = 'y(yes)/n(no): ';
            go = input(prompt,'s');
            if strcmp(go,'y') || strcmp(go,'yes')
                rightInput = 1;
                fprintf('\nContinue...\n')
            elseif strcmp(go,'n') || strcmp(go,'no')
                rightInput = 1;
                fprintf('\nFinish.\n')
                return
            else
                fprintf('Invalid input! Please re-input.\n')
            end
        end
    end
elseif ~exist(dirName.mat,'dir'), mkdir(dirName.mat);
end

dirName.formatIn = 'yyyy-mm-dd';
date.serial.start = datenum(date.start, dirName.formatIn);  % day numbers from year 0000
date.serial.end   = datenum(date.end, dirName.formatIn);
hourTotal = (date.serial.end-date.serial.start+1)*24;

seed = 2;  %intialize
goNext = 0;
while goNext == 0
    % randomization
    rng(seed,'twister');
    sensor.random = randperm(hourTotal);
    
    for g = 1 : groupTotal
    for s = sensor.num{g}
    
%     for s = sensor.num
        t(2) = tic;
        sensor.label.manual{s} = zeros(labelTotal,hourTotal);
        % manually label
        sensor.trainSetSize(s) = ceil(sensor.trainRatio(s) * hourTotal);
        figure
        set(gcf,'Units','pixels','Position',[100, 100, 300, 300]);
        n = 1;
        while n <= sensor.trainSetSize(s)
            sensor.label.manual{s}(:,sensor.random(n)) = zeros(labelTotal,1);  % initialize for re-label if necessary
            
            [random.date, random.hour] = colLocation(sensor.random(n), date.start);
            random.path = [readRoot '/' random.date '/' random.date sprintf(' %02d-VIB.mat',random.hour)];
            
            if ~exist(random.path, 'file')
                fprintf('\nCAUTION:\n%s\nNo such file! Filled with a zero.\n', random.path)
                sensor.data{s}(1, sensor.random(n)) = zeros;
            else
                read = ['load(''' random.path ''');']; eval(read);
                sensor.data{s}(:, sensor.random(n)) = data(:, s);
            end
            clear data
            plot(sensor.data{s}(:,sensor.random(n)),'color','k');
            position = get(gcf,'Position');
            set(gcf,'Units','pixels','Position',[position(1), position(2), 300, 300]);  % control figure's position
            set(gca,'Units','normalized', 'Position',[0.1300 0.1100 0.7750 0.8150]);  % control axis's position in figure
            xlim([0 size(sensor.data{s},1)]);
            fprintf('\nSensor-%02d trainning set size: %d  Now: %d\n', s, sensor.trainSetSize(s), n)
            fprintf('Data type:')
            for l = 1 : labelTotal
                fprintf('\n%s', sensor.label.name{l})
            end
            prompt = '\nInput: ';
            classify = input(prompt,'s');
            classify = str2double(classify);  % filter charactor input
            if classify <= labelTotal && classify >= 1
                sensor.label.manual{s}(classify,sensor.random(n)) = 1;
                n = n + 1;
            elseif classify == 0
                if n > 1
                    fprintf('\nRedo previous one.\n')
                    n = n - 1;
                else fprintf('\nThis is already the first!\n')
                end
            else
                fprintf('\n\n\n\n\n\nInvalid input! Input 1-9 for labelling, 0 for redoing previous one.\n')
            end
        end
        close
        
%         ticRemain = tic;
        c = 0; % total count initialize
        for l = 1 : labelTotal
            % find label and corresponding data
            count.label{l,s} = find(sensor.label.manual{s}(l,:));
            manual.label{l}.data{s} = sensor.data{s}(:,count.label{l,s});
            % generate all-type folders
            dirName.label.manual{l,s} = [dirName.sensor{s} '/' sensor.label.name{l} '/manual'];
            if ~exist(dirName.label.manual{l,s},'dir'), mkdir(dirName.label.manual{l,s}); end
            dirName.label.net{l,s} = [dirName.sensor{s} '/' sensor.label.name{l} '/neuralNet'];
            if ~exist(dirName.label.net{l,s},'dir'), mkdir(dirName.label.net{l,s}); end
            % generate image vectors
            manual.label{l}.image{s} = [];
            figure
            for n = 1:size(manual.label{l}.data{s},2)
                c = c + 1;
                fprintf('\nGenerating sensor-%02d images of %s data in training set...\nNow: %d  Total: %d  ',...
                    s, sensor.label.name{l}, n, size(manual.label{l}.data{s},2))
                plot(manual.label{l}.data{s}(:,n),'color','k');
                position = get(gcf,'Position');
                set(gcf,'Units','pixels','Position',[position(1) position(2) 100 100]);  % control figure's position
                set(gca,'Units','normalized', 'Position',[0 0 1 1]);  % control axis's position in figure
                set(gca,'visible','off');
                xlim([0 size(manual.label{l}.data{s},1)]);
                set(gcf,'color','white');

                img = getframe(gcf);
                img = imresize(img.cdata, [100 100]);  % expected dimension
                img = rgb2gray(img);
                img = im2double(img);
                % imshow(img)
                imwrite(img,[dirName.label.manual{l,s} sprintf('/%s_', sensor.label.name{l}) num2str(count.label{l,s}(n)) '.png']);
                manual.label{l}.image{s}(:,n) = img(:);
%                 tocRemain = toc(ticRemain);
%                 tRemain = tocRemain * (sensor.trainSetSize(s)*length(sensor.num) - c) / c;
%                 [hours, mins, secs] = sec2hms(tRemain);
%                 fprintf('About %02dh%02dm%05.2fs left.\n', hours, mins, secs)
            end
            close
            clear img
            % delete useless folder(s)
            check = ls(dirName.label.manual{l,s});
            if ispc, check(1:4) = []; end
            if isempty(check), rmdir([dirName.sensor{s} '/' sensor.label.name{l}], 's'); end
            
        end
        
        % pass to 'temp' suffix variables
        labelTemp = sensor.label.manual{s};
        for l = 1 : labelTotal
            manualTemp{l} = manual.label{l}.image{s};
            countTemp{l} = count.label{l,s};
        end
        % delete big and useless variables
        for l = 1 : labelTotal
            manual.label{l} = rmfield(manual.label{l}, 'data');
        end
        sensor = rmfield(sensor, 'data');
        % save single sensor data
        dirName.matPart{s} = [dirName.mat sprintf('/sensor%02d.mat', s)];
        if exist(dirName.matPart{s}, 'file'), delete(dirName.matPart{s}); end
        fprintf('\nSaving sensor-%02d training set...\nLocation: %s\n', s, dirName.matPart{s})
        save(dirName.matPart{s}, 'labelTemp', 'manualTemp', 'countTemp', '-v7.3')
        
        elapsedTime(2) = toc(t(2));
        [hours, mins, secs] = sec2hms(elapsedTime(2));
        fprintf('\nSensor-%02d training set making time consumption: %02dh%02dm%05.2fs\n\n\n\n', s, hours, mins, secs)
    end
    end
    
    sensor = rmfield(sensor, 'random');
    goNext = 1;
    
%     fprintf('\nGo on, or re-random sampling and re-label data for any missing types?\n')
%     rightInput = 0;
%     while rightInput == 0
%         prompt = 'g(go)/r(redo): ';
%         go = input(prompt,'s');
%         if strcmp(go,'r') || strcmp(go,'redo')
%             rightInput = 1;
%             seed = seed + 1;
%         elseif strcmp(go,'g') || strcmp(go,'go')
%             rightInput = 1;
%             goNext = 1;
%         else
%             fprintf('Invalid input! Please re-input.\n')
%         end
%     end
    
end

% update work flow status
status(2,2) = {1};
savePath = [GetFullPath(dirName.home) '/' dirName.status];
if exist(savePath, 'file'), delete(savePath); end
save(savePath, '-v7.3')

elapsedTime(2) = toc(t(2)); [hours, mins, secs] = sec2hms(elapsedTime(2));
fprintf('\n\n\nSTEP2:\nSensor(s) training set making completes, using %02d:%02d:%05.2f .\n', ...
    hours, mins, secs)

% ask go on or stop
head = 'Continue to step3, automatically train deep neural network(s) now?';
tail = 'Continue to automatically train deep neural network(s)...';

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
elseif step == 2, fprintf('\nFinish.\n'), return
elseif ismember(3, step), fprintf('\n%s\n\n\n', tail)
end
pause(0.5)
clear head tail savePath

end

%% 3 train network(s)
if ismember(3, step) || isempty(step)
% update new parameters and load training sets
if ~isempty(step) && step(1) == 3
    for s = sensor.numVec
        newP{1,s} = sensor.trainRatio(s);
    end
    newP{2,1} = sensor.pSize;
    newP{3,1} = step;
    dirName.mat = [GetFullPath(dirName.home) '/trainingSetMat'];
    
    for g = 1 : groupTotal
        for s = sensor.num{g}
            dirName.matPart{s} = [dirName.mat sprintf('/sensor%02d.mat', s)];
            if ~exist(dirName.matPart{s}, 'file')
                fprintf('\nCAUTION:\nSensor-%02d traning set not found! Ignored it.\n', s)
                index = find(sensor.num{g} == s);
                sensor.num{g}(index) = [];
            else
                load(dirName.matPart{s});
                sensor.label.manual{s} = labelTemp;
                for l = 1 : labelTotal
                    manual.label{l}.image{s} = manualTemp{l};
                    count.label{l,s} = countTemp{l};
                end
                clear labelTemp manualTemp countTemp
            end
        end
    end
    % update
    sensor.numVec = [];
    for g = 1 : groupTotal, sensor.numVec = [sensor.numVec sensor.num{g}(:)']; end
    if isempty(sensor.numVec)
        fprintf('\nCAUTION:\nNo training set found in\n%s\n', dirName.mat)
        fprintf('Need to make trainning set (step2) first.\nFinish.\n')
        return
    end
    
    for s = sensor.numVec
        sensor.trainRatio(s) = newP{1,s};
    end
    sensor.pSize =  newP{2,1};
    step = newP{3,1};
    clear newP
end

t(3) = tic;
dirName.formatIn = 'yyyy-mm-dd';
date.serial.start = datenum(date.start, dirName.formatIn);  % day numbers from year 0000
date.serial.end   = datenum(date.end, dirName.formatIn);
% hourTotal = (date.serial.end-date.serial.start+1)*24;

dirName.net = [dirName.home '/net'];
if ~exist(dirName.net,'dir'), mkdir(dirName.net); end

fprintf('\nData combining...\n')
for g = 1 : groupTotal
    feature{g}.image = [];
    feature{g}.label.manual = [];
    for s = sensor.num{g}
        for l = 1 : labelTotal
            feature{g}.image = [feature{g}.image manual.label{l}.image{s}];  % modify here!
            feature{g}.label.manual = [feature{g}.label.manual sensor.label.manual{s}(:,count.label{l,s})];  % modify here!
        end
    end
end

seed = 1;
rng(seed,'twister');
fprintf('\nTraining...\n')
for g = 1 : groupTotal
    ticRemain = tic;
    randp{g} = randperm(size(feature{g}.image,2));  % randomization
    feature{g}.image = feature{g}.image(:, randp{g});
    feature{g}.label.manual = feature{g}.label.manual(:, randp{g});
    for s = sensor.num{g}(1)
        % train deep neural network
        feature{g}.trainRatio = 50/100;
        feature{g}.trainSize = floor(size(feature{g}.image,2) * feature{g}.trainRatio);
        % hidden layer 1
        hiddenSize(1) = 200;
        autoenc{1} = trainAutoencoder(feature{g}.image(:,1 : feature{g}.trainSize),...
            hiddenSize(1), ...
            'MaxEpochs',50, ...
            'L2WeightRegularization',0.004, ...
            'SparsityRegularization',4, ...
            'SparsityProportion',0.15, ...
            'ScaleData', false);
        feat{1} = encode(autoenc{1},feature{g}.image(:,1 : feature{g}.trainSize));
        % hidden layer 2
        hiddenSize(2) = 100;
        autoenc{2} = trainAutoencoder(feat{1},hiddenSize(2), ...
            'MaxEpochs',50, ...
            'L2WeightRegularization',0.002, ...
            'SparsityRegularization',4, ...
            'SparsityProportion',0.1, ...
            'ScaleData', false);
        feat{2} = encode(autoenc{2},feat{1});
        % hidden layer 3
        hiddenSize(3) = 50;
        autoenc{3} = trainAutoencoder(feat{2},hiddenSize(3), ...
            'MaxEpochs',100, ...
            'L2WeightRegularization',0.002, ...
            'SparsityRegularization',4, ...
            'SparsityProportion',0.1, ...
            'ScaleData', false);
        feat{3} = encode(autoenc{3},feat{2});
        % softmax classifier
        softnet = trainSoftmaxLayer(feat{3}, feature{g}.label.manual(:,1 : feature{g}.trainSize),...
            'MaxEpochs',400);
        % stack
        sensor.neuralNet{s} = stack(autoenc{1},autoenc{2},autoenc{3},softnet);
%         view(sensor.neuralNet{s})
%         plotWeights(autoenc{1});
%         plotWeights(autoenc{2});
%         plotWeights(autoenc{3});
%         set(findobj(0,'type','figure'),'visible','on');
%         set(gcf,'color','white');

        % fine tuning
%         sensor.neuralNet{s}.divideParam.trainRatio = 70/100;
%         sensor.neuralNet{s}.divideParam.valRatio = 15/100;
%         sensor.neuralNet{s}.divideParam.testRatio = 15/100;
        [sensor.neuralNet{s},sensor.trainRecord{s}] = train(sensor.neuralNet{s}, ...
            feature{g}.image(:,1 : feature{g}.trainSize), feature{g}.label.manual(:,1 : feature{g}.trainSize));
        nntraintool close
        y = sensor.neuralNet{s}(feature{g}.image(:,feature{g}.trainSize+1 : end));
        
        temp.jFrame = view(sensor.neuralNet{s});
        % create it in a MATLAB figure
        temp.hFig = figure('Menubar','none', 'Position',[100 100 960 166]);
        jpanel = get(temp.jFrame,'ContentPane');
        [~,h] = javacomponent(jpanel);
        set(h, 'units','normalized', 'position',[0 0 1 1]);
        % close java window
        temp.jFrame.setVisible(false);
        temp.jFrame.dispose();
        % print to file
        set(temp.hFig, 'PaperPositionMode', 'auto');
        saveas(temp.hFig, [dirName.net sprintf('/group-%d_netArchitecture.png', g)]);
        % close figure
        close(temp.hFig)
        
        figure
        plotperform(sensor.trainRecord{s});
        saveas(gcf,[dirName.net sprintf('/group-%d_netPerform.png', g)]);
        close
        
        figure
        plotconfusion(feature{g}.label.manual(:,feature{g}.trainSize+1 : end), y);
        saveas(gcf,[dirName.net sprintf('/group-%d_netConfuse.png', g)]);
        close
        clear h jpanel
        temp = rmfield(temp, {'jFrame', 'hFig'});
        
    end
    % copy to every sensor
    if length(sensor.num{g} > 1)
        for s = sensor.num{g}(2:end)
            sensor.neuralNet{s} = sensor.neuralNet{sensor.num{g}(1)};
            sensor.trainRecord{s} = sensor.trainRecord{sensor.num{g}(1)};
        end
    end
    
    fprintf('\nGroup-%d dnn training done. ', g)
    tocRemain = toc(ticRemain);
    tRemain = tocRemain * (groupTotal - g);
    [hours, mins, secs] = sec2hms(tRemain);
    fprintf('About %02dh%02dm%05.2fs left.\n', hours, mins, secs)
    
end

elapsedTime(3) = toc(t(3)); [hours, mins, secs] = sec2hms(elapsedTime(3));
fprintf('\n\n\nSTEP3:\nDeep neural network(s) training completes, using %02dh%02dm%05.2fs .\n', ...
    hours, mins, secs)

% update work flow status
status(2,3) = {1};
savePath = [GetFullPath(dirName.home) '/' dirName.status];
if exist(savePath, 'file'), delete(savePath); end
save(savePath, '-v7.3')

% ask go on or stop
head = 'Continue to step4 - anomaly detection?';
tail = 'Continue to anomaly detection...';
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

%% 4 anomaly detection
if ismember(4, step) || isempty(step)
% update new parameters and load training sets
if ~isempty(step) && step(1) == 4
    newP{2,1} = sensor.pSize;
    newP{3,1} = step;
    newP{4,1} = sensor.label.name;
    
    readPath = [GetFullPath(dirName.home) '/' dirName.file];
    load(readPath)
    
    sensor.pSize =  newP{2,1};
    step = newP{3,1};
    sensor.label.name = newP{4,1};
    clear newP
end

t(4) = tic;
dirName.formatIn = 'yyyy-mm-dd';
date.serial.start = datenum(date.start, dirName.formatIn);  % day numbers from year 0000
date.serial.end   = datenum(date.end, dirName.formatIn);
% hourTotal = (date.serial.end-date.serial.start+1)*24;

% anomaly detection
fprintf('\nDetecting...\n')
[labelTempNeural, countTempNeural, dateVec, dateSerial] = ...
    classifierMulti(readRoot, sensor.numVec, date.serial.start, date.serial.end, ...
    dirName.home, sensor.label.name, sensor.neuralNet);
for s = sensor.numVec
    sensor.label.neuralNet{s} = labelTempNeural{s};
    for l = 1 : labelTotal
        sensor.count{l,s} = countTempNeural{l,s};
    end
    sensor.date.vec{s} = dateVec;
    sensor.date.serial{s} = dateSerial;
end
clear labelTempNeural countTempNeural

elapsedTime(4) = toc(t(4)); [hours, mins, secs] = sec2hms(elapsedTime(4));
fprintf('\n\n\nSTEP4:\nAnomaly detection completes, using %02dh%02dm%05.2fs .\n', ...
    hours, mins, secs)

% update work flow status
status(2,4) = {1};
savePath = [GetFullPath(dirName.home) '/' dirName.status];
if exist(savePath, 'file'), delete(savePath); end
save(savePath, '-v7.3')

% ask go on or stop
head = 'Continue to step5, anomaly statistics?';
tail = 'Continue to do anomaly statistics...';
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
elseif step == 4, fprintf('\nFinish.\n'), return
elseif ismember(5, step), fprintf('\n%s\n\n\n', tail)
end
pause(0.5)
clear head tail savePath

end

%% 5 statistics
if ismember(5, step) || isempty(step)
% update new parameters and load training sets
if ~isempty(step) && step(1) == 5
    newP{2,1} = sensor.pSize;
    newP{3,1} = step;
    newP{4,1} = dirName.home;
    
    readPath = [GetFullPath(dirName.home) '/' dirName.file];
    fprintf('Loading...\n')
    load(readPath)
    
    sensor.pSize =  newP{2,1};
    step = newP{3,1};
    dirName.home = newP{4,1};
    clear newP
end
t(5) = tic;
dirName.formatIn = 'yyyy-mm-dd';
date.serial.start = datenum(date.start, dirName.formatIn);  % day numbers from year 0000
date.serial.end   = datenum(date.end, dirName.formatIn);
hourTotal = (date.serial.end-date.serial.start+1)*24;

% reportCover; % make report cover!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% plot panorama
dirName.plotPano = [dirName.home '/plot/panorama'];
if ~exist(dirName.plotPano, 'dir'), mkdir(dirName.plotPano); end
for s = sensor.numVec
    panorama(sensor.date.serial{s}, sensor.label.neuralNet{s}, sprintf('        %02d', s), color(1:labelTotal));
    dirName.panorama{s} = [sprintf('%s--%s_sensor_%02d', date.start, date.end, s) '_anomalyDetectionPanorama.png'];
    saveas(gcf,[dirName.plotPano '/' dirName.panorama{s}]);
    fprintf('\nSenor-%02d anomaly detection panorama file location:\n%s\n', ...
        s, GetFullPath([dirName.plotPano '/' dirName.panorama{s}]))
    close
    
    % update sensor.status
    sensor.status{s}(2,5) = {1};
end

n = 0;
panopano = [];
for s = sensor.numVec
    n = n + 1;
    p{s} = imread(GetFullPath([dirName.plotPano '/' dirName.panorama{s}]));
    if n > 1
        height = size(p{s},1);
        width = size(p{s},2);
        p{s} = p{s}(1:ceil(height*0.22), :, :);
    end
    panopano = cat(1, p{s}, panopano);
end
dirName.panopano = [sprintf('%s--%s_sensor_all%s', date.start, date.end, sensorStr) ...
                    '_anomalyDetectionPanorama.png'];
imwrite(panopano, [dirName.plotPano '/' dirName.panopano]);
% reportPano; % make report chapter - Panorama!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

clear height width p n

% plot monthly stats per sensor
dirName.plotSPS = [dirName.home '/plot/statsPerSensor'];
if ~exist(dirName.plotSPS, 'dir'), mkdir(dirName.plotSPS); end
for s = sensor.numVec
    for n = 1 : 12
        for l = 1 : labelTotal
            aim = find(sensor.date.vec{s}(:,2) == n);
            sensor.statsPerSensor{s}(n, l) = length(find(sensor.label.neuralNet{s}(aim) == l));
        end
    end
    monthStatsPerSensor(sensor.statsPerSensor{s}, s, sensor.label.name, color);
    dirName.statsPerSensor{s} = [sprintf('%s--%s_sensor_%02d', date.start, date.end, s) '_anomalyStats.png'];
    saveas(gcf,[dirName.plotSPS '/' dirName.statsPerSensor{s}]);
    fprintf('\nSenor-%02d anomaly stats bar-plot file location:\n%s\n', ...
        s, GetFullPath([dirName.plotSPS '/' dirName.statsPerSensor{s}]))

    close
end
% reportStatsSensor;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% plot anomaly space-time distribution per type
dirName.plotSPT = [dirName.home '/plot/statsPerType'];
if ~exist(dirName.plotSPT, 'dir'), mkdir(dirName.plotSPT); end
for l = 1 : labelTotal
   for s = sensor.numVec
       for n = 1 : 12
           aim = find(sensor.date.vec{s}(:,2) == n);
           sensor.statsPerLabel{l}(n, s) = length(find(sensor.label.neuralNet{s}(aim) == l));
       end
   end
   if sum(sum(sensor.statsPerLabel{l})) > 0
        monthStatsPerLabel(sensor.statsPerLabel{l}, l, sensor.label.name{l}, color);
        dirName.statsPerLabel{l} = sprintf('%s--%s_sensor%s_anomalyStats_%s.png', ...
            date.start, date.end, sensorStr, sensor.label.name{l});
        saveas(gcf,[dirName.plotSPT '/' dirName.statsPerLabel{l}]);
        fprintf('\n%s anomaly stats bar-plot file location:\n%s\n', ...
            sensor.label.name{l}, GetFullPath([dirName.plotSPT '/' dirName.statsPerLabel{l}]))
        close
    end
end
% reportStatsLabel;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% plot sensor-type bar stats
dirName.plotSum = [dirName.home '/plot/statsSumUp'];
if ~exist(dirName.plotSum, 'dir'), mkdir(dirName.plotSum); end
for s = sensor.numVec
   for l = 1 : labelTotal
       statsSum(s, l) = length(find(sensor.label.neuralNet{s} == l));
   end
end

if ~isempty(statsSum(1,1)) && size(statsSum, 1) == 1
    statsSum(2,1:labelTotal) = 0;
end

figure
h = bar(statsSum, 'stacked');
xlabel('Sensor');
ylabel('Count (hours)');
legend(sensor.label.name);
lh=findall(gcf,'tag','legend');
set(lh,'location','northeastoutside');
title(sprintf('%s--%s', date.start, date.end));
grid on
for n = 1 : labelTotal
    set(h(n),'FaceColor', color{n});
end
set(gca, 'fontsize', 12);

dirName.statsSum = sprintf('%s--%s_sensor%s_anomalyStats.png', ...
    date.start, date.end, sensorStr);
saveas(gcf,[dirName.plotSum '/' dirName.statsSum]);
fprintf('\nSum-up anomaly stats image file location:\n%s\n', ...
    GetFullPath([dirName.plotSum '/' dirName.statsSum]))
close
% reportStatsTotal;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% crop legend to panorama's folder
img = imread([dirName.plotSum '/' dirName.statsSum]);
if ispc
    imgLegend = imcrop(img, [646.5 42.5 172 300]);
elseif ismac
%     imgLegend = imcrop(img, [660.5 42.5 160 229]);
    imgLegend = imcrop(img, [882.5 57.5 204 280]);
end
figure, imshow(imgLegend)
saveas(gcf, [dirName.plotPano '/legend.png']); close

elapsedTime(5) = toc(t(5)); [hours, mins, secs] = sec2hms(elapsedTime(5));
fprintf('\n\n\nSTEP5:\nAnomaly statistics completes, using %02dh%02dm%05.2fs .\n', ...
    hours, mins, secs)

% update work flow status
status(2,5) = {1};
savePath = [GetFullPath(dirName.home) '/' dirName.status];
if exist(savePath, 'file'), delete(savePath); end
save(savePath, '-v7.3')

% ask go on or stop
head = 'Continue to step6, automatically remove outliers?';
tail = 'Continue to automatically remove outliers...';
savePath = [GetFullPath(dirName.home) '/' dirName.file];
fprintf('\nSaving results...\nLocation: %s\n', savePath)
if exist(savePath, 'file'), delete(savePath); end
% save(savePath, '-v7.3')
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
elseif step == 5, fprintf('\nFinish.\n'), return
elseif ismember(6, step), fprintf('\n%s\n\n\n', tail)
end
clear head tail savePath

end

%% 6 clean outliers
if ismember(6, step) || isempty(step)
% update new parameters
if step == 6
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
t(6) = tic;
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
        position = get(gcf,'Position');
        set(gcf,'Units','pixels','Position',[position(1) position(2) 100 100]);  % control figure's position
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
            out.dotCount = 0;
            n = n + 1;
%         elseif temp.classify == 2
%             fprintf('Continue deleting outlier...\n\n')
        end
    else
        n = n + 1;
    end

    if n == util.hours+1
        elapsedTime(6) = toc(t(6));
        [hours, mins, secs] = sec2hms(elapsedTime(6));
        fprintf('\n\n\n\n\n\nSTEP6:\nSensor-%02d outlier cleaning done, using %02d:%02d:%05.2f .\n', ...
            s, hours, mins, secs)
        fprintf('%d data pieces cleaned.\n', length(sensor.count{3,s}))
    end
end
close

% update sensor.status
sensor.status{s}(2,6) = {1};
fprintf('\nSaving results...\nLocation: %s\n', GetFullPath(dirName.home))
if exist([dirName.home '/' dirName.file], 'file'), delete([dirName.home '/' dirName.file]); end
save([dirName.home '/' dirName.file])
elapsedTime(6) = toc(t(6)); [hours, mins, secs] = sec2hms(elapsedTime(1));
fprintf('\nTime consumption: %02dh%02dm%05.2fs .\n', hours, mins, secs)
fprintf('\nFinish!\n')
close
end

end
