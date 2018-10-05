function [EER,FPR1,FPR01,ROC] = calculate_roc(D, IDXP, IDXN)

EER   = [];
FPR1  = [];
FPR01 = [];
ROC   = {};
for k=1:length(IDXP),
    dp = D(IDXP{k});
    dn = D(IDXN{k});
    [EER(k),FPR1(k),FPR01(k), dee,dfr1,dfr01, d,fp,fn] = calculate_rates(dp, dn);
    ROC{k} = [fp(:) fn(:)];
end

EER   = EER(:);
FPR1  = FPR1(:);
FPR01 = FPR01(:);
ROC   = ROC(:);