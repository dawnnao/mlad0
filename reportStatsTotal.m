headObj{4} = Heading1('Statistics in total');
headObj{4}.FontSize = '18';
append(doc, headObj{4});

cBlank = cBlankNew; frag = 1;
cBlankNew = cBlank + frag;
for n = cBlank+1 : cBlankNew
    blankObj{n} = Paragraph('');
    append(doc, blankObj{n});
end

imgsize = size(imread([dirName.plotSum '/' dirName.statsSum]));
width = [num2str(4 * imgsize(2)/imgsize(1)) 'in'];
statsObj = Image([dirName.plotSum '/' dirName.statsSum]);
statsObj.Height = '4in';
statsObj.Width = width;
statsPara = Paragraph(statsObj);
statsPara.HAlign = 'center';
append(doc, statsPara);

br{cPageBreak} = PageBreak();
append(doc ,br{cPageBreak}); cPageBreak = cPageBreak + 1;

close(doc);
