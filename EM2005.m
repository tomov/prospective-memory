function [subjects, subjects_extra] = EM2005( params )
% run a simulation of the E&M with certain parameters and spit out the data
% for all subjects

params

% from E&M Experiment 1 methods
subjects_per_condition = 24;
blocks_per_condition = 8;
pm_blocks = [1 3 6 7];
%pm_blocks = [1 2 3 4 5 6 7 8]; % temporary TODO remove in final simulation
trials_per_block = 24;

subjects = [];
subjects_extra = [];

for OG_ONLY = 0:1 %0:1
    for FOCAL = 1:-1:0  % 1:-1:0
        for EMPHASIS = 0:1 %0:1
            sim = Simulator(FOCAL, EMPHASIS, OG_ONLY, params);

            % init OG trial pool
            og_stimuli = [
                {'crocodile,an animal'}, 1;
                {'crocodile,a subject'}, 1;
                {'physics,an animal'}, 1;
                {'physics,a subject'}, 1;
                {'math,an animal'}, 1;
                {'math,a subject'}, 1;
            ];
            og_correct = {'Yes'; 'No'; 'No'; 'Yes'; 'No'; 'Yes'};
        
            % init PM trial pool
            pm_targets = [
                {'tortoise,an animal'}, 1;
                {'tortoise,a subject'}, 1;
            ];
            pm_og_correct = {'Yes'; 'No'};
            pm_correct = {'PM', 'PM'};
            
            % generate OG block
            reps = trials_per_block / size(og_stimuli, 1);
            og_block = repmat(og_stimuli, reps, 1);
            og_block_correct = repmat(og_correct, reps, 1);
            
            % generate trial sequence (all blocks concatenated)
            stimuli = repmat(og_block, blocks_per_condition, 1);
            correct = repmat(og_block_correct, blocks_per_condition, 1);
            og_correct = correct;
            is_target = zeros(blocks_per_condition * trials_per_block, 1);
            
            % insert one PM target in each of the PM blocks
            if ~OG_ONLY
                %{
                for i = 1:length(stimuli)
                    if mod(i,3) == 0
                        target_id = mod(i, size(pm_targets, 1)) + 1;
                        middle = i;
                        stimuli(middle,:) = pm_targets(target_id, :);
                        correct(middle) = pm_correct(target_id);
                        og_correct(middle) = pm_og_correct(target_id);
                        is_target(middle) = 1;
                    end
                end
                %}
                
                for i = 1:length(pm_blocks)
                    b = pm_blocks(i);
                    block_start = (b - 1) * trials_per_block + 1;
                    block_end = b * trials_per_block;
                    middle = int32((block_start + block_end) / 2);
                    target_id = mod(i, size(pm_targets, 1)) + 1;
                    
                    stimuli(middle,:) = pm_targets(target_id, :);
                    correct(middle) = pm_correct(target_id);
                    og_correct(middle) = pm_og_correct(target_id);
                    is_target(middle) = 1;
                end
                
            end
            
            if FOCAL
                sim.instruction('see:tortoise', 'PM Task', 2);
            else 
                sim.instruction('see:tor', 'PM Task', 2);
            end

            % randomize order
            %{
            idx = randperm(size(stimuli, 1))';
            stimuli = stimuli(idx, :);
            is_target = is_target(idx, :);
            correct = correct(idx, :);
            %}

            for s = 1:subjects_per_condition
                [responses, RTs, act, acc, onsets, nets] = sim.trial(stimuli);

                [OG_RT, ~, OG_Hit, PM_RT, ~, PM_Hit, PM_miss_OG_hit] = getstats(sim, OG_ONLY, FOCAL, EMPHASIS, ...
                    responses, RTs, act, acc, onsets, ...
                    is_target, correct, og_correct);
                subject = [OG_ONLY, FOCAL, EMPHASIS, OG_RT, OG_Hit, PM_RT, PM_Hit, PM_miss_OG_hit];
                subjects = [subjects; subject];
                extra = {sim, OG_ONLY, FOCAL, EMPHASIS, responses, RTs, act, acc, onsets, nets};
                subjects_extra = [subjects_extra; extra];
            end
        end
    end
end