% experiments on ispm

clc
% load settings
setting_up_shrec2010_nonrigid_s;

% load distance matrix
load(fullfile(DIST_DIR, ['distance_' num2str(VOCAB_SIZES) '_coding_' CodingType '_desc_' DescriptorType '.mat']), 'D_multi_level');

% pLevels is the level of partition
[num_shapes,num_shapes,pLevels] = size(D_multi_level);
load('GroundTruth_SHREC2010.mat');

% Single level partition
% for p = 1: pLevels
%     D = D_multi_level(:,:,p);
%     fprintf('Single level partition %dth level performace.\n', p);
%     Evaluation_DistanceMatrix(D,GroundTruth);
% end

% % Linear combined level partition
% for p = 1: pLevels
%     D = sum(D_multi_level(:,:,1:p),3);
%     fprintf('Linear combined level partition %dth level performace.\n', p);
%     Evaluation_DistanceMatrix(D,GroundTruth);
% end
% 
% % Weighted combined level partition
for p = 1: pLevels
    if p == 1
        D = D_multi_level(:,:,p);
    else
        D = zeros(num_shapes,num_shapes);
        for pp = 1:p-1
            D =  D + (D_multi_level(:,:,pp) - D_multi_level(:,:,pp+1))./2^(p-pp);
        end
    end
    D = sum(D_multi_level(:,:,1:p),3);
    
    fprintf('Weighted combined level partition %dth level performace.\n', p);
    Evaluation_DistanceMatrix(D,GroundTruth);
end