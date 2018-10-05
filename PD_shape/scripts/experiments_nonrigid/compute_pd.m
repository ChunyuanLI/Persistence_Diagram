
% 09/01/2014
% This script aims to compute the descriptor
%
% 

%%
% load settings
setting_up_shrec2010_nonrigid_s;

warning off;
mkdir(Specific_DESC_PD_DIR);
warning on;   


% Statistics
tic;
nerr  = 0;
nskip = 0;
nok   = 0;  
fprintf(1, 'Compute the PDs of the gesture...\n');

tic
for s =  1:length(SHAPES), 
    
    shapename = SHAPES{s};
    fprintf(1, '  %-30s \t ', shapename);

    
    
    % load descriptors
    load(fullfile(Specific_DESC_DIR, shapename), 'desc');
    
    % connectivity construction
    load(fullfile(MESH_DIR, shapename));
    ringv = mesh_ringv(vertices, faces);
    

    % compute pd
    tau = 10; % infinite
    scalar_value = desc;
    
    [LeefItem,LeefTable,Durations,Merged_forest] = ...
        persistence_computing(vertices,ringv,scalar_value, tau);   
    
    PDs = {};
    for i = 1:length(Durations)
        Duration = Durations{i};
        PDs = [PDs; {Duration(:,3:-1:2)}]; % points are above the diagonal in comparison
    end
    
    % save result
    save(fullfile(Specific_DESC_PD_DIR, shapename), 'PDs');

    str = fprintf('PD of %s is extracted.\n', shapename);
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
