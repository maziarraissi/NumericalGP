function f=Exact_solution_x2(t,xx)

x1 = xx(:,1);
x2 = xx(:,2);

f = (1/2).*pi.*exp(1).^((-5/4).*pi.^2.*t).*sin(pi.*x1).*cos((1/2).*pi.*x2);

end