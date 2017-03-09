function [f, v] = predictor(x_star)

global ModelInfo
x_b = ModelInfo.x_b;
x_u = ModelInfo.x_u;

u_b = ModelInfo.u_b;
u = ModelInfo.u;

y=[u_b;u_b;u_b;u;u;u];

D = size(x_b,2);
N_b = size(u_b, 1);
N_u = size(u, 1);

S0 = ModelInfo.S0;

S = [zeros(3*N_b, 3*N_b) zeros(3*N_b,3*N_u);
     zeros(3*N_u,3*N_b) repmat(S0,[3 3])];

hyp = ModelInfo.hyp;

psi_n1n1_0b = k_n1n1(x_star, x_b(1),  hyp(1:end-1),0) - k_n1n1(x_star, x_b(2),  hyp(1:end-1),0);

psi_n1n_03 = k_n1n_03(x_star, x_u, hyp(1:end-1),0);
psi_n1n_02 = k_n1n_02(x_star, x_u, hyp(1:end-1),0);
psi_n1n_01 = k_n1n_01(x_star, x_u, hyp(1:end-1),0);

psi = [psi_n1n1_0b zeros(size(x_star)) zeros(size(x_star)) psi_n1n_03 psi_n1n_02 psi_n1n_01];

L=ModelInfo.L;

f = psi*(L'\(L\y));

alpha = (L'\(L\psi'));

v = k_n1n1(x_star, x_star,  hyp(1:end-1),0) - psi*alpha + alpha'*S*alpha;


