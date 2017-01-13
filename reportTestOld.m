clear;clc;close all;

word = actxserver('Word.Application');
word.Visible = 1;

document = word.Documents.Add;
selection = word.Selection;

selection.TypeText('Hello world. ');
selection.TypeText('My name is Professor Kitchin');
selection.TypeParagraph;
selection.TypeText('How are you today?');
selection.TypeParagraph;

selection.TypeText('Big Finale');
selection.Style='Heading 1';
selection.TypeParagraph;

H1 = document.Styles.Item('Heading 1');
H1.Font.Name = 'Garamond';
H1.Font.Size = 20;
H1.Font.Bold = 1;
H1.Font.TextColor.RGB=60000; % some ugly color green

selection.TypeParagraph
selection.TypeText('That is all for today!')

document.SaveAs2([pwd '/test.docx']);
word.Quit();





