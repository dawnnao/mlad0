function [sensorData, dateVec, dateSerial] = readIn(pathRoot, sensorNum, dayStart, dayEnd)
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

path.root = pathRoot;
count = 1;
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
            sensorData(1, count) = zeros;
        else
            read = ['load(''' path.full ''');'];
            eval(read);
            sensorData(:, count) = data(:, sensorNum);
            fprintf('\nReading sensor-%02d data...  %d-%02d-%02d  %02d:00-%02d:00  Done!  ', ...
                sensorNum, dateVec(count,1), dateVec(count,2), dateVec(count,3), hour,hour+1)
        end
        tocRemain = toc(ticRemain);
        tRemain = tocRemain * ((dayEnd-dayStart+1)*24 - count);
        [hours, mins, secs] = sec2hms(tRemain);
        fprintf('About %02dh%02dm%05.2fs left.\n', hours, mins, secs)
        count = count+1;
        data = [];
    end
end
count = count-1;
% if ~exist('sensorData', 'var'),  sensorData = []; end
clear data

end
