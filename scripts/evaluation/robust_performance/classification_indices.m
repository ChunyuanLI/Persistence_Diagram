function [IDXP, IDXN, XFORM, STRENGTH] = classification_indices(MASK, shapeid, xform, strength)

% Positive shape ids
IDS = unique(shapeid); 
IDS = IDS(find(IDS<1000));
XFORM    = [unique(xform)];
STRENGTH = [min(strength):max(strength)];

% Generate leave-one-out queries
M = zeros(size(MASK(shapeid,shapeid)));
for x = 1:length(XFORM),
    X = XFORM{x};
    for s = 1:length(STRENGTH),
        S = STRENGTH(s);
        for i = 1:length(IDS),
            I = IDS(i);
            idxd = find( ~(strcmpi(X, xform) & shapeid == I) );
            idxq = find( strcmpi(X, xform) & strength == S & shapeid == I);
            M(idxq,idxd) = MASK(shapeid(idxq),shapeid(idxd));
        end
    end
end

IDXP = {};
IDXN = {};
IDXP{length(XFORM)+1} = [];
IDXN{length(XFORM)+1} = [];
for x = 1:length(XFORM),
    idxp = find( bsxfun(@times, M, strcmpi(XFORM{x}, xform(:))) > 0);
    idxn = find( bsxfun(@times, M, strcmpi(XFORM{x}, xform(:))) < 0);
    IDXP{x} = idxp;
    IDXN{x} = idxn;
    IDXP{length(XFORM)+1} = union(IDXP{length(XFORM)+1}, idxp);
    IDXN{length(XFORM)+1} = union(IDXN{length(XFORM)+1}, idxn);
end

XFORM = [XFORM {'all'}];