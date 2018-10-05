

load test.mat;
[shapeid, xform, strength] = names2fields(names);

[ids,i] = unique(shapeid); 
MASK = MASK(i,i);
[i,j,m] = find(MASK);
MASK = sparse(ids(i),ids(j),m, max(ids),max(ids));

% Compute distance matrix
distfun = @(x,y)(norm(x/norm(x)-y/norm(y),2));

D = vector_dist(vectors, distfun);

[IDXQ, IDXD, XFORM, STRENGTH] = query_indices(shapeid, xform, min(5,strength));

MAP = calculate_map(D,IDXQ,IDXD,MASK(shapeid,shapeid));

print_map(MAP,XFORM,STRENGTH);

[IDXP, IDXN, XFORM, STRENGTH] = classification_indices(MASK, shapeid, xform,  min(5,strength));

[EER,FPR1,FPR01,ROC] = calculate_roc(D, IDXP, IDXN);

print_roc(EER,FPR1,FPR01,XFORM);

plot_roc(ROC, XFORM);






return;

%IDXP = cellfun(@(idxq,idxd)(find(MASK(shapeid(idxq),shapeid(idxd)) == +1)), IDXQ, IDXD, 'UniformOutput', false);
IDXN = cellfun(@(idxq,idxd)(find(MASK(shapeid(idxq),shapeid(idxd)) == -1)), IDXQ, IDXD, 'UniformOutput', false);

for i=2:size(IDXP,3),
    IDXP(:,:,1) = cellfun(@union, IDXP(:,:,1), IDXP(:,:,i), 'UniformOutput',false);
    IDXN(:,:,1) = cellfun(@union, IDXN(:,:,1), IDXN(:,:,i), 'UniformOutput',false);
end
IDXP = IDXP(:,:,1);
IDXN = IDXN(:,:,2);



%classification_indices


%[eer,fpr1,fpr01, dee,dfr1,dfr01, d,fp,fn] = calculate_rates(dp, dn, d0);


%[map, ap] = calculate_map(D, [1:10], [1:end], MASK(shapeid,shapeid));

%D = vector_dist(vectors(1:10), distfun);
%D = vector_dist({vectors(1:10), 10*vectors(1:10)}, distfun);
%D = vector_dist(vectors(1:10), {distfun, distfun1});
%D = vector_dist({vectors(1:10), 10*vectors(1:10)}, {distfun, distfun1});




%V   = cellfun(@(x)(str2num(x{2}(8:end))), FIELDS, 'UniformOutput', true);




