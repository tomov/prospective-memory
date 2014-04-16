
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

