function visualize_surf(mesh_x, tx,ux, col)%idx0, col)

if 0,
    ux = zeros(length(idx0), 3);
    tx = zeros(length(idx0), 1);    
    for k=1:length(idx0),
        idx1 = find(mesh_x.TRIV(:,1) == idx0(k));
        idx2 = find(mesh_x.TRIV(:,2) == idx0(k));
        idx3 = find(mesh_x.TRIV(:,3) == idx0(k));
        idx = [[idx1(:) idx1(:)*0 + 1]; [idx2(:) idx2(:)*0 + 2]; [idx3(:) idx3(:)*0 + 3];];
        idx = idx(1,:);
        tx(k) = idx(1);
        ux(k,idx(2)) = 1;
    end
end

    

        u0 = ones(size(mesh_x.TRIV,1),3)/3;
        t0 = 1:size(mesh_x.TRIV,1);
        d = lininterp(ux,tx, u0,t0, mesh_x, mesh_x);
        [d,c] = min(d,[],1);

        c = col(c);
trisurf(mesh_x.TRIV, mesh_x.X, mesh_x.Y, mesh_x.Z, c); axis image; axis off;
if length(c) == length(mesh_x.Z),
    shading interp;
else
    shading flat; 
end

lighting phong; 

if 0,

view([0 90]);
camlight head;
view([0 90+120]);
camlight head;
view([0 90+240]);
camlight head;
view([0 90]);

view([0 0]);
end

%if nargin > 2,
%    [x,y,z] = barycentric_to_extrinsic(mesh_x,tx,ux);
%elseif nargin == 2,
%    x = mesh_x.X(tx);
%    y = mesh_x.Y(tx);
%    z = mesh_x.Z(tx);
%end

if nargin >= 2,
    [x,y,z] = barycentric_to_extrinsic(mesh_x,tx,ux);
    hold on; 
    for k=1:length(x),
        plot3(x(k),y(k),z(k),'.k');
        text(x(k),y(k),z(k),sprintf(' %d',k));
    end
    hold off;
end

function [x,y,z] = barycentric_to_extrinsic(mesh_x, tx, ux)

ux = [ux(:,1:2) 1-sum(ux(:,1:2),2)];
idxv = mesh_x.TRIV(tx,:);
x = mesh_x.X(idxv);
y = mesh_x.Y(idxv);
z = mesh_x.Z(idxv);
x = sum(x.*ux,2);
y = sum(y.*ux,2);
z = sum(z.*ux,2);



