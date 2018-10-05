function [tx, ux, ty, uy, f, normg, iter, local_stress] = minimize_stress1 (mesh_x, embed_x, mesh_y, embed_y, tx, ux, ty, uy, W, opt)

% Setup optimization options

if nargin < 10,
    opt = [];
end

if ~isfield(opt,'minextrelchange'),     minextrelchange   = 0.001;  else    minextrelchange = opt.minextrelchange;      end
if ~isfield(opt,'extiter'),             extiter   = 2;              else    extiter = opt.extiter;                      end
if extiter < 1, extiter = 1; end

% Verbosity
% 0 - silent, 1 - final result, 2 - outeriter, 3 - inner iter
if ~isfield(opt,'verbose'),             verbose   = 1;              else    verbose = opt.verbose;                      end    
if verbose < 3, opt.verbose = 0; end


% Format input
%ux = [ux(:,1:2) 1-sum(ux(:,1:2),2)];
%uy = [uy(:,1:2) 1-sum(uy(:,1:2),2)];
ux = ux(:,1:2);
uy = uy(:,1:2);


% Set weights
if isempty(W) | nargin < 9,  W = ones(length(tx)); end


f = Inf;
for iter = 1:extiter,
    
    fold = f;

    if mod(iter,2),

        % Embed X->Y
        D  = lininterp_symm (ux, tx, mesh_x, embed_x);
        
%        warning off;
%        W = 1./(D.^2);
%        W(isnan(W) | isinf(W)) = 0;
%        warning on;
        
        [ty,uy,f,normg,niter] = minimize_stress(mesh_y, embed_y, ty, uy, D, W, opt);
    
    else
        
        % Embed Y->X
        D  = lininterp_symm (uy, ty, mesh_y, embed_y);

%        warning off;
%        W = 1./(D.^2);
%        W(isnan(W) | isinf(W)) = 0;
%        warning on;
        
        [tx,ux,f,normg,niter] = minimize_stress(mesh_x, embed_x, tx, ux, D, W, opt);
    
    end

    relchange = (fold-f)/f;
    
    if verbose > 1 & ~isinf(relchange) & ~isnan(relchange),
        fprintf(1,' %4d \t f = %8.6g \t |g| = %8.6f \t iters = %4d \t rel. change = %6.2g\n', iter, f, normg, niter, relchange);
    elseif verbose > 1,
        fprintf(1,' %4d \t f = %8.6g \t |g| = %8.6f \t iters = %4d\n', iter, f, normg, niter);
    end
    
    % Relative change is small enough
    if relchange < minextrelchange,
        if verbose > 0, 
            fprintf(1, 'Relative stress change reached %6.2g < %6.2g\nOptimization terminated\n', relchange, minextrelchange);
        end
        break;
    end

end

% Maximum number of iterations reached
if relchange >= minextrelchange & iter >= extiter & verbose > 0,
    fprintf(1, 'Iteration count exceeded %d\nOptimization terminated\n', extiter);
end        

if nargout >= 8,
    D  = lininterp_symm (uy, ty, mesh_y, embed_y);
    [f_, g1_, g2_, H11_, H12_, H22_, local_stress] = stress_symm (ux, tx, mesh_x, embed_x, D, W);
end

