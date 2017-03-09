set(0,'defaulttextinterpreter','latex')
addpath ./export_fig

nn = 25;
error = zeros(1,nn);
T = 0.2;
dt = 10^-2;
Ntr = 4:4+nn-1;
for i = 1:nn
    error(i) = main(Ntr(i),dt,T);
end
semilogy(Ntr,error,'-*b', 'LineWidth', 2, 'MarkerSize', 10);
axis square
axis tight
h = legend('Error','Location','NorthEast');
set(h,'Interpreter','latex');
xlabel('number of data points')
ylabel('Error')
set(gca,'FontSize',14);
set(gcf, 'Color', 'w');
tit = sprintf('Time: 0.2');
title(tit);

export_fig ./Figures/Heat_space_error.png -r300
% buf = sprintf('time_error_Ntr%d.txt', Ntr);
% save(buf,'-ascii','-double', 'error');
rmpath ./export_fig