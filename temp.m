import mlreportgen.dom.*
rpt = Document('test','pdf');

append(rpt,Heading(1,'Magic Square Report','Heading 1'));

sect1 = DOCXPageLayout;
sect1.PageSize.Orientation = 'landscape';
sect1.PageSize.Height = '8.5in';
sect1.PageSize.Width = '11in';
append(rpt,Paragraph('The next page shows a magic square.'),sect1);
 
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