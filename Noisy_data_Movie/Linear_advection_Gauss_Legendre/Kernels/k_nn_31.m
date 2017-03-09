function K=k_nn_31(x, y, hyp, i)
global ModelInfo;

b1 = 1/2;
b2 = 1/2;
a12 = 1/4 - 1/6*sqrt(3);
a11 = 1/4;

dt = ModelInfo.dt;

if i == 0
    
    K = b1*dt*DkDx(x,y,hyp(3:4),i) + a11*b1*dt^2*DkDxDy(x, y, hyp(3:4), i) ...
        + a12*b2*dt^2*DkDxDy(x, y, hyp(5:6), i);
    
elseif i == 1 || i == 2
    
    K = 0.*bsxfun(@minus,x,y');
    
elseif i == 3 || i == 4
    
    K= b1*dt*DkDx(x,y,hyp(3:4),i-2) + a11*b1*dt^2*DkDxDy(x, y, hyp(3:4), i-2);
    
elseif i == 5 || i == 6
    
    K= a12*b2*dt^2*DkDxDy(x, y, hyp(5:6), i-4);
    
end

end