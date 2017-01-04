clear;clc;close all;

a = imread('a.png');
b = imread('b.png');
c = imread('c.png');

%%
height = size(b,1);
width = size(b,2);

%%
bNew = b(1:ceil(height*0.22), :, :);

cNew = c(1:ceil(height*0.22), :, :);

% imshow(bNew);

%%
d = cat(1,cNew, bNew, a);
% imshow(d);

saveas(d,'test.png');



