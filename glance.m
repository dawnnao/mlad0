function [sensorData, dateVec, dateSerial] = glance(pathRead, sensorNum, dayStart, dayEnd, pathSave, prefix)
% DESCRIPTION:
%   This is a subfunction of pspp.m, to read user specified data, and
%   display progress in command window.

% OUTPUTS:
%   sensorData (double) - Each column is an hour's raw data
%   dateVec (double) - 
%   dateSerial (double) - 
% 
% INPUTS:
%   pathRoot () - 
% 

% AUTHOR:
%   Zhiyi Tang
%   tangzhi1@hit.edu.cn
%   Center of Structural Monitoring and Control
% 
% DATE CREATED:
%   2016/12/19  

path.root = pathRead;
hourTotal = (dayEnd-dayStart+1)*24;
count = 1;
figure
for day = dayStart : dayEnd
    string = datestr(day);
    for hour = 0:23
        ticRemain = tic;
        dateVec(count,:) = datevec(string,'dd-mmm-yyyy');
        dateVec(count,4) = hour;
        dateSerial(count,1) = datenum(dateVec(count,:));
        path.folder = sprintf('%04d-%02d-%02d',dateVec(count,1),dateVec(count,2), dateVec(count,3));
        path.file = [path.folder sprintf(' %02d-VIB.mat',hour)];
        path.full = [path.root '/' path.folder '/' path.file];
        if ~exist(path.full, 'file')
            fprintf('\nCAUTION:\n%s\nNo such file! Filled with a zero.\n', path.full)
            sensorData(1, 1) = zeros;  % always save in column 1
        else
            read = ['load(''' path.full ''');'];
            eval(read);
            sensorData(:, 1) = data(:, sensorNum);  % always save in column 1
        end
%         set(gcf, 'visible', 'off');
        plot(sensorData(:, 1),'color','k');
        set(gcf,'Units','pixels','Position',[100 100 100 100]);  % control figure's position
        set(gca,'Units','normalized', 'Position',[0 0 1 1]);  % control axis's position in figure
        set(gca,'visible','off');
        xlim([0 size(sensorData,1)]); % !!!!!!!!!!!!!!!! to check£¬ resize anyhow
        
        img = getframe(gcf);
        img = imresize(img.cdata, [100 100]);  % expected dimension
        img = rgb2gray(img);
        img = im2double(img);
        imshow(img)
%         set(gcf, 'visible', 'on');
        pathSaveAll = [pathSave '/' prefix num2str(count) '.png'];
        imwrite(img, pathSaveAll);
        
        tocRemain = toc(ticRemain);
        tRemain = tocRemain * (hourTotal - count);
        [hours, mins, secs] = sec2hms(tRemain);
        fprintf('\nGenerating sensor-%02d images...  %d-%02d-%02d  %02d:00-%02d:00  Done!', ...
            sensorNum, dateVec(count,1), dateVec(count,2), dateVec(count,3), hour, hour+1)
        fprintf('\nTotal: %d  Now: %d  ', hourTotal, count)
        fprintf('About %02dh%02dm%05.2fs left.\n', hours, mins, secs)
        count = count+1;
        data = [];
    end
end
count = count-1;
close all
clear data

end
