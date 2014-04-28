function act = F( x )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    act = zeros(size(x));
    act(x > 0) = x(x > 0) ./ (1 + x(x > 0));
end

