% must precompute simulation values from stats, which in turn must be
% called from main.m and iterate over all possibilities of focal/nonfocal
% high/low emphasis

figure;

emp_foc_low_RT = 1120.87;
emp_foc_low_STD = 116.48;
emp_foc_low_OG = 97;
emp_foc_low_PM = 88;

emp_foc_high_RT = 1239.17;
emp_foc_high_STD = 175.42;
emp_foc_high_OG = 97;
emp_foc_high_PM = 92;

emp_nonfoc_low_RT = 1425.39;
emp_nonfoc_low_STD = 379.52;
emp_nonfoc_low_OG = 97;
emp_nonfoc_low_PM = 53;

emp_nonfoc_high_RT = 1593.43;
emp_nonfoc_high_STD = 300.86;
emp_nonfoc_high_OG = 97;
emp_nonfoc_high_PM = 81;


subplot(2, 2, 1);
plot([0 1], [emp_foc_low_RT emp_foc_high_RT], '-o');
hold on;
plot([0 1], [emp_nonfoc_low_RT emp_nonfoc_high_RT], '-*');
hold off;
axis([-0.5 1.5 1000 1700]);
ylabel('RT (msec)');
set(gca, 'XTickLabel', {'', 'low emphasis', '', 'high emphasis', ''});
legend('Focal', 'Nonfocal');
title('Empirical Data (Einstein & McDaniel 2005)');

subplot(2, 2, 2);
plot([0 1], [sim_foc_low_RT sim_foc_high_RT] * 10, '-o');
hold on;
plot([0 1], [sim_nonfoc_low_RT sim_nonfoc_high_RT] * 10, '-*');
hold off;
axis([-0.5 1.5 1000 1700]);
ylabel('RT (msec = 10 * cycles)');
set(gca, 'XTickLabel', {'', 'low emphasis', '', 'high emphasis', ''});
legend('Focal', 'Nonfocal');
title('Simulation Results');


subplot(2, 2, 3);
plot([0 1], [emp_foc_low_PM emp_foc_high_PM], '-o');
hold on;
plot([0 1], [emp_nonfoc_low_PM emp_nonfoc_high_PM], '-*');
hold off;
axis([-0.5 1.5 50 100]);
ylabel('PM Hit Rate (%)');
set(gca, 'XTickLabel', {'', 'low emphasis', '', 'high emphasis', ''});
legend('Focal', 'Nonfocal');

subplot(2, 2, 4);
plot([0 1], [sim_foc_low_PM sim_foc_high_PM], '-o');
hold on;
plot([0 1], [sim_nonfoc_low_PM sim_nonfoc_high_PM], '-*');
hold off;
axis([-0.5 1.5 50 100]);
ylabel('PM Hit Rate (%)');
set(gca, 'XTickLabel', {'', 'low emphasis', '', 'high emphasis', ''});
legend('Focal', 'Nonfocal');



