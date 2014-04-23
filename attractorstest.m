
x = [-5:0.3:5];
%x = 1
cycs = 300;

I = 0;
li = -2;
se = 3;
ve = 0;

W = [
    se-0.21 li-0.5 ve 0;
    li se 0 ve;
    ve 0 se-0.21 li-0.5;
    0 ve li se;
    ];
b = [I I I I];
tau = 0.1;
instruction = 10;

z = zeros(size(x, 2));

for i = 1:size(x, 2)
    for j = 1:size(x, 2)
        i1 = x(i);
        i2 = x(j)+0.1;
        
        %i1 = -5;
        %i2 = 5;
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
            legend('1','2','3','4');
        end
    end
end

if size(x, 2) > 1
    figure;
    surf(x, x, z);
end