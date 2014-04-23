
x = [-10:0.5:10];
%x = 1
cycs = 200;

I = 0;
li = -2.5;
se = 2.5;
ve = 1;

W = [
    se li ve 0;
    li se 0 ve;
    ve 0 se li;
    0 ve li se;
    ];
b = [I I I I];
tau = 0.1;
instruction = 10;

z = zeros(size(x, 2));

for i = 1:size(x, 2)
    for j = 1:size(x, 2)
        i1 = x(i);
        i2 = x(j);
        
        %a = [a1 a2];
        a = [0 0 0 0];
        net = [0 0 0 0];
        avg = [0 0 0 0];
        act = zeros(cycs+1, 4);
        act(1,:) = a;
        for cyc = 1:cycs
            if cyc < instruction
                net = [i1 i2 i1 i2];
            else
                net = a * W + b;
            end
            avg = (1 - tau) * avg + tau * net;
            a = 1 ./ (1 + exp(-avg));
            act(cyc+1,:) = a;
        end
        z(i, j) = norm(act(end,:) - act(instruction,:));
        
        if size(x, 2) == 1
            figure;
            plot(act);
            ylim([0 1]);
        end
    end
end

if size(x, 2) > 1
    figure;
    surf(x, x, z);
end