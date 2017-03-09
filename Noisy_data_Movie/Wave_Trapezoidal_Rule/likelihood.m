function [NLML,D_NLML]=likelihood(hyp)

global ModelInfo
x_b = ModelInfo.x_b;
x_u = ModelInfo.x_u;
x_v = ModelInfo.x_v;

u_b = ModelInfo.u_b;
u = ModelInfo.u;
v = ModelInfo.v;

y=[u_b;u;v];

sigma_u = exp(hyp(end-1));
sigma_v = exp(hyp(end));

jitter = ModelInfo.jitter;

[N_b, D] = size(x_b);
N_u = size(u, 1);
N_v = size(v, 1);
N = N_b+N_u+N_v;

K_nn_uu = k_nn_uu(x_b,x_b,hyp(1:end-2), 0) + eye(N_b).*jitter;
K_nn1_uu = k_nn1_uu(x_b,x_u,hyp(1:end-2), 0);
K_nn1_uv = k_nn1_uv(x_b,x_v,hyp(1:end-2), 0);

K_n1n1_uu = k_n1n1_uu(x_u,x_u,hyp(1:end-2), 0) + eye(N_u).*sigma_u + eye(N_u).*jitter;
K_n1n1_uv = k_n1n1_uv(x_u,x_v,hyp(1:end-2), 0);

K_n1n1_vv = k_n1n1_vv(x_v,x_v,hyp(1:end-2), 0) + eye(N_v).*sigma_v + eye(N_v).*jitter;

K = [K_nn_uu K_nn1_uu K_nn1_uv;
    K_nn1_uu' K_n1n1_uu K_n1n1_uv;
    K_nn1_uv' K_n1n1_uv' K_n1n1_vv];

% K = K + eye(N).*jitter;

% Cholesky factorisation
[L,p]=chol(K,'lower');

ModelInfo.L = L;

if p > 0
    fprintf(1,'Covariance is ill-conditioned\n');
end

alpha = L'\(L\y);
NLML = 0.5*y'*alpha + sum(log(diag(L))) + log(2*pi)*N/2;

D_NLML = 0*hyp;
Q =  L'\(L\eye(N)) - alpha*alpha';
for i=1:2*(D+1)
    
    DK_nn_uu = k_nn_uu(x_b,x_b,hyp(1:end-2), i);
    DK_nn1_uu = k_nn1_uu(x_b,x_u,hyp(1:end-2), i);
    DK_nn1_uv = k_nn1_uv(x_b,x_v,hyp(1:end-2), i);
    
    DK_n1n1_uu = k_n1n1_uu(x_u,x_u,hyp(1:end-2), i);
    DK_n1n1_uv = k_n1n1_uv(x_u,x_v,hyp(1:end-2), i);
    
    DK_n1n1_vv = k_n1n1_vv(x_v,x_v,hyp(1:end-2), i);
    
    DK = [DK_nn_uu DK_nn1_uu DK_nn1_uv;
          DK_nn1_uu' DK_n1n1_uu DK_n1n1_uv;
          DK_nn1_uv' DK_n1n1_uv' DK_n1n1_vv];
    
    D_NLML(i) = sum(sum(Q.*DK))/2;
end

D_NLML(end-1) = sigma_u*trace(Q(N_b+1:N_b+N_u,N_b+1:N_b+N_u))/2;
D_NLML(end) = sigma_v*trace(Q(N_b+N_u+1:end,N_b+N_u+1:end))/2;