% clear;clc;close all

% a = 1:10;

% figure
set(gcf, 'visible', 'off');

plot(a)

img = getframe(gcf);
img = imresize(img.cdata, [200 200]);
img = rgb2gray(img);
img = im2double(img);

imshow(img)
set(gcf, 'visible', 'on');

saveas(gcf, 'test.png');

close
