% PARAMETERS_SS_shrec2011_nonrigid

switch DescriptorType
    
    case 'GPS'
        start_eval = 2;
        end_eval = n_eigenvalues;
        
    case 'HKS'
        t0 =  1024;
        alpha1 = 1.32; 
        tauScale = 5; 
        tau = 0:1:tauScale;   
    case 'HKS_C'  % HKS Coordinates
        t0 =  0.01; 
        alpha1 = 4;  
        tauScale = 5; 
        
    case 'SIHKS'
        t0 =  1;%1024; 
        TimeScale = 25;   
        alpha1 =  2;
        tau = 1:(1/16):TimeScale; 
        numF = 5;
    case 'WKS'        
        N = 10; 
        wks_variance = N* 0.05; 
    
    case 'SGWS'
        Nscales = 2;
        designtype='abspline3';
        %esigntype='mexican_hat';
        %designtype='meyer';
        %designtype='simple_tf';

end