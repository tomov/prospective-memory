
%x = [-1:0.2:5];
x = 1;
cycs = 5000;

%{
I = 0;
li = -2; % lateral inhibition
se = -2; % self-excitation
ve = 0; % vertical excitation
ci = 0; % cross-inhibition
step = 0.2;
%}

I = 0.33;
alpha = 2.0;
beta = 0.15;
step = 0.01;
n = 6;


W = 1 - eye(n);
b = zeros(1, n);

z = zeros(size(x, 2));

for i = 1:size(x, 2)
    for j = 1:size(x, 2)
        a1 = x(i);
        a2 = x(j);
 
        a = [a1 a2 a1 a2];
        if size(x, 2) == 1
            a = zeros(1, n);
        end
        act = zeros(cycs+1, n);
        
                                                %act(1,:) = 1 ./ (1 + exp(-a));
                                                act(1,:) = a;
        for cyc = 1:cycs
            for k = 1:n
                start = k * 300 + 10;
                finish = start + 500;
                if cyc > start && cyc < finish
                    b(k) = I;
                else
                    b(k) = -0.1;
                end
            end
            
            da = alpha * F(a) - beta * F(a * W) + b + normrnd(0, 0.2, size(a));
            a = (1 - step) * a + step * da;
            %a = max(a, 0);
                                                %act(cyc+1,:) = 1 ./ (1 + exp(-a));
                                                act(cyc+1,:) = F(a);
        end
        z(i, j) = norm(act(end,:) - act(1,:));
        
        if size(x, 2) == 1
            figure;
            plot(act);
            ylim([-0.1 1.1]);
            legend('1', '2', '3', '4', '5', '6');
        end
    end
end

if size(x, 2) > 1
    figure;
    surf(x, x, z);
end