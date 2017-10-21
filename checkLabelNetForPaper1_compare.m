clear; clc; close all;

% % win
load('E:\results\adi\2012-01-01--2012-12-31_sensor_1-38_fusion_seed_5_trainRatio_3pct\sensorLabelNetSerial.mat')
labelNet = reshape(sensorLabelNetSerial, [8784 38])';

%%
labelTotal = 7;
for n = 1 : labelTotal
    labelNetCheck{n} = [];
end
        
% count labels by type
for s = 1 : 38
    for n = 1 : labelTotal
        labelByType = find(labelNet(s, :) == n)';
        labelNetCheck{n} = cat(1, labelNetCheck{n}, labelByType);
        labelByType = [];
    end
end
clear labelByType

%%
path.root = 'C:\dataArchiveTemp\Sutong\'; % raw data path
load('C:\Users\Owner\Documents\GitHub\adi\trainingSet_justLabel_inSensorCell_drift_modified3.mat')

% mac
% path.root = '/Users/zhiyitang/Programming/data/Sutong/'; % raw data path
% load('/Users/zhiyitang/Programming/data/trainingSet_justLabel_inSensorCell.mat');

%%
labelTotal = size(sensor.label.name, 2);

for s = 13 : 24
    count = 1;
    idx = find((sensor.label.manual{s} == 6) & (labelNet(s, :) == 7));
%     idx = find(sensor.label.manual{s} == 7);
%     idx = find(labelNet(s, :) == 7);
    while count <= length(idx)
        [date, hour] = colLocation(idx(count), '2012-01-01');
        dateVec = datevec(date, 'yyyy-mm-dd');
        path.folder = sprintf('%04d-%02d-%02d',dateVec(1,1),dateVec(1,2), dateVec(1,3));
        path.file = [path.folder sprintf(' %02d-VIB.mat',hour)];
        path.full = [path.root '/' path.folder '/' path.file];
        if ~exist(path.full, 'file')
            fprintf('\nCAUTION:\n%s\nNo such file! Filled with a zero.\n', path.full)
            sensorData(1, 1) = zeros;  % always save in column 1
        else
            read = ['load(''' path.full ''');']; eval(read);
            sensorData(:, 1) = data(:, s);  % always save in column 1
        end
        plot(sensorData(:, 1),'color','k');
        position = get(gcf,'Position');
        set(gcf,'Units','pixels','Position',[position(1), position(2), 100, 100]);  % control figure's position
        set(gca,'Units','normalized', 'Position',[0 0 1 1]);  % control axis's position in figure
        set(gca,'visible','off');
        xlim([0 size(sensorData,1)]);
        set(gcf,'color','white');
        
        % modify label
        fprintf('\nChannel %d, absIdx %d', s, idx(count))
        fprintf('\nAll: %d, Now: %d', length(idx), count)
        fprintf('\nCurrent label: %d\n', sensor.label.manual{s}(idx(count)))
        fprintf('\nData type:')
        for l = 1 : labelTotal
            fprintf('\n%s', sensor.label.name{l})
        end
        fprintf('\n\n9-next without change\n0-previous\n909-save current progress\n')
        
        prompt = '\nInput: ';
        classify = input(prompt,'s');
        classify = str2double(classify);  % filter charactor input
        if classify <= labelTotal && classify >= 1
            sensor.label.manual{s}(idx(count)) = classify;
            count = count + 1;
        elseif classify == 9
            count = count + 3;
        elseif classify == 0
            if count > 1
                fprintf('\nRedo previous one.\n')
                count = count - 1;
            else fprintf('\nThis is already the first!\n')
            end
        elseif classify == 909
            fprintf('\nSaving current progress...\n')
            saveNameTemp = sprintf('trainingSet_justLabel_inSensorCell_toChannel%d-absIdx%d.mat', s, idx(count)-1);
            save(saveNameTemp, 'sensor', '-v7.3')
        else
            fprintf('\n\n\n\n\n\nInvalid input! Input 1-7 for labelling, 0 for redoing previous one,\n')
            fprintf('9 for jumping to the next without change, 909 for saving current progress.\n')
        end
        fprintf('-----------------------------------\n')
        
    end    
    idx = [];
    
    
    
%     count = 1;
%     while count <= 8784
%         if sensor.label.manual{s}(count) == 3
%             [date, hour] = colLocation(count, '2012-01-01');
%             dateVec = datevec(date, 'yyyy-mm-dd');
%             path.folder = sprintf('%04d-%02d-%02d',dateVec(1,1),dateVec(1,2), dateVec(1,3));
%             path.file = [path.folder sprintf(' %02d-VIB.mat',hour)];
%             path.full = [path.root '/' path.folder '/' path.file];
%             if ~exist(path.full, 'file')
%                 fprintf('\nCAUTION:\n%s\nNo such file! Filled with a zero.\n', path.full)
%                 sensorData(1, 1) = zeros;  % always save in column 1
%             else
%                 read = ['load(''' path.full ''');']; eval(read);
%                 sensorData(:, 1) = data(:, s);  % always save in column 1
%             end
%             plot(sensorData(:, 1),'color','k');
%             position = get(gcf,'Position');
%             set(gcf,'Units','pixels','Position',[position(1), position(2), 100, 100]);  % control figure's position
%             set(gca,'Units','normalized', 'Position',[0 0 1 1]);  % control axis's position in figure
%             set(gca,'visible','off');
%             xlim([0 size(sensorData,1)]);
%             set(gcf,'color','white');
% 
% %             img = getframe(gcf);
% %             img = imresize(img.cdata, [100 100]);  % expected dimension
% %             img = rgb2gray(img);
% %             img = im2double(img);
% %             imshow(img)
% 
%             % modify label
%             fprintf('\nNow: channel %d, absIdx %d', s, count)
%             fprintf('\nCurrent label: %d\n', sensor.label.manual{s}(count))
%             fprintf('\nData type:')
%             for l = 1 : labelTotal
%                 fprintf('\n%s', sensor.label.name{l})
%             end
%             fprintf('\n\n9-next\n0-previous\n909-save current progress\n')
%             
%             prompt = '\nInput: ';
%             classify = input(prompt,'s');
%             classify = str2double(classify);  % filter charactor input
%             if classify <= labelTotal && classify >= 1
%                 sensor.label.manual{s}(count) = classify;
%                 count = count + 1;
%             elseif classify == 9
%                 count = count + 1;
%             elseif classify == 0
%                 if count > 1
%                     fprintf('\nRedo previous one.\n')
%                     count = count - 1;
%                     sensor.label.manual{s}(count) = 3; % let the previous into loop
%                 else fprintf('\nThis is already the first!\n')
%                 end
%             elseif classify == 909
%                 fprintf('\nSave current progress...\n')
%                 saveNameTemp = sprintf('trainingSet_justLabel_inSensorCell_toChannel%d-absIdx%d.mat', s, count-1);
%                 save(saveNameTemp, 'sensor', '-v7.3')
%             else
%                 fprintf('\n\n\n\n\n\nInvalid input! Input 1-7 for labelling, 0 for redoing previous one,\n')
%                 fprintf('9 for jumping to the next, 909 for saving current progress.\n')
%             end
%             fprintf('-----------------------------------\n')
%         else
%             count = count + 1;
%         end
%     end
    
end