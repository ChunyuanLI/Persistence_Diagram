% experiment_ssbof

setting_up_shrec2010_nonrigid_s

% time to diffuse in Heat Kernel
t = 1024;

% load settings
skip_coding = 0;

% load dictionary
load(fullfile(VOCAB_DIR, ['dict_' num2str(VOCAB_SIZES) '_desc_' DescriptorType '.mat']), 'dict', 'sigma');
[nBases, dimDesc] = size(dict);
dimFea = sum(nBases*pyramid);
codes_Size = dimFea;


Specific_DESC_DIR = fullfile(DESC_DIR, DescriptorType);

warning off;
mkdir(Hard_SS_BOF_DIR);
mkdir(Soft_SS_BOF_DIR);
warning on;   

Meshes = dir(fullfile(MESH_DIR, '*.mat'));
SHAPES = {Meshes.name};

dSize = size(dict', 2);


str = '';
for s = 1:length(SHAPES), 

    shapename = SHAPES{s};
    str = mprintf(str, '%s', shapename);    
    
    % Load eigendecomposition
    load(fullfile(EVECS_DIR, shapename), 'evecs', 'evals');

    % Load descriptor
    load(fullfile(Specific_DESC_DIR, shapename), 'desc');
    
    % Normalize descriptors
    desc = double(desc);
    desc = normalize(desc, DESCRIPTOR_NORMALIZATION, 2);
    
    nSmp = size(desc, 1);

    % compute the codes for each local feature
    DD = pdist2(dict,desc,'euclidean');

    %%%%%%%%% hard assignment %%%%%%%%%%%%%%%%%%  
    %     nSmp = size(desc, 1);
    %     vq_codes = zeros(dSize, nSmp);
    %     for iter1 = 1:nSmp,
    %     [~,idx] = min(DD(:, iter1),[],1);
    %     vq_codes(idx,iter1) = 1;
    %     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

    % soft codes via vector quantization
    vq_codes = exp(-0.5*DD.^2/(sigma*SIGMA_SCALE)^2);
    vq_codes = abs(vq_codes);
    
    [num_vertices,n_eigenvalues] = size(evecs);
    
    E = evals;
    PHI = evecs;
    
    E = abs(E);
    LL = exp(-t*E);
    HK = PHI*diag(LL)*PHI'; 
    % HK = ones(num_vertices,num_vertices);
    % Diffusion = pdist2(HK,HK); 
    
    % bag of feature
    beta1_sum = sum(vq_codes, 2);
    BOF = beta1_sum./sum(beta1_sum(:)); 
    
    % spatial sensetive bag of feature
    SSBOF = vq_codes*HK*vq_codes';
    SSBOF = SSBOF(:);
    SSBOF = SSBOF(:)./sum(SSBOF(:));
 
    % save(fullfile(Hard_SS_BOF_DIR, shapename), 'BOF','SSBOF');
    save(fullfile(Soft_SS_BOF_DIR, shapename), 'BOF','SSBOF');

    % fprintf('done. \n');   
   
end

% load bog and ssbof
BoFs = []; 
SS_BOFs = [];

str = '';
for s = 1:length(SHAPES), 

    shapename = SHAPES{s};
    str = mprintf(str, '%s', shapename);    
    load(fullfile(Soft_SS_BOF_DIR, shapename), 'BOF','SSBOF');
    BoFs = [BoFs;BOF']; 
    SS_BOFs = [SS_BOFs;SSBOF'];
end

% evaluate
load('GroundTruth_SHREC2010.mat');

D = pdist2(BoFs,BoFs);
Evaluation_DistanceMatrix(D,GroundTruth);

D = pdist2(SS_BOFs,SS_BOFs);
Evaluation_DistanceMatrix(D,GroundTruth);
D;
