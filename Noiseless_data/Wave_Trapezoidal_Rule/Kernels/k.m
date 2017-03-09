function K=k(x, y, hyp, i)

logsigma = hyp(1);
logtheta = hyp(2);

if i==0 || i==1

	K = exp(1).^(logsigma+(-1/2).*exp(1).^((-1).*logtheta).*bsxfun(@minus,x,y').^2);

elseif i== 2

	K = (1/2).*exp(1).^(logsigma+(-1).*logtheta+(-1/2).*exp(1).^((-1).*logtheta).*bsxfun(@minus,x,y').^2).*bsxfun(@minus,x,y').^2;
end

end