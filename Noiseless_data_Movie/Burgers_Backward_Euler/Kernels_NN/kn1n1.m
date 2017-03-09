function [K] = kn1n1(x, y, hyp, unx, uny, i)
global ModelInfo;

nu = ModelInfo.nu;
dt = ModelInfo.dt;

n_x = size(x,1);
uny = ones(n_x,1)*uny';

n_y = size(y,1);
unx = unx*ones(1,n_y);

K = k(x,y,hyp,i) + dt*uny.*DkDy(x,y,hyp,i) - nu*dt*D2kDy2(x,y,hyp,i) ...
    + dt*unx.*DkDx(x,y,hyp,i) + dt^2*unx.*uny.*DkDxDy(x, y, hyp, i) ...
    - nu*dt^2*unx.*D3kDxDy2(x, y, hyp, i) - nu*dt*D2kDx2(x, y, hyp, i) ...
    - nu*dt^2*uny.*D3kDx2Dy(x, y, hyp, i) + nu^2*dt^2*D4kDx2Dy2(x, y, hyp, i);

end

