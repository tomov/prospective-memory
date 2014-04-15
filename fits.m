% for RL presentation

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




sim_foc_low_RT = 141;
sim_foc_low_STD = 54;
sim_foc_low_OG = 99.5;
sim_foc_low_PM = 86.25;

sim_foc_high_RT = 149;
sim_foc_high_STD = 51.3;
sim_foc_high_OG = 99;
sim_foc_high_PM = 98; % !!!

sim_nonfoc_low_RT = 206.8;
sim_nonfoc_low_STD = 95;
sim_nonfoc_low_OG = 95;
sim_nonfoc_low_PM = 71;

sim_nonfoc_high_RT = 226;
sim_nonfoc_high_STD = 107;
sim_nonfoc_high_OG = 91;
sim_nonfoc_high_PM = 88;


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
plot([0 1], [sim_foc_low_RT sim_foc_high_RT] * 5.5 + 350, '-o');
hold on;
plot([0 1], [sim_nonfoc_low_RT sim_nonfoc_high_RT] * 5.5 + 350, '-*');
hold off;
axis([-0.5 1.5 1000 1700]);
ylabel('RT (msec = 5.5 * cycles + 350)');
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



