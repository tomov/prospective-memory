% Initialize inputs and correct outputs for all trials
%

T_ongoing = 10000;
T_PM = T_ongoing * 2;

inputs = [];
inputs = [inputs; repmat({'a B'}, T_ongoing, 1)];
inputs = [inputs; repmat({'a C'}, T_ongoing, 1)];
inputs = [inputs; repmat({'b A'}, T_ongoing, 1)];
inputs = [inputs; repmat({'b C'}, T_ongoing, 1)];
inputs = [inputs; repmat({'c A'}, T_ongoing, 1)];
inputs = [inputs; repmat({'c B'}, T_ongoing, 1)];

inputs = [inputs; repmat({'A b'}, T_ongoing, 1)];
inputs = [inputs; repmat({'A c'}, T_ongoing, 1)];
inputs = [inputs; repmat({'B a'}, T_ongoing, 1)];
inputs = [inputs; repmat({'B c'}, T_ongoing, 1)];
inputs = [inputs; repmat({'C a'}, T_ongoing, 1)];
inputs = [inputs; repmat({'C b'}, T_ongoing, 1)];

inputs = [inputs; repmat({'a A'}, T_PM, 1)];
inputs = [inputs; repmat({'b B'}, T_PM, 1)];
inputs = [inputs; repmat({'c C'}, T_PM, 1)];
inputs = [inputs; repmat({'A a'}, T_PM, 1)];
inputs = [inputs; repmat({'B b'}, T_PM, 1)];
inputs = [inputs; repmat({'C c'}, T_PM, 1)];

correct = [];
correct = [correct; repmat({'Right'}, 6 * T_ongoing, 1)];
correct = [correct; repmat({'Left'}, 6 * T_ongoing, 1)];
correct = [correct; repmat({'PM'}, 6 * T_PM, 1)];

assert(size(inputs, 1) == size(correct, 1), 'Input and output arrays must be of same size');
T = size(inputs, 1);


% Initialize simulators
%

names = {'No monitoring', 'Standard', 'High monitoring', 'Stimulus degradation'};
sim = [Simulator(), Simulator(), Simulator(), Simulator()];
sim(1).MONITORING_ACTIVATION = 0;
sim(3).MONITORING_ACTIVATION = 1;
sim(4).INPUT_ACTIVATION = 0.9;
S = size(sim, 2);


% Simulate trials
%

outputs = cell(T, S);
cycles = cell(T, S);
activation_logs = cell(T, S);

for i=1:S
    tic;
    simulator = sim(i);
    [outputs(:,i), cycles(:,i), activation_logs(:,i)] = cellfun(@simulator.trial, inputs, num2cell(ones(T, 1)), 'UniformOutput', false);
    toc
end






% Calculate results
%

ongoing_RT = zeros(T, S);
ongoing_RT_cnt = zeros(1, S);
PM_hits = zeros(T, S);
PM_hits_cnt = 0;
ongoing_accuracy = zeros(T, S);
ongoing_accuracy_cnt = 0;

PM_miss_RT = zeros(T, S);
PM_miss_RT_cnt = zeros(1, S);
PM_hit_RT = zeros(T, S);
PM_hit_RT_cnt = zeros(1, S);

for i = 1:T
    % get ongoing RT
    if strcmp(correct(i),'PM') == 0
        for j = 1:S
            if strcmp(outputs{i, j}, correct(i)) == 1
                ongoing_RT_cnt(j) = ongoing_RT_cnt(j) + 1;
                ongoing_RT(ongoing_RT_cnt(j), j) = cycles{i,j};
            end
        end
    end
    
    % get PM hits
    if strcmp(correct(i),'PM') == 1
        PM_hits_cnt = PM_hits_cnt + 1;
        for j = 1:S
            if strcmp(outputs{i, j}, correct(i)) == 1
                PM_hits(PM_hits_cnt, j) = 1;
            end
        end
    end
    
    % get ongoing accuracy
    if strcmp(correct(i),'PM') == 0
        ongoing_accuracy_cnt = ongoing_accuracy_cnt + 1;
        for j = 1:S
            if strcmp(outputs{i, j}, correct(i)) == 1
                ongoing_accuracy(ongoing_accuracy_cnt, j) = 1;
            end
        end
    end

    % get PM hit/miss RT
    if strcmp(correct(i),'PM') == 1
        for j = 1:S
            if strcmp(outputs{i, j}, correct(i)) == 1
                PM_hit_RT_cnt(j) = PM_hit_RT_cnt(j) + 1;
                PM_hit_RT(PM_hit_RT_cnt(j), j) = cycles{i,j};
            elseif strcmp(outputs{i, j}, 'Timeout') == 0 % don't count timeouts as misses
                PM_miss_RT_cnt(j) = PM_miss_RT_cnt(j) + 1;
                PM_miss_RT(PM_miss_RT_cnt(j), j) = cycles{i,j};
            end
        end
    end
end


% for figure 3 -- extract standard RT's
ongoing_RT_std = ongoing_RT(:, 2);
PM_hit_RT_std = PM_hit_RT(:, 2);
PM_miss_RT_std = PM_miss_RT(:, 2);
ongoing_RT_std(ongoing_RT_cnt(2)+1:end) = [];
PM_hit_RT_std(PM_hit_RT_cnt(2)+1:end) = [];
PM_miss_RT_std(PM_miss_RT_cnt(2)+1:end) = [];

% for figures 1 and 2 -- average results
ongoing_RT = sum(ongoing_RT) ./ ongoing_RT_cnt;
PM_hits = sum(PM_hits) / PM_hits_cnt * 100;
ongoing_accuracy = sum(ongoing_accuracy) / ongoing_accuracy_cnt * 100;
PM_hit_RT = sum(PM_hit_RT) ./ PM_hit_RT_cnt;
PM_miss_RT = sum(PM_miss_RT) ./ PM_miss_RT_cnt;




% Plot results
%

% Figure 2
figure;

fig2_a = ongoing_RT(1:3);
subplot(1, 3, 1);
bar(fig2_a);
set(gca,'XTickLabel', {names{1}, names{2}, names{3}});
title('Mean ongoing RT (cycles)', 'FontWeight','bold');

fig2_b = PM_hits(1:3);
subplot(1, 3, 2);
bar(fig2_b);
set(gca,'XTickLabel', {names{1}, names{2}, names{3}});
title('Mean PM hits (%)', 'FontWeight','bold');

fig2_c = ongoing_accuracy(1:3);
subplot(1, 3, 3);
bar(fig2_c);
set(gca,'XTickLabel', {names{1}, names{2}, names{3}});
title('Mean ongoing accuracy (%)', 'FontWeight','bold');

% Figure 3
figure;

fig3_a = [PM_miss_RT(2), PM_miss_RT(4);
          ongoing_RT(2), ongoing_RT(4);
          PM_hit_RT(2) , PM_hit_RT(4)];
subplot(1, 2, 1);
bar(fig3_a);
set(gca,'XTickLabel', {'PM miss', 'Ongoing', 'PM hit'});
legend('Standard', 'Degraded input');
title('RT (cycles)', 'FontWeight','bold');
      
fig3_b = [ongoing_accuracy(2), ongoing_accuracy(4);
          PM_hits(2)         , PM_hits(4)];
subplot(1, 2, 2);
bar(fig3_b);
set(gca,'XTickLabel', {'Ongoing', 'PM'});
legend('Standard', 'Degraded input');
title('Accuracy (%)', 'FontWeight','bold');

% Figure 4
figure;

subplot(1, 3, 1);
hist(ongoing_RT_std, 40);
xlabel('RT (cycles)');
CV = std(ongoing_RT_std) / mean(ongoing_RT_std);
title(strcat('Ongoing: CV = ', num2str(CV)), 'FontWeight','bold');

subplot(1, 3, 2);
hist(PM_miss_RT_std, 40);
xlabel('RT (cycles)');
CV = std(PM_miss_RT_std) / mean(PM_miss_RT_std);
title(strcat('PM miss: CV = ', num2str(CV)), 'FontWeight','bold');

subplot(1, 3, 3);
hist(PM_hit_RT_std, 40);
xlabel('RT (cycles)');
CV = std(PM_hit_RT_std) / mean(PM_hit_RT_std);
title(strcat('PM hit: CV = ', num2str(CV)), 'FontWeight','bold');
