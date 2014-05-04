function plot_all_conditions_exp3( stats, ymin, ymax, slope, intercept, show_legend)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

target_titles = {'1 Target', '6 Targets'};
markers = {'b-o', 'r-*'};
emphasis_titles = {'Low', 'High'};
og_only_titles = {'PM', 'No-PM'};
handles = [];

legend_titles = {};
for EMPHASIS = 0:1
    xticklabels = {};
    values = [];
    errors = [];
    xes = [];
    x = 1;
    for OG_ONLY = 1:-1:0
        target_idx = 0;
        for TARGETS = 1
            target_idx = target_idx + 1;
            stat = stats(stats(:, 1) == OG_ONLY & stats(:, 2) == TARGETS & stats(:, 3) == EMPHASIS, :);
            M = stat(4) * slope + intercept;
            SD = stat(5) * slope;
            values = [values, M];
            errors = [errors, SD];
            xes = [xes, x];
            x = x + 1;
            xlabel = sprintf('%s, %s', target_titles{target_idx}, og_only_titles{OG_ONLY+1});
            xticklabels = [xticklabels,  {xlabel}];
        end
    end
    hold on;
    errorbar(xes, values, errors);
    handle = plot(xes, values, markers{EMPHASIS + 1}, 'LineWidth', 2, 'MarkerSize', 6);
    handles = [handles, handle];
    legend_titles = [legend_titles; emphasis_titles(EMPHASIS + 1)];
end

hold off;
axis([0 x ymin ymax]);
set(gca, 'XTickLabel', [{''}, xticklabels, {''}]);
if show_legend
    legend(handles, legend_titles);
end



