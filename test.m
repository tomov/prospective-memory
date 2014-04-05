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
    {'boost'}, 1;
    {'halt'}, 1;
    {'sphere'}, 1;
    {'seed'}, 1;
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
    ];

correct = {
    'say:1 vowel';
    'say:1 vowel';
    'say:2 vowels';
    'say:1 vowel';
    'say:2 vowels';
    'say:1 vowel';
    'say:2 vowels';
    'say:1 vowel';
    'say:2 vowels';    
    'say:1 vowel';    
    'say:2 vowels';    
    'say:2 vowels';    
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

sim.wm_capacity = 2;
%sim.instruction('see:boost,see:halt,see:sphere,see:seed', 'PM Task', 2);
sim.print_EM
[responses, RTs, act] = sim.trial(stimuli, true);


figures;