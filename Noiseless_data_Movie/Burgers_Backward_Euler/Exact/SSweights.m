function [ alpha, beta, gamma ] = BDFweights(J)

switch J
    case 1
        alpha = [1.0, 0.0, 0.0];
        beta = [1.0, 0.0, 0.0];
        gamma = 1.0;
    case 2
%         alpha = [2.0, -0.5, 0.0];
        alpha = [1.0, 0.0, 0.0];
        beta = [2.0, -1.0/2.0, 0.0];
        gamma = 3.0/2.0;
    case 3
%         alpha = [3.0, -3.0/2.0, 1.0/3.0];
        alpha = [1.0, 0.0, 0.0];
        beta = [3.0, -3.0/2.0, 1.3];
        gamma = 11.0/6.0;
    otherwise
        disp('unsupported integration order')
end


end

