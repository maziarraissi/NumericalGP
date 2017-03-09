clear all; clc; close all;

addpath ./Utilities
addpath ~/export_fig
addpath ./Kernels

rng('default')

global ModelInfo

set(0,'defaulttextinterpreter','latex')

%% Setup
Ntr_u = 14;
Ntr_v = 16;
Ntr_u_artificial = 51;
Ntr_v_artificial = 49;
dim = 1;
lb = zeros(1,dim);
ub = 1.0*ones(1,dim);
jitter = 1e-8;
ModelInfo.jitter=jitter;
noise_u = 0.0;
noise_v = 0.0;

plt = 1;

T = 1.5;
dt = 1e-2;

ModelInfo.dt = dt;

nsteps = T/dt;
n_star_u = 400;
n_star_v = 400;
x_star_u = linspace(lb(1),ub(1),n_star_u)';
x_star_v = linspace(lb(1),ub(1),n_star_v)';

num_plots = 4;

%% Optimize model

ModelInfo.x_b = [0;1];
ModelInfo.u_b = [0;0];

ModelInfo.x_u = bsxfun(@plus,lb,bsxfun(@times,   lhsdesign(Ntr_u,dim)    ,(ub-lb)));
ModelInfo.u = Exact_solution(0, ModelInfo.x_u);
ModelInfo.u = ModelInfo.u + noise_u*randn(size(ModelInfo.u));

ModelInfo.x_v = bsxfun(@plus,lb,bsxfun(@times,   lhsdesign(Ntr_v,dim)    ,(ub-lb)));
ModelInfo.v = Exact_solution_derivative(0, ModelInfo.x_v);
ModelInfo.v = ModelInfo.v + noise_v*randn(size(ModelInfo.v));

ModelInfo.S0 = zeros(Ntr_u+Ntr_v);

ModelInfo.hyp = log([1 1 1 1 exp(-6) exp(-6)]);

if plt == 1
    fig = figure(1);
    set(fig,'units','normalized','outerposition',[0 0 1 .4])
    %set(fig,'units','normalized','outerposition',[0 0 1 1])
    clf
    color2 = [217,95,2]/255;
    k=1;
    subplot(2,num_plots,k)
    hold
    plot(x_star_u,Exact_solution(0, x_star_u),'b','LineWidth',3);
    plot(ModelInfo.x_u, ModelInfo.u,'ro','MarkerSize',12,'LineWidth',3);
    %yLimits = get(gca,'YLim');
    xlabel('$0 \leq x \leq 1$')
    ylabel('$u(t,x)$')
    axis square
    ylim([-1 1]);
    %ylim([yLimits(1) yLimits(2)]);
    set(gca, 'XTick', sort(ModelInfo.x_u));
    set(gca, 'XTickLabel', [])
    set(gca,'TickLength',[0.05 0.05]);
    set(gca,'FontSize',14);
    set(gcf, 'Color', 'w');
    tit = sprintf('Time: %.2f\n%d initial data', 0,Ntr_u);
    title(tit);
    
    subplot(2,num_plots,num_plots + k)
    hold
    plot(x_star_v,Exact_solution_derivative(0, x_star_v),'b','LineWidth',3);
    plot(ModelInfo.x_v, ModelInfo.v,'ro','MarkerSize',12,'LineWidth',3);
    %yLimits = get(gca,'YLim');
    xlabel('$0 \leq x \leq 1$')
    ylabel('$v(t,x)$')
    axis square
    ylim([-5 5]);
    %ylim([yLimits(1) yLimits(2)]);
    set(gca, 'XTick', sort(ModelInfo.x_v));
    set(gca, 'XTickLabel', [])
    set(gca,'TickLength',[0.05 0.05]);
    set(gca,'FontSize',14);
    set(gcf, 'Color', 'w');
    tit = sprintf('%d initial data',Ntr_v);
    title(tit);
    
    
    % w = waitforbuttonpress;
    drawnow;
end

error_u = zeros(1,nsteps);
error_v = zeros(1,nsteps);
%%
for i = 1:nsteps
    
    [ModelInfo.hyp,~,~] = minimize(ModelInfo.hyp, @likelihood, -5000);
    [NLML,~]=likelihood(ModelInfo.hyp);
    %     exp(ModelInfo.hyp)
    
    [Kpred, Kvar] = predictor(x_star_u, x_star_v);
    Kvar = abs(diag(Kvar));
    u_star_mean = Kpred(1:n_star_u);
    v_star_mean = Kpred(n_star_u+1:end);
    u_star_var = Kvar(1:n_star_u);
    v_star_var = Kvar(n_star_u+1:end);
    
    Exact = Exact_solution(i*dt,x_star_u);
    Exact_derivative = Exact_solution_derivative(i*dt, x_star_v);
    
    error_u(i) = norm(u_star_mean - Exact)/norm(Exact);
    error_v(i) = norm(v_star_mean - Exact_derivative)/norm(Exact_derivative);
    fprintf(1,'Step: %d, Time = %f, NLML = %e, error_u = %e, error_v = %e\n', i, i*dt, NLML, error_u(i), error_v(i));
    
    x_u = bsxfun(@plus,lb,bsxfun(@times,   lhsdesign(Ntr_u_artificial,dim)    ,(ub-lb)));
    x_v = bsxfun(@plus,lb,bsxfun(@times,   lhsdesign(Ntr_v_artificial,dim)    ,(ub-lb)));
    [data, ModelInfo.S0] = predictor(x_u,x_v);
    ModelInfo.u = data(1:Ntr_u_artificial);
    ModelInfo.v = data(Ntr_u_artificial+1:end);
    ModelInfo.x_u = x_u;
    ModelInfo.x_v = x_v;
    
    if plt == 1 && mod(i,ceil(nsteps/num_plots))==0 && i < nsteps
        %   if plt == 1
        k = k+1;
        subplot(2,num_plots,k)
        hold
        plot(x_star_u,Exact,'b','LineWidth',3);
        plot(x_star_u, u_star_mean,'r--','LineWidth',3);
        %plot(ModelInfo.x_u, ModelInfo.u,'ro','MarkerSize',12,'LineWidth',1);
        [l,p] = boundedline(x_star_u, u_star_mean, 2.0*sqrt(u_star_var), ':', 'alpha','cmap', color2);
        outlinebounds(l,p);
        %plot(ModelInfo.x0, ModelInfo.y0,'o','MarkerSize',10,'LineWidth',3);
        %yLimits = get(gca,'YLim');
        xlabel('$0 \leq x \leq 1$')
        %ylabel('$u(t,x)$')
        axis square
        ylim([-1 1]);
        %ylim([yLimits(1) yLimits(2)]);
        set(gca, 'XTick', sort(ModelInfo.x_u));
        set(gca, 'XTickLabel', [])
        set(gca,'TickLength',[0.05 0.05]);
        set(gca,'FontSize',14);
        set(gcf, 'Color', 'w');
        tit = sprintf('Time: %.2f\nError: %e\n%d artificial data', i*dt ,error_u(i),Ntr_u_artificial);
        title(tit);
        
        subplot(2,num_plots,num_plots+k)
        hold
        plot(x_star_v,Exact_derivative,'b','LineWidth',3);
        plot(x_star_v, v_star_mean,'r--','LineWidth',3);
        %plot(ModelInfo.x_v, ModelInfo.v,'ro','MarkerSize',12,'LineWidth',1);
        [l,p] = boundedline(x_star_v, v_star_mean, 2.0*sqrt(v_star_var), ':', 'alpha','cmap', color2);
        outlinebounds(l,p);
        %plot(ModelInfo.x0, ModelInfo.y0,'o','MarkerSize',10,'LineWidth',3);
        %yLimits = get(gca,'YLim');
        xlabel('$0 \leq x \leq 1$')
        %ylabel('$v(t,x)$')
        axis square
        ylim([-5 5]);
        %ylim([yLimits(1) yLimits(2)]);
        set(gca, 'XTick', sort(ModelInfo.x_v));
        set(gca, 'XTickLabel', [])
        set(gca,'TickLength',[0.05 0.05]);
        set(gca,'FontSize',14);
        set(gcf, 'Color', 'w');
        tit = sprintf('Error: %e\n%d artificial data', error_v(i), Ntr_v_artificial);
        title(tit);
        
        % w = waitforbuttonpress;
        drawnow;
        
    end
    
    
end

export_fig ./Figures/Wave_noiseless.png -r300

rmpath ./Utilities
rmpath ~/export_fig
rmpath ./Kernels