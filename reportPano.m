headObj{1} = Heading1('Panorama');
append(doc, headObj{1});

panoRotate = imread([dirName.plotPano '/' dirName.panopano]);
panoRotate = imrotate(panoRotate, -90);
dirName.panoRotate = [sprintf('%s--%s_sensor_all%s', date.start, date.end, sensorStr) ...
                    '_anomalyDetectionPanoramaRotate.png'];
imwrite(panoRotate, [dirName.plotPano '/' dirName.panoRotate]);

panoObj = Image([dirName.plotPano '/' dirName.panoRotate]);
panoObj.Style = {ScaleToFit};
% panoObj.VAlign = 'middle';
append(doc, panoObj);

br{cPageBreak} = PageBreak();
append(doc ,br{cPageBreak}); cPageBreak = cPageBreak + 1;

close(doc);


