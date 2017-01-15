% %% Create 3-D Bar Graph
% % Load the data set |count.dat|, which returns a three-column matrix, |count|.
% % Store |Y| as the first 10 rows of |count|.
% 
% % Copyright 2015 The MathWorks, Inc.
% 
% load count.dat
% Y = count(1:10,:);
% 
% %%
% % Create a 3-D bar graph of |Y|. By default, the style is |detached|.
% % figure
% bar3(Y')
% xlabel('Type')
% ylabel('Month')
% zlabel('Count (hours)')
% title('Detached Style')
% view(45, 30)
% 
% 

if 1 == 1
    warning('In 1!');
elseif 2 == 2
    wraning('In 2!');
end