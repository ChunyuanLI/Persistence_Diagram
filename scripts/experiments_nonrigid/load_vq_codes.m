
% load settings
% setting_up;


Hard_BOF_DIR  = fullfile(BOF_DIR, DescriptorType,'hard');
Soft_BOF_DIR  = fullfile(BOF_DIR, DescriptorType,'soft');

num_shapes = length(SHAPES);

feature1 = [];
feature2 = [];

for s = 1:length(SHAPES), 

    shapename = SHAPES{s};
    str = mprintf(str, '%s', shapename);    
    
    % Load BOFs
    %load(fullfile(Specific_KSVD_CODE_DIR, shapename), 'beta1','beta2');
    %load(fullfile(Specific_LLC_CODE_DIR, shapename), 'beta1','beta2');
    load(fullfile(Soft_BOF_DIR, shapename), 'beta1','beta2');
    feature1 = [feature1, beta1]; 
    feature2 = [feature2, beta2];
end    
str = mprintf(str, '\n');  
