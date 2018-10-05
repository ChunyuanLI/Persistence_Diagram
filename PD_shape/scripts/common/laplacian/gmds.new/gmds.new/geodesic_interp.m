% [ty, uy] = geodesic_interp (mesh_x, embed_x, mesh_y, embed_y, tx, ux, ty0, uy0)
%
% Geodesic interpolation.
% Given a set of n points Ux = {u_1,...,u_n} on X, and a set of m<n points 
% Uy = {v_1,...,v_m} such that each v_i corresponds to u_i, complete Uy to 
% {v_1,...,v_m,v_{m+1},...,v_n}.
%
% Input:  mesh_x, embed_x - representation of the surface X
%         mesh_y, embed_y - representation of the surface Y
%         tx, ux - barycentric coordinates of n points in Ux.
%         ty0, uy0 - barycentric coordinates of y points in Uy.
% Output: (ty,uy) - barycentric coordinates of the completed set of n
%         points in Y; ty(1:m) = ty0, uy(1:m) = uy0.
%
% (C) Alex Bronstein, 2005-2007. All rights reserved.

function [ty,uy] = geodesic_interp (surface_x, surface_y, tx, ux, ty0, uy0)

tx0 = tx(1:length(ty0));
ux0 = ux(1:length(ty0),:);
tx1 = tx(length(ty0)+1:end);
ux1 = ux(length(ty0)+1:end,:);

Dx = lininterp (ux0,tx0, ux1,tx1, surface_x, surface_x);


uy = zeros(length(surface_y.X),3);
ty = zeros(length(surface_y.X),1);
for v = 1:length(ty),
    ty(v) = surface_y.VTRI{v}(1);
    idxv = surface_y.TRIV(ty(v),:);
    idx = find(idxv == v);
    uy(v,idx) = 1;
end

Dy = lininterp (uy0,ty0, uy,ty, surface_y, surface_y);

err = zeros(length(tx1),1);
idx = zeros(length(tx1),1);

% Find best vertices
for v = 1:length(tx1),

    dx = Dx(:,v);
    e = sum((Dy-repmat(dx,[1 size(Dy,2)])).^2,1);
    
    [e,idx_] = min(e);
    err(v) = e;
    idx(v) = idx_;
    
end

% Refine vertices
uy1 = zeros(length(tx1), 2);
ty1 = zeros(length(tx1), 1);

for vv = 1:length(tx1),

    v = idx(vv);
    
    F = zeros(length(surface_y.VTRI{v}),3);

    for t=1:length(surface_y.VTRI{v}),

        idxt = surface_y.VTRI{v}(t);
        idxv = surface_y.TRIV(idxt,:);
        dy = Dy(:,idxv);
        D = [dy(:,1)-dy(:,3) dy(:,2)-dy(:,3)];
        delta = Dx(:,vv);
        d = dy(:,3)-delta;

        H = 2*D'*D;
        b = 2*D'*d;
        u0 = [1; 1]/3;
        g  = H*u0 + b;
        f0 = 0.5*u0'*H*u0 + b'*u0 + d'*d;

        [u, f] = solve_newton (H, g, u0', f0);

        F(t,:) = [u f];

    end

    [f,idxt] = min(F(:,end));
    u = F(idxt,1:2);
    idxt = surface_y.VTRI{v}(idxt);

    ty1(vv) = idxt;
    uy1(vv,:) = u;

end

uy1 = [uy1 1-sum(uy1,2)];
uy0 = [uy0(:,1:2) 1-sum(uy0(:,1:2),2)];

ty = [ty0; ty1];
uy = [uy0; uy1];



