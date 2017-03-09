function error = main(Ntr,dt,T)
clc; close all

addpath ./Kernels
addpath ./Utilities

rng('default')

global ModelInfo

set(0,'defaulttextinterpreter','latex')

%% Setup
Ntr_artificial = Ntr;
dim = 1;
lb = zeros(1,dim);
ub = 1.0*ones(1,dim);
jitter = 1e-8;
ModelInfo.jitter=jitter;
noise = 0.0;

plt = 0;

ModelInfo.dt = dt;

nsteps = T/dt;
nn = 400;
xstar = linspace(lb(1),ub(1),nn)';

num_plots = 3;

%% Optimize model

ModelInfo.x_b = [lb(1); ub(1)];
ModelInfo.u_b = 0;

ModelInfo.x_u = bsxfun(@plus,lb,bsxfun(@times,   lhsdesign(Ntr,dim)    ,(ub-lb)));
ModelInfo.u = Exact_solution(0, ModelInfo.x_u);
ModelInfo.u = ModelInfo.u + noise*randn(size(ModelInfo.u));

ModelInfo.S0 = zeros(Ntr);

ModelInfo.hyp = log([1 1 1 1 1 1 10^-6]);

if plt == 1
    fig = figure(1);
    set(fig,'units','normalized','outerposition',[0 0 1 .5])
    clf
    color2 = [217,95,2]/255;
    k = 1;
    subplot(2,num_plots,k)
    hold
    plot(xstar,Exact_solution(0,xstar),'b','LineWidth',3);
    plot(ModelInfo.x_u, ModelInfo.u,'ro','MarkerSize',12,'LineWidth',3);
    xlabel('$x$')
    ylabel('$u(0,x)$')
    axis square
    ylim([-1.5 1.5]);
    set(gca,'FontSize',14);
    set(gcf, 'Color', 'w');
    tit = sprintf('Time: %.2f\n%d training points', 0,Ntr);
    title(tit);
    
    drawnow;
end

%%
for i = 1:nsteps
    
    [ModelInfo.hyp,~,~] = minimize(ModelInfo.hyp, @likelihood, -5000);
    [NLML,~]=likelihood(ModelInfo.hyp);
    
    [Kpred, Kvar] = predictor(xstar);
    Kvar = abs(diag(Kvar));
    Exact = Exact_solution( i*dt, xstar);
    error = norm(Kpred-Exact,2)/norm(Exact,2);
    
    fprintf(1,'Step: %d, Time = %f, NLML = %e, error_u = %e\n', i, i*dt, NLML, error);
    
    x_u = bsxfun(@plus,lb,bsxfun(@times,   lhsdesign(Ntr_artificial,dim)    ,(ub-lb)));
    [ModelInfo.u, ModelInfo.S0] = predictor(x_u);
    ModelInfo.x_u = x_u;
    
    if plt == 1 && mod(i,floor(nsteps/(2*num_plots-1)))==0
        k = k+1;
        subplot(2,num_plots,k)
        hold
        plot(xstar,Exact,'b','LineWidth',3);
        plot(xstar, Kpred,'r--','LineWidth',3);
        [l,p] = boundedline(xstar, Kpred, 2.0*sqrt(Kvar), ':', 'alpha','cmap', color2);
        outlinebounds(l,p);
        xlabel('$x$')
        ylabel('$u(t,x)$')
        axis square
        ylim([-1.5 1.5]);
        set(gca,'FontSize',14);
        set(gcf, 'Color', 'w');
        tit = sprintf('Time: %.2f\n%d artificial data', i*dt ,Ntr_artificial);
        title(tit);
              
        drawnow;
    end
    
    
end

rmpath ./Kernels
rmpath ./Utilities