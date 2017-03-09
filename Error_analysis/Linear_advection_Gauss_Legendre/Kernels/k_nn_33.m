function K=k_nn_33(x, y, hyp, i)
global ModelInfo;

b1 = 1/2;
b2 = 1/2;

dt = ModelInfo.dt;

if i == 0
    
    K = k(x,y,hyp(1:2),i) + b1^2*dt^2*DkDxDy(x, y, hyp(3:4), i) ...
        + b2^2*dt^2*DkDxDy(x, y, hyp(5:6), i);
    
elseif i == 1 || i == 2
    
    K = k(x, y, hyp(1:2), i);
    
elseif i == 3 || i == 4
    
    K= b1^2*dt^2*DkDxDy(x, y, hyp(3:4), i-2);
    
elseif i == 5 || i == 6
    
    K= b2^2*dt^2*DkDxDy(x, y, hyp(5:6), i-4);
    
end

end