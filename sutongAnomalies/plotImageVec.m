% clear;clc;close all;

name = {'1-normal' '2-outlier' '3-minor' ...
        '4-missing' '5-trend' '6-drift'...
        '7-bias' '8-cutoff' '9-square'};
% figure
for n = 1:9
    img = imread([name{n} '.png']);
    
    img = imresize(img, [10 10]);
    
%     imshow(img)
    
%     img = rgb2gray(img);
    img = im2double(img(:));

    imageInfo = imfinfo([name{n} '.png']);
    width = imageInfo.Width;
    height = imageInfo.Height;
%     img = img(1:(height*3));
    
    
    
    

    x = 1 : length(img);
    subplot(9,1,n)
    plot(x, img, 'linewidth', 1.5)
    ylim([0 1]);
    title(name{n})
    box off
    set(gca, 'fontsize', 16);
    
end