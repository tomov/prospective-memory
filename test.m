clear
Model
Simulator


sim = Simulator();

stimuli = [
    {'church'}, 1;
    {'fight'}, 1;
    {'jail'}, 1;
    {'herb'}, 1;
    {'goal'}, 1;
    {'jaw'}, 1;
    {'cite'}, 1;
    {'gnaw'}, 1;
    ];

stimuli = [stimuli; stimuli; stimuli; stimuli; stimuli; stimuli; stimuli]

     
%{
RTtot = []
for i = 1:20
    i
    [responses, RTs, act] = sim.trial(stimuli2013, true);
    RTtot = [RTtot RTs(10:end)];
end
%}

sim.wm_capacity = 2;
sim.instruction('see:boost,see:halt,see:sphere,see:seed', 'PM Task', 2);
sim.print_EM
[responses, RTs, act] = sim.trial(stimuli, true);


subplot(3, 2, 1);
plot(act(:, sim.output_ids));
%legend(sim.units(sim.output_ids));
title('Outputs');

subplot(3, 2, 3);
plot(act(:, sim.response_ids));
legend(sim.units(sim.response_ids));
title('Responses');

subplot(3, 2, 5);
plot(act(:, sim.perception_ids));
legend(sim.units(sim.perception_ids));
title('Feature Perception');

%subplot(3, 2, 6);
%plot(act(:, sim.input_ids));
%legend(sim.units(sim.input_ids));
%title('Stimulus Inputs');

subplot(3, 2, 2);
plot(act(:, sim.task_ids));
legend(sim.units(sim.task_ids));
title('Task Monitoring');

subplot(3, 2, 4);
plot(act(:, sim.target_ids));
legend(sim.units(sim.target_ids));
title('Target Monitoring');

subplot(3, 2, 6);
plot(act(:, sim.attention_ids));
legend(sim.units(sim.attention_ids));
title('Ongoing Monitoring');

%subplot(3, 2, 6);
%plot(act(:, sim.unit_id('Super Inhibition')));
%legend(sim.units(sim.unit_id('Super Inhibition')));
%title('Super Inhibition');


RTs
responses