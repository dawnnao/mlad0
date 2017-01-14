headObj{1} = Heading1('Panorama');
append(doc, headObj{1});

panoRotate = imread([dirName.plotPano '/' dirName.panopano]);
panoRotate = imrotate(panoRotate, -90);
dirName.panoRotate = [sprintf('%s--%s_sensor_all%s', date.start, date.end, sensorStr) ...
                    '_anomalyDetectionPanoramaRotate.png'];
imwrite(panoRotate, [dirName.plotPano '/' dirName.panoRotate]);

imgsize = size(imread([dirName.plotPano '/' dirName.panoRotate]));
width = [num2str(8.5 * imgsize(2)/imgsize(1)) 'in'];
panoObj = Image([dirName.plotPano '/' dirName.panoRotate]);
panoObj.Height = '8.5in';
panoObj.Width = width;
panoPara = Paragraph(panoObj);
panoPara.HAlign = 'center';
append(doc, panoPara);

br{cPageBreak} = PageBreak();
append(doc ,br{cPageBreak}); cPageBreak = cPageBreak + 1;

close(doc);


