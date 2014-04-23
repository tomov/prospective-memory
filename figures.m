figure;

t_range = 1:2000;
y_lim = [sim.MINIMUM_ACTIVATION - 0.1 sim.MAXIMUM_ACTIVATION + 0.1];
onset_plot = onsets(onsets < t_range(end));

subplot(4, 2, 1);
plot(act(t_range, sim.output_ids));
legend(sim.units(sim.output_ids));
title('Outputs');
ylim(y_lim);

subplot(4, 2, 3);
plot(act(t_range, sim.response_ids));
legend(sim.units(sim.response_ids));
title('Responses');
ylim(y_lim);

subplot(4, 2, 5);
plot(act(t_range, sim.perception_ids));
legend(sim.units(sim.perception_ids));
title('Feature Perception');
ylim(y_lim);

subplot(4, 2, 7);
plot(act(t_range, sim.input_ids));
legend(sim.units(sim.input_ids));
title('Stimulus Inputs');
ylim(y_lim);

subplot(4, 2, 4);
plot(act(t_range, sim.task_ids));
legend(sim.units(sim.task_ids));
title('Task Representation');
ylim(y_lim);
line([onset_plot onset_plot],y_lim,'Color',[0.5 0.5 0.5])

subplot(4, 2, 2);
plot(acc(t_range, :));
legend(sim.units(sim.output_ids));
title('Evidence Accumulation');
%ylim([sim.MINIMUM_ACTIVATION sim.MAXIMUM_ACTIVATION]);

subplot(4, 2, 6);
plot(act(t_range, sim.attention_ids));
legend(sim.units(sim.attention_ids));
title('Feature Attention');
ylim(y_lim);
line([onset_plot onset_plot],y_lim,'Color',[0.5 0.5 0.5])





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

