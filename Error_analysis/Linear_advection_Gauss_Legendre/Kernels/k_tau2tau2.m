function K=k_tau2tau2(x, y, hyp, i)

if i == 0 
    
    K = k(x, y, hyp(5:6), i);
    
elseif i==5 || i==6
    
    K = k(x, y, hyp(5:6), i-4);
    
else
    
    K=0.*bsxfun(@minus,x,y');
    
end

end