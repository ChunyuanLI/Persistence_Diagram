function [IDXQ, IDXD, XFORM, STRENGTH] = query_indices(shapeid, xform, strength)

% Positive shape ids
IDS = unique(shapeid); 
IDS = IDS(find(IDS<1000));
XFORM    = [unique(xform)];
STRENGTH = [min(strength):max(strength)];

% Generate leave-one-out queries
IDXQ = {};
IDXD = {};
for x = 1:length(XFORM),
    X = XFORM{x};
    for s = 1:length(STRENGTH),
        S = STRENGTH(s);
        for i = 1:length(IDS),
            I = IDS(i);
            idxd = find( ~(strcmpi(X, xform) & shapeid == I) );
            idxq = find( strcmpi(X, xform) & strength == S & shapeid == I);
            IDXQ{x,s,i} = idxq;
            IDXD{x,s,i} = idxd;
        end
    end
end

XFORM = [XFORM {'all'}];