function K=k_n1n_u3(x, y, hyp, i)
global ModelInfo;

dt = ModelInfo.dt;

if i >= 0 && i <= 3
    
    K = k(x, y, hyp(1:3), i) - 1/2*dt*DskDy1s(x, y, hyp(1:3), i) ...
        - 1/2*dt*DskDy2s(x, y, hyp(1:3), i);
        
elseif i >= 4 && i <= 6
    
    K=0.*bsxfun(@minus,x(:,1),y(:,1)');
    
end

end