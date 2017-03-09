function [NLML,D_NLML]=likelihood(hyp)

global ModelInfo
x_b = ModelInfo.x_b;
x_u = ModelInfo.x_u;

u_b = ModelInfo.u_b;
u = ModelInfo.u;

y=[u_b;u_b;u_b;u;u;u];

jitter = ModelInfo.jitter;

sigma_n = exp(hyp(end));

D = size(x_b,2);
N_b = size(u_b, 1);
N_u = size(u, 1);

N = 3*N_b + 3*N_u;

K_n1n1_bb = k_n1n1(x_b(1), x_b(1), hyp(1:end-1), 0) - k_n1n1(x_b(1), x_b(2), hyp(1:end-1), 0) ...
    - k_n1n1(x_b(2), x_b(1), hyp(1:end-1), 0) + k_n1n1(x_b(2), x_b(2), hyp(1:end-1), 0);    
    

K_n1n_b3 = k_n1n_03(x_b(1), x_u, hyp(1:end-1), 0) - k_n1n_03(x_b(2), x_u, hyp(1:end-1), 0);
K_n1n_b_2 = k_n1n_02(x_b(1), x_u, hyp(1:end-1), 0) - k_n1n_02(x_b(2), x_u, hyp(1:end-1), 0);
K_n1n_b_1 = k_n1n_01(x_b(1), x_u, hyp(1:end-1), 0) - k_n1n_01(x_b(2), x_u, hyp(1:end-1), 0);

K_tau2tau2_bb = k_tau2tau2(x_b(1), x_b(1), hyp(1:end-1), 0) - k_tau2tau2(x_b(1), x_b(2), hyp(1:end-1), 0) ...
    - k_tau2tau2(x_b(2), x_b(1), hyp(1:end-1), 0) + k_tau2tau2(x_b(2), x_b(2), hyp(1:end-1), 0);    


K_tau2n_b3 = k_tau2n_03(x_b(1), x_u, hyp(1:end-1), 0) - k_tau2n_03(x_b(2), x_u, hyp(1:end-1), 0);
K_tau2n_b2 = k_tau2n_02(x_b(1), x_u, hyp(1:end-1), 0) - k_tau2n_02(x_b(2), x_u, hyp(1:end-1), 0);
K_tau2n_b1 = k_tau2n_01(x_b(1), x_u, hyp(1:end-1), 0) - k_tau2n_01(x_b(2), x_u, hyp(1:end-1), 0);

K_tau1tau1_bb = k_tau1tau1(x_b(1), x_b(1), hyp(1:end-1), 0) - k_tau1tau1(x_b(1), x_b(2), hyp(1:end-1), 0) ...
    - k_tau1tau1(x_b(2), x_b(1), hyp(1:end-1), 0) + k_tau1tau1(x_b(2), x_b(2), hyp(1:end-1), 0);

K_tau1n_b3 = k_tau1n_03(x_b(1), x_u, hyp(1:end-1), 0) - k_tau1n_03(x_b(2), x_u, hyp(1:end-1), 0);
K_tau1n_b2 = k_tau1n_02(x_b(1), x_u, hyp(1:end-1), 0) - k_tau1n_02(x_b(2), x_u, hyp(1:end-1), 0);
K_tau1n_b1 = k_tau1n_01(x_b(1), x_u, hyp(1:end-1), 0) - k_tau1n_01(x_b(2), x_u, hyp(1:end-1), 0);


K_nn_33 = k_nn_33(x_u, x_u, hyp(1:end-1), 0) + eye(N_u)*sigma_n + eye(N_u)*jitter;
K_nn_32 = k_nn_32(x_u, x_u, hyp(1:end-1), 0);
K_nn_31 = k_nn_31(x_u, x_u, hyp(1:end-1), 0);

K_nn_22 = k_nn_22(x_u, x_u, hyp(1:end-1), 0) + eye(N_u)*sigma_n + eye(N_u)*jitter;
K_nn_21 = k_nn_21(x_u, x_u, hyp(1:end-1), 0);
  
K_nn_11 = k_nn_11(x_u, x_u, hyp(1:end-1), 0) + eye(N_u)*sigma_n + eye(N_u)*jitter;

  
K = [K_n1n1_bb  0             0             K_n1n_b3   zeros(1,N_u) zeros(1,N_u);
     0          K_tau2tau2_bb 0             K_tau2n_b3 K_tau2n_b2   K_tau2n_b1;
     0          0             K_tau1tau1_bb K_tau1n_b3 K_tau1n_b2   K_tau1n_b1;
     K_n1n_b3'  K_tau2n_b3'   K_tau1n_b3'   K_nn_33    K_nn_32      K_nn_31;
     K_n1n_b_2' K_tau2n_b2'   K_tau1n_b2'   K_nn_32'   K_nn_22      K_nn_21;
     K_n1n_b_1' K_tau2n_b1'   K_tau1n_b1'   K_nn_31'   K_nn_21'     K_nn_11];


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
for i=1:3*(D+1)

K_n1n1_bb = k_n1n1(x_b(1), x_b(1), hyp(1:end-1), i) - k_n1n1(x_b(1), x_b(2), hyp(1:end-1), i) ...
    - k_n1n1(x_b(2), x_b(1), hyp(1:end-1), i) + k_n1n1(x_b(2), x_b(2), hyp(1:end-1), i);    
    

K_n1n_b3 = k_n1n_03(x_b(1), x_u, hyp(1:end-1), i) - k_n1n_03(x_b(2), x_u, hyp(1:end-1), i);
K_n1n_b_2 = k_n1n_02(x_b(1), x_u, hyp(1:end-1), i) - k_n1n_02(x_b(2), x_u, hyp(1:end-1), i);
K_n1n_b_1 = k_n1n_01(x_b(1), x_u, hyp(1:end-1), i) - k_n1n_01(x_b(2), x_u, hyp(1:end-1), i);

K_tau2tau2_bb = k_tau2tau2(x_b(1), x_b(1), hyp(1:end-1), i) - k_tau2tau2(x_b(1), x_b(2), hyp(1:end-1), i) ...
    - k_tau2tau2(x_b(2), x_b(1), hyp(1:end-1), i) + k_tau2tau2(x_b(2), x_b(2), hyp(1:end-1), i);    


K_tau2n_b3 = k_tau2n_03(x_b(1), x_u, hyp(1:end-1), i) - k_tau2n_03(x_b(2), x_u, hyp(1:end-1), i);
K_tau2n_b2 = k_tau2n_02(x_b(1), x_u, hyp(1:end-1), i) - k_tau2n_02(x_b(2), x_u, hyp(1:end-1), i);
K_tau2n_b1 = k_tau2n_01(x_b(1), x_u, hyp(1:end-1), i) - k_tau2n_01(x_b(2), x_u, hyp(1:end-1), i);

K_tau1tau1_bb = k_tau1tau1(x_b(1), x_b(1), hyp(1:end-1), i) - k_tau1tau1(x_b(1), x_b(2), hyp(1:end-1), i) ...
    - k_tau1tau1(x_b(2), x_b(1), hyp(1:end-1), i) + k_tau1tau1(x_b(2), x_b(2), hyp(1:end-1), i);

K_tau1n_b3 = k_tau1n_03(x_b(1), x_u, hyp(1:end-1), i) - k_tau1n_03(x_b(2), x_u, hyp(1:end-1), i);
K_tau1n_b2 = k_tau1n_02(x_b(1), x_u, hyp(1:end-1), i) - k_tau1n_02(x_b(2), x_u, hyp(1:end-1), i);
K_tau1n_b1 = k_tau1n_01(x_b(1), x_u, hyp(1:end-1), i) - k_tau1n_01(x_b(2), x_u, hyp(1:end-1), i);


K_nn_33 = k_nn_33(x_u, x_u, hyp(1:end-1), i);
K_nn_32 = k_nn_32(x_u, x_u, hyp(1:end-1), i);
K_nn_31 = k_nn_31(x_u, x_u, hyp(1:end-1), i);

K_nn_22 = k_nn_22(x_u, x_u, hyp(1:end-1), i);
K_nn_21 = k_nn_21(x_u, x_u, hyp(1:end-1), i);
  
K_nn_11 = k_nn_11(x_u, x_u, hyp(1:end-1), i);

  
DK = [K_n1n1_bb  0             0             K_n1n_b3   zeros(1,N_u) zeros(1,N_u);
     0          K_tau2tau2_bb 0             K_tau2n_b3 K_tau2n_b2   K_tau2n_b1;
     0          0             K_tau1tau1_bb K_tau1n_b3 K_tau1n_b2   K_tau1n_b1;
     K_n1n_b3'  K_tau2n_b3'   K_tau1n_b3'   K_nn_33    K_nn_32      K_nn_31;
     K_n1n_b_2' K_tau2n_b2'   K_tau1n_b2'   K_nn_32'   K_nn_22      K_nn_21;
     K_n1n_b_1' K_tau2n_b1'   K_tau1n_b1'   K_nn_31'   K_nn_21'     K_nn_11];

    D_NLML(i) = sum(sum(Q.*DK))/2;
end

D_NLML(end) = sigma_n*trace(Q(3*N_b+1:end,3*N_b+1:end))/2;
