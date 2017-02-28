% PARAMETERS_SS_shrec2010_nonrigid

switch DescriptorType
      
    case 'GPS'
        start_eval = 2;
        end_eval = n_eigenvalues;
        
    case 'HKS'
        t0 =  70.24;
        alpha1 = 1.24; 
        tauScale = 15; 
        tau = 6:(1/1):tauScale;   
    case 'HKS_C'  % HKS Coordinates
        t0 =  0.01; 
        alpha1 = 4;  
        tauScale = 5; 
        
    case 'SIHKS'
        t0 = 1; 
        TimeScale = 25;   
        alpha1 =  2;
        tau = 0:(1/16):TimeScale; 
        numF = 17;

    case 'WKS'        
        N = 10; 
        wks_variance = N* 0.05; 
    case 'WKSn'        
        N = 10; 
        wks_variance = N* 0.05; 
    
    case 'SGWS'
        Nscales = 2;
        designtype='abspline3';
        %esigntype='mexican_hat';
        %designtype='meyer';
        %designtype='simple_tf';
end