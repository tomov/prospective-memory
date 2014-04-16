clear
Model
Simulator


sim = Simulator();

stimuli = [
    {'tortoise,an animal'}, 1;
    {'tortoise,a subject'}, 1;
    {'crocodile,an animal'}, 1;
    {'crocodile,a subject'}, 1;
    {'history,an animal'}, 1;
    {'history,a subject'}, 1;
    {'math,an animal'}, 1;
    {'math,a subject'}, 1;
    ];

% PM / no PM: change 1's to 0's
is_target = [
            1;
            1;
    0;
    0;
            0;
            0;
    0;
    0;
    ];

% PM / no PM: uncomment and comment out respective responses
correct = {
%            'Yes';
%            'No';
            'PM';
            'PM';
    'Yes';
    'No'
            'No';
            'Yes';
%            'PM';
%            'PM';
    'No'
    'Yes';
    };


reps = 20;
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

sim.wm_capacity = 4;
% Einstein 2005: focal
sim.instruction('see:tortoise', 'PM Task', 2);
% Einstein 2005: nonfocal
%sim.instruction('see:tor', 'PM Task', 2);
sim.print_EM
[responses, RTs, act, acc] = sim.trial(stimuli);


figures;