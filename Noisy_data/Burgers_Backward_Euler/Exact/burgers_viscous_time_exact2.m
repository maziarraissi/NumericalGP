function u = burgers_viscous_time_exact2 ( nu, xn, x, tn, t )

%*****************************************************************************80
%
%% BURGERS_VISCOUS_TIME_EXACT2 evaluates a solution to the Burgers equation.
%
%  Discussion:
%
%    The form of the Burgers equation considered here is:
%
%      du       du        d^2 u
%      -- + u * -- = nu * -----
%      dt       dx        dx^2
%
%    for 0.0 < x < 2 Pi and 0 < t.
%
%    The initial condition is
%
%      u(x,0) = 4 - 2 * nu * dphi(x,0)/dx / phi(x,0)
%
%    where
%
%      phi(x,t) = exp ( - ( x-4*t      ) / ( 4*nu*(t+1) ) )
%               + exp ( - ( x-4*t-2*pi ) / ( 4*nu*(t+1) ) )
%
%    The boundary conditions are periodic:
%
%      u(0,t) = u(2 Pi,t)
%
%    The viscosity parameter nu may be taken to be 0.01, but other values
%    may be chosen.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    24 September 2015
%
%  Author:
%
%    John Burkardt.
%
%  Parameters:
%
%    Input, real NU, the viscosity.
%
%    Input, integer XN, the number of spatial grid points.
%
%    Input, real X(XN), the spatial grid points.
%
%    Input, integer TN, the number of time grid points.
%
%    Input, real T(TN), the time grid points.
%
%    Output, real U(XN,TN), the solution of the Burgers
%    equation at each space and time grid point.
%
  u = zeros ( xn, tn );

  for j = 1 : tn

    for i = 1 : xn

      a = ( x(i) - 4.0 * t(j) );
      b = ( x(i) - 4.0 * t(j) - 2.0 * pi );
      c = 4.0 * nu * ( t(j) + 1.0 );
      phi = exp ( - a ^ 2 / c ) + exp ( - b ^ 2 / c );
      dphi = - 2.0 * a * exp ( - a ^ 2 / c ) / c ...
             - 2.0 * b * exp ( - b ^ 2 / c ) / c;
      u(i,j) = 4.0 - 2.0 * nu * dphi / phi;

    end

  end

  return
end
