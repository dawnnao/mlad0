function autoReport

import mlreportgen.dom.*;

reportType = 'docx';
doc = Document('reportTest',reportType);
append(doc, 'Hello World!');

paraObj = Paragraph('This is a paragraph.');
append(doc, paraObj);

imageObj = Image(which('Python.png'));
imageObj.Width = '1.5in';
imageObj.Height = '1in';
append(doc,imageObj);

tableObj = Table(magic(6));
append(doc,tableObj);

close(doc);
% rptview(doc.OutputPath);

end