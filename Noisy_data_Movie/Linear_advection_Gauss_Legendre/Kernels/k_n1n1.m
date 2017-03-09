function K=k_n1n1(x, y, hyp, i)

if i >= 0 && i <= 2
    
    K = k(x, y, hyp(1:2), i);
    
else
    
    K=0.*bsxfun(@minus,x,y');
    
end

end