
%% parameter

SKIP_EXISTING = 0;
% dataset to process
DATASET = 'SHREC2010_Nonrigid';

% eigen implementation
LB_PARAM = 'cot';
max_num_evecs = 200;

% number of level sets on second eigenfunction
num_levelsets = 10; % Reeg graph
pyramid = [1, 2, 4, 8, 16, 32, 64, 128];%, 256];  % ISPM

CodingType = 'k_means'; % 'k_means' 'llc' 'ksvd' 'sc'

% dictionary
num_smp = 3e5; % number of sampled descriptors for dictionary learning

%VOCAB_SIZES            = [4 8 16 24 32 48 64];
VOCAB_SIZES            = 32;

% Training set size for kmeans 
VOCAB_TRAININGSET_SIZE = 3e5;
VOCAB_TRAIN_NITER      = 250;
VOCAB_TRAIN_REPEATS    = 5;
VOCAB_TRAIN_OUTLIERS   = 0.01;

% How to normalize the descriptor vector 
% Can be 'none', 'L1' or 'L2'
DESCRIPTOR_NORMALIZATION = 'L2';
SIGMA_SCALE              = 2;

DescriptorType = 'Stacked'; % Stacked
AssignmentType = 'Soft';

% llc number of nearest neighbor
LLC_knn = 5;

% KSVD sparse coding
ksvd_dictsize = 200;
ksvd_Tdata = 5; % sparsity level
ksvd_iternum = 20;

% shape dna
num_evals_dna = 12;

%% load dir for data
%DATA_ROOT_DIR           = fullfile(pwd, '../../data/SHREC');

PROJECT_ROOT_DIR        = get_father_dic(pwd,2);
DATA_ROOT_DIR           = fullfile(PROJECT_ROOT_DIR, '/data/',DATASET);
%DATA_ROOT_DIR           = get_father_dic(DATA_ROOT_DIR,2);

% Relative data directories

OFF_DIR                 = fullfile(DATA_ROOT_DIR, 'off');
MESH_DIR                = fullfile(DATA_ROOT_DIR, 'mesh');
GROUNDTRUTH_DIR         = fullfile(DATA_ROOT_DIR, 'groundtruth');
EIGENSYSTEM_DIR         = fullfile(DATA_ROOT_DIR, ['eigensystem.' LB_PARAM]);
EVECS_DIR               = fullfile(DATA_ROOT_DIR, ['evecs.' LB_PARAM]);
DESC_DIR                = fullfile(DATA_ROOT_DIR, ['descriptors.' LB_PARAM]);
PD_DIR                  = fullfile(DATA_ROOT_DIR, ['pd.' LB_PARAM]);
REEBGRAPH_DIR           = fullfile(DATA_ROOT_DIR, ['reebgraph' LB_PARAM]);
VOCAB_DIR               = fullfile(DATA_ROOT_DIR, ['vocabs.' LB_PARAM]);
SC_CODE_DIR             = fullfile(DATA_ROOT_DIR, ['sc_codes.' LB_PARAM]);
PATHS_CODE_DIR          = fullfile(DATA_ROOT_DIR, ['pathscodes.' LB_PARAM]);
BOF_DIR                 = fullfile(DATA_ROOT_DIR, ['bofs.' LB_PARAM]);
SS_BOF_DIR              = fullfile(DATA_ROOT_DIR, ['ssbofs.' LB_PARAM]);
LLC_CODE_DIR            = fullfile(DATA_ROOT_DIR, ['llc_codes.' LB_PARAM]);
KSVD_CODE_DIR           = fullfile(DATA_ROOT_DIR, ['ksvd_codes.' LB_PARAM]);
STATISTIC_CODE_DIR      = fullfile(DATA_ROOT_DIR, ['statistic_codes.' LB_PARAM]);
DIST_DIR                = fullfile(DATA_ROOT_DIR, ['distance.' LB_PARAM]);
PERF_DIR                = fullfile(DATA_ROOT_DIR, ['perf.' LB_PARAM]);
FIG_DIR                 = fullfile(DATA_ROOT_DIR, 'fig');

% 
Specific_DESC_DIR       = fullfile(DESC_DIR, DescriptorType);

Specific_DESC_PD_DIR    = fullfile(PD_DIR, DescriptorType);

Hard_BOF_DIR            = fullfile(BOF_DIR, DescriptorType,'hard');
Soft_BOF_DIR            = fullfile(BOF_DIR, DescriptorType,'soft');

Hard_SS_BOF_DIR            = fullfile(SS_BOF_DIR, DescriptorType,'hard');
Soft_SS_BOF_DIR            = fullfile(SS_BOF_DIR, DescriptorType,'soft');

Specific_LLC_CODE_DIR            = fullfile(LLC_CODE_DIR, DescriptorType);
Specific_SC_CODE_DIR             = fullfile(SC_CODE_DIR, DescriptorType);

Specific_KSVD_CODE_DIR                  = fullfile(KSVD_CODE_DIR, DescriptorType);
Specific_SELF_STATISTIC_CODE_DIR        = fullfile(STATISTIC_CODE_DIR, DescriptorType,'self');
Specific_DICT_STATISTIC_CODE_DIR        = fullfile(STATISTIC_CODE_DIR, DescriptorType,'dict');

REEBGRAPH_level_DIR                 = fullfile(REEBGRAPH_DIR,['num_levelsets_',num2str(num_levelsets)]); 
Specific_PATHS_CODE_level_DIR       = fullfile(PATHS_CODE_DIR,['num_levelsets_',num2str(num_levelsets)],DescriptorType); 


%% load dir for code

% Root directory for code
SCRIPTS_ROOT_DIR        = fullfile(PROJECT_ROOT_DIR, '/scripts/');
CODE_ROOT_DIR           = fullfile(SCRIPTS_ROOT_DIR, 'common');

% Set path for proposed code


% Set path for auxilary code

addpath(CODE_ROOT_DIR);
addpath(fullfile(SCRIPTS_ROOT_DIR, 'evaluation'));
addpath(fullfile(CODE_ROOT_DIR, 'utils'));                  % generic utilities
addpath(genpath(fullfile(CODE_ROOT_DIR, 'laplacian')));     % mesh Laplacian
addpath(genpath(fullfile(CODE_ROOT_DIR, 'sgwt_toolbox')));  % spectral graph wavelets
addpath(genpath(fullfile(CODE_ROOT_DIR, 'reebgraph')));     % reeb graph 
addpath(fullfile(CODE_ROOT_DIR, 'descriptors'));            % scale space & descriptors
addpath(fullfile(CODE_ROOT_DIR, 'vq'));                     % vector quantization
addpath(fullfile(CODE_ROOT_DIR, 'pd'));                     % persistent diagram

% addpath(fullfile(CODE_ROOT_DIR, 'bofs'));                 % bags of features
addpath(fullfile(CODE_ROOT_DIR, 'meshcodes'));              % basic mesh processing code
addpath(pwd);


Meshes = dir(fullfile(MESH_DIR, '*.mat'));
SHAPES = {Meshes.name};
