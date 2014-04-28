function [stat, res] = EM2005( params )
% run a simulation of the E&M with certain parameters and spit out the
% stats

params
stat = [];
res = [];

for OG_ONLY = 0:1
    for FOCAL = 1:-1:0
        for EMPHASIS = 0:1
            sim = Simulator(FOCAL, EMPHASIS, OG_ONLY, params);

            % OG and PM trials

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

            if OG_ONLY
                is_target = [0; 0; 0; 0; 0; 0; 0; 0];
                correct = {'Yes'; 'No'; 'Yes'; 'No'; 'No'; 'Yes'; 'No'; 'Yes'};
            elseif FOCAL
                is_target = [1; 1; 0; 0; 0; 0; 0; 0];
                correct = {'PM'; 'PM'; 'Yes'; 'No'; 'No'; 'Yes'; 'No'; 'Yes'};
                sim.instruction('see:tortoise', 'PM Task', 2);
            else 
                % NONFOCAL
                is_target = [1; 1; 0; 0; 1; 1; 0; 0];
                correct = {'PM'; 'PM'; 'Yes'; 'No'; 'PM'; 'PM'; 'No'; 'Yes'};
                sim.instruction('see:tor', 'PM Task', 2);
            end

            % add some OG-only trials

            for gimme_some_og_trials=1:2
                stimuli = [
                    stimuli;
                    {'crocodile,an animal'}, 1;
                    {'crocodile,a subject'}, 1;
                    {'math,an animal'}, 1;
                    {'math,a subject'}, 1;
                    {'crocodile,an animal'}, 1;
                    {'crocodile,a subject'}, 1;
                    {'math,an animal'}, 1;
                    {'math,a subject'}, 1;
                ];
                is_target = [is_target; 0; 0; 0; 0; 0; 0; 0; 0];
                correct = [correct; {'Yes'; 'No'; 'No'; 'Yes'; 'Yes'; 'No'; 'No'; 'Yes'}];
            end


            % replicate stimuli
            reps = 30;
            stimuli = repmat(stimuli, reps, 1);
            is_target = repmat(is_target, reps, 1);
            correct = repmat(correct, reps, 1);

            % randomize order
            %{
            idx = randperm(size(stimuli, 1))';
            stimuli = stimuli(idx, :);
            is_target = is_target(idx, :);
            correct = correct(idx, :);
            %}

            sim.wm_capacity = 2;
            [responses, RTs, act, acc, onsets, nets] = sim.trial(stimuli);

            s = getstats(sim, OG_ONLY, FOCAL, EMPHASIS, ...
                responses, RTs, act, acc, onsets, ...
                is_target, correct);
            stat = [stat, s];
            res = [res; {sim, OG_ONLY, FOCAL, EMPHASIS, responses, RTs, act, acc, onsets, nets}];
        end
    end
end

% this is a hack b/c fitparam doesn't work with NaNs
stat(isnan(stat)) = -100;