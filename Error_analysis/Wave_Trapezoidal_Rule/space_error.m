set(0,'defaulttextinterpreter','latex')
addpath ~/export_fig

nn = 10;
error_u = zeros(1,nn);
error_v = zeros(1,nn);
T = 0.2;
dt = 10^-2;
Ntr = 4:4+nn-1;
for i = 1:nn
    [error_u(i),error_v(i)] = main(Ntr(i),dt,T);
end
error_u(6) = [];
error_v(6) = [];
Ntr(6) = [];

semilogy(Ntr,error_u,'-*b',Ntr,error_v,'-+k', 'LineWidth', 2, 'MarkerSize', 10);
axis square
axis tight
h = legend('Error: $u$','Error: $v$','Location','NorthEast');
set(h,'Interpreter','latex');
xlabel('number of data points')
ylabel('Error')
set(gca,'FontSize',14);
set(gcf, 'Color', 'w');
tit = sprintf('Time: 0.2');
title(tit);

export_fig ./Figures/Wave_space_error.png -r300
% buf = sprintf('time_error_Ntr%d.txt', Ntr);
% save(buf,'-ascii','-double', 'error');