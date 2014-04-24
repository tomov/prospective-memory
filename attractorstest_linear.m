
x = [-1:0.2:5];
%x = 1;
cycs = 1000;

%{
I = 0;
li = -2;
se = -2;
ve = 0;
step = 0.2;
%}

I = 3.8;
li = -1;
se = 0;
ve = 0;
step = 0.2;

W = [
    se li
    li se
    ];
b = [I I];

z = zeros(size(x, 2));

for i = 1:size(x, 2)
    for j = 1:size(x, 2)
        a1 = x(i);
        a2 = x(j);
 
        %a1 = 0.5; a2 = -0.5;
        a = [a1 a2];
        net = [0 0];
        avg = [0 0];
        act = zeros(cycs+1, 2);
                                                %act(1,:) = 1 ./ (1 + exp(-a));
                                                act(1,:) = a;
        for cyc = 1:cycs
            net = a * W + b;
                                                %da = net;
                                                da = -a + quadsquare(b + a * W);
            a = a + step * da;
                                                %act(cyc+1,:) = 1 ./ (1 + exp(-a));
                                                act(cyc+1,:) = a;
        end
        z(i, j) = norm(act(end,:) - act(1,:));
        
        if size(x, 2) == 1
            figure;
            plot(act);
            ylim([0 4]);
        end
    end
end

if size(x, 2) > 1
    figure;
    surf(x, x, z);
end