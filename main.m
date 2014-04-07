clear
Model
Simulator


sim = Simulator();

stimuli = [
    {'tortoise,an animal'}, 1;
    {'tortoise,a subject'}, 1;
    {'tortoise,a relative'}, 1;
    {'tortoise,a sport'}, 1;
    
    {'football,a sport'}, 1;
    {'football,an animal'}, 1;
    {'football,a subject'}, 1;
    {'football,a relative'}, 1;
    
    {'history,a subject'}, 1;
    {'history,an animal'}, 1;
    {'history,a relative'}, 1;
    {'history,a sport'}, 1;
    
    {'mother,a relative'}, 1;
    {'mother,an animal'}, 1;
    {'mother,a subject'}, 1;
    {'mother,a sport'}, 1;
    
    ];

is_target = [
    0;
    0;
    0;
    0;
    
    0;
    0;
    0;
    0;
    
    0;
    0;
    0;
    0;
    
    0;
    0;
    0;
    0;
    
    ];

correct = {
    'Yes';
    'No';
    'No';
    'No';
    
    'Yes';
    'No';
    'No';
    'No';
    
    'Yes';
    'No';
    'No';
    'No';
    
    'Yes';
    'No';
    'No';
    'No';
    
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

sim.wm_capacity = 2;
%sim.instruction('see:boost,see:halt,see:sphere,see:seed', 'Target', 2);
sim.print_EM
[responses, RTs, act] = sim.trial(stimuli, true);


figures;