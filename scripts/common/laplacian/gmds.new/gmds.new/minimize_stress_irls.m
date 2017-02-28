function [tx, ux, ty, uy, f, normg, iter, local_stress] = minimize_stress_irls (mesh_x, embed_x, mesh_y, embed_y, tx, ux, ty, uy, W0, p, opt)

if ~isfield(opt,'minirlsrelchange'),     minirlsrelchange   = 0.001;  else    minirlsrelchange = opt.minirlsrelchange;      end
if ~isfield(opt,'irlsiter'),             irlsiter   = 25;             else    irlsiter = opt.irlsiter;                      end

% Verbosity
% 0 - silent, 1 - final result, 2 - outeriter, 3 - inner iter
if ~isfield(opt,'verbose'),             verbose   = 1;              else    verbose = opt.verbose;                      end    


if p == 2,
   [tx, ux, ty, uy, f, normg, iter, local_stress] = minimize_stress1 (mesh_x, embed_x, mesh_y, embed_y, tx, ux, ty, uy, W0, opt);
   return;
end

if verbose < 3, opt.verbose = 0; end

W = W0;
f = Inf;
for iter = 1:irlsiter,
    fold = f;
    [tx, ux, ty, uy, f, normg, niter, local_stress] = minimize_stress1 (mesh_x, embed_x, mesh_y, embed_y, tx, ux, ty, uy, W, opt);
    
    relchange = (fold-f)/f;
    
    if verbose > 1 & ~isinf(relchange) & ~isnan(relchange),
        fprintf(1,' %4d \t f = %8.6g \t |g| = %8.6f \t iters = %4d \t rel. change = %6.2g\n', iter, f, normg, niter, relchange);
    elseif verbose > 1,
        fprintf(1,' %4d \t f = %8.6g \t |g| = %8.6f \t iters = %4d\n', iter, f, normg, niter);
    end    


    
    % Relative change is small enough
    if relchange < minirlsrelchange,
        if verbose > 0, 
            fprintf(1, 'Relative stress change reached %6.2g < %6.2g\nOptimization terminated\n', relchange, minirlsrelchange);
        end
        break;
    end    
    
    W = W0.*local_stress.^(p-2);
    
end


% Maximum number of iterations reached
if relchange >= minirlsrelchange & iter >= irlsiter & verbose > 0,
    fprintf(1, 'Iteration count exceeded %d\nOptimization terminated\n', irlsiter);
end      