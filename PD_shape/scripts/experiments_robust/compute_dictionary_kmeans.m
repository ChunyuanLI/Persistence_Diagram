

% 16/12/2013
% This script computes the dictionary via kmeans. 
% The low level feture can be: GPS HKS WKS SIHKS HMS SGWS
% Load the descriptors
%%
% 
%DescriptorType = 'SGWS';
setting_up_robust;%%
% load settings

% Specific_DESC_DIR = fullfile(DESC_DIR, DescriptorType);

warning off;
mkdir(Specific_DESC_DIR);
warning on;   

% Load one mesh to check the descriptors
load(fullfile(Specific_DESC_DIR, SHAPES{1}), 'desc');
dimdesc = size(desc,2);

% Build training set
fprintf(1, 'Building training set...\n');
num_shapes = length(SHAPES); % num of shapes
num_per_shape = round(num_smp/num_shapes); % num of descriptors sampled from each shape
num_smp = num_per_shape*num_shapes; % total number of sampled descriptors

% Allocate memory space for descriptors
X = zeros(num_smp,dimdesc);
cnt = 0;
str = '';

for ii = 1:num_shapes,
    
    % Load descriptors
    load(fullfile(Specific_DESC_DIR, SHAPES{ii}), 'desc');

    % Add descriptors to training set
    num_desc = size(desc, 1);
    rndidx = randperm(num_desc)';
    X(cnt+1:cnt+num_per_shape,:) = desc(rndidx(1:num_per_shape),:);
    cnt = cnt+num_per_shape;
    
    % Print statistics
    str = mprintf(str, '  Shapes: %-4d \t Descriptors: %s', ii, cnt);
    
end;


% Normalize descriptors
X = double(X);
X = normalize(X, DESCRIPTOR_NORMALIZATION, 2);

warning off;
mkdir(VOCAB_DIR);
warning on;    

% Train vocabularies of all sizes
for k=1:length(VOCAB_SIZES),

    nvocab = VOCAB_SIZES(k);
    
    if SKIP_EXISTING && exist(fullfile(VOCAB_DIR, ['dict_' num2str(nvocab) '_desc_' DescriptorType '.mat']), 'file'),
        fprintf(1, 'Skipping vocabulary of size %d, file already exists\n', nvocab);
        continue;
    end
    
    fprintf(1, 'Training vocabulary of size %d...\n', nvocab);
        
    % Train vocabulary
    [idx, dict] = kmeans2(double(X), nvocab, ...
                'maxiter', VOCAB_TRAIN_NITER, ...
                'display', 1, ...
                'replicates', VOCAB_TRAIN_REPEATS, ...
                'randstate', 0, ...
                'outlierfrac', VOCAB_TRAIN_OUTLIERS);    
            
    % Compute sigma        
    tree = ann('init', dict');
    [sig, mind] = ann('search', tree, X', 1, 'eps', 1.1);
    sigma = median(mind);
    ann('deinit', tree);
    clear ann;

    % Save vocabulary
    save(fullfile(VOCAB_DIR, ['dict_' num2str(nvocab) '_desc_' DescriptorType '.mat']), 'dict', 'sigma');
    
end