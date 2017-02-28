function MAP = calculate_map(D,IDXQ,IDXD,MASK)
AP  = cellfun(@(idxq,idxd)(calculate_ap(D,idxq,idxd,MASK)), IDXQ, IDXD, 'UniformOutput', false);
SAP = sum(cellfun(@sum, AP), 3);
N   = sum(cellfun(@length, AP), 3);
SAP = cumsum(SAP,2);
N   = cumsum(N,2);
MAP = [SAP; sum(SAP,1)]./[N; sum(N,1)];
