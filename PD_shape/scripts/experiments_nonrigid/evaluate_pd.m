% experiments on ispm
clc
% load settings
setting_up_shrec2010_nonrigid_s;

% load distance matrix
load(fullfile(DIST_DIR, ['distance_',DescriptorType,'.mat']), 'D_multi_level');

[num_shapes,num_shapes,pLevels] = size(D_multi_level);
load('GroundTruth_SHREC2010.mat');

% % Normalize each function distance
% for p = 1: pLevels
%     D = D_multi_level(:,:,p);
%     D = D/median(D(:));
%     D_multi_level(:,:,p) = D;
% end

% Single level partition
% for p = 1: pLevels
%     D = D_multi_level(:,:,p);
%     fprintf('Single level partition %dth level performace.\n', p);
%     Evaluation_DistanceMatrix(D,GroundTruth);
% end

% Linear combined level partition
for p = 1:pLevels
    D = sum(D_multi_level(:,:,1:p),3);
    fprintf('Linear combined level partition %dth level performace.\n', p);
    Evaluation_DistanceMatrix(D,GroundTruth);
end