clear all;clc;close all;

import mlreportgen.dom.*;
report = Document('today');
append(report, ['Today is ', date, '.']);
close(report);
rptview(report.OutputPath);