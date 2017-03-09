function K = knn1(x, y, hyp, uny, i)
global ModelInfo;

nu = ModelInfo.nu;
dt = ModelInfo.dt;

logsigma = hyp(1);
logtheta = hyp(2:end);
nn = size(x,1);

if (i==0 || i==1)
    
    K = exp(1).^(logsigma+(-2).*logtheta+(-1/2).*exp(1).^((-1).*logtheta) ...
        .*bsxfun(@minus,x,y').^2).*(exp(1).^(2.*logtheta)+(-1).*dt.*nu.*bsxfun(@minus,x,y').^2+...
        dt.*exp(1).^logtheta.*(nu+bsxfun(@minus,x,y').*(ones(nn,1)*uny')));
    
    
elseif i==2
    
    K = (1/2).*exp(1).^(logsigma+(-2).*logtheta+(-1/2).*exp(1).^((-1).* ...
        logtheta).*bsxfun(@minus,x,y').^2).*(exp(1).^((-1).*logtheta).*(exp(1).^( ...
        2.*logtheta).*((-2).*dt.*nu+bsxfun(@minus,x,y').^2)+5.*dt.*exp(1) ...
        .^logtheta.*nu.*bsxfun(@minus,x,y').^2+(-1).*dt.*nu.*bsxfun(@minus,x,y').^4)+dt.*( ...
        (-2).*exp(1).^logtheta+bsxfun(@minus,x,y').^2).*bsxfun(@minus,x,y').*(ones(nn,1)*uny'));
end

end

