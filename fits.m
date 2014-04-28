% must precompute simulation values from stats, which in turn must be
% called from main.m and iterate over all possibilities of focal/nonfocal
% high/low emphasis
init_goalstats;
set_simstats;

figure;

xticklabel = {'low,no PM', 'high,no PM', 'low,PM', 'high,PM'};

% ------------ OG RT's ----------------

subplot(3, 2, 1);
plot([0 1 2 3], [emp_foc_low_RT_noPM emp_foc_high_RT_noPM emp_foc_low_RT  emp_foc_high_RT], ...
    'b-o', ...
    'LineWidth',2, ...
    'MarkerSize', 6);
hold on;
%errorbar([0 1 2 3], [emp_foc_low_RT_noPM emp_foc_high_RT_noPM emp_foc_low_RT  emp_foc_high_RT], ...
%    [emp_foc_low_SD_noPM emp_foc_high_SD_noPM emp_foc_low_SD  emp_foc_high_SD]);

plot([0 1 2 3], [emp_nonfoc_low_RT_noPM emp_nonfoc_high_RT_noPM emp_nonfoc_low_RT  emp_nonfoc_high_RT], ...
    'r-*', ...
    'LineWidth',2, ...
    'MarkerSize', 6);
%errorbar([0 1 2 3], [emp_nonfoc_low_RT_noPM emp_nonfoc_high_RT_noPM emp_nonfoc_low_RT  emp_nonfoc_high_RT], ...
%    [emp_nonfoc_low_SD_noPM emp_nonfoc_high_SD_noPM emp_nonfoc_low_SD  emp_nonfoc_high_SD]);
hold off;
axis([-0.5 3.5 1000 1700]);
ylabel('RT (msec)');
set(gca, 'XTickLabel', xticklabel);
legend('Focal', 'Nonfocal');
title('Empirical Data (Einstein & McDaniel 2005)');


subplot(3, 2, 2);
plot([0 1 2 3], cyc2rt([sim_foc_low_RT_noPM sim_foc_high_RT_noPM sim_foc_low_RT  sim_foc_high_RT], true), ...
    'b-o', ...
    'LineWidth',2, ...
    'MarkerSize', 6);
hold on;
%errorbar([0 1 2 3], cyc2rt([sim_foc_low_RT_noPM sim_foc_high_RT_noPM sim_foc_low_RT  sim_foc_high_RT], true), ...
%    cyc2rt([sim_foc_low_SD_noPM sim_foc_high_SD_noPM sim_foc_low_SD  sim_foc_high_SD], false));

plot([0 1 2 3], cyc2rt([sim_nonfoc_low_RT_noPM sim_nonfoc_high_RT_noPM sim_nonfoc_low_RT  sim_nonfoc_high_RT], true), ...
    'r-*', ...
    'LineWidth',2, ...
    'MarkerSize', 6);    
%errorbar([0 1 2 3], cyc2rt([sim_nonfoc_low_RT_noPM sim_nonfoc_high_RT_noPM sim_nonfoc_low_RT  sim_nonfoc_high_RT], true), ...
%    cyc2rt([sim_nonfoc_low_SD_noPM sim_nonfoc_high_SD_noPM sim_nonfoc_low_SD  sim_nonfoc_high_SD], false));
hold off;
axis([-0.5 3.5 1000 1700]);
ylabel('RT (msec = 12 * cycles + 150)');
set(gca, 'XTickLabel', xticklabel);
%legend('Focal', 'Nonfocal');
title('Simulation Results');


% ------------ PM hit rates ------------


subplot(3, 2, 3);
plot([2 3], [ emp_foc_low_PM  emp_foc_high_PM], ...
    'b-o', ...
    'LineWidth',2, ...
    'MarkerSize', 6);
hold on;
plot([2 3], [ emp_nonfoc_low_PM  emp_nonfoc_high_PM], ...
    'r-*', ...
    'LineWidth',2, ...
    'MarkerSize', 6);    
hold off;
axis([-0.5 3.5 40 100]);
ylabel('PM Hit Rate (%)');
set(gca, 'XTickLabel', xticklabel);
%legend('Focal', 'Nonfocal');

subplot(3, 2, 4);
plot([2 3], [ sim_foc_low_PM  sim_foc_high_PM], ...
    'b-o', ...
    'LineWidth',2, ...
    'MarkerSize', 6);    
hold on;
plot([2 3], [ sim_nonfoc_low_PM  sim_nonfoc_high_PM], ...
    'r-*', ...
    'LineWidth',2, ...
    'MarkerSize', 6);    
hold off;
axis([-0.5 3.5 40 100]);
%ylabel('PM Hit Rate (%)');
set(gca, 'XTickLabel', xticklabel);
%legend('Focal', 'Nonfocal');

% ------------ OG accuracies ------------

subplot(3, 2, 5);
plot([0 1 2 3], [emp_foc_low_OG_noPM emp_foc_high_OG_noPM emp_foc_low_OG  emp_foc_high_OG], ...
    'b-o', ...
    'LineWidth',2, ...
    'MarkerSize', 6);
hold on;
plot([0 1 2 3], [emp_nonfoc_low_OG_noPM emp_nonfoc_high_OG_noPM emp_nonfoc_low_OG  emp_nonfoc_high_OG], ...
    'r-*', ...
    'LineWidth',2, ...
    'MarkerSize', 6);    
hold off;
axis([-0.5 3.5 40 100]);
ylabel('OG accuracy (%)');
set(gca, 'XTickLabel', xticklabel);
%legend('Focal', 'Nonfocal');

subplot(3, 2, 6);
plot([0 1 2 3], [sim_foc_low_OG_noPM sim_foc_high_OG_noPM sim_foc_low_OG  sim_foc_high_OG], ...
    'b-o', ...
    'LineWidth',2, ...
    'MarkerSize', 6);
hold on;
plot([0 1 2 3], [sim_nonfoc_low_OG_noPM sim_nonfoc_high_OG_noPM sim_nonfoc_low_OG  sim_nonfoc_high_OG], ...
    'r-*', ...
    'LineWidth',2, ...
    'MarkerSize', 6);
hold off;
axis([-0.5 3.5 40 100]);
%ylabel('OG accuracy (%)');
set(gca, 'XTickLabel', xticklabel);
%legend('Focal', 'Nonfocal');




