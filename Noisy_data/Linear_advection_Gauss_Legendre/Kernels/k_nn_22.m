function K=k_nn_22(x, y, hyp, i)
global ModelInfo;

a21 = 1/4 + 1/6*sqrt(3);
a22 = 1/4;

dt = ModelInfo.dt;

if i == 0
    
    K = k(x,y,hyp(5:6),i) + a21^2*dt^2*DkDxDy(x, y, hyp(3:4), i) ...
        + a22^2*dt^2*DkDxDy(x, y, hyp(5:6), i);
    
elseif i == 1 || i == 2
    
    K = 0.*bsxfun(@minus, x, y');
    
elseif i == 3 || i == 4
    
    K= a21^2*dt^2*DkDxDy(x, y, hyp(3:4), i-2);
    
elseif i == 5 || i == 6
    
    K= k(x,y,hyp(5:6),i-4) + a22^2*dt^2*DkDxDy(x, y, hyp(5:6), i-4);
    
end

end