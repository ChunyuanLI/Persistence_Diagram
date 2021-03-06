% function [] = combine_BoF_Persistence()
clear
clc

% load settings
 setting_up_robust;

% load distance matrix
% load(fullfile(DIST_DIR, ['distance_pd_',DescriptorType,'.mat']), 'D_multi_level');

combine_PDs;
D_multi_level = stacked_DD;

[num_shapes,num_shapes,pLevels] = size(D_multi_level);

for p = pLevels
    D = sum(D_multi_level(:,:,1:p),3);
end
D1 = D/median(D(:));


DescriptorType = 'Stacked'; 
load(fullfile(DIST_DIR, ['distance_' num2str(VOCAB_SIZES) '_coding_' CodingType '_desc_' DescriptorType '.mat']), 'D_multi_level');
D_multi_level = abs(D_multi_level);
pLevels = 4;
for p =  1:pLevels
    if p == 1
        D = D_multi_level(:,:,p);
    else
        D = zeros(num_shapes,num_shapes);
        for pp = 1:p-1
            D =  D + (D_multi_level(:,:,pp) - D_multi_level(:,:,pp+1))./2^(p-pp);
        end
    end
    D = sum(D_multi_level(:,:,1:p),3);
end

D2 = D/median(D(:));

% prop = 0.1 for BoF and PD in HKS 
% prop = 0.02 for ISPM (L=2) and PD in HKS 
% prop = 0.2 for BoF and PD in SIHKS 
% prop = 0.0001 for ISPM (L=7) and PD in HKS 
% prop = 0.1 for BoF and PD in Stacked spectral descriptor HKS+SIHKS  
% prop = 0.1 for ISPM (L=2) and PD in Stacked spectral descriptor HKS+SIHKS 

prop =0.1; %0.00001;% [0.01:0.05:1,2:3:20];
for i = 1:length(prop)
    D = prop(i)*D1 + 1*D2;
    compute_shapegoogle_performance(D)
end
 
 