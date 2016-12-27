clear;clc;close all


I = imread('zzz.png');

% I2 = imcrop(I);

I2 = imcrop(I,[880.5 55.5 210 284]);

figure
imshow(I2)
saveas(gcf, 'zz.png');
close
