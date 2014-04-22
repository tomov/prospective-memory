% must precompute simulation values from stats, which in turn must be
% called from main.m and iterate over all possibilities of focal/nonfocal
% high/low emphasis

figure;

% no PM task

emp_foc_low_RT_noPM = 1073.25;
emp_foc_low_SD_noPM = 112.04;
emp_foc_low_OG_noPM = 97;
emp_foc_low_PM_noPM = NaN;

emp_foc_high_RT_noPM = 1149.25;
emp_foc_high_SD_noPM = 137.58;
emp_foc_high_OG_noPM = 97;
emp_foc_high_PM_noPM = NaN;

emp_nonfoc_low_RT_noPM = 1140.92;
emp_nonfoc_low_SD_noPM = 172.87;
emp_nonfoc_low_OG_noPM = 97;
emp_nonfoc_low_PM_noPM = NaN;

emp_nonfoc_high_RT_noPM = 1183.17;
emp_nonfoc_high_SD_noPM = 164.43;
emp_nonfoc_high_OG_noPM = 97;
emp_nonfoc_high_PM_noPM = NaN;

% PM task

emp_foc_low_RT = 1120.87;
emp_foc_low_SD = 116.48;
emp_foc_low_OG = 97;
emp_foc_low_PM = 88;

emp_foc_high_RT = 1239.17;
emp_foc_high_SD = 175.42;
emp_foc_high_OG = 97;
emp_foc_high_PM = 92;

emp_nonfoc_low_RT = 1425.39;
emp_nonfoc_low_SD = 379.52;
emp_nonfoc_low_OG = 97;
emp_nonfoc_low_PM = 53;

emp_nonfoc_high_RT = 1593.43;
emp_nonfoc_high_SD = 300.86;
emp_nonfoc_high_OG = 97;
emp_nonfoc_high_PM = 81;


xticklabel = {'low, no PM', 'low, PM', 'high, no PM', 'high, PM'};

% OG RT's

subplot(3, 2, 1);
plot([0 1 2 3], [emp_foc_low_RT_noPM emp_foc_low_RT emp_foc_high_RT_noPM emp_foc_high_RT], '-o');
hold on;
%errorbar([0 1], [emp_foc_low_RT emp_foc_high_RT], [emp_foc_low_SD emp_foc_high_SD]);
plot([0 1 2 3], [emp_nonfoc_low_RT_noPM emp_nonfoc_low_RT emp_nonfoc_high_RT_noPM emp_nonfoc_high_RT], '-*');
%errorbar([0 1], [emp_nonfoc_low_RT emp_nonfoc_high_RT], [emp_nonfoc_low_SD emp_nonfoc_high_SD]);
hold off;
axis([-0.5 3.5 1000 1700]);
ylabel('RT (msec)');
set(gca, 'XTickLabel', xticklabel);
legend('Focal', 'Nonfocal');
title('Empirical Data (Einstein & McDaniel 2005)');

subplot(3, 2, 2);
plot([0 1 2 3], [sim_foc_low_RT_noPM sim_foc_low_RT sim_foc_high_RT_noPM sim_foc_high_RT] * 10, '-o');
hold on;
%errorbar([0 1], [sim_foc_low_RT sim_foc_high_RT] * 10, [sim_foc_low_SD sim_foc_high_SD] * 10);
plot([0 1 2 3], [sim_nonfoc_low_RT_noPM sim_nonfoc_low_RT sim_nonfoc_high_RT_noPM sim_nonfoc_high_RT] * 10, '-*');
%errorbar([0 1], [sim_nonfoc_low_RT sim_nonfoc_high_RT] * 10, [sim_nonfoc_low_SD sim_nonfoc_high_SD] * 10);
hold off;
axis([-0.5 3.5 1000 1700]);
ylabel('RT (msec = 10 * cycles)');
set(gca, 'XTickLabel', xticklabel);
legend('Focal', 'Nonfocal');
title('Simulation Results');

% PM hit rates

subplot(3, 2, 3);
plot([1 3], [ emp_foc_low_PM  emp_foc_high_PM], '-o');
hold on;
plot([1 3], [ emp_nonfoc_low_PM  emp_nonfoc_high_PM], '-*');
hold off;
axis([-0.5 3.5 50 100]);
ylabel('PM Hit Rate (%)');
set(gca, 'XTickLabel', xticklabel);
legend('Focal', 'Nonfocal');

subplot(3, 2, 4);
plot([1 3], [ sim_foc_low_PM  sim_foc_high_PM], '-o');
hold on;
plot([1 3], [ sim_nonfoc_low_PM  sim_nonfoc_high_PM], '-*');
hold off;
axis([-0.5 3.5 50 100]);
ylabel('PM Hit Rate (%)');
set(gca, 'XTickLabel', xticklabel);
legend('Focal', 'Nonfocal');

% OG accuracies

subplot(3, 2, 5);
plot([0 1 2 3], [emp_foc_low_OG_noPM emp_foc_low_OG emp_foc_high_OG_noPM emp_foc_high_OG], '-o');
hold on;
plot([0 1 2 3], [emp_nonfoc_low_OG_noPM emp_nonfoc_low_OG emp_nonfoc_high_OG_noPM emp_nonfoc_high_OG], '-*');
hold off;
axis([-0.5 3.5 50 100]);
ylabel('OG accuracy (%)');
set(gca, 'XTickLabel', xticklabel);
legend('Focal', 'Nonfocal');

subplot(3, 2, 6);
plot([0 1 2 3], [sim_foc_low_OG_noPM sim_foc_low_OG sim_foc_high_OG_noPM sim_foc_high_OG], '-o');
hold on;
plot([0 1 2 3], [sim_nonfoc_low_OG_noPM sim_nonfoc_low_OG sim_nonfoc_high_OG_noPM sim_nonfoc_high_OG], '-*');
hold off;
axis([-0.5 3.5 50 100]);
ylabel('OG accuracy (%)');
set(gca, 'XTickLabel', xticklabel);
legend('Focal', 'Nonfocal');




