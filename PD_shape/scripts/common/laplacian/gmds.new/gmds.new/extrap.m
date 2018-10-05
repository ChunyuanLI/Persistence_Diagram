function x_ = extrap(XX)
dX  = XX(:,2:end-1) - XX(:,1:end-2);
d2X = XX(:,3:end) - 2*XX(:,2:end-1) + XX(:,1:end-2);
Y   = d2X; 

x_ = XX(:,1) - dX * inv(Y'*d2X) * (Y'*dX(:,1));
return
