import mlreportgen.dom.*;
dirName.docFile = sprintf('%s--%s_sensor%s%s', date.start, date.end, sensorStr, netlayout);
reportType = 'docx';
doc = Document(dirName.docFile, reportType);

cBlank = 0; frag = 4;
cBlankNew = cBlank + frag;
for n = cBlank+1 : cBlankNew
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

cBlank = cBlankNew; frag = 12;
cBlankNew = cBlank + frag;
for n = cBlank+1 : cBlankNew
    blankObj{n} = Paragraph('');
    append(doc, blankObj{n});
end

arthurObj = Paragraph('Center of Structural Monitoring and Control');
arthurObj.Bold = false;
arthurObj.FontSize = '18';
arthurObj.HAlign = 'center';
append(doc, arthurObj);

cBlank = cBlankNew; frag = 2;
cBlankNew = cBlank + frag;
for n = cBlank+1 : cBlankNew
    blankObj{n} = Paragraph('');
    append(doc, blankObj{n});
end

% dateStr = date;
dateObj = Paragraph('2017-01-14');
dateObj.Bold = false;
dateObj.FontSize = '18';
dateObj.HAlign = 'center';
append(doc, dateObj);

cPageBreak = 1; br{cPageBreak} = PageBreak();
append(doc ,br{cPageBreak}); cPageBreak = cPageBreak + 1;

% sect{1} = DOCXPageLayout;
% sect{1}.PageSize.Orientation = 'landscape';
% sect{1}.SectionBreak = 'Next Page';
% sect{1}.PageSize.Height = '8.5in';
% sect{1}.PageSize.Width = '11in';
% append(doc, sect{1});