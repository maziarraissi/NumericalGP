function f=Exact_solution(t,xx)

x1 = xx(:,1);
x2 = xx(:,2);

f = exp(1).^((-5/4).*pi.^2.*t).*sin(pi.*x1).*sin((1/2).*pi.*x2);

end