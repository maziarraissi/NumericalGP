function K=DkDx(x, y, hyp, i)

logsigma = hyp(1);
logtheta = hyp(2);

n_x = size(x,1);
n_y = size(y,1);

x = x*ones(1,n_y);
y = ones(n_x,1)*y';

if i==0 || i==1

	K = exp(1).^(logsigma+(-1).*logtheta+(-1/2).*exp(1).^((-1).*logtheta) ...
  .*(x+(-1).*y).^2).*((-1).*x+y);

elseif i== 2

	K = (1/2).*exp(1).^(logsigma+(-2).*logtheta+(-1/2).*exp(1).^((-1).* ...
logtheta).*(x+(-1).*y).^2).*(2.*exp(1).^logtheta+(-1).*(x+(-1).*y) ...
  .^2).*(x+(-1).*y);
  
end

end