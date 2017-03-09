function K=LLk(x, y, hyp, i)

logsigma = hyp(1);
logtheta = hyp(2);

if i==0 || i==1

	K = exp(1).^(logsigma+(-4).*logtheta+(-1/2).*exp(1).^((-1).*logtheta).*bsxfun(@minus,x,y').^2).*(3.*exp(1).^(2.*logtheta)+(-6).*exp(1).^logtheta.*bsxfun(@minus,x,y').^2+bsxfun(@minus,x,y').^4);

elseif i== 2

	K = (1/2).*exp(1).^(logsigma+(-5).*logtheta+(-1/2).*exp(1).^((-1).*logtheta).*bsxfun(@minus,x,y').^2).*((-12).*exp(1).^(3.*logtheta)+39.*exp(1).^(2.*logtheta).*bsxfun(@minus,x,y').^2+(-14).*exp(1).^logtheta.*bsxfun(@minus,x,y').^4+bsxfun(@minus,x,y').^6);
end

end