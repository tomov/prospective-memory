clear
Model
Simulator


sim = Simulator();

stimuli = [
    {'1,R'}, 1;
    {'2,G'}, 1;
    {'3,R'}, 1;
    {'4,G'}, 1;
    {'6,R'}, 1;
    {'7,G'}, 1;
    {'8,R'}, 1;
    {'9,G'}, 1;
    ];

     
     
%{
RTtot = []
for i = 1:20
    i
    [responses, RTs, act] = sim.trial(stimuli2013, true);
    RTtot = [RTtot RTs(10:end)];
end
%}

sim.wm_capacity = 2;
sim.instruction('See 7', 'Parity', 2);
sim.print_EM
[responses, RTs, act] = sim.trial(stimuli, true);


subplot(3, 2, 1);
plot(act(:, sim.output_ids));
legend(sim.units(sim.output_ids));
title('Outputs');

subplot(3, 2, 3);
plot(act(:, sim.response_ids));
legend(sim.units(sim.response_ids));
title('Responses');

subplot(3, 2, 5);
plot(act(:, sim.seen_ids));
legend(sim.units(sim.seen_ids));
title('Feature Perception');

subplot(3, 2, 6);
plot(act(:, sim.input_ids));
legend(sim.units(sim.input_ids));
title('Stimulus Inputs');

subplot(3, 2, 2);
plot(act(:, sim.task_monitor_ids));
legend(sim.units(sim.task_monitor_ids));
title('Task Monitoring');

subplot(3, 2, 4);
plot(act(:, sim.target_monitor_ids));
legend(sim.units(sim.target_monitor_ids));
title('Target Monitoring');

%subplot(3, 2, 6);
%plot(act(:, sim.unit_id('Super Inhibition')));
%legend(sim.units(sim.unit_id('Super Inhibition')));
%title('Super Inhibition');


RTs
responses