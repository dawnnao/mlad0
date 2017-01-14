function rptpop(doctype)
%RPTPOP DOM-based report example
%
%   This example is based on the MATLAB example: "Predicting the US
%   Population." That example was generated using MATLAB Publish. This
%   example is generated using the DOM API. This example is intended to
%   illustrate a simple use of the API, one that does not entail use of
%   holes or templates.
%
%   rptpop() generates an HTML version of the report.
% 
%   rptpop(doctype) generates a report of the specified type:
%   'html', 'docx', or 'pdf'.

%   Copyright MathWorks, 2013-2014.

% This statement eliminates the need to qualify the names of DOM
% objects in this function, e.g., you can refer to 
% mlreportgen.dom.Document simply as Document.
import mlreportgen.dom.*;

if nargin < 1
    doctype = 'html';
end

% Create a cell array to hold images that we are going to generate
% for this report. That will facilitate deleting the images at the
% end of report generation when they are no longer needed.
images = {};

% Create a document.
rpt = Document('population', doctype);

% Create a title for the report.
h = Heading(2, 'Predicting the US Population');

% Create a border format object that effectively draws a light gray
% rule under the title.
b = Border();
b.BottomStyle = 'single';
b.BottomColor = 'LightGray';
b.BottomWidth = '1pt';

% Set the style of the title programmatically to be dark orange with 
% a light gray rule under it.
%
% Note that we could have achieved the same effect
% by defining a title style in a template associated with this object
% and setting the heading's StyleName property to the name of the 
% template-defined style, e.g.,
%
% h.StyleName = 'Title';
%
% This would allow us to change the appearance of the title without 
% having to change the code.
%
% Note also that we append the border and color format objects to the
% heading's existing Style array. This avoids overwriting the
% heading's existing OutlineLevel format.
h.Style = [h.Style {Color('DarkOrange'), b}];

% Append the heading to the document.
append(rpt, h);

% Add some boilerplate text to the document, using the addBodyPara
% function defined below. Note that we could have included this text
% in a template created especially for this report. That would simplify
% this function significantly and allow us to modify the boilerplate
% text without having to modify this code.
addBodyPara(rpt, 'This example shows that using polynomials of even modest degree to predict the future by extrapolating data is a risky business.');
addBodyPara(rpt, 'This example is older than MATLAB.  It started as an exercise in "Computer Methods for Mathematical Computations", by Forsythe, Malcolm and Moler, published by Prentice-Hall in 1977.');
addBodyPara(rpt, 'Now, MATLAB and Handle Graphics make it much easier to vary the parameters and see the results, but the underlying mathematical principles are unchanged.');
addBodyPara(rpt, 'Here is the US Census data from 1900 to 2000.');


% Time interval
t = (1900:10:2000)';

% Population
p = [75.995 91.972 105.711 123.203 131.669 ...
     150.697 179.323 203.212 226.505 249.633 281.422]';

% Plot
plot(t,p,'bo');
axis([1900 2020 0 400]);
title('Population of the U.S. 1900-2000');
ylabel('Millions');

% Add the plot to the document (see addPlot function below).
img = addPlot(rpt, 'plot1');

% Add plot image to the list of images to be deleted at the end of
% report generation. Note that we need to keep the images around until
% the report is closed. That is because we cannot add images to the
% report package while the main report file is still open.
images = [images {img}]; %#ok<*NASGU>

% Add some more boilerplate to the report.
addBodyPara(rpt, 'What is your guess for the population in the year 2010?');
addBodyPara(rpt, 'Let''s fit the data with a polynomial in t and use it to extrapolate to t = 2010.  The coefficients in the polynomial are obtained by solving a linear system of equations involving a 11-by-11 Vandermonde matrix, whose elements are powers of scaled time, A(i,j) = s(i)^(n-j);');

% Compute coefficients for a polynomial approximation to the 
% population data.
n = length(t);
s = (t-1950)/50;
A = zeros(n);
A(:,end) = 1;
for j = n-1:-1:1, A(:,j) = s .* A(:,j+1); end

% Add more boilerplate.
addBodyPara(rpt, 'The coefficients c for a polynomial of degree d that fits the data p are obtained by solving a linear system of equations involving the last d+1 columns of the Vandermonde matrix:');
addBodyPara(rpt, 'A(:,n-d:n)*c ~= p');
addBodyPara(rpt, 'If d is less than 10, there are more equations than unknowns and a least squares solution is appropriate.  If d is equal to 10, the equations can be solved exactly and the polynomial actually interpolates the data.  In either case, the system is solved with MATLAB''s backslash operator.  Here are the coefficients for the cubic fit.');

c = A(:,n-3:n)\p;

% Append array of coefficients to the report. Note that we can append
% numeric (and cell) arrays directly to the document. The DOM API 
% converts a 1xN array to a list and an MxN array to a table. (Arrays
% of more than two dimensions are not supported).
append(rpt, c);

addBodyPara(rpt, 'Now we evaluate the polynomial at every year from 1900 to 2010 and plot the results.');

v = (1900:2020)';
x = (v-1950)/50;
w = (2010-1950)/50;
y = polyval(c,x);
z = polyval(c,w);

hold on
plot(v,y,'k-');
plot(2010,z,'ks');
text(2010,z+15,num2str(z));
hold off

img = addPlot(rpt, 'plot2');
images = [images {img}]; %#ok<*NASGU>

addBodyPara(rpt, 'Compare the cubic fit with the quartic.  Notice that the extrapolated point is very different.');

c = A(:,n-4:n)\p;
y = polyval(c,x);
z = polyval(c,w);

hold on
plot(v,y,'k-');
plot(2010,z,'ks');
text(2010,z-15,num2str(z));
hold off

img = addPlot(rpt, 'plot3');
images = [images {img}]; %#ok<*NASGU>

addBodyPara(rpt, 'As the degree increases, the extrapolation becomes even more erratic.');

cla
plot(t,p,'bo'); hold on; axis([1900 2020 0 400]);
colors = hsv(8); labels = {'data'};
for d = 1:8
   [Q,R] = qr(A(:,n-d:n));
   R = R(1:d+1,:); Q = Q(:,1:d+1);
   c = R\(Q'*p);    % Same as c = A(:,n-d:n)\p;
   y = polyval(c,x);
   z = polyval(c,11);
   plot(v,y,'color',colors(d,:));
   labels{end+1} = ['degree = ' int2str(d)]; %#ok<AGROW>
end
legend(labels, 'Location', 'NorthWest')

img = addPlot(rpt, 'plot4');
images = [images {img}]; %#ok<*NASGU>

% Close the report.
close(rpt);

% Closing the report causes the images needed for the report to be copied
% into the report package (docx for Word, htmx for HTML). So we can
% now delete them.
for i = 1:length(images)
    delete(images{i});
end

% rptview('population', doctype);

end

function addBodyPara(rpt, text)
% Format report text and append it to a document.
import mlreportgen.dom.*;
p = append(rpt, Paragraph(text));
p.Style = {FontFamily('Arial'), FontSize('10pt')};
end

function imgname = addPlot(rpt, name)
% Convert the specified plot to an image and
% append the image to the document. Return
% the image name so it can be deleted at the
% end of report generation.
import mlreportgen.dom.*;

% Select an appropriate image type, depending
% on the document type.
if strcmpi(rpt.Type, 'html')
    imgtype = '-dpng';
    imgname= [name '.png'];
else
    % This Microsoft-specific vector graphics format
    % can yield better quality images in Word documents.
    imgtype = '-dmeta';
    imgname = [name '.emf'];
end

% Convert figure to the specified image type.
print(imgtype, imgname);

% Set image height and width.
img = Image(imgname);
img.Width = '5in';
img.Height = '4in';

% Append image to document.
append(rpt, Paragraph(img)); % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% Delete plot figure window.
delete(gcf);

end
