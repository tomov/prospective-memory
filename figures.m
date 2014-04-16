
figure;

subplot(4, 2, 1);
plot(act(:, sim.output_ids));
legend(sim.units(sim.output_ids));
title('Outputs');
ylim([sim.MINIMUM_ACTIVATION - 0.1 sim.MAXIMUM_ACTIVATION + 0.1]);

subplot(4, 2, 3);
plot(act(:, sim.response_ids));
legend(sim.units(sim.response_ids));
title('Responses');
ylim([sim.MINIMUM_ACTIVATION - 0.1 sim.MAXIMUM_ACTIVATION + 0.1]);

subplot(4, 2, 5);
plot(act(:, sim.perception_ids));
legend(sim.units(sim.perception_ids));
title('Feature Perception');
ylim([sim.MINIMUM_ACTIVATION - 0.1 sim.MAXIMUM_ACTIVATION + 0.1]);

subplot(4, 2, 7);
plot(act(:, sim.input_ids));
legend(sim.units(sim.input_ids));
title('Stimulus Inputs');
ylim([sim.MINIMUM_ACTIVATION - 0.1 sim.MAXIMUM_ACTIVATION + 0.1]);

subplot(4, 2, 4);
plot(act(:, sim.task_ids));
legend(sim.units(sim.task_ids));
title('Task Representation');
ylim([sim.MINIMUM_ACTIVATION - 0.1 sim.MAXIMUM_ACTIVATION + 0.1]);

%subplot(4, 2, 4);
%plot(act(:, sim.monitor_ids));
%legend(sim.units(sim.monitor_ids));
%title('Target Monitoring');
%ylim([sim.MINIMUM_ACTIVATION sim.MAXIMUM_ACTIVATION]);

subplot(4, 2, 2);
plot(acc(:, :));
legend(sim.units(sim.output_ids));
title('Evidence Accumulation');
%ylim([sim.MINIMUM_ACTIVATION sim.MAXIMUM_ACTIVATION]);

%subplot(4, 2, 6);
%plot(act(:, sim.target_ids));
%legend(sim.units(sim.target_ids));
%title('Target Detection');
%ylim([sim.MINIMUM_ACTIVATION sim.MAXIMUM_ACTIVATION]);

subplot(4, 2, 6);
plot(act(:, sim.attention_ids));
legend(sim.units(sim.attention_ids));
title('Feature Attention');
ylim([sim.MINIMUM_ACTIVATION - 0.1 sim.MAXIMUM_ACTIVATION + 0.1]);

%subplot(3, 2, 6);
%plot(act(:, sim.unit_id('Super Inhibition')));
%legend(sim.units(sim.unit_id('Super Inhibition')));
%title('Super Inhibition');


RTs
responses





bar_names = {'OG correct', 'PM hit', 'false alarm', 'OG wrong', 'PM miss', 'OG timeout', 'PM timeout'};
OG_count = 0;
PM_count = 0;
OG_correct_RTs = [];
PM_hit_RTs = [];
false_alarm_RTs = [];
OG_wrong_RTs = [];
PM_miss_RTs = [];
OG_timeout_RTs = [];
PM_timeout_RTs = [];

for i=1:size(responses, 1)
    if strcmp(responses{i}, correct{i}) == 1
        % right answer
        if is_target(i) == 0
            % OG correct
            OG_count = OG_count + 1;
            OG_correct_RTs = [OG_correct_RTs; RTs(i)];
        else
            % PM hit
            PM_count = PM_count + 1;
            PM_hit_RTs = [PM_hit_RTs; RTs(i)];
        end
    else
        % wrong answer
        if is_target(i) == 0
            OG_count = OG_count + 1;
            % timeout
            if strcmp(responses{i}, 'timeout') == 1
                OG_timeout_RTs = [OG_timeout_RTs; RTs(i)];
                continue;
            end
            if strcmp(responses{i}, 'say:PM') == 1
                % false alarm
                false_alarm_RTs = [false_alarm_RTs; RTs(i)];
            else
                % OG wrong
                OG_wrong_RTs = [OG_wrong_RTs; RTs(i)];
            end
        else
            PM_count = PM_count + 1;
            % timeout
            if strcmp(responses{i}, 'timeout') == 1
                PM_timeout_RTs = [PM_timeout_RTs; RTs(i)];
                continue;
            end
            % PM miss
            PM_miss_RTs = [PM_miss_RTs; RTs(i)];
        end
    end
end

OG_count
PM_count


figure;

subplot(1, 2, 1);
bar([mean(OG_correct_RTs), mean(PM_hit_RTs), ...
    mean(false_alarm_RTs), mean(OG_wrong_RTs), mean(PM_miss_RTs), ...
    mean(OG_timeout_RTs), mean(PM_timeout_RTs)]);
set(gca, 'XTickLabel', bar_names);
ylim([0 sim.CYCLES_PER_SEC]);
title('RT (cycles)', 'FontWeight','bold');

subplot(1, 2, 2);
bar(100 * [size(OG_correct_RTs, 1) / OG_count, size(PM_hit_RTs, 1) / PM_count, ...
    size(false_alarm_RTs, 1) / OG_count, size(OG_wrong_RTs, 1) / OG_count, size(PM_miss_RTs, 1) / PM_count, ...
    size(OG_timeout_RTs, 1) / OG_count, size(PM_timeout_RTs, 1) / PM_count]);
set(gca, 'XTickLabel', bar_names);
ylim([0 100]);
title('Fraction of responses (%)', 'FontWeight','bold');
ylim([0 100]);


fprintf('mean OG correct RTs = %.4f (%.4f)\n', mean(OG_correct_RTs), std(OG_correct_RTs));
fprintf('mean PM hit RTs = %.4f (%.4f)\n', mean(PM_hit_RTs), std(PM_hit_RTs));
fprintf('OG accuracy = %.4f%%\n', size(OG_correct_RTs, 1) / OG_count * 100);
fprintf('PM hit rate = %.4f%%\n', size(PM_hit_RTs, 1) / PM_count * 100);

