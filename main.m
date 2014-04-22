warning('off', 'MATLAB:ClassInstanceExists');
clear classes % ! super important ! if you don't do this, MATLAB won't reload your classes

OG_ONLY = 0;
FOCAL = 1; % 0 = nonfocal, 1 = focal
EMPHASIS = 1; % 0 = low emphasis, 1 = high emphasis

for OG_ONLY = 0:1
    for FOCAL = 0:1
        for EMPHASIS = 0:1
            if OG_ONLY
                og_string = 'No PM task';
            else
                og_string = 'PM task';
            end
            if FOCAL
                if EMPHASIS
                    fprintf('\n ----> focal, high emphasis, %s ----\n', og_string);
                else
                    fprintf('\n ----> focal, low emphasis, %s ----\n', og_string);
                end
            else
                if EMPHASIS
                    fprintf('\n ----> nonfocal, high emphasis, %s ----\n', og_string);
                else
                    fprintf('\n ----> nonfocal, low emphasis, %s ----\n', og_string);
                end
            end

            sim = Simulator(FOCAL, EMPHASIS, OG_ONLY);

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

            reps = 20;
            stimuli = repmat(stimuli, reps);
            is_target = repmat(is_target, reps);
            correct = repmat(correct, reps);

            sim.wm_capacity = 2;
            [responses, RTs, act, acc] = sim.trial(stimuli);

            stats;
            %sim.print_EM
            %figures;
        end
    end
end
    
fits;