%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% solving constraint optimization problem using Newton-Raphson method
%
% Eric Xing
% UC Berkeley
% Jan 15, 2002
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function A = Newton(data, S, D, C)

size_data=size(data);
N=size_data(1);
d=size_data(3);

a=ones(d,1);
X=data;

fudge = 0.00001;
threshold1 = 0.02;
reduction = 1.5;

% suppose d is a column vector
% sum(d'Ad) = sum(trace(d'Ad)) = sum(trace(dd'A)) 
%           = trace(sum(dd'A) = trace(sum(dd')A)

s_sum = zeros(1,d);
d_sum = zeros(1,d);
for i = 1:N
  for j = i+1:N
      d_ij = X(i,j,:); %X(i,:) - X(j,:);
      d_ij = d_ij(:)';
    if S(i,j) == 1
      s_sum = s_sum + d_ij.^2;
    elseif D(i,j) == 1
      d_sum = d_sum + d_ij.^2;
    end
  end
end 


tt=1;
error=1;
while error > threshold1

  [fD0, fD_1st_d, fD_2nd_d] = D_constraint(X, D, a, N, d);
  obj_initial =  s_sum*a + C*fD0; 
  fS_1st_d = s_sum;                    % first derivative of the S constraints

  Gradient = fS_1st_d - C*fD_1st_d;            % gradient of the objective
  Hessian = - C*fD_2nd_d + fudge*eye(d);       % Hessian of the objective
  invHessian = inv(Hessian);
  step = invHessian*Gradient';

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Newton-Raphson update
  % search over optimal lambda
  
  lambda= 2e-1;        % initial step-size
  t=1;             % counter
  atemp = a - lambda*step;
  atemp = max(atemp, 0);

  obj = s_sum*atemp + C*D_objective(X, D, atemp, N, d);
  obj_previous = obj * 1.1;    %  just to get the while loop started

  while obj < obj_previous
    lambda_previous = lambda;
    obj_previous = obj;
    a_previous = atemp;
    lambda = lambda/reduction; 
    atemp = a - lambda*step;
    atemp = max(atemp, 0);
    obj = s_sum*atemp + C*D_objective(X, D, atemp, N, d);
    t=t+1;   % inner counter
  end    % line search for lambda that minimize obj
  
  a = a_previous;
  
  error = abs((obj_previous - obj_initial)/obj_previous);
  tt = tt + 1   % outer counter
  
end
A=diag(a);
