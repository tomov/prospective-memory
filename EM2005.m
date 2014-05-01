function [data, extra] = EM2005( params, exp_id )
% run a simulation of the E&M with certain parameters and spit out the data
% for all subjects

params

assert(exp_id == 1 || exp_id == 2);

% from E&M Experiment 1 & 2 methods
subjects_per_condition = 1; % 24;
blocks_per_condition = [8 4];  % exp 1, exp 2
trials_per_block = [24 40]; % exp 1, exp 2
pm_blocks_exp1 = [1 3 6 7];
pm_trials_exp2 = [40 80 120 160];

% since we're doing only 1 experiment at a time
blocks_per_condition = 4; %blocks_per_condition(exp_id);
trials_per_block = trials_per_block(exp_id);

data = [];
extra = [];

og_range = 0:1;
focal_range = 1:-1:0;
emphasis_range = 0:1;
if exp_id == 2
    emphasis_range = 0;
end

for OG_ONLY = 0 %og_range
    for FOCAL = 0 %focal_range
        for EMPHASIS = 0:1 %emphasis_range

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
            og_block = repmat(og_stimuli, trials_per_block, 1);
            og_block_correct = repmat(og_correct, trials_per_block, 1);
            og_block = og_block(1:trials_per_block,:);
            og_block_correct = og_block_correct(1:trials_per_block,:);
            
            % generate trial sequence (all blocks concatenated)
            stimuli = repmat(og_block, blocks_per_condition, 1);
            correct = repmat(og_block_correct, blocks_per_condition, 1);
            og_correct = correct;
            is_target = zeros(blocks_per_condition * trials_per_block, 1);
            
            % insert one PM target in each of the PM blocks
            if ~OG_ONLY
                % every third trial is a PM trial -- this is only for
                % testing; not used in any of E&M's experiments
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
                
                %{
                if exp_id == 1
                    % in experiment 1, there is a target in blocks 1, 3, 6, 7
                    for i = 1:length(pm_blocks_exp1)
                        b = pm_blocks_exp1(i);
                        block_start = (b - 1) * trials_per_block + 1;
                        block_end = b * trials_per_block;
                        middle = int32((block_start + block_end) / 2);
                        target_id = mod(i, size(pm_targets, 1)) + 1;

                        stimuli(middle,:) = pm_targets(target_id, :);
                        correct(middle) = pm_correct(target_id);
                        og_correct(middle) = pm_og_correct(target_id);
                        is_target(middle) = 1;
                    end
                elseif exp_id == 2
                    % in experiment 2, trials 40, 80, 120, and 160 are
                    % targets
                    for i = 1:length(pm_trials_exp2)
                        target_id = mod(i, size(pm_targets, 1)) + 1;
                        trial = pm_trials_exp2(i);
                        stimuli(trial,:) = pm_targets(target_id, :);
                        correct(trial) = pm_correct(target_id);
                        og_correct(trial) = pm_og_correct(target_id);
                        is_target(trial) = 1;                        
                    end
                end
                %}
            end
            
            % randomize order
            
            %{
            idx = randperm(size(stimuli, 1))';
            stimuli = stimuli(idx, :);
            is_target = is_target(idx, :);
            correct = correct(idx, :);
            %}

            % simulate!
            
            sim = Simulator(FOCAL, EMPHASIS, OG_ONLY, params);            
            if FOCAL
                sim.instruction('tortoise');
            else 
                sim.instruction('tor');
            end

            for subject_id = 1:subjects_per_condition
                [responses, RTs, act, acc, onsets, offsets, nets] = sim.trial(stimuli);

                if exp_id == 1
                    % for experiment 1, each subject = 1 sample
                    [OG_RT, ~, OG_Hit, PM_RT, ~, PM_Hit, PM_miss_OG_hit] = getstats(sim, OG_ONLY, FOCAL, EMPHASIS, ...
                        responses, RTs, act, acc, onsets, offsets, ...
                        is_target, correct, og_correct);

                    subject = [OG_ONLY, FOCAL, EMPHASIS, OG_RT, OG_Hit, PM_RT, PM_Hit, PM_miss_OG_hit];
                    data = [data; subject];
                    %extra = {sim, OG_ONLY, FOCAL, EMPHASIS, responses, RTs, act, acc, onsets, offsets, nets};
                    %exp1_extra = [exp1_extra; extra];
                    
                elseif exp_id == 2
                    % for experiment 2, each block = 1 sample (i.e. 4
                    % samples per subject)
                    for block_id = 1:blocks_per_condition
                        block_start = (block_id - 1) * trials_per_block + 1;
                        block_end = block_id * trials_per_block;                    
                        [OG_RT, ~, OG_Hit, PM_RT, ~, PM_Hit, PM_miss_OG_hit] = ...
                            getstats(sim, OG_ONLY, FOCAL, EMPHASIS, ...
                            responses(block_start:block_end), RTs(block_start:block_end), [], [], [], [], ...
                            is_target(block_start:block_end), ...
                            correct(block_start:block_end), ...
                            og_correct(block_start:block_end));

                        % put subject and block id's at the end to make it
                        % compatible with the data from experiment 1
                        block = [OG_ONLY, FOCAL, EMPHASIS, OG_RT, OG_Hit, PM_RT, PM_Hit, PM_miss_OG_hit, subject_id, block_id];
                        data = [data; block];
                    end                    
                end    
            end
            
        end
    end
end