
function compute_shapegoogle_performance(D)
load test.mat;
%load Wavelet_48_vectors.mat
[shapeid, xform, strength] = names2fields(names);

[ids,i] = unique(shapeid); 
MASK = MASK(i,i);
[i,j,m] = find(MASK);
MASK = sparse(ids(i),ids(j),m, max(ids),max(ids));

% Compute distance matrix
distfun = @(x,y)(norm(x/norm(x)-y/norm(y),2));

% load('shapeGoogle_distance.mat');
% D = Dis;
%  D = vector_dist(vectors, distfun);
% 
[IDXQ, IDXD, XFORM, STRENGTH] = query_indices(shapeid, xform, min(5,strength));

MAP = calculate_map(D,IDXQ,IDXD,MASK(shapeid,shapeid));

% print_map(MAP,XFORM,STRENGTH);

[IDXP, IDXN, XFORM, STRENGTH] = classification_indices(MASK, shapeid, xform,  min(5,strength));

[EER,FPR1,FPR01,ROC] = calculate_roc(D, IDXP, IDXN);

print_roc(EER,FPR1,FPR01,XFORM);
% figure
% plot_roc(ROC, XFORM);

