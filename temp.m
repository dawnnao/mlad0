import mlreportgen.dom.*
rpt = Document('test','docx');

append(rpt,Heading(1,'Magic Square Report','Heading 1'));

sect = DOCXPageLayout;
sect.PageSize.Orientation = 'landscape';
sect.PageSize.Height = '8.5in';
sect.PageSize.Width = '11in';
append(rpt,Paragraph('The next page shows a magic square.'),sect);
 
table = append(rpt,magic(22));
table.Border = 'solid';
table.ColSep = 'solid';
table.RowSep = 'solid';




append(rpt,Heading(1,'Magic Square Report','Heading 1'));

sect2 = DOCXPageLayout;
sect2.PageSize.Orientation = 'landscape';
sect2.PageSize.Height = '8.5in';
sect2.PageSize.Width = '11in';
append(rpt,Paragraph('The next page shows a magic square.'),sect2);
 
table2 = append(rpt,magic(22));
table2.Border = 'solid';
table2.ColSep = 'solid';
table2.RowSep = 'solid';
 
close(rpt);
rptview(rpt.OutputPath);