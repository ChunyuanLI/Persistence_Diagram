
% 16/12/2013
% This script aims to compute the spectral descriptor
% It includes: GPS HKS WKS SIHKS HMS SGWS
% The parameters for different dataset given in files: 
% PARAMETERS_SS_shrec2011_nonrigid
% PARAMETERS_SS_shrec2011_nonrigid
%%
% 

%%
% load settings
setting_up_shrec2010_nonrigid_s;

warning off;
mkdir(Specific_DESC_DIR);
warning on;   

% Statistics
tic;
nerr  = 0;
nskip = 0;
nok   = 0;  
fprintf(1, 'Compute the spectral descriptor of the mesh...\n');

tic
for s =  1:length(SHAPES), 
    
    shapename = SHAPES{s};
    fprintf(1, '  %-30s \t ', shapename);
    
    if SKIP_EXISTING && exist(fullfile(Specific_DESC_DIR, shapename), 'file'),
        fprintf(1, 'file already exists, skipping\n');
        nskip = nskip+1;
        continue;
    end

    % Load eigendecomposition
    load(fullfile(EVECS_DIR, shapename), 'evecs', 'evals');

    % Compute spectral descriptors
    desc = Get_Signature(evecs, evals,DescriptorType,DATASET);
    
    % Save result
    save(fullfile(Specific_DESC_DIR, shapename), 'desc');

    str = fprintf('Spectral descriptor of %s is extracted.\n', shapename);
    nok = nok+1;

end
toc

% Statistics
fprintf(1, '\n LB Computation complete\n');
fprintf(1, ' Elapsed time:   %s\n', toc);
fprintf(1, ' Total Shapes:   %d\n', length(SHAPES));
fprintf(1, ' Average time:   %s\n', toc/length(SHAPES));
fprintf(1, ' Computed:       %d\n', nok);
fprintf(1, ' Skipped:        %d\n', nskip);
fprintf(1, ' Errors:         %d\n', nerr);
