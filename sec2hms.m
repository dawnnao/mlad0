function [hours, mins, secs] = sec2hms(t)
% DESCRIPTION:
%   This is a subfunction of mvad.m, to convert seconds into hour:min:sec format

% AUTHOR:
%   Zhiyi Tang
%   tangzhi1@hit.edu.cn
%   Center of Structural Monitoring and Control
% 
% DATE CREATED:
%   12/10/2016

hours = floor(t / 3600);
t = t - hours * 3600;
mins = floor(t / 60);
secs = t - mins * 60;
end