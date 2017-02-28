function [u, f, idx] = solve_newton (H, g, um, f00)
% idx = 1 - Current solution (um)
%       2 - No active constrains
%       3 - u1 = 0
%       4 - u2 = 0
%       5 - u3 = 0
%       6 - u1=0 & u2=0
%       7 - u1=0 & u3=0
%       8 - u2=0 & u3=0

b = g-H*um';


fi = 0.5*um*H*um' + b'*um';

% No active constrains
d  = (H(1,1)*H(2,2)-H(1,2)^2); % Hessian determinant
if d == 0,
   H = H + eye(2,2)*1e-8; 
   d  = (H(1,1)*H(2,2)-H(1,2)^2); % Hessian determinant
end

u0 = -[H(2,2) -H(1,2); -H(1,2) H(1,1)]*b/d;
f0 = 0.5*u0'*H*u0 + b'*u0;
c0 = u0(1)>0 & u0(2)>0 & u0(1)+u0(2)<1;

% u1 = 0 is active
u1 = [0 -b(2)/H(2,2)]';
f1 = 0.5*u1'*H*u1 + b'*u1;
c1 = u1(2)>0 & u1(1)+u1(2)<1;

% u2 = 0 is active
u2 = [-b(1)/H(1,1) 0]';
f2 = 0.5*u2'*H*u2 + b'*u2;
c2 = u2(1)>0 & u2(1)+u2(2)<1;

% u1+u2 = 1 is active
u  = -(H(1,2)+b(1)-H(2,2)-b(2))/(H(1,1)-2*H(1,2)+H(2,2));
u3 = [u 1-u]';
f3 = 0.5*u3'*H*u3 + b'*u3;
c3 = u3(1)>0 & u3(2)>0;

% u1 = 0 & u2 = 0 are active
u4 = [0 0]';
f4 = 0;

% u1 = 0 & u1+u2 = 1 are active
u5 = [0 1]';
f5 = 0.5*u5'*H*u5 + b'*u5;

% u2 = 0 & u1+u2 = 1 are active
u6 = [1 0]';
f6 = 0.5*u6'*H*u6 + b'*u6;

f = [fi f0 f1 f2 f3 f4 f5 f6];
u = [um' u0 u1 u2 u3 u4 u5 u6];
c = [1 c0 c1 c2 c3 1  1  1];

f(c==0) = Inf;

if nargin > 3,
    c = f00-fi;
    f = f+c;
end

[f, idx] = min(f);

u = u(:,idx)';

