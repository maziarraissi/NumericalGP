set(0,'defaulttextinterpreter','latex')
addpath ~/export_fig

nn = 10;
error_1 = zeros(1,nn);
error_2 = zeros(1,nn);
T = 0.1;
dt_1 = 10^-2;
dt_2 = 10^-3;
Ntr = 9:9+nn-1;
for i = 1:nn
    error_1(i) = main(Ntr(i),dt_1,T);
    error_2(i) = main(Ntr(i),dt_2,T);
end
semilogy(Ntr,error_1,'-*b', Ntr,error_2,'-+k', 'LineWidth', 2, 'MarkerSize', 10);
axis square
axis tight
h = legend('Error ($\Delta t = 10^{-2}$)','Error ($\Delta t = 10^{-3}$)','Location','NorthEast');
set(h,'Interpreter','latex');
xlabel('number of data points')
ylabel('Error')
set(gca,'FontSize',14);
set(gcf, 'Color', 'w');
tit = sprintf('Time: 0.1');
title(tit);


export_fig ./Figures/Burgers_space_error.png -r300
% buf = sprintf('time_error_Ntr%d.txt', Ntr);
% save(buf,'-ascii','-double', 'error');