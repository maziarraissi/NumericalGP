function K=k_nn_u1(x, y, hyp, i)

if i == 0 
    
    K = k(x, y, hyp(4:6), i);
    
elseif i>=1 && i <= 3
    
    K=0.*bsxfun(@minus,x(:,1),y(:,1)');
    
elseif i>=4 && i <= 6
    
    K = k(x, y, hyp(4:6), i-3);
    
end

end