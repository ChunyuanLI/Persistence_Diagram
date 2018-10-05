% experiments on ispm
clc
% load settings
 setting_up_robust;

% load distance matrix
load(fullfile(DIST_DIR, ['distance_pd_',DescriptorType,'.mat']), 'D_multi_level');

[num_shapes,num_shapes,pLevels] = size(D_multi_level);

% Single level partition
% for p = 1: pLevels
%     D = D_multi_level(:,:,p);
%     fprintf('Single level partition %dth level performace.\n', p);
%     compute_shapegoogle_performance(D);
% end

% Linear combined level partition
for p = pLevels
    D = sum(D_multi_level(:,:,1:p),3);
    fprintf('Linear combined %d functions performace.\n', p);
    compute_shapegoogle_performance(D);
end

