function [d, d_um1, d_um2, dd_um1_um1, dd_um1_um2, dd_um2_um2] = lininterp_symm(um,tm, mesh, embed)

% m = length(tm);
% 
% 
% % d = um(:,1)*ones(1,m) + ones(m,1)*um(:,1)' + um(:,2)*ones(1,m) + ones(m,1)*um(:,2)';
% % d_um1 = ones(m,m) + eye(m,m);
% % d_um2 = ones(m,m) + eye(m,m);
% 
% q = 1:m;
% r = m:-1:1;
% d = um(:,1)*q + q'*um(:,1)'   +  um(:,2)*r + r'*um(:,2)'; % + um(:,2)*ones(1,m) + ones(m,1)*um(:,2)';
% 
% d_um1 = repmat(q,[m 1]);
% d_um2 = repmat(r,[m 1]);
% %d_um1 = d_um1+diag(diag(d_um1));
% %d_um2 = zeros(m,m);
% 
% 
% dd_um1_um1 = zeros(m,m);
% dd_um1_um2 = zeros(m,m);
% dd_um2_um2 = zeros(m,m);
% 
% 
% return;

[d, d_um1, d_um2, d_un1, d_un2,  dd_um1_un1, dd_um1_un2, dd_um2_un1, dd_um2_un2] = lininterp(um,tm, um,tm, mesh, embed);

m = length(tm);

M = 0.5*ones(m,m);
M = M+diag(diag(M));

d_um1 = (d_um1+d_un1').*M;
d_um2 = (d_um2+d_un2').*M;

dd_um1_um1 = dd_um1_un1.*M*2;
dd_um1_um2 = dd_um1_un2.*M*2;
dd_um2_um2 = dd_um2_un2.*M*2;
 
