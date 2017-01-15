headObj{2} = Heading1('Statistics by sensor');
headObj{2}.FontSize = '18';
append(doc, headObj{2});

cBlank = cBlankNew; frag = 1;
cBlankNew = cBlank + frag;
for n = cBlank+1 : cBlankNew
    blankObj{n} = Paragraph('');
    append(doc, blankObj{n});
end

tableObj{1} = Table(3);
row{1} = TableRow();
c = 1;
for s = sensor.numVec
    imgsize = size(imread([dirName.plotSPS '/' dirName.statsPerSensor{s}]));
    width = [num2str(2 * imgsize(2)/imgsize(1)) 'in'];
    imageSPS{s} = Image([dirName.plotSPS '/' dirName.statsPerSensor{s}]);
    imageSPS{s}.Height = '2in';
    imageSPS{s}.Width = width;
    append(row{1}, TableEntry(imageSPS{s}));
    if mod(c,3) == 0
        append(tableObj{1},row{1});
        row{1} = TableRow();
    elseif s == sensor.numVec(end)
        append(tableObj{1},row{1});
    end
    c = c + 1;
end
tableObj{1}.HAlign = 'center';
append(doc, tableObj{1});

br{cPageBreak} = PageBreak();
append(doc ,br{cPageBreak}); cPageBreak = cPageBreak + 1;
