function K=k_nn_u3(x, y, hyp, i)
global ModelInfo;

dt = ModelInfo.dt;

if i == 0
    
    K = - 1/2*dt*DskDy1s(x, y, hyp(4:6), i) ...
        - 1/2*dt*DskDy2s(x, y, hyp(4:6), i);
     
elseif i >= 1 && i <= 3
    
    K=0.*bsxfun(@minus,x(:,1),y(:,1)');
        
elseif i >= 4 && i <= 6
    
    K = - 1/2*dt*DskDy1s(x, y, hyp(4:6), i-3) ...
        - 1/2*dt*DskDy2s(x, y, hyp(4:6), i-3);
    
end

end