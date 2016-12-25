clear;clc;close all

%%
a = 1:10;

figure
plot(a)

%%
p = get(gcf,'position');

%%
set(gcf,'Units','pixels','Position',p);