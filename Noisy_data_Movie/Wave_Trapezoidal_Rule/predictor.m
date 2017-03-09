function [f, v] = predictor(x_star_u, x_star_v)

global ModelInfo
x_b = ModelInfo.x_b;
x_u = ModelInfo.x_u;
x_v = ModelInfo.x_v;

u_b = ModelInfo.u_b;
u = ModelInfo.u;
v = ModelInfo.v;

y=[u_b;u;v];

N_b = length(u_b);
N_u = length(u);
N_v = length(v);

S0 = ModelInfo.S0;

S = [zeros(N_b,N_b) zeros(N_b,N_u+N_v);
     zeros(N_u+N_v,N_b) S0];

hyp = ModelInfo.hyp;

K_nn_uu = k_nn_uu(x_star_u, x_b,  hyp(1:end-2),0);
K_nn1_uu = k_nn1_uu(x_star_u, x_u,  hyp(1:end-2),0);
K_nn1_uv = k_nn1_uv(x_star_u, x_v,  hyp(1:end-2),0);

K_nn_vu = k_nn_uv(x_b, x_star_v,  hyp(1:end-2),0)';
K_nn1_vu = k_nn1_vu(x_star_v, x_u,  hyp(1:end-2),0);
K_nn1_vv = k_nn1_vv(x_star_v, x_v,  hyp(1:end-2),0);

psi = [K_nn_uu K_nn1_uu K_nn1_uv;
        K_nn_vu K_nn1_vu K_nn1_vv];
    
V_nn_uu = k_nn_uu(x_star_u, x_star_u,  hyp(1:end-2),0);
V_nn_uv = k_nn_uv(x_star_u, x_star_v,  hyp(1:end-2),0);
V_vv_vv = k_nn_vv(x_star_v, x_star_v,  hyp(1:end-2),0);

VV = [V_nn_uu V_nn_uv;
     V_nn_uv' V_vv_vv];

L=ModelInfo.L;

f = psi*(L'\(L\y));

alpha = (L'\(L\psi'));

v = VV - psi*alpha + alpha'*S*alpha;


