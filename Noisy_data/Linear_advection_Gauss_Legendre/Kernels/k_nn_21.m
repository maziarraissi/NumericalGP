function K=k_nn_21(x, y, hyp, i)
global ModelInfo;

a21 = 1/4 + 1/6*sqrt(3);
a22 = 1/4;
a12 = 1/4 - 1/6*sqrt(3);
a11 = 1/4;

dt = ModelInfo.dt;

if i == 0
    
    K = a12*dt*DkDy(x,y,hyp(5:6),i) + a21*dt*DkDx(x,y,hyp(3:4),i) ...
        + a21*a11*dt^2*DkDxDy(x,y,hyp(3:4),i) + a22*a12*dt^2*DkDxDy(x,y,hyp(5:6),i);
    
elseif i == 1 || i == 2
    
    K = 0.*bsxfun(@minus, x, y');
    
elseif i == 3 || i == 4
    
    K= a21*dt*DkDx(x,y,hyp(3:4),i-2) + a21*a11*dt^2*DkDxDy(x,y,hyp(3:4),i-2);
    
elseif i == 5 || i == 6
    
    K= a12*dt*DkDy(x,y,hyp(5:6),i-4) + a22*a12*dt^2*DkDxDy(x,y,hyp(5:6),i-4);
    
end

end