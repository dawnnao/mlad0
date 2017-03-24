for m = 1 : 38
   w{m} = cell2mat(sensor.neuralNet{1,m}.IW); 
end

wtest = w{1};
sizeHidden1 = size(wtest,1)
%%
for n = 1 : sizeHidden1
    wtest(n,:) = wtest(n,:)./sqrt(sum(wtest(n,:).^2));
end
wmax = max(max(wtest))

%%
dirName = sprintf('visualizeFeatures-%d/',sizeHidden1);
if ~exist(dirName,'dir'), mkdir(dirName); end
figure('position', [50, 50, 800, 800])
for n = 1 : sizeHidden1
    n
    feature{n} = reshape(wtest(n,:),[100,100]);
    subaxis(10,10,n, 'S',0.005, 'M',0.005);
%     subplot(10,10,n);
    imshow(feature{n},[0,wmax]);
%     set(gca,'Units','normalized', 'Position',[0 0 1 1]);
end
saveas(gcf, [dirName sprintf('feature-%03d',sizeHidden1) '.png']); close
