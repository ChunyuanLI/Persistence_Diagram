function [ap] = calculate_ap(D, idxq, idxd, MASK)

ap = zeros(length(idxq),1); % average precision
for k = 1:length(idxq),
    q = idxq(k);
    
    d = D(q,idxd); % distance
    m = MASK(q,idxd);
    [d,idx] = sort(d, 'ascend');
    m = m(idx);

    is_relevant = double(m>0);
    n = cumsum(double(m~=0));  % |{retrieved}|
    r = cumsum(is_relevant); % |{relevant}|
    n(n==0 & r==0) = 1;
    pre = r./n; % precision
    rec = r./r(end); % recall
    
    ap(k) = sum(is_relevant .* pre)/r(end); % average precision
end
