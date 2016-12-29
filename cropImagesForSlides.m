clear;clc;,close all

for n = 1 : 38
    name = sprintf('plot/statsPerSensor/2012-01-01--2012-12-31_sensor_%02d_anomalyStats.png', n);
    img{n} = imread(name);
    
    imgNew{n} = imcrop(img{n}, [40.5 64.5 1174 1088]);
    imshow(imgNew{n});
    
    dirName = 'plotCrop/statsPerSensor';
    if ~exist(dirName, 'dir'), mkdir(dirName); end
    nameNew = sprintf('plotCrop/statsPerSensor/2012-01-01--2012-12-31_sensor_%02d_anomalyStats.png', n);
    saveas(gcf, nameNew);
end

%%
% imcrop(img{1})