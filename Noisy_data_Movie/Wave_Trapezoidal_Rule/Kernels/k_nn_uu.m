function K=k_nn_uu(x, y, hyp, i)
global ModelInfo;

dt = ModelInfo.dt;

if i == 0

	K = k(x,y,hyp(1:2),i) + 1/4*dt^2*k(x,y,hyp(3:4),i);

elseif i==1 || i==2

	K = k(x,y,hyp(1:2),i);


elseif i==3 || i==4

	K = 1/4*dt^2*k(x,y,hyp(3:4),i-2);

end

end