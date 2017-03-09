function K=k_tau1n_03(x, y, hyp, i)
global ModelInfo;

b1 = 1/2;

dt = ModelInfo.dt;

if i == 0
    
    K = b1*dt*DkDy(x, y, hyp(3:4), i);
    
elseif i == 1 || i == 2
    
    K = 0.*bsxfun(@minus, x, y');
    
elseif i == 3 || i == 4
    
    K = b1*dt*DkDy(x, y, hyp(3:4), i-2);
    
elseif i == 5 || i == 6
    
    K = 0.*bsxfun(@minus, x, y');
    
end

end