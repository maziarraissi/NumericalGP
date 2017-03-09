function [NLML,D_NLML]=likelihood(hyp)

global ModelInfo
x_u = ModelInfo.x_u;
x_b = ModelInfo.x_b;

u = ModelInfo.u;
u_b = ModelInfo.u_b;
y=[u_b; u];

jitter = ModelInfo.jitter;

sigma_n = exp(hyp(end));

[n_u, D] = size(x_u);
n_b = size(x_b, 1);
n = n_b + n_u;

Knn = knn(x_b, x_b, hyp(1:D+1), 0);
Knn1 = knn1(x_b, x_u, hyp(1:D+1), u, 0);
Kn1n1 = kn1n1(x_u, x_u, hyp(1:D+1), u, u, 0) + eye(n_u).*sigma_n;

K = [Knn Knn1;
    Knn1' Kn1n1];

K = K + eye(n).*jitter;

% Cholesky factorisation
[L,p]=chol(K,'lower');

ModelInfo.L = L;

if p > 0
    fprintf(1,'Covariance is ill-conditioned\n');
end

alpha = L'\(L\y);
NLML = 0.5*y'*alpha + sum(log(diag(L))) + log(2*pi)*n/2;


D_NLML = 0*hyp;
Q =  L'\(L\eye(n)) - alpha*alpha';
for i=1:D+1
    DKnn = knn(x_b, x_b, hyp(1:D+1),i);
    DKnn1 = knn1(x_b, x_u, hyp(1:D+1), u, i);
    DKn1n1 = kn1n1(x_u, x_u, hyp(1:D+1), u, u, i);
     
    DK = [DKnn   DKnn1;
          DKnn1'  DKn1n1];

    D_NLML(i) = sum(sum(Q.*DK))/2;
end

D_NLML(end) = sigma_n*trace(Q(n_b+1:end,n_b+1:end))/2;