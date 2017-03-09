function K = knn1(x, y, hyp, uny, i)

global ModelInfo;

nu = ModelInfo.nu;
dt = ModelInfo.dt;

n_x = size(x,1);
uny = ones(n_x,1)*uny';

K = k(x,y,hyp,i) + dt*uny.*DkDy(x,y,hyp,i) - nu*dt*D2kDy2(x,y,hyp,i);

end


