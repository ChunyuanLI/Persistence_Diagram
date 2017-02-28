% compute_distance


% load settings
setting_up;
skip_coding = 0;

% load dictionary
load(fullfile(VOCAB_DIR, ['dict_' num2str(VOCAB_SIZES) '_desc_' DescriptorType '.mat']), 'dict', 'sigma');
[nBases, dimDesc] = size(dict);
dimFea = sum(nBases*pyramid);
% codes_Size = 2*dSize+ 2*(dSize-1) + dSize*dSize+(dSize-1)*(dSize-1);
codes_Size = dimFea;


warning off;
mkdir(Specific_PATHS_CODE_level_DIR);
warning on;   

Meshes = dir(fullfile(MESH_DIR, '*.mat'));
SHAPES = {Meshes.name};


% Statistics
tic;
nerr  = 0;
nskip = 0;
nok   = 0;  
fprintf(1, 'Compute the bof codes of the mesh...\n');


tic
for s =  1:length(SHAPES), 
    
    shapename = SHAPES{s};
    fprintf(1, '  %-30s \t ', shapename);
    
    if SKIP_EXISTING && exist(fullfile(Hard_BOF_DIR, shapename), 'file'),
        fprintf(1, 'file already exists, skipping\n');
        nskip = nskip+1;
        continue;
    end

%     % Load eigendecomposition
%     load(fullfile(EVECS_DIR, shapename), 'evecs', 'evals');
     
    % Load reeb graph paths
    load(fullfile(REEBGRAPH_level_DIR, shapename), 'Paths', 'Components');

    % Load descriptor
    load(fullfile(Specific_DESC_DIR, shapename), 'desc');
    % Normalize descriptors
    desc = double(desc);
    desc = normalize(desc, DESCRIPTOR_NORMALIZATION, 2);
    
    num_nodes_on_path = 1;
    % coding with spectral descriptors via BoF
    beta1 = average_pooling_soft_on_paths(Components, desc, dict, Paths,sigma*SIGMA_SCALE, num_nodes_on_path); 
    
    % Save result
    save(fullfile(Specific_PATHS_CODE_level_DIR, shapename), 'beta1');


    str = fprintf('VQ codes of %s is extracted.\n', shapename);
    nok = nok+1;

end
toc

% Statistics
fprintf(1, '\n Computation complete\n');
fprintf(1, ' Elapsed time:   %s\n', toc);
fprintf(1, ' Total Shapes:   %d\n', length(SHAPES));
fprintf(1, ' Average time:   %s\n', toc/length(SHAPES));
fprintf(1, ' Computed:       %d\n', nok);
fprintf(1, ' Skipped:        %d\n', nskip);
fprintf(1, ' Errors:         %d\n', nerr);



