function [f, g1, g2, H11, H12, H22, local_stress] = stress_symm (um, tm, mesh, embed, D, W)

if nargout == 1,
    [d] = lininterp_symm(um,tm, mesh, embed);
elseif nargout == 2,
    [d, d_um1, d_um2] = lininterp_symm(um,tm, mesh, embed);
else
    [d, d_um1, d_um2, dd_um1_um1, dd_um1_um2, dd_um2_um2] = lininterp_symm(um,tm, mesh, embed);
end

m = length(tm);

if nargin < 6,
   W = ones(m,m) / (m^2-m);
end

W = W-diag(diag(W));

% Function
f = W.*(d-D).^2;
f = sum(f(:));


% Compute gradient
if nargout > 1,
    g1 = 4*sum(W.*(d-D).*d_um1, 2); 
    g2 = 4*sum(W.*(d-D).*d_um2, 2);
end

% Compute Hessian
if nargout > 2,
    H11 = 4*d_um1.*d_um1'.*W + 4*W.*(d-D).*dd_um1_um1;
    H11 = H11 + diag(4*sum( W.*d_um1.^2 , 2));
    
    H12 = 4*d_um2.*d_um1'.*W + 4*W.*(d-D).*dd_um1_um2';
    H12 = H12 + diag(4*sum( W.*d_um1.*d_um2 , 2));

    H22 = 4*d_um2.*d_um2'.*W + 4*W.*(d-D).*dd_um2_um2;
    H22 = H22 + diag(4*sum( W.*d_um2.^2 , 2));
end

local_stress = (d-D).^2;
local_stress = local_stress-diag(diag(local_stress));

