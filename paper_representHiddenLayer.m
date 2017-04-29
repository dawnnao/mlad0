%% 1st hidden layer
for m = 1 : 38
   wInput{m} = cell2mat(sensor.neuralNet{1,m}.IW); 
end

wtest = wInput{1};
sizeHidden1 = size(wtest,1)
%%
for n = 1 : sizeHidden1
    wtest(n,:) = wtest(n,:)./sqrt(sum(wtest(n,:).^2));
end
wmax = max(max(wtest))
wmin = min(min(wtest))

%%
dirName = sprintf('visualizeFeatures-%d/',sizeHidden1);
if ~exist(dirName,'dir'), mkdir(dirName); end
figure('position', [50, 50, 800, 800])
for n = 1 : sizeHidden1
    n
    feature1{n} = reshape(wtest(n,:),[100,100]);
    subaxis(10,10,n, 'S',0.005, 'M',0.005);
%     subplot(10,10,n);
    imshow(feature1{n},[]);
%     set(gca,'Units','normalized', 'Position',[0 0 1 1]);
end
saveas(gcf, [dirName sprintf('featureOfHiddenLayer1-%03d',sizeHidden1) '.emf']); close

%%
figure
imshow(feature1{78},[])
figure
imshow(feature1{79},[])
figure
forMissing = feature1{78}+feature1{79};
imshow(forMissing,[])


%%
for m = 1 : 38
   wHiddenLayer{m} = sensor.neuralNet{1,m}.LW;
end

wtest = wHiddenLayer{1};
sizeHidden1 = size(wtest,1)

%% 2nd hidden layer
feature2 = cell2mat(wtest(2,1));
max(max(feature2))
min(min(feature2))
imshow(feature2,[], 'InitialMagnification', 'fit')

%% 3nd hidden layer
feature3 = cell2mat(wtest(3,2));
max(max(feature3))
min(min(feature3))
imshow(feature3,[], 'InitialMagnification', 'fit')

%% output layer
feature4 = cell2mat(wtest(4,3));
max(max(feature4))
min(min(feature4))
imshow(feature4,[], 'InitialMagnification', 'fit')





