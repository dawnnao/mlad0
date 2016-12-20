function edge = abbr(vec)
% DESCRIPTION:
%   This function can detect the heads and tails of sections in a vector.
%   E.g. a vector [1 3 4 6 7 8], then the heads are [1 3 6], tails are 
%   [1 4 8].

% OUTPUTS:
%   edge (double) - 1st row are heads, 2nd row are tails.
%                   Per column is a group
% 
% INPUTS:
%   vec (double) - vector needs to detect heads and tails of sections
% 
% EXAMPLE:
%   edge = abbr([1 3 4 6 7 8])
%   edge = [1 3 6;
%           1 4 8]
% 
%   edge = abbr([1 2 4 5 6 9 11 12 13])
%   edge = [1 4 9 11;
%           2 6 9 13]

% AUTHOR:
%   Zhiyi Tang
%   tangzhi1@hit.edu.cn
%   Center of Structural Monitoring and Control
% 
% DATE CREATED:
%   2016/12/19

line = zeros(1, max(vec)+1);
line(vec) = vec;

edge = [];
grp = 1;
if line(1) > 0, edge(1,grp) = 1; end

for n = 2:length(line)
    
    if line(n) > 0 && line(n-1) == 0
        edge(1,grp) = n;
    elseif line(n) == 0 && line(n-1) > 0
        edge(2,grp) = n-1;
        grp = grp + 1;
    end
end

end