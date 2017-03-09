function K=k_n1n1_uv(x, y, hyp, i)

if i >= 0 && i <= 3
    
    K = DkDy2(x, y, hyp(1:3), i);
    
else
    
    K=0.*bsxfun(@minus,x(:,1),y(:,1)');
    
end

end