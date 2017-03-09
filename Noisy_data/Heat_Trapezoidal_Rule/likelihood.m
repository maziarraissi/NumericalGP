function [NLML,D_NLML]=likelihood(hyp)

global ModelInfo
x_D = ModelInfo.x_D;
x_N = ModelInfo.x_N;
x_u = ModelInfo.x_u;

u_D = ModelInfo.u_D;
v_N = ModelInfo.v_N;
u = ModelInfo.u;

y=[u_D;v_N;u_D;v_N;u;u];

jitter = ModelInfo.jitter;

sigma_u = exp(hyp(end));

D = size(x_u,2);
N_D = size(u_D, 1);
N_N = size(v_N, 1);
N_u = size(u, 1);

N = N_D+N_N+N_D+N_N+N_u+N_u;

K_n1n1_DD = k_n1n1_uu(x_D, x_D, hyp(1:end-1), 0) + eye(N_D).*jitter;    
K_n1n1_DN = k_n1n1_uv(x_D, x_N, hyp(1:end-1), 0);
K_n1n_D3 = k_n1n_u3(x_D, x_u, hyp(1:end-1), 0);
K_n1n1_NN = k_n1n1_vv(x_N, x_N, hyp(1:end-1), 0) + eye(N_N).*jitter;
K_n1n_N3 = k_n1n_v3(x_N, x_u, hyp(1:end-1), 0);

K_nn_DD = k_nn_uu(x_D, x_D, hyp(1:end-1), 0) + eye(N_D).*jitter;    
K_nn_DN = k_nn_uv(x_D, x_N, hyp(1:end-1), 0);
K_nn_D3 = k_nn_u3(x_D, x_u, hyp(1:end-1), 0);
K_nn_D1 = k_nn_u1(x_D, x_u, hyp(1:end-1), 0);
K_nn_NN = k_nn_vv(x_N, x_N, hyp(1:end-1), 0) + eye(N_N).*jitter;
K_nn_N3 = k_nn_v3(x_N, x_u, hyp(1:end-1), 0);
K_nn_N1 = k_nn_v1(x_N, x_u, hyp(1:end-1), 0);

K_nn_33 = k_nn_33(x_u, x_u, hyp(1:end-1), 0) + eye(N_u).*sigma_u + eye(N_u).*jitter;
K_nn_31 = k_nn_31(x_u, x_u, hyp(1:end-1), 0);
K_nn_11 = k_nn_11(x_u, x_u, hyp(1:end-1), 0) + eye(N_u).*sigma_u + eye(N_u).*jitter;

K = [K_n1n1_DD K_n1n1_DN zeros(N_D,N_D) zeros(N_D,N_N) K_n1n_D3 zeros(N_D,N_u);
     K_n1n1_DN' K_n1n1_NN zeros(N_N,N_D) zeros(N_N,N_N) K_n1n_N3 zeros(N_N,N_u);
     zeros(N_D,N_D) zeros(N_D,N_N) K_nn_DD  K_nn_DN  K_nn_D3 K_nn_D1;
     zeros(N_N,N_D) zeros(N_N,N_N) K_nn_DN' K_nn_NN  K_nn_N3 K_nn_N1;
     K_n1n_D3' K_n1n_N3' K_nn_D3' K_nn_N3' K_nn_33 K_nn_31;
     zeros(N_u,N_D) zeros(N_u,N_N) K_nn_D1' K_nn_N1' K_nn_31' K_nn_11];

% K = K + eye(n).*jitter;

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

K_n1n1_DD = k_n1n1_uu(x_D, x_D, hyp(1:end-1), i);    
K_n1n1_DN = k_n1n1_uv(x_D, x_N, hyp(1:end-1), i);
K_n1n_D3 = k_n1n_u3(x_D, x_u, hyp(1:end-1), i);
K_n1n1_NN = k_n1n1_vv(x_N, x_N, hyp(1:end-1), i);
K_n1n_N3 = k_n1n_v3(x_N, x_u, hyp(1:end-1), i);

K_nn_DD = k_nn_uu(x_D, x_D, hyp(1:end-1), i);    
K_nn_DN = k_nn_uv(x_D, x_N, hyp(1:end-1), i);
K_nn_D3 = k_nn_u3(x_D, x_u, hyp(1:end-1), i);
K_nn_D1 = k_nn_u1(x_D, x_u, hyp(1:end-1), i);
K_nn_NN = k_nn_vv(x_N, x_N, hyp(1:end-1), i);
K_nn_N3 = k_nn_v3(x_N, x_u, hyp(1:end-1), i);
K_nn_N1 = k_nn_v1(x_N, x_u, hyp(1:end-1), i);

K_nn_33 = k_nn_33(x_u, x_u, hyp(1:end-1), i);
K_nn_31 = k_nn_31(x_u, x_u, hyp(1:end-1), i);
K_nn_11 = k_nn_11(x_u, x_u, hyp(1:end-1), i);

DK = [K_n1n1_DD K_n1n1_DN zeros(N_D,N_D) zeros(N_D,N_N) K_n1n_D3 zeros(N_D,N_u);
     K_n1n1_DN' K_n1n1_NN zeros(N_N,N_D) zeros(N_N,N_N) K_n1n_N3 zeros(N_N,N_u);
     zeros(N_D,N_D) zeros(N_D,N_N) K_nn_DD  K_nn_DN  K_nn_D3 K_nn_D1;
     zeros(N_N,N_D) zeros(N_N,N_N) K_nn_DN' K_nn_NN  K_nn_N3 K_nn_N1;
     K_n1n_D3' K_n1n_N3' K_nn_D3' K_nn_N3' K_nn_33 K_nn_31;
     zeros(N_u,N_D) zeros(N_u,N_N) K_nn_D1' K_nn_N1' K_nn_31' K_nn_11];

    D_NLML(i) = sum(sum(Q.*DK))/2;
end

D_NLML(end) = sigma_u*trace(Q(2*N_D+2*N_N+1:end,2*N_D+2*N_N+1:end))/2;
