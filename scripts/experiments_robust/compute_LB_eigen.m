
% 16/12/2013

% load settings
setting_up_robust;

Meshes = dir(fullfile(MESH_DIR, '*.mat'));
Meshes = {Meshes.name};
SHAPES = Meshes;

% Current reference shape
curr_refname = '';

% Statistics
tic;
nerr  = 0;
nskip = 0;
nok   = 0;  
fprintf(1, 'Compute the LB eigensystem of the mesh...\n');

warning off;
mkdir(EVECS_DIR);
mkdir(EIGENSYSTEM_DIR);
warning on;    

tic
for s =  1:length(SHAPES), 
    
    shapename = SHAPES{s};
    fprintf(1, '  %-30s \t ', shapename);
    
    if SKIP_EXISTING && exist(fullfile(EVECS_DIR, shapename), 'file'),
        fprintf(1, 'file already exists, skipping\n');
        nskip = nskip+1;
        continue;
    end


    % Load shape [vertices, faces]
    load(fullfile(MESH_DIR, shapename));
    
    %shape = mesh2shape(vertices, faces);

    % Compute the LB eigensystem
    
    try
        num_vert = length(shape.X);
        num_evecs = min(num_vert - 1, max_num_evecs);
        switch(LB_PARAM)
            case('cot')
                [evecs, evals, W, A] = main_mshlp('cotangent', shape, num_evecs);
            otherwise
                assert(0);
        end
    catch
        fprintf(1, 'error computing eigendecomposition, skipping\n');
        nerr = nerr+1;
        continue;
    end

 
    % Save result
    save(fullfile(EVECS_DIR, shapename), ...
         'evecs', 'evals');
    save(fullfile(EIGENSYSTEM_DIR, shapename), ...
         'shape', 'W', 'A', 'evecs', 'evals');

    str = fprintf('%s is eigendecomposited.\n', shapename);
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
