function f=Exact_solution(t,x)

    f = 1/2*sin(pi*x).*cos(pi*t) + 1/3*sin(3*pi*x).*sin(3*pi*t);
    
end