function s = getstats(sim, OG_ONLY, FOCAL, EMPHASIS, responses, RTs, act, acc, onsets, is_target, correct)

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
            if strcmp(responses{i}, 'PM') == 1
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


%{
RTs
responses
OG_count
PM_count
%}

if OG_ONLY
    og_string = 'No PM task';
else
    og_string = 'PM task';
end
if FOCAL
    if EMPHASIS
        fprintf('\n ----> focal, high emphasis, %s ----\n', og_string);
    else
        fprintf('\n ----> focal, low emphasis, %s ----\n', og_string);
    end
else
    if EMPHASIS
        fprintf('\n ----> nonfocal, high emphasis, %s ----\n', og_string);
    else
        fprintf('\n ----> nonfocal, low emphasis, %s ----\n', og_string);
    end
end

%if ~OG_ONLY
    fprintf('mean OG correct RTs = %.4f (%.4f)\n', mean(OG_correct_RTs), std(OG_correct_RTs));
    fprintf('mean PM hit RTs = %.4f (%.4f)\n', mean(PM_hit_RTs), std(PM_hit_RTs));
    fprintf('OG accuracy = %.4f%%\n', size(OG_correct_RTs, 1) / OG_count * 100);
    fprintf('PM hit rate = %.4f%%\n', size(PM_hit_RTs, 1) / PM_count * 100);
%end


% save stats for fits

RT = mean(OG_correct_RTs);
% http://en.wikipedia.org/wiki/Standard_error !!!
SD = std(OG_correct_RTs) / sqrt(size(OG_correct_RTs, 2));
OG = size(OG_correct_RTs, 1) / OG_count * 100;
PM = size(PM_hit_RTs, 1) / PM_count * 100;

s = [RT SD OG PM];





% show figures

if true
    figure;

    t_range = 1:2000;
    y_lim = [sim.MINIMUM_ACTIVATION - 0.1 sim.MAXIMUM_ACTIVATION + 0.1];
    bar_names = {'OG correct', 'PM hit', 'false alarm', 'OG wrong', 'PM miss', 'OG timeout', 'PM timeout'};
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

    subplot(4, 2, 2);
    plot(acc(t_range, :));
    legend(sim.units(sim.output_ids));
    title('Evidence Accumulation');
    %ylim([sim.MINIMUM_ACTIVATION sim.MAXIMUM_ACTIVATION]);

    subplot(4, 2, 4);
    plot(act(t_range, sim.task_ids));
    legend(sim.units(sim.task_ids));
    title('Task Representation');
    ylim(y_lim);
    line([onset_plot onset_plot],y_lim,'Color',[0.5 0.5 0.5])

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

end