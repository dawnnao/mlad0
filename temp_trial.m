% a{1} = [1 2 3;4 5 6];
% a{2} = [1 1 1];
% 
% data.col1 = [1 2 3]
% 
% data.col2 = [1;2;3]
% 
% colNum = 1;
% data.colNum = [1 1 1]
% 
% data{3} = [1 2 3;4 5 6;7 8 9]
% 
% figure
% a = reshape(feature(:,2),[208 208]);
% imshow(a)
% set(gcf,'Units','pixels');
% set(gcf,'Position',[100 100 100 100]);  % control figure's position
% set(gca,'Units','normalized');
% set(gca,'Position',[0 0 1 1]);  % control axis's position in figure
% 
% aTest = NaN(1,100);
% figure
% plot(aTest)
% 
% aTest = NaN(3,3)
% 
% aTest(:,4:6) = NaN
% 
% a = [1 2 3 44 5];
% [ans ansIndex] = max(a)
% 
% for a = 1:10
%     a
% end
% 
% %%
% fprintf('  abc\n')
% 
% %%
% sprintf('  abc');
% %%
% disp(fprintf('  abc'));
% 
% %%
% disp('  abc')
% %%
% figure
% imageSize = 208;
% imageTemp = reshape(feature.image(:,2),[imageSize imageSize]);
% imshow(imageTemp)
% 
% %%
% figure
% imageSize = 208;
% imageTemp = reshape(sensor.image{27}(:,2),[imageSize imageSize]);
% imshow(imageTemp)
% 
% %%
% feature.image(:,2)
% 
% %%
% a{1} = '1.raw'
% a{2,1} = 1
% 
% %%
% sensor.status = {'1.raw' '2.classify' '3.outlierRemove' '4.compressSensingRecover'; 0 0 0 0};
% sensor.status{2,3} = 1;
% 
% %%
% rng(1,'twister');
% a = randperm(10);
% 
% %%
% save '/test/matlab.mat' classify
% 
% % images of classification results
% figure
% for n = 1 : temp.size.col
%     set(gcf,'Units','pixels','Position',[100 100 100 100]);  % control figure's position
%     set(gca,'Units','normalized', 'Position',[0 0 1 1]);  % control axis's position in figure
%     set(gca,'visible','off');
%     temp.image = reshape(sensor.image{sensor.num}(:,n),[temp.size.image temp.size.image]);
%     imshow(temp.image)
%     if sensor.label.neuralNet{sensor.num}(n) == 1
%         saveas(gcf,[dirName.good '/good_' num2str(n) '.png']);
%     elseif sensor.label.neuralNet{sensor.num}(n) == 2
%         saveas(gcf,[dirName.bad '/bad_' num2str(n) '.png']);
%     else
%         disp('invalid classification!')
%     end
%     fprintf('finish classification, generating images...  now: %d  total: %d\n', n, temp.size.col)
% end
% fprintf('\ndone! saving...\n')
% close
% sensor.status{sensor.num}(2,2) = {1};  % mark
% 

figure
a = reshape(feature.image(:,2),[208 208]);
imshow(a)
set(gcf,'Units','pixels');
set(gcf,'Position',[100 100 100 100]);  % control figure's position
set(gca,'Units','normalized');
set(gca,'Position',[0 0 1 1]);  % control axis's position in figure

%%
find(sensor.label.neuralNet{27}(:,:) == 1);

%%
1 == 2 || 1 == 1

%%
prompt = 'y(yes)/n(no): ';
go = input(prompt,'s');

%%
plotperform(sensor.trainRecord{sensor.num});
pause
close

plotconfusion(sensor.label.manual{sensor.num},outputs);
pause
close

%%
view(sensor.neuralNet{sensor.num})
saveas(gcf,['test.png']);

%%
% neural net, and view it
jframe = view(sensor.neuralNet{sensor.num});

% create it in a MATLAB figure
hFig = figure('Menubar','none', 'Position',[100 100 565 166]);
jpanel = get(jframe,'ContentPane');
[~,h] = javacomponent(jpanel);
set(h, 'units','normalized', 'position',[0 0 1 1])

% close java window
jframe.setVisible(false);
jframe.dispose();

% print to file
set(hFig, 'PaperPositionMode', 'auto')
saveas(hFig, 'architecture.png')

% close figure
close(hFig)

%%
fprintf('Data type:\n1-normal      2-missing    3-outlier\n4-outrange    5-drift      6-trend interference\nInput: ')


%%
t1 = tic;

for n = 1:1000
    a = n^2;
end

t2 = toc;

t2 - t1

%%

tic
A = rand(12000, 4400);
B = rand(12000, 4400);
toc
tic
C = A'.*B';
toc

%%
a(6) = 3

a(3) = 5





















