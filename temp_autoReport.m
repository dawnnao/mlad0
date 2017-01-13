clear all;clc;close all;
import mlreportgen.dom.*;
reportType = 'docx';
doc = Document('docTrial', reportType);

%% Cover
c = 0;
frag = 4;
cNew = c + frag;
for n = c+1 : cNew
    blankObj{n} = Paragraph('');
    append(doc, blankObj{n});
end

titleObj{1} = Paragraph('Anomaly Detection Auto-Report');
titleObj{1}.Bold = false;
titleObj{1}.FontSize = '26';
titleObj{1}.HAlign = 'center';
append(doc, titleObj{1});

titleObj{2} = Paragraph('£¨Version: 0.1£©');
titleObj{2}.Bold = false;
titleObj{2}.FontSize = '18';
titleObj{2}.HAlign = 'center';
append(doc, titleObj{2});

c = cNew;
frag = 12;
cNew = c + frag;
for n = c+1 : cNew
    blankObj{n} = Paragraph('');
    append(doc, blankObj{n});
end

arthurObj = Paragraph('Center of Structural Monitoring and Control');
arthurObj.Bold = false;
arthurObj.FontSize = '18';
arthurObj.HAlign = 'center';
append(doc, arthurObj);

c = cNew;
frag = 2;
cNew = c + frag;
for n = c+1 : cNew
    blankObj{n} = Paragraph('');
    append(doc, blankObj{n});
end

dateObj = Paragraph(date);
dateObj.Bold = false;
dateObj.FontSize = '18';
dateObj.HAlign = 'center';
append(doc, dateObj);

br = PageBreak();
append(doc, br);

headObj1 = Heading1('Panorama');
append(doc, headObj1);

paraObj = Paragraph('This is a auto-report test.');
append(doc, paraObj);


close(doc);
%% Panorama
imageObj = Image(which('Python.png'));
imageObj.Width = '3in';
imageObj.Height = '3in';
% append(doc,imageObj);


% imageRotate = imread(which('Python.png'));
% imageRotate = imrotate(imageRotate, 90);
% imshow(imageRotate);

tableObj = Table(2);

row = TableRow();
append(row, TableEntry(imageObj));
append(row, TableEntry('Col2'));
append(tableObj,row);

row = TableRow();
append(row,TableEntry('data11'));
append(row,TableEntry('data12'));
append(tableObj,row);

append(doc, tableObj);

% append(doc,tableObj);

% tableObj = Table(zeros(2,1));
% append(doc,tableObj);

% t1 = row(tableObj,1);
% append(t1, imageObj);




% headObj2 = Heading1('Statistics by sensor');
% append(doc, headObj2);

close(doc);

% rptview(doc.OutputPath);









