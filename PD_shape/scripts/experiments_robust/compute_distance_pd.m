
% load settings
setting_up_robust;
skip_coding = 0;

warning off;
mkdir(DIST_DIR);
warning on;   


% spatial levels
num_instances           = length(SHAPES);


load(fullfile(Specific_DESC_PD_DIR, SHAPES{1}), 'PDs');
num_desc                = length(PDs);
D_multi_level           = zeros(num_instances,num_instances,num_desc);

str = '';
for s = 1:num_instances
    
    shapename = SHAPES{s};
    str = mprintf(str, '%s', num2str(s)); 
    
    % load test data
    load(fullfile(Specific_DESC_PD_DIR, shapename), 'PDs');
    PDs_test = PDs;
    
    for t = 1:num_instances         
            % load labeled data for comparison
            load(fullfile(Specific_DESC_PD_DIR, SHAPES{t}),'PDs');
            PDs_labeled = PDs;
            
            num_desc = length(PDs);
            dis = zeros(num_desc,1);
            for idx =  1:num_desc
                dis(idx,1) = bottleneck_distance(PDs_test{idx}, PDs_labeled{idx});
            end
            D_multi_level(s,t,:) = dis(:);       
    end

end

% Save result
save(fullfile(DIST_DIR, ['distance_pd_',DescriptorType,'.mat']), 'D_multi_level');



