clear; clc; close all;

%%
fprintf('\nLoading detection results...\n')
% load('E:\results\adi\2012-01-01--2012-12-31_sensor_1-38_fusion - Copy\2012-01-01--2012-12-31_sensor_1-38_fusion.mat')
load('E:\results\adi\2012-01-01--2012-12-31_sensor_1-38_fusion_seed_5_trainRatio_3pct\sensorLabelNetSerial.mat')
% labelNet = sensorLabelNetSerial;
labelNet = sensorLabelNetSerial';
labelNet = ind2vec(labelNet);

clearvars -except labelNet

%%
fprintf('\nLoading actual labels of 2012...\n')
load('C:\Users\Owner\Documents\GitHub\adi\trainingSet_justLabel_inSensorCell_trend2drift_normal2outlier_minor2outlier_square2minor_modified.mat')

labelMan = [];
for mTemp = 1 : 38
    labelMan = cat(1, labelMan, sensor.label.manual{mTemp}');
end

labelMan = ind2vec(labelMan');

%%
% load('/Users/zhiyitang/Programming/results/2012-01-01--2012-12-31_sensor_1-38_fusion/trainingSetMat/trainingSet_justLabel.mat')

%%
figure
plotconfusion(labelNet, labelMan)
xlabel('Predicted');
ylabel('Actual');
title([]);
set(gca,'fontname', 'Times New Roman', 'fontweight', 'bold', 'fontsize', 12);
% minimize white space
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2) + 0.03;
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4) - 0.03;
ax.Position = [left bottom ax_width ax_height];
saveas(gcf, [sprintf('comfusionMatrix_2012_') datestr(now,'yyyy-mm-dd_HH-MM-SS') sprintf('.png')]);
% close
