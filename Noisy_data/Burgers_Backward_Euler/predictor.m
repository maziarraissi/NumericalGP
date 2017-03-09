function [f, v] = predictor(x_star)

global ModelInfo
x_u = ModelInfo.x_u;
x_b = ModelInfo.x_b;

u = ModelInfo.u;
u_b = ModelInfo.u_b;
y=[u_b; u];

n_u = length(u);
n_b = length(u_b);

S0 = ModelInfo.S0;

S = [zeros(n_b,n_b) zeros(n_b,n_u);
     zeros(n_u,n_b) S0];

hyp = ModelInfo.hyp;
D = size(x_u,2);

K1 = knn(x_star, x_b, hyp(1:D+1),0);
K2 = knn1(x_star, x_u, hyp(1:D+1), u, 0);

psi = [K1 K2];

L=ModelInfo.L;

f = psi*(L'\(L\y));

alpha = (L'\(L\psi'));

v = knn(x_star, x_star, ModelInfo.hyp(1:D+1),0) - psi*alpha + alpha'*S*alpha;


