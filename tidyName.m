function name = tidyName(edge)
% DESCRIPTION:
%   This is a subfunction of mvad.m, to make abbreviation in char format.
%   Use with abbr.m
% 
% OUTPUT:
%   name (string)
% 
% INPUT:
%   edge (double) - 1st row are heads, 2nd row are tails.
%                   Per column is a group
% EXAMPLE:
%   edge = [1 3 6;
%           1 4 8]
%   name = tidyName(edge);
%   name = '_1_3,4_6-8'
% 
%   edge = [1 4 9 11;
%           2 6 9 13]
%   name = tidyName(edge);
%   name = '_1,2_4-6_9_11-13'

% AUTHOR:
%   Zhiyi Tang
%   tangzhi1@hit.edu.cn
%   Center of Structural Monitoring and Control
% 
% DATE CREATED:
%   12/10/2016

for n = 1 : size(edge,2)
    if edge(2,n) == edge(1,n)
        str{n} = sprintf('_%d', edge(1,n));
    elseif edge(2,n) == edge(1,n) + 1
        str{n} = sprintf('_%d,%d', edge(1,n), edge(2,n));
    elseif edge(2,n) > edge(1,n) + 1
        str{n} = sprintf('_%d-%d', edge(1,n), edge(2,n));
    end
end
name = strjoin(str,'');

end