% function autoReport(saveRoot, sensorNum, dateStart, dateEnd, docName)

import mlreportgen.dom.*;

reportType = 'docx';
doc = Document('docName', reportType);
append(doc, 'Anomaly Detection Auto-Report £¨Version: 0.1£©');

paraObj = Paragraph('Panorama');
append(doc, paraObj);

imageObj = Image(which('Python.png'));
imageObj.Width = '3in';
imageObj.Height = '3in';
append(doc,imageObj);

tableObj = Table(magic(10));
append(doc,tableObj);

close(doc);
% rptview(doc.OutputPath);

% end