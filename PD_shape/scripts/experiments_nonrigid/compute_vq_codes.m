% compute_distance

setting_up_shrec2010_nonrigid_s
% load settings
skip_coding = 0;

% load dictionary
load(fullfile(VOCAB_DIR, ['dict_' num2str(VOCAB_SIZES) '_desc_' DescriptorType '.mat']), 'dict', 'sigma');
[nBases, dimDesc] = size(dict);
dimFea = sum(nBases*pyramid);
% codes_Size = 2*dSize+ 2*(dSize-1) + dSize*dSize+(dSize-1)*(dSize-1);
codes_Size = dimFea;


Specific_DESC_DIR = fullfile(DESC_DIR, DescriptorType);
Hard_BOF_DIR  = fullfile(BOF_DIR, DescriptorType,'hard');
Soft_BOF_DIR  = fullfile(BOF_DIR, DescriptorType,'soft');




warning off;
mkdir(Hard_BOF_DIR);
mkdir(Soft_BOF_DIR);
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

    % Load eigendecomposition
    load(fullfile(EVECS_DIR, shapename), 'evecs', 'evals');

    % Load descriptor
    load(fullfile(Specific_DESC_DIR, shapename), 'desc');
    % Normalize descriptors
    desc = double(desc);
    desc = normalize(desc, DESCRIPTOR_NORMALIZATION, 2);
    
    % coding with spectral descriptors via BoF
    [beta1,beta2] = average_pooling_hard(evecs, desc, dict, pyramid);    
    % Save result
    save(fullfile(Hard_BOF_DIR, shapename), 'beta1','beta2');
    
    % coding with spectral descriptors via BoF
    [beta1,beta2] = average_pooling_soft(evecs, desc, dict, pyramid,sigma*SIGMA_SCALE);    
    % Save result
    save(fullfile(Soft_BOF_DIR, shapename), 'beta1','beta2');


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



