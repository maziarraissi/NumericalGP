function K=k_tau1tau1(x, y, hyp, i)

if i == 0 
    
    K = k(x, y, hyp(3:4), i);
    
elseif i==3 || i==4
    
    K = k(x, y, hyp(3:4), i-2);
    
else
    
    K=0.*bsxfun(@minus,x,y');
    
end

end