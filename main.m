clear
Model
Simulator


sim = Simulator();

stimuli = [
    {'tortoise,an animal'}, 1;
    {'tortoise,a subject'}, 1;
    {'history,an animal'}, 1;
    {'history,a subject'}, 1;
    ];

% PM / no PM: change 1's to 0's
is_target = [
    0;
    0;
    0;
    0;
    ];

% PM / no PM: uncomment and comment out respective responses
correct = {
        'Yes';
    'No';
    'No'
        'Yes';
    };


reps = 1;
stimuli = repmat(stimuli, reps);
is_target = repmat(is_target, reps);
correct = repmat(correct, reps);
    
     
%{
RTtot = []
for i = 1:20
    i
    [responses, RTs, act] = sim.trial(stimuli2013, true);
    RTtot = [RTtot RTs(10:end)];
end
%}

sim.wm_capacity = 3;
% Einstein 2005: focal
%sim.instruction('see:tortoise', 'Target', 2);
% Einstein 2005: nonfocal
sim.instruction('see:tor', 'Target', 2);
sim.print_EM
[responses, RTs, act, acc] = sim.trial(stimuli);


figures;