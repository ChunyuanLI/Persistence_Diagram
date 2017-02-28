function D = squared_dist(X,Y)

if nargin < 2,
    Y = X;
end

D = bsxfun(@plus, sum(X.^2,2), sum(Y.^2,2)') - 2*X*Y';
%D = repmat(sum(X.^2,2),[1 size(Y,1)]) + repmat(sum(Y.^2,2)',[size(X,1) 1]) - 2*X*Y';