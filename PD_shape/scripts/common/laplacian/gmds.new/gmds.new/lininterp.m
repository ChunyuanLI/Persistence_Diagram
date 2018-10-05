function [d,  d_um1, d_um2, d_un1, d_un2,  dd_um1_un1, dd_um1_un2, dd_um2_un1, dd_um2_un2] = lininterp(um,tm, un,tn, mesh, embed)


m = length(tm);
n = length(tn);

Vm = mesh.TRIV(tm,:);
Vn = mesh.TRIV(tn,:);

d11 = embed.D(Vm(:,1), Vn(:,1));
d12 = embed.D(Vm(:,1), Vn(:,2));
d13 = embed.D(Vm(:,1), Vn(:,3));

d21 = embed.D(Vm(:,2), Vn(:,1));
d22 = embed.D(Vm(:,2), Vn(:,2));
d23 = embed.D(Vm(:,2), Vn(:,3));

d31 = embed.D(Vm(:,3), Vn(:,1));
d32 = embed.D(Vm(:,3), Vn(:,2));
d33 = embed.D(Vm(:,3), Vn(:,3));


um1 = um(:,1);
um2 = um(:,2);
um3 = 1-um1-um2;

un1 = un(:,1);
un2 = un(:,2);
un3 = 1-un1-un2;

um1 = repmat(um1,[1 n]);
um2 = repmat(um2,[1 n]);
um3 = repmat(um3,[1 n]);

un1 = repmat(un1',[m 1]);
un2 = repmat(un2',[m 1]);
un3 = repmat(un3',[m 1]);

d1 = um1.*d11 + um2.*d21 + um3.*d31;
d2 = um1.*d12 + um2.*d22 + um3.*d32;
d3 = um1.*d13 + um2.*d23 + um3.*d33;

% Distance matrix
d  = un1.*d1 + un2.*d2 + un3.*d3;


% Gradients
%dd(i,j) / dumk(m) =  {  d_umk(m,j)     : i == m
%                     {  0              : i != m
%dd(i,j) / dunk(n) =  {  d_unk(i,n)     : j == n
%                     {  0              : j != n

if nargout > 1,
    d1_um1 = d11-d31;
    d2_um1 = d12-d32;
    d3_um1 = d13-d33;
    d_um1 = un1.*d1_um1 + un2.*d2_um1 + un3.*d3_um1;
end

if nargout > 2,
    d1_um2 = d21-d31;
    d2_um2 = d22-d32;
    d3_um2 = d23-d33;    
    d_um2 = un1.*d1_um2 + un2.*d2_um2 + un3.*d3_um2;
end


if nargout > 3,
    d_un1 = d1 - d3;
end

if nargout > 4,
    d_un2 = d2 - d3;
end


% Mixed second-order derivatives
% d^2d(i,j) / dumk(m) dunl(n)

if nargout > 5,
    dd_um1_un1 = d11 - d31 - d13 + d33;
end

if nargout > 6,
    dd_um1_un2 = d12 - d32 - d13 + d33;
end

if nargout > 7,
    dd_um2_un1 = d21 - d31 - d23 + d33;
end

if nargout > 8,
    dd_um2_un2 = d22 - d32 - d23 + d33;
end

