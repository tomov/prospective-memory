
%x = [-1:0.2:5];
x = 1;
cycs = 1000;

%{
I = 0;
li = -2; % lateral inhibition
se = -2; % self-excitation
ve = 0; % vertical excitation
ci = 0; % cross-inhibition
step = 0.2;
%}

I = 3.8;
li = -1; % lateral inhibition
se = 0; % self-excitation
ve = 0; % vertical excitation
ci = 0.002; % cross-inhibition
step = 0.2;


W = [
    se li ve ci;
    li se ci ve;
    ve 0 se li;
    0 ve li se;
    ];
b = [I I I I];

z = zeros(size(x, 2));

for i = 1:size(x, 2)
    for j = 1:size(x, 2)
        a1 = x(i);
        a2 = x(j);
 
        a = [a1 a2 a1 a2];
        if size(x, 2) == 1
            a = [4 0 1.5 2];
        end
        net = [0 0 0 0];
        avg = [0 0 0 0];
        act = zeros(cycs+1, 4);
                                                %act(1,:) = 1 ./ (1 + exp(-a));
                                                act(1,:) = a;
        for cyc = 1:cycs
            net = a * W + b;
                                               % da = net;
                                                da = -a + quadsquare(b + a * W);
            a = a + step * da;
                                                %act(cyc+1,:) = 1 ./ (1 + exp(-a));
                                                act(cyc+1,:) = a;
        end
        z(i, j) = norm(act(end,:) - act(1,:));
        
        if size(x, 2) == 1
            figure;
            plot(act);
            ylim([-3 5]);
            legend('1', '2', '3', '4');
        end
    end
end

if size(x, 2) > 1
    figure;
    surf(x, x, z);
end