
% 12/31/2013

% load settings
setting_up_synthetic;


OFFs = dir(fullfile(OFF_DIR, '*.obj'));
OFFs = {OFFs.name};
SHAPES = OFFs;

% Current reference shape
curr_refname = '';

% Statistics
tic;
nerr  = 0;
nskip = 0;
nok   = 0;  
fprintf(1, 'rename the mesh...\n');

warning off;
mkdir(MESH_DIR);
warning on;    


for s = 204% 1:length(SHAPES), 
    
    shapename = SHAPES{s};
    fprintf(1, '  %-30s \t ', shapename);
    
    if SKIP_EXISTING && exist(fullfile(MESH_DIR, shapename), 'file'),
        fprintf(1, 'file already exists, skipping\n');
        nskip = nskip+1;
        continue;
    end

    % Load shape
    [vertices, faces] = read_obj(fullfile(OFF_DIR, shapename));
    
    % Rename the mesh, and transform to mat files
    
    try
        faces = faces';
        vertices = vertices';
        NAME = shapename;
        l = length(NAME);
        if l == 5
            index = str2num(NAME((l-4):(l-3)));
            save([MESH_DIR,'\S00',NAME((l-4):(l-3)),'mat'],'faces','vertices');
        end
        if l == 6
            index = str2num(NAME((l-4):(l-3)));
            save([MESH_DIR,'\S0',NAME((l-5):(l-3)),'mat'],'faces','vertices');
        end
        if l == 7
            index = str2num(NAME((l-4):(l-3)));
            save([MESH_DIR,'\S',NAME((l-6):(l-3)),'mat'],'faces','vertices');
        end
    catch
        fprintf(1, 'error renaming the mesh, skipping\n');
        nerr = nerr+1;
        continue;
    end
    


    str = fprintf('%s is renamed and and in mat.\n', NAME);
    nok = nok+1;

end