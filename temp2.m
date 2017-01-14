import mlreportgen.dom.*;
d = Document('myreport','docx');
open(d);
 
s = d.CurrentDOCXSection;
s.PageSize.Orientation  ='landscape';
s.PageSize.Height = '8.5in';
s.PageSize.Width = '11in';
append(d,'This document has landscape pages');

close(d);
rptview('myreport','docx');