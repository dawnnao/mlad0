function [date, h] = colLocation(x,dateStart)
% DESCRIPTION:
%   This is a subfunction for mvad.m, to calculate xth hour's date. Hour
%   counting starts at a user-specified date.

% OUTPUTS:
%   date (char) - xth hour's date
%   h (double) - xth hour's time (ranges from 0(00:00) to 23(23:00))
% 
% INPUTS:
%   x (double) - xth hour
%   dateStart (char) - start date, hour counting starts at 00:00
%                      input format: 'yyyy-mm-dd'
% 
% EXAMPLE:
%   [date, h] = colLocation(25,'2016-01-01')
%   date = 2016-01-02
%   h = 0
 
% AUTHOR:
%   Zhiyi Tang
%   tangzhi1@hit.edu.cn
%   Center of Structural Monitoring and Control
% 
% DATE CREATED:
%   12/10/2016

dateStart = datenum(dateStart,'yyyy-mm-dd'); % start at 2016-01-01 00:00
x = x-1;
h = mod(x,24);
d = (x-h)/24 + 1;
date = dateStart + d - 1;
date = datestr(date,'yyyy-mm-dd');
% disp(['   The column is at:  ' date sprintf('  %02d:00-%02d:00', h, h+1)])
end