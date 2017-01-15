headObj{3} = Heading1('Statistics by label');
headObj{3}.FontSize = '18';
append(doc, headObj{3});

cBlank = cBlankNew; frag = 1;
cBlankNew = cBlank + frag;
for n = cBlank+1 : cBlankNew
    blankObj{n} = Paragraph('');
    append(doc, blankObj{n});
end

tableObj{2} = Table(1);
row{2} = TableRow();
c = 1;
for l = 1 : labelTotal
    imgsize = size(imread([dirName.plotSPT '/' dirName.statsPerLabel{l}]));
    width = [num2str(2.8 * imgsize(2)/imgsize(1)) 'in'];
    imageSPT{s} = Image([dirName.plotSPT '/' dirName.statsPerLabel{l}]);
    imageSPT{s}.Height = '2.8in';
    imageSPT{s}.Width = width;
    append(row{2}, TableEntry(imageSPT{s}));
    if mod(c,1) == 0
        append(tableObj{2},row{2});
        row{2} = TableRow();
    elseif l == labelTotal
        append(tableObj{2},row{2});
    end
    c = c + 1;
end
tableObj{2}.HAlign = 'center';
append(doc, tableObj{2});

br{cPageBreak} = PageBreak();
append(doc ,br{cPageBreak}); cPageBreak = cPageBreak + 1;
