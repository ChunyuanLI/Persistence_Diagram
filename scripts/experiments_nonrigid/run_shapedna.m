

setting_up_shrec2010_nonrigid_s;

num_shapes = length(SHAPES);

% 1. load eigen values
feature1 = [];
str = '';
for s = 1:length(SHAPES), 

    shapename = SHAPES{s};
    str = mprintf(str, '%s', shapename);    
    
    % Load eigendecomposition
    load(fullfile(EVECS_DIR, shapename), 'evals');
    feature1 = [feature1, evals]; 
end    
str = mprintf(str, '\n');  

% 2. compute distance
warning off;
mkdir(DIST_DIR);
warning on;   

fea1 = feature1(1:num_evals_dna,:)';
D = pdist2(fea1,fea1,'euclidean');

fea1_n = feature1(1:num_evals_dna,:)';
fea1_n = fea1_n./repmat(fea1_n(:,2),1,num_evals_dna);
D_n = pdist2(fea1_n,fea1_n,'euclidean');

% 3. Save result
save(fullfile(DIST_DIR, ['distance_shapeDNA' num2str(num_evals_dna) '.mat']), 'D', 'D_n','num_evals_dna');

% 4. evaluate
load('GroundTruth_SHREC2010.mat');

fprintf('Shape DNA with the first %dth eigenvalues.\n', num_evals_dna);
Evaluation_DistanceMatrix(D,GroundTruth);

fprintf('Shape DNA with the normalized first %dth eigenvalues.\n', num_evals_dna);
Evaluation_DistanceMatrix(D_n,GroundTruth);
