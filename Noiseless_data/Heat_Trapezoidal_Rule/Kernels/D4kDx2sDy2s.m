function K=D4kDx2sDy2s(x, y, hyp, i)

logsigma = hyp(1);
logtheta1 = hyp(2);
logtheta2 = hyp(3);

n_x = size(x,1);
n_y = size(y,1);

x1 = x(:,1)*ones(1,n_y);
x2 = x(:,2)*ones(1,n_y);

y1 = ones(n_x,1)*y(:,1)';
y2 = ones(n_x,1)*y(:,2)';


if i==0 || i==1
    
    K = exp(1).^(logsigma+(-4).*logtheta2+(-1/2).*exp(1).^((-1).* ...
        logtheta1).*(x1+(-1).*y1).^2+(-1/2).*exp(1).^((-1).*logtheta2).*( ...
        x2+(-1).*y2).^2).*(3.*exp(1).^(2.*logtheta2)+(-6).*exp(1) ...
        .^logtheta2.*(x2+(-1).*y2).^2+(x2+(-1).*y2).^4);
    
elseif i== 2
    
    K = (1/2).*exp(1).^(logsigma+(-1).*logtheta1+(-4).*logtheta2+(-1/2).* ...
        exp(1).^((-1).*logtheta1).*(x1+(-1).*y1).^2+(-1/2).*exp(1).^((-1) ...
        .*logtheta2).*(x2+(-1).*y2).^2).*(x1+(-1).*y1).^2.*(3.*exp(1).^( ...
        2.*logtheta2)+(-6).*exp(1).^logtheta2.*(x2+(-1).*y2).^2+(x2+(-1).* ...
        y2).^4);
    
elseif i== 3
    
    K = (1/2).*exp(1).^(logsigma+(-5).*logtheta2+(-1/2).*exp(1).^((-1).* ...
        logtheta1).*(x1+(-1).*y1).^2+(-1/2).*exp(1).^((-1).*logtheta2).*( ...
        x2+(-1).*y2).^2).*((-12).*exp(1).^(3.*logtheta2)+39.*exp(1).^(2.* ...
        logtheta2).*(x2+(-1).*y2).^2+(-14).*exp(1).^logtheta2.*(x2+(-1).* ...
        y2).^4+(x2+(-1).*y2).^6);
    
end

end