function K=k_tau2n_03(x, y, hyp, i)
global ModelInfo;

b2 = 1/2;

dt = ModelInfo.dt;

if i == 0
    
    K = b2*dt*DkDy(x, y, hyp(5:6), i);
    
elseif i == 1 || i == 2
    
    K = 0.*bsxfun(@minus, x, y');
    
elseif i == 3 || i == 4
    
    K = 0.*bsxfun(@minus, x, y');
    
elseif i == 5 || i == 6
    
    K= b2*dt*DkDy(x, y, hyp(5:6), i-4);
    
end

end