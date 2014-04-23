function phi = quadsquare( I )
% the quadratic-quare root transfer function from 
% http://galton.uchicago.edu/~nbrunel/pdfs/boucheny05.pdf
    phi = zeros(size(I));
    for i = 1:size(I,2)
        if I(i) < 0
            phi(i) = 0;
        elseif I(i) <= 1
            phi(i) = I(i)^2;
        else
            phi(i) = 2 * sqrt(I(i) - 3/4);
        end 
    end
end

