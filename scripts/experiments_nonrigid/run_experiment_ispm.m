%
    
    clear all
    clc
    %setting_up_synthetic
    setting_up_shrec2010_nonrigid_s     % 0. Settings
    % compute_LB_eigen                  % 1. Compute LB eigendecomposition
    % compute_descriptor                  % 2. Compute descriptors
    % stack_descriptors
    compute_dictionary_kmeans           % 3. Compute vocabularies
    compute_vq_codes                    % 4. Compute vq code with ISPM
    compute_distance                    % 5. Compute distance of vq code

    evaluate_ispm_bof                   % 6. evaluation
