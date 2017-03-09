function K=k_nn1_vu(x, y, hyp, i)
global ModelInfo;

dt = ModelInfo.dt;

if i == 0

	K = -1/2*dt*k(x,y,hyp(3:4),i) + 1/2*dt*Lk(x,y,hyp(1:2),i);

elseif i==1 || i==2

	K = 1/2*dt*Lk(x,y,hyp(1:2),i);


elseif i==3 || i==4

	K = -1/2*dt*k(x,y,hyp(3:4),i-2);

end

end