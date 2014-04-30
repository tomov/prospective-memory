
x = [-1:0.2:5];
x = 1;
cycs = 150;

%{
I = 0;
li = -2; % lateral inhibition
se = -2; % self-excitation
ve = 0; % vertical excitation
ci = 0; % cross-inhibition
step = 0.2;
%}

I = 4;
li = -2; % lateral inhibition
se = -2; % self-excitation
ve = -1; % vertical excitation
ci = -1; % cross-inhibition
step = 0.1;


W = [
    se li ve ci -2;
    li se ci ve -2;
    ve ci se li -2;
    ci ve li se -2;
    -2 -2 -2 -2 se;
    ];
b = [I I I I I];
init_a = [4 0 1.5 2 10];

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
            
            if cyc > 50 && cyc < 90
                b(2) = 15;
            else
                if cyc == 90
                    a(1:5) = init_a(1:5);
                end
                b(2) = I;
            end

            %if cyc > 20 && cyc < 40
            %    b(5) = 15;
            %else
            %    b(5) = I;
            %end
            
                                                da = net;
                                                %da = -a + quadsquare(b + a * W);
            a = a + step * da;
            a = min(a, 5);
            a = max(a, -5);
                                                %act(cyc+1,:) = 1 ./ (1 + exp(-a));
                                                act(cyc+1,:) = a;
        end
        z(i, j) = norm(act(end,:) - act(1,:));
        
        if size(x, 2) == 1
            figure;
            
            plot(act, 'LineWidth', 2);
            ylim([-5 6]);
            legend('OG Task', 'PM Task', 'OG Features', 'PM Features', 'Load');
            ylabel('activation');
            xlabel('cycle');
            line([10 10],ylim, 'LineStyle', '--', 'Color',[0.5 0.5 0.5]);
            line([50 50],ylim, 'LineStyle', '--', 'Color',[0.5 0.5 0.5]);
            line([90 90],ylim, 'LineStyle', '--', 'Color',[0.5 0.5 0.5]);
            
            line([110 110],ylim, 'LineStyle', '--', 'Color',[0.5 0.5 0.5]);
            
            text(12, -4.4, 'trial #1');
            text(52, -4.4, 'trial #2');
            
            %text(92, -4.4, 'trial #3');
            text(92, -4.4, 'end trial');            
            text(112, -4, 'trial #3');
            
            %title('Ongoing Trials, 5 WM units');            
            title('Task Switch, 5 WM units');
            
            figureHandle = gcf;
            set(findall(figureHandle,'type','text'),'fontSize',14);
        end
    end
end

if size(x, 2) > 1
    figure;
    surf(x, x, z);
end