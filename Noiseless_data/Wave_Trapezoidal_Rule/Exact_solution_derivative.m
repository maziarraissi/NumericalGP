function f=Exact_solution_derivative(t,x)

    f = (-1/2).*pi.*sin(pi.*t).*sin(pi.*x)+pi.*cos(3.*pi.*t).*sin(3.*pi.*x);
  
end