function D = vector_dist(vectors, distfun)

if iscell(vectors),
    D = {};
    for k=1:length(vectors),
        d = vector_dist(vectors{k}, distfun);
        if ~iscell(d), d = {d}; end
        D(k,:) = d(:)';
    end
    return;
end

if length(distfun) > 1,
    D = {};
    for k=1:length(distfun),
        D{k} = vector_dist(vectors, distfun{k});
    end
    D = D(:)';
    return;
end

if iscell(distfun),
    distfun = distfun{1};
end

v = num2cell(vectors,1);
D = cellfun(distfun, repmat(v(:)', [length(v) 1]), repmat(v(:), [1 length(v)]));