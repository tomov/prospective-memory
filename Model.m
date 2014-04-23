classdef Model < handle
    % All constants and predefined variables in the model
    %
    
    properties (Access = public)
        % PDP model parameters
        
        NOISE_SIGMA = 0.1; % TODO -- ??
        STEP_SIZE = 0.01;
        DECAY = 0.01;
        CYCLES_PER_SEC = 500;
        INSTRUCTION_CYLCES = 10;
        SETTLE_LEEWAY = 20;
        SETTLE_MEAN_EPS = 1e-5; % adjust these when you add noise to the model
        SETTLE_STD_EPS = 1e-6; % ...this too
        TAU = 0.1; % rate constant from Jon's paper
        EVIDENCE_ACCUM_SIGMA = 0.1;
        EVIDENCE_ACCUM_ALPHA = 0.1;
        EVIDENCE_ACCUM_THRESHOLD = 1.5;
        
        % activation levels

        MAXIMUM_ACTIVATION = 1;
        MINIMUM_ACTIVATION = 0;
        
        INPUT_ACTIVATION = 1;

        % --- begin connection weights ---
        
        % perception
        
        BIAS_FOR_PERCEPTION = -15;
        PERCEPTION_INHIBITION = 0;
        
        INPUT_TO_PERCEPTION = 10;
        INPUT_TO_PERCEPTION_INHIBITION = 0;
        
        ATTENTION_TO_PERCEPTION = 10;
        ATTENTION_TO_PERCEPTION_INHIBITION = 0;

        % responses
        
        BIAS_FOR_RESPONSES = -7;
        RESPONSE_INHIBITION = -5;
        
        PERCEPTION_TO_RESPONSE = 2;
        PERCEPTION_TO_RESPONSE_INHIBITION = 0;

        TASK_TO_RESPONSE = 7;
        TASK_TO_RESPONSE_INHIBITION = -7;
        
        % outputs
        
        BIAS_FOR_OUTPUTS = 0;
        OUTPUT_INHIBITION = -3;
        
        RESPONSE_TO_OUTPUT = 1;
        RESPONSE_TO_OUTPUT_INHIBITION = 0;
        
        % task representation
        
        BIAS_FOR_TASK = 0;
        TASK_INHIBITION = -2.5;
        TASK_SELF = 2.5;
        
        ATTENTION_TO_TASK = 0;
        ATTENTION_TO_TASK_INHIBITION = 0;
        
        OG_TASK_INITIAL_BIAS = 0;
        OG_TASK_RESET_BIAS = 0;
        PM_TASK_INITIAL_BIAS = 0;
        PM_TASK_RESET_BIAS = 0;
        
        PERCEPTION_TO_TASK = 10;  % EM
        
        % feature attention
        
        BIAS_FOR_ATTENTION = 0; % b > 0 x1=x2 > 0.5; b < 0 => x1=x2 < 0.5
        ATTENTION_INHIBITION = -2.5; % LI/SE > 1 => x1=x2 < 0.5; LI/SE < 1 => x1=x2 > 0.5; LI=SE => x1=x2=0.5 (given b = 0)
        ATTENTION_SELF = 2.5;
        % LI + SE > 10 => x1 = 0, x2 = 1 because of the logistic -- think
        % of the sum as the driving difference in the x-coordinates between
        % the two activations; aim for LI + SE = 5 for the sweet spot
        
        TASK_TO_ATTENTION = 0;    % VI (all-way, no VE) => same effect as b
        TASK_TO_ATTENTION_INHIBITION = 0; % disbalaned VI/VE => no x1=x2 stable state...
        
        OG_ATTENTION_INITIAL_BIAS = 0;
        OG_ATTENTION_RESET_BIAS = 0;
        PM_ATTENTION_INITIAL_BIAS = 0;
        PM_ATTENTION_RESET_BIAS = 0;
        

        %OUTPUT_TO_SELF = 0; % makes response->output more like copying rather than integration
        %RESPONSE_TO_SELF = 0;
        
        % --- end of connection weights ---
        
        % EM parameters
        
        LEARNING_RATE = 0.01;
                
        % variables
        
        units
        N
        unit_id
        
        input_units
        perception_units
        response_units
        output_units
        task_units
        attention_units
        
        input_ids
        perception_ids
        response_ids
        output_ids
        task_ids
        attention_ids
        
        wm_ids
        ffwd_ids
        
        connections
        weights
        bias
        initial_current
        reset_current
        
        FOCAL
        EMPHASIS
        OG_ONLY
    end
    
    methods
        function lateral_inhibition(self, units, weight)
            for i=1:size(units, 2)
                for j=1:size(units, 2)
                    if i ~= j
                        self.connections = [self.connections;
                            units(i), units(j), weight];
                        %fprintf('%s -> %s: %d (LI)\n', self.units{units(i)}, self.units{units(j)}, weight);
                    end
                end
            end
        end
        
        
        function forward_parallel(self, from, to, weight)
            assert(size(from, 2) <= size(to, 2));
            for i=1:size(from, 2)
                self.connections = [self.connections;
                    from(i), to(i), weight];
                %fprintf('%s -> %s: %d\n', self.units{from(i)}, self.units{to(i)}, weight);
            end
        end

        function forward_all_to_all(self, from, to, weight)
            for i=1:size(from, 2)
                for j=1:size(to, 2)
                    if ~ismember([from(i), to(j)], self.connections(:,1:2), 'rows')
                        self.connections = [self.connections;
                            from(i), to(j), weight];
                        %fprintf('%s -> %s: %d (FI)\n', self.units{from(i)}, self.units{to(j)}, weight);
                    end
                end
            end
        end

        function self_excitation(self, units, weight)
            for i=1:size(units, 2)
                self.connections = [self.connections;
                    units(i), units(i), weight];
                %fprintf('%s -> %s: %d (SE)\n', self.units{units(i)}, self.units{units(i)}, weight);
            end
        end
        
        function self = Model(FOCAL, EMPHASIS, OG_ONLY)
            self.FOCAL = FOCAL;
            self.EMPHASIS = EMPHASIS;
            self.OG_ONLY = OG_ONLY;
            
            % specify unit names in each layer
            self.input_units = {
                'tortoise', 'history', 'crocodile', 'math', ... % (focal targets)
                'a subject', 'an animal', ... % categories
                };
            self.perception_units = strcat('see:', self.input_units')';
            self.perception_units = [self.perception_units, 'see:tor'];
            self.response_units = {
                'A Subject', 'An Animal', 'No Match 1', 'No Match 2', 'PM Response'
                };
            self.output_units = {
                'Yes', 'No', 'PM'
                };
            self.task_units = {
                'OG Task', 'PM Task'
                };
            self.attention_units = {
                'OG features', ...
                'PM features'
                };
            self.units = [
                self.input_units, ...
                self.perception_units, ...
                self.response_units, ...
                self.output_units, ...
                self.task_units, ...
                self.attention_units, ...
                {'timeout'}
                ];
            
            % generate indices (for convenience)
            self.N = size(self.units, 2);
            self.unit_id = containers.Map(self.units, 1:self.N);

            self.input_ids = cellfun(@self.unit_id, self.input_units);
            self.perception_ids = cellfun(@self.unit_id, self.perception_units);
            self.response_ids = cellfun(@self.unit_id, self.response_units);
            self.output_ids = cellfun(@self.unit_id, self.output_units);
            self.task_ids = cellfun(@self.unit_id, self.task_units);
            self.attention_ids = cellfun(@self.unit_id, self.attention_units);
            
            self.ffwd_ids = [self.input_ids self.perception_ids self.response_ids self.output_ids];
            self.wm_ids = [self.task_ids self.attention_ids];

            % ---==== specify connections between units ====---
            
            self.connections = [
                % task monitoring to responses
                self.unit_id('OG Task')        , self.unit_id('A Subject')         , self.TASK_TO_RESPONSE;
                self.unit_id('OG Task')        , self.unit_id('An Animal')         , self.TASK_TO_RESPONSE;
                self.unit_id('OG Task')        , self.unit_id('No Match 1')        , self.TASK_TO_RESPONSE;
                self.unit_id('OG Task')        , self.unit_id('No Match 2')        , self.TASK_TO_RESPONSE;
                self.unit_id('PM Task')        , self.unit_id('PM Response')       , self.TASK_TO_RESPONSE;
                
                % perception to response mapping (direct OG pathway)
                % -- categories to categories
                self.unit_id('see:a subject')                  , self.unit_id('A Subject')          , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('see:an animal')                  , self.unit_id('An Animal')          , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('see:a subject')                  , self.unit_id('No Match 1')         , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('see:an animal')                  , self.unit_id('No Match 2')         , self.PERCEPTION_TO_RESPONSE;
                
                % -- animals to matching categories
                self.unit_id('see:history')                , self.unit_id('A Subject')         , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('see:math')                   , self.unit_id('A Subject')         , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('see:tortoise')               , self.unit_id('An Animal')         , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('see:crocodile')              , self.unit_id('An Animal')         , self.PERCEPTION_TO_RESPONSE;
                
                % -- default response is No Match
                self.unit_id('see:history')                , self.unit_id('No Match 2')         , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('see:math')                   , self.unit_id('No Match 2')         , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('see:tortoise')               , self.unit_id('No Match 1')         , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('see:crocodile')              , self.unit_id('No Match 1')         , self.PERCEPTION_TO_RESPONSE;
                
                % raw inputs to perception -- PM targets
                self.unit_id('tortoise')               , self.unit_id('see:tor')         , self.INPUT_TO_PERCEPTION;
                self.unit_id('history')                , self.unit_id('see:tor')         , self.INPUT_TO_PERCEPTION;
                
                % responses to outputs                
                self.unit_id('A Subject')           , self.unit_id('Yes')            , self.RESPONSE_TO_OUTPUT;
                self.unit_id('An Animal')           , self.unit_id('Yes')            , self.RESPONSE_TO_OUTPUT;
                self.unit_id('No Match 1')          , self.unit_id('No')             , self.RESPONSE_TO_OUTPUT;
                self.unit_id('No Match 2')          , self.unit_id('No')             , self.RESPONSE_TO_OUTPUT;
                self.unit_id('PM Response')         , self.unit_id('PM')             , self.RESPONSE_TO_OUTPUT;
                
                % LCA mutual inhibition and excitation
                self.unit_id('OG features') , self.unit_id('OG Task') , self.ATTENTION_TO_TASK;
                self.unit_id('OG Task') , self.unit_id('OG features') , self.TASK_TO_ATTENTION;

                self.unit_id('PM features') , self.unit_id('OG Task') , self.ATTENTION_TO_TASK_INHIBITION;
                self.unit_id('OG Task') , self.unit_id('PM features') , self.TASK_TO_ATTENTION_INHIBITION;

                self.unit_id('PM features') , self.unit_id('PM Task') , self.ATTENTION_TO_TASK;
                self.unit_id('PM Task') , self.unit_id('PM features') , self.TASK_TO_ATTENTION;
                
                self.unit_id('OG features') , self.unit_id('PM Task') , self.ATTENTION_TO_TASK_INHIBITION;
                self.unit_id('PM Task') , self.unit_id('OG features') , self.TASK_TO_ATTENTION_INHIBITION;
            ];
            
            % perception to task representation (indirect PM pathway)
            self.forward_all_to_all(self.perception_ids, self.task_ids, 0); % EM!!!
            
            % attention to perception
            from = self.unit_id('OG features');
            to = cellfun(@self.unit_id, strcat('see:', {
                'tortoise', 'history', 'crocodile', 'math', ...
                'a subject', 'an animal'
                }')');
            self.forward_all_to_all(from, to, self.ATTENTION_TO_PERCEPTION);
            
            if FOCAL
                self.OG_ATTENTION_INITIAL_BIAS = 5;
                self.OG_ATTENTION_RESET_BIAS = 5;
                self.PM_ATTENTION_INITIAL_BIAS = -5;
                self.PM_ATTENTION_RESET_BIAS = -5;
            else
                self.OG_ATTENTION_INITIAL_BIAS = 0;
                self.OG_ATTENTION_RESET_BIAS = 0;
                self.PM_ATTENTION_INITIAL_BIAS = 0;
                self.PM_ATTENTION_RESET_BIAS = 0;
                % attention to nonfocal target projection
                from = self.unit_id('PM features');
                to = cellfun(@self.unit_id, strcat('see:', {
                    'tor'
                    }')');
                self.forward_all_to_all(from, to, self.ATTENTION_TO_PERCEPTION);
            end
            
            if EMPHASIS
                self.OG_TASK_INITIAL_BIAS = 0;
                self.OG_TASK_RESET_BIAS = 0;
                self.PM_TASK_INITIAL_BIAS = 0;
                self.PM_TASK_RESET_BIAS = 0;
            else
                self.OG_TASK_INITIAL_BIAS = 5;
                self.OG_TASK_RESET_BIAS = 5;
                self.PM_TASK_INITIAL_BIAS = -5;
                self.PM_TASK_RESET_BIAS = -5;
            end

            % raw inputs to perception (cont'd)
            self.forward_parallel(self.input_ids, self.perception_ids, self.INPUT_TO_PERCEPTION);
            
            % forward inhibitions
            self.forward_all_to_all(self.input_ids, self.perception_ids, self.INPUT_TO_PERCEPTION_INHIBITION);
            self.forward_all_to_all(self.perception_ids, self.response_ids, self.PERCEPTION_TO_RESPONSE_INHIBITION);
            self.forward_all_to_all(self.task_ids, self.response_ids, self.TASK_TO_RESPONSE_INHIBITION);
            self.forward_all_to_all(self.response_ids, self.output_ids, self.RESPONSE_TO_OUTPUT_INHIBITION);

            % lateral inhibitions
            self.lateral_inhibition(self.perception_ids, self.PERCEPTION_INHIBITION);
            self.lateral_inhibition(self.response_ids, self.RESPONSE_INHIBITION);
            self.lateral_inhibition(self.output_ids, self.OUTPUT_INHIBITION);
            self.lateral_inhibition(self.task_ids, self.TASK_INHIBITION);
            self.lateral_inhibition(self.attention_ids, self.ATTENTION_INHIBITION);

            % self excitations
            self.self_excitation(self.task_ids, self.TASK_SELF);
            self.self_excitation(self.attention_ids, self.ATTENTION_SELF);
            
            % generate weight matrix from defined connections
            self.weights = sparse(self.connections(:,1), self.connections(:,2), self.connections(:,3), ...
                self.N, self.N);

            % biases
            self.bias = zeros(1, self.N);
            self.bias(self.perception_ids) = self.BIAS_FOR_PERCEPTION;
            self.bias(self.response_ids) = self.BIAS_FOR_RESPONSES;
            self.bias(self.output_ids) = self.BIAS_FOR_OUTPUTS;
            self.bias(self.task_ids) = self.BIAS_FOR_TASK;
            self.bias(self.attention_ids) = self.BIAS_FOR_ATTENTION;
            if OG_ONLY
                % turn off PM task and feature units
                self.bias(self.unit_id('PM features')) = -100;
                self.bias(self.unit_id('PM Task')) = -100;
            end
            
            % initial currents
            self.initial_current = zeros(1, self.N);
            self.initial_current(self.unit_id('OG Task')) = self.OG_TASK_INITIAL_BIAS;
            self.initial_current(self.unit_id('OG features')) = self.OG_ATTENTION_INITIAL_BIAS;
            self.initial_current(self.unit_id('PM Task')) = self.PM_TASK_INITIAL_BIAS;
            self.initial_current(self.unit_id('PM features')) = self.PM_ATTENTION_INITIAL_BIAS;
            
            % reset currents
            self.reset_current = zeros(1, self.N);
            self.reset_current(self.unit_id('OG Task')) = self.OG_TASK_RESET_BIAS;
            self.reset_current(self.unit_id('OG features')) = self.OG_ATTENTION_RESET_BIAS;
            self.reset_current(self.unit_id('PM Task')) = self.PM_TASK_RESET_BIAS;
            self.reset_current(self.unit_id('PM features')) = self.PM_ATTENTION_RESET_BIAS;
        end
        
        function EM = print_EM(self)
            EM = full(self.weights(self.perception_ids, self.task_ids));
            EM = EM';
        end
        
        function show_EM(self)
            EM = self.print_EM();
            m = max(EM(:));
            figure;
            imshow(imresize(1-EM/m, 60, 'box'))
        end
    end
end
