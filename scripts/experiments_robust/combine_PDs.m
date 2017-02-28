% function [] = combine_PDs()

% load settings
 setting_up_robust;

% load distance matrix

DescriptorType = 'HKS';
load(fullfile(DIST_DIR, ['distance_pd_',DescriptorType,'.mat']), 'D_multi_level');
[num_shapes,num_shapes,HKS_pLevels] = size(D_multi_level);
HKS_D_multi_level = D_multi_level;


% DescriptorType = 'WKS';
% load(fullfile(DIST_DIR, ['distance_pd_',DescriptorType,'.mat']), 'D_multi_level');
% [~,~,WKS_pLevels] = size(D_multi_level);
% WKS_D_multi_level = D_multi_level;

DescriptorType = 'SIHKS';
load(fullfile(DIST_DIR, ['distance_pd_',DescriptorType,'.mat']), 'D_multi_level');
[~,~,SIHKS_pLevels] = size(D_multi_level);
SIHKS_D_multi_level = D_multi_level;

pLevels = HKS_pLevels + SIHKS_pLevels;
% pLevels = HKS_pLevels + WKS_pLevels + SIHKS_pLevels;
stacked_DD = zeros(num_shapes,num_shapes,pLevels);

for i = 1:num_shapes
    for j =1:num_shapes
        H  = HKS_D_multi_level(i,j,:);
        %W  = WKS_D_multi_level(i,j,:);
        SI = SIHKS_D_multi_level(i,j,:);
        
        stacked_DD(i,j,:) = [H(:);...
                          %  W(:);...
                            SI(:)]; 
    end
end

% % Normalize each function distance
% for p = 1: pLevels
%     D = stacked_DD(:,:,p);
%     D = D/sum(D(:));
%     stacked_DD(:,:,p) = D;
% end

% Linear combined level partition
% for p = 1: pLevels
%     D = sum(stacked_DD(:,:,1:p),3);
%     fprintf('Linear combined level partition %dth level performace.\n', p);
%     compute_shapegoogle_performance(D);
% end