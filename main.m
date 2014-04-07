clear
Model
Simulator


sim = Simulator();

stimuli = [
    {'tortoise,an animal'}, 1;
    {'football,a sport'}, 1;
    {'football,an animal'}, 1;
    {'football,a subject'}, 1;
    {'football,a relative'}, 1;
    
    {'tortoise,a subject'}, 1;
    {'mother,a relative'}, 1;
    {'mother,an animal'}, 1;
    {'mother,a subject'}, 1;
    {'mother,a sport'}, 1;
    
    {'tortoise,a sport'}, 1;
    {'crocodile,an animal'}, 1;
    {'crocodile,a relative'}, 1;
    {'crocodile,a subject'}, 1;
    {'crocodile,a sport'}, 1;

    {'tortoise,a relative'}, 1;
    {'sheep,an animal'}, 1;
    {'sheep,a relative'}, 1;
    {'sheep,a subject'}, 1;
    {'sheep,a sport'}, 1;
    ];

% PM / no PM: change 1's to 0's
is_target = [    
        1;
    0;
    0;
    0;
    0;
    
        1;
    0;
    0;
    0;
    0;
    
        1;
    0;
    0;
    0;
    0;
    
        1;
    0;
    0;
    0;
    0;    
    ];

% PM / no PM: uncomment and comment out respective responses
correct = {
%            'Yes';
            'PM';
    'Yes';
    'No';
    'No';
    'No';
    
%            'No';
            'PM';
    'Yes';
    'No';
    'No';
    'No';
    
%            'No';
            'PM';
    'Yes';
    'No';
    'No';
    'No';

%            'No';
            'PM';
    'Yes';
    'No';
    'No';
    'No';
    };


reps = 10;
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
sim.instruction('see:tortoise', 'Target', 2);
% Einstein 2005: nonfocal
%sim.instruction('see:tor', 'Target', 2);
sim.print_EM
[responses, RTs, act] = sim.trial(stimuli, true);


figures;