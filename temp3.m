clear all;clc;close all;
import mlreportgen.dom.*;
reportType = 'docx';
doc = Document('docTrial', reportType, which('myTemplate.dotx'));
% doc = Document('docTrial', reportType);


%% Cover
sectCurrent{1} = doc.CurrentPageLayout;
% sectCurrent{1}.PageHeaders = 'pageHeader';
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
frag = 4; % 12
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

dateObj = Paragraph();
dateObj.Bold = false;
dateObj.FontSize = '18';
dateObj.HAlign = 'center';
append(doc, dateObj);
append(dateObj, date);

% s = doc.CurrentDOCXSection;

sect{1} = DOCXPageLayout;
% sect{1}.PageSize.Orientation = 'landscape';
% sect{1}.SectionBreak = 'Same Page';
% sect{1}.PageSize.Height = '8.5in';
% sect{1}.PageSize.Width = '11in';
append(doc, sect{1});

%% Panorama
% s{1} = doc.CurrentDOCXSection;
% s{1}.PageSize.Orientation = 'landscape';
% s{1}.PageSize.Height = '8.5in';
% s{1}.PageSize.Width = '11in';

paraObj{1} = Paragraph('This is an auto-report test.');
paraObj{1}.StyleName = 'Heading 1';
append(doc, paraObj{1});

headObj{1} = Heading1('Panorama');
append(doc, headObj{1});

img = imread(which('Python.png'));

imageObj{1} = Image(which('Python.png'));
imageObj{1}.Width = '3in';
imageObj{1}.Height = '3in';
% imageObj{1}.VAlign = 'middle';
% imageObj{1}.StyleName = 'Quote';
% imageObj{1}.Style = {ScaleToFit};
% imageObj{1}.HAlign = 'center';
imagePara = Paragraph(imageObj{1});
imagePara.HAlign = 'center';
append(doc, imagePara);

tableObj{1} = Table(2);
row = TableRow();
append(row, TableEntry('Col1'));
append(row, TableEntry('Col2'));
append(tableObj{1},row);
row = TableRow();
append(row,TableEntry('data11'));
append(row,TableEntry('data12'));
append(tableObj{1},row);
append(doc, tableObj{1});

paraObj{2} = Paragraph('End of Panorama.');
% append(doc, paraObj{2});

% s = doc.CurrentDOCXSection;
% s.SectionBreak  = true;

% br{1} = PageBreak();
% append(doc ,br{1});

% sect{2} = DOCXPageLayout;
% sect{2}.PageSize.Orientation = 'portrait';
% sect{2}.PageHeaders = 'pageHeader';
% sect{2}.SectionBreak = 'Next Page';
% append(doc, paraObj{2}, sect{2});

temp = doc.CurrentDOCXSection;

%% Statistics by sensor
% s = doc.CurrentDOCXSection;
% s.SectionBreak  = true;

headObj{2} = Heading1('Statistics by sensor');
append(doc, headObj{2});

imageObj{2} = Image(which('Python.png'));
imageObj{2}.Width = '3in';
imageObj{2}.Height = '3in';
% imageRotate = imread(which('Python.png'));
% imageRotate = imrotate(imageRotate, 90);
% imshow(imageRotate);

tableObj{2} = Table(2);
row = TableRow();
append(row, TableEntry(imageObj{2}));
append(row, TableEntry('Col2'));
append(tableObj{2},row);
row = TableRow();
append(row,TableEntry('data11'));
append(row,TableEntry('data12'));
append(tableObj{2},row);
append(doc, tableObj{2});

paraObj{2} = Paragraph('End of Panorama.');
append(doc, paraObj{2});

% sect{2} = DOCXPageLayout(2);
% sect{2}.PageSize.Orientation = 'portrait';
% append(doc, sect{2});

% sect{3} = DOCXPageLayout;
% append(doc, sect{3});

%%

close(doc);
% rptview(doc.OutputPath);









