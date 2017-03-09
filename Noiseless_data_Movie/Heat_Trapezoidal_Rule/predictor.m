function [f, v] = predictor(x_star)

global ModelInfo
x_D = ModelInfo.x_D;
x_N = ModelInfo.x_N;
x_u = ModelInfo.x_u;

u_D = ModelInfo.u_D;
v_N = ModelInfo.v_N;
u = ModelInfo.u;

y=[u_D;v_N;u_D;v_N;u;u];

D = size(x_u,2);
N_D = size(u_D, 1);
N_N = size(v_N, 1);
N_u = size(u, 1);


S0 = ModelInfo.S0;

S = [zeros(2*N_D+2*N_N, 2*N_D+2*N_N) zeros(2*N_D + 2*N_N,2*N_u);
     zeros(2*N_u,2*N_D + 2*N_N) repmat(S0,[2,2])];

hyp = ModelInfo.hyp;

psi_n1n1_uD = k_n1n1_uu(x_star, x_D,  hyp(1:end-1),0);
psi_n1n1_uN = k_n1n1_uv(x_star, x_N,  hyp(1:end-1),0);

psi_n1n_u3 = k_n1n_u3(x_star, x_u,  hyp(1:end-1),0);

psi = [psi_n1n1_uD psi_n1n1_uN zeros(size(x_star,1),N_D) zeros(size(x_star,1),N_N) psi_n1n_u3 zeros(size(x_star,1),N_u)];

L=ModelInfo.L;

f = psi*(L'\(L\y));

alpha = (L'\(L\psi'));

v = k_n1n1_uu(x_star, x_star,  hyp(1:end-1),0) - psi*alpha + alpha'*S*alpha;


