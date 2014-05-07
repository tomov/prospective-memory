
x = [-1:0.2:5];
x = 1;
cycs = 80000;

%{
I = 0;
li = -2; % lateral inhibition
se = -2; % self-excitation
ve = 0; % vertical excitation
ci = 0; % cross-inhibition
step = 0.2;
%}

I = 3;
li = -2; % lateral inhibition
se = -2 + 0.0004; % self-excitation
ve = -1; %-1; % vertical excitation
ci = -1; %-1; % cross-inhibition
step = 0.1;


W = [
    se li ve ci -1;
    li se ci ve -1;
    ve ci se li -1;
    ci ve li se -1;
    -1 -1 -1 -1 -2;
    ];
b_high = [I I I I 0];
b_low = b_high / 10;
b = b_high;
init_a = [1 0.6 1 0.9 0];

z = zeros(size(x, 2));

for i = 1:size(x, 2)
    for j = 1:size(x, 2)
        a1 = x(i);
        a2 = x(j);
 
        a = [a1 a2 a1 a2];
        if size(x, 2) == 1
            a = init_a;
        end
        net = [0 0 0 0];
        avg = [0 0 0 0];
        act = zeros(cycs+1, 5);
                                                %act(1,:) = 1 ./ (1 + exp(-a));
                                                act(1,:) = a;
        for cyc = 1:cycs
            net = a * W + b;

            
            %{
            if cyc > 40 && cyc < 45
                b(5) = I * 1.2;
            else
                %b(5) = 0;
            end
            %}
            
            
            %{
            if cyc > 40 && cyc < 45
                b(1) = I * 1.2;
                b(2) = I * 1.8;
                b(3) = I * 0.7;
                b(4) = I * 0.5;
            else
                b(:) = I;
            end
            %}
            
            
            if cyc > 90 && cyc < 130
                b(2) = 4;
            else
                if cyc == 130 || cyc == 131
                    a(1:2) = init_a(1:2);
                end
                b(2) = I;
            end
            
            %b = b - b * 0.00001;
            
            %{
            if cyc > 50 && cyc < 70
                b = b_low;
            else
                b = b_high;
            end
            %}

            
            %if cyc > 20 && cyc < 40
            %    b(5) = 15;
            %else
            %    b(5) = I;
            %end
            
                                                da = net;
                                                %da = -a + quadsquare(b + a * W);
            a = a + step * da;
            a = min(a, 1);
            a = max(a, 0);
                                                %act(cyc+1,:) = 1 ./ (1 + exp(-a));
                                                act(cyc+1,:) = a;
        end
        z(i, j) = norm(act(end,:) - act(1,:));
        
        if size(x, 2) == 1
            figure;
            
            plot(act(:,1:4), 'LineWidth', 2);
            ylim([0 1]);
            %xlim([0 220]);
            legend('OG Task', 'PM Task', 'OG attention', 'PM attention', 'WM Load');
            ylabel('activation');
            xlabel('cycle');
            %{
            line([10 10],ylim, 'LineStyle', '--', 'Color',[0.5 0.5 0.5]);
            line([50 50],ylim, 'LineStyle', '--', 'Color',[0.5 0.5 0.5]);
            line([90 90],ylim, 'LineStyle', '--', 'Color',[0.5 0.5 0.5]);
            line([130 130],ylim, 'LineStyle', '--', 'Color',[0.5 0.5 0.5]);
            line([41 41],ylim, 'LineStyle', '-', 'Color',[0.5 0.5 0.5]);
            line([150 150],ylim, 'LineStyle', '--', 'Color',[0.5 0.5 0.5]);
            line([190 190],ylim, 'LineStyle', '--', 'Color',[0.5 0.5 0.5]);
            %line([130 130],ylim, 'LineStyle', '--', 'Color',[0.5 0.5 0.5]);
            
%            line([110 110],ylim, 'LineStyle', '--', 'Color',[0.5 0.5 0.5]);
            
            text(12, 0.1, 'trial #1');
            text(52, 0.1, 'trial #2');
            
            text(92,  0.1, 'trial #3');
            %text(92,  0.05, '(target)');
            %text(92, 0.1, 'end trial');            
            text(132,  0.15, 'end trial');
            text(152, 0.1, 'trial #4');

            text(192, 0.1, 'trial #5');
            %text(112, 0.1, 'trial #3');
            %}
            
            %title('Ongoing Trials, 5 WM units');            
            title('WM Activations over time');
            
            figureHandle = gcf;
            set(findall(figureHandle,'type','text'),'fontSize',14);
        end
    end
end

if size(x, 2) > 1
    figure;
    surf(x, x, z);
end