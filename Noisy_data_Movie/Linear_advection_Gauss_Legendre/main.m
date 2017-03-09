clear all; clc; close all

addpath ./Kernels
addpath ./Utilities
addpath ~/export_fig

rng('default')

global ModelInfo

set(0,'defaulttextinterpreter','latex')

%% Setup
Ntr = 20;
Ntr_artificial = 25;
dim = 1;
lb = zeros(1,dim);
ub = 1.0*ones(1,dim);
jitter = 1e-8;
ModelInfo.jitter=jitter;
noise = 0.2;

plt = 1;

T = 9;
dt = 1e-1;
ModelInfo.dt = dt;

nsteps = T/dt;
nn = 400;
xstar = linspace(lb(1),ub(1),nn)';

num_plots = 3;

movObj = QTWriter('Advection_noisy.mov');
movObj.FrameRate = 4;

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
%     set(fig,'units','normalized','outerposition',[0 0 1 .5])
    set(fig,'units','normalized','outerposition',[0 0 1 1])
    clf
    color2 = [217,95,2]/255;
%     k = 1;
%     subplot(2,num_plots,k)
    hold
    plot(xstar,Exact_solution(0,xstar),'b','LineWidth',3);
    plot(ModelInfo.x_u, ModelInfo.u,'ro','MarkerSize',12,'LineWidth',3);
    %yLimits = get(gca,'YLim');
    xlabel('$0 \leq x \leq 1$')
    ylabel('$u(0,x)$')
    axis square
    ylim([-1.5 1.5]);
    %ylim([yLimits(1) yLimits(2)]);
    set(gca, 'XTick', sort(ModelInfo.x_u));
    set(gca, 'XTickLabel', [])
    set(gca,'TickLength',[0.05 0.05]);
    set(gca,'FontSize',14);
    set(gcf, 'Color', 'w');
    tit = sprintf('Time: %.2f\n%d training points', 0,Ntr);
    title(tit);
    
    
    % w = waitforbuttonpress;
    drawnow;
    
    writeMovie(movObj, getframe(fig));
end

%%
for i = 1:nsteps
    
    [ModelInfo.hyp,~,~] = minimize(ModelInfo.hyp, @likelihood, -5000);
    [NLML,~]=likelihood(ModelInfo.hyp);
    % exp(ModelInfo.hyp)
    
    [Kpred, Kvar] = predictor(xstar);
    Kvar = abs(diag(Kvar));
    Exact = Exact_solution( i*dt, xstar);
    error = norm(Kpred-Exact,2)/norm(Exact,2);
    
    fprintf(1,'Step: %d, Time = %f, NLML = %e, error_u = %e\n', i, i*dt, NLML, error);
    
    x_u = bsxfun(@plus,lb,bsxfun(@times,   lhsdesign(Ntr_artificial,dim)    ,(ub-lb)));
    [ModelInfo.u, ModelInfo.S0] = predictor(x_u);
    ModelInfo.x_u = x_u;
    
    
%     for j = 2:nn-1
%         u_Lax(i+1,j) = aa*u_Lax(i,j-1) + bb*u_Lax(i,j) + cc*u_Lax(i,j+1);
%     end
%     u_Lax(i+1,1) = aa*u_Lax(i,nn-1) + bb*u_Lax(i,1) + cc*u_Lax(i,2);
%     u_Lax(i+1,end) = aa*u_Lax(i,nn-1) + bb*u_Lax(i,end) + cc*u_Lax(i,2);
    
    if plt == 1 %&& mod(i,floor(nsteps/(2*num_plots-1)))==0
%         k = k+1;
%         subplot(2,num_plots,k)
        clf
        hold
        plot(xstar,Exact,'b','LineWidth',3);
        plot(xstar, Kpred,'r--','LineWidth',3);
%         plot(xstar, u_Lax(i+1,:), 'k:','LineWidth',1);
        % plot(ModelInfo.x0, ModelInfo.y0,'ro','MarkerSize',12,'LineWidth',1);
        [l,p] = boundedline(xstar, Kpred, 2.0*sqrt(Kvar), ':', 'alpha','cmap', color2);
        outlinebounds(l,p);
        %plot(ModelInfo.x0, ModelInfo.y0,'o','MarkerSize',10,'LineWidth',3);
        %yLimits = get(gca,'YLim');
        xlabel('$0 \leq x \leq 1$')
        ylabel('$u(t,x)$')
        axis square
        ylim([-1.5 1.5]);
        %ylim([yLimits(1) yLimits(2)]);
        set(gca, 'XTick', sort(ModelInfo.x_u));
        set(gca, 'XTickLabel', [])
        set(gca,'TickLength',[0.05 0.05]);
        set(gca,'FontSize',14);
        set(gcf, 'Color', 'w');
        tit = sprintf('Time: %.2f\n%d artificial data', i*dt ,Ntr_artificial);
        title(tit);
        
        % w = waitforbuttonpress;
        drawnow;
        
        writeMovie(movObj, getframe(fig));
        
    end
    
    
end

movObj.Loop = 'backandforth';
close(movObj);


% buf = sprintf('error_dt%.0e_noise_%f.txt', dt, noise);
% save(buf,'-ascii','-double', 'error');
% figure(2)
% clf
% hold
% plot((dt:dt:T), error)
%
%
export_fig ./Figures/Advection.png -r300