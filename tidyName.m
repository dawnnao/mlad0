function name = tidyName(edge)





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