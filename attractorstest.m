
x = [0:0.02:1];
cycs = 100;

W = [
    3 -2.4;
    -2.4 3
    ];
b = [0 0];

z = zeros(size(x, 2));

for i = 1:size(x, 2)
    for j = 1:size(x, 2)
        a1 = x(i);
        a2 = x(j);
        z(i, j) = a1 + a2;
        
        a = [a1 a2];
        net = [0 0];
        act = zeros(cycs+1, 2);
        act(1,:) = a;
        for cyc = 1:cycs
            net = a * W + b;
            a = 1 ./ (1 + exp(-net));
            act(cyc+1,:) = a;
        end
        z(i, j) = norm(act(end,:) - act(1,:));
        
        %plot(act);
        %ylim([0 1]);
    end
end

figure;
surf(x, x, z);
%act = 1 ./ (1 + exp(-net));