classdef Model < handle
    % All constants and predefined variables in the model
    %
    
    properties (Access = public)
        % PDP model parameters
        
        NOISE_SIGMA = 0.015;
        STEP_SIZE = 0.01;
        DECAY = 0.01;
        CYCLES_PER_SEC = 500;
        
        % activation levels

        MAXIMUM_ACTIVATION = 1;
        MINIMUM_ACTIVATION = -0.1;
        RESPONSE_THRESHOLD = 0.5;
        
        INPUT_ACTIVATION = 1;

        % --- begin connection weights ---
        
        % biases = leaks
        BIAS_FOR_PERCEPTION = -10;
        BIAS_FOR_RESPONSES = -3.5;
        BIAS_FOR_OUTPUTS = -0.5;
        BIAS_FOR_TASK = 0;
        BIAS_FOR_MONITOR = -10;
        BIAS_FOR_TARGET = -1;
        BIAS_FOR_ATTENTION = 0;
        
        % feedforward excitatory
        
        INPUT_TO_PERCEPTION = 10;
        PERCEPTION_TO_RESPONSE = 3.4;
        PERCEPTION_TO_RESPONSE_DOUBLE = 2;
        RESPONSE_TO_OUTPUT = 5;
        
        TARGET_TO_RESPONSE = 5;
        TARGET_TO_TASK = 0;
        PERCEPTION_TO_TARGET = 3.7; % vary this between 3 and 5 to vary the PM hit rate (range applies mainly for monitor = 0)

        % feedforward inhibitory

        PERCEPTION_TO_RESPONSE_INHIBITION = 0;
        RESPONSE_TO_OUTPUT_INHIBITION = 0;
        TARGET_TO_RESPONSE_INHIBITION = 0;
        
        % top-down excitatory
        
        TASK_TO_RESPONSE = 1;
        ATTENTION_TO_PERCEPTION = 9;
        MONITOR_TO_TARGET = 2;
        
        % top-down inhibitory
        
        TASK_TO_RESPONSE_INHIBITION = 0;

        % lateral intralayer inhibitory

        PERCEPTION_INHIBITION = 0;
        RESPONSE_INHIBITION = -2;
        OUTPUT_INHIBITION = 0;
        TASK_INHIBITION = -3;
        MONITOR_INHIBITION = 0;
        ATTENTION_INHIBITION = 0;
        
        % self-excitatory
        
        TASK_SELF = 5;
        MONITOR_SELF = 5;
        ATTENTION_SELF = 5;
        
        % self-inhibitory
        
        OUTPUT_TO_SELF = -3; % makes response->output more like copying rather than integration
        TARGET_TO_SELF = -3; % -2;
        RESPONSE_TO_SELF = 0;
        
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
        monitor_units
        target_units
        attention_units
        
        input_ids
        perception_ids
        response_ids
        output_ids
        task_ids
        monitor_ids
        target_ids
        attention_ids
        
        wm_ids
        
        connections
        weights
        bias
    end
    
    methods
        function lateral_inhibition(self, units, weight)
            for i=1:size(units, 2)
                for j=1:size(units, 2)
                    if i ~= j
                        self.connections = [self.connections;
                            units(i), units(j), weight];
                        fprintf('%s -> %s: %d (LI)\n', self.units{units(i)}, self.units{units(j)}, weight);
                    end
                end
            end
        end
        
        
        function forward_parallel(self, from, to, weight)
            assert(size(from, 2) <= size(to, 2));
            for i=1:size(from, 2)
                self.connections = [self.connections;
                    from(i), to(i), weight];
                fprintf('%s -> %s: %d\n', self.units{from(i)}, self.units{to(i)}, weight);
            end
        end

        function forward_all_to_all(self, from, to, weight)
            for i=1:size(from, 2)
                for j=1:size(to, 2)
                    if ~ismember([from(i), to(j)], self.connections(:,1:2), 'rows')
                        self.connections = [self.connections;
                            from(i), to(j), weight];
                        fprintf('%s -> %s: %d (FI)\n', self.units{from(i)}, self.units{to(j)}, weight);
                    end
                end
            end
        end

        function self_excitation(self, units, weight)
            for i=1:size(units, 2)
                self.connections = [self.connections;
                    units(i), units(i), weight];
                fprintf('%s -> %s: %d (SE)\n', self.units{units(i)}, self.units{units(i)}, weight);
            end
        end
        
        function self = Model()
            % specify unit names in each layer
            self.input_units = {
                'tortoise', 'history', ... % words (focal targets)
                'mother', 'crocodile', 'football', 'sheep', ... % words (nontargets)
                'a subject', 'an animal', 'a sport', 'a relative', ... % categories
                };
            self.perception_units = strcat('see:', self.input_units')';
            self.perception_units = [self.perception_units, 'see:tor', 'see:foot', 'see:croc'];
            self.response_units = {
                'A Subject', 'An Animal', 'A Sport', 'A Relative', 'No Match', 'PM Response'
                };
            self.output_units = {
                'Yes', 'No', 'PM'
                };
            self.task_units = {
                'Word Categorization', 'PM Task'
                };
            self.monitor_units = {
                'Monitor'
                };
            self.target_units = {
                'Target'
                };
            self.attention_units = {
                'Attend Word', ...
                'Attend Category', ...
                'Attend Syllables'
                };
            self.units = [
                self.input_units, ...
                self.perception_units, ...
                self.response_units, ...
                self.output_units, ...
                self.task_units, ...
                self.monitor_units, ...
                self.target_units, ...
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
            self.monitor_ids = cellfun(@self.unit_id, self.monitor_units);
            self.target_ids = cellfun(@self.unit_id, self.target_units);
            self.attention_ids = cellfun(@self.unit_id, self.attention_units);
            
            self.wm_ids = [self.task_ids self.monitor_ids self.attention_ids];

            % ---==== specify connections between units ====---
            
            self.connections = [
                % task monitoring to responses
                self.unit_id('Word Categorization')        , self.unit_id('A Subject')         , self.TASK_TO_RESPONSE;
                self.unit_id('Word Categorization')        , self.unit_id('An Animal')         , self.TASK_TO_RESPONSE;
                self.unit_id('Word Categorization')        , self.unit_id('A Sport')           , self.TASK_TO_RESPONSE;
                self.unit_id('Word Categorization')        , self.unit_id('A Relative')        , self.TASK_TO_RESPONSE;
                self.unit_id('Word Categorization')        , self.unit_id('No Match')          , self.TASK_TO_RESPONSE;
                self.unit_id('PM Task')                    , self.unit_id('PM Response')       , self.TASK_TO_RESPONSE;
                
                % perception to response mapping (direct OG pathway)
                % -- categories to categories
                self.unit_id('see:a subject')                  , self.unit_id('A Subject')         , self.PERCEPTION_TO_RESPONSE_DOUBLE;
                self.unit_id('see:an animal')                  , self.unit_id('An Animal')         , self.PERCEPTION_TO_RESPONSE_DOUBLE;
                self.unit_id('see:a sport')                    , self.unit_id('A Sport')           , self.PERCEPTION_TO_RESPONSE_DOUBLE;
                self.unit_id('see:a relative')                 , self.unit_id('A Relative')        , self.PERCEPTION_TO_RESPONSE_DOUBLE;
                
                % -- animals to matching categories
                self.unit_id('see:tortoise')               , self.unit_id('An Animal')         , self.PERCEPTION_TO_RESPONSE_DOUBLE;
                self.unit_id('see:history')                , self.unit_id('A Subject')         , self.PERCEPTION_TO_RESPONSE_DOUBLE;
                self.unit_id('see:mother')                 , self.unit_id('A Relative')        , self.PERCEPTION_TO_RESPONSE_DOUBLE;
                self.unit_id('see:crocodile')              , self.unit_id('An Animal')         , self.PERCEPTION_TO_RESPONSE_DOUBLE;
                self.unit_id('see:football')               , self.unit_id('A Sport')           , self.PERCEPTION_TO_RESPONSE_DOUBLE;
                self.unit_id('see:sheep')                  , self.unit_id('An Animal')         , self.PERCEPTION_TO_RESPONSE_DOUBLE;
                
                % -- default response is No Match
                self.unit_id('see:tortoise')               , self.unit_id('No Match')         , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('see:history')                , self.unit_id('No Match')         , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('see:mother')                 , self.unit_id('No Match')         , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('see:crocodile')              , self.unit_id('No Match')         , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('see:football')               , self.unit_id('No Match')         , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('see:sheep')                  , self.unit_id('No Match')         , self.PERCEPTION_TO_RESPONSE;
                
                % raw inputs to perception
                self.unit_id('tortoise')               , self.unit_id('see:tor')         , self.INPUT_TO_PERCEPTION;
                self.unit_id('history')                , self.unit_id('see:tor')         , self.INPUT_TO_PERCEPTION;
                self.unit_id('crocodile')              , self.unit_id('see:croc')         , self.INPUT_TO_PERCEPTION;
                self.unit_id('football')               , self.unit_id('see:foot')         , self.INPUT_TO_PERCEPTION;
                
                % responses to outputs                
                self.unit_id('A Subject')           , self.unit_id('Yes')            , self.RESPONSE_TO_OUTPUT;
                self.unit_id('An Animal')           , self.unit_id('Yes')            , self.RESPONSE_TO_OUTPUT;
                self.unit_id('A Sport')             , self.unit_id('Yes')            , self.RESPONSE_TO_OUTPUT;
                self.unit_id('A Relative')          , self.unit_id('Yes')            , self.RESPONSE_TO_OUTPUT;
                self.unit_id('No Match')            , self.unit_id('No')             , self.RESPONSE_TO_OUTPUT;
                self.unit_id('PM Response')         , self.unit_id('PM')             , self.RESPONSE_TO_OUTPUT;
            ];
            
            % perception to target detection to response mappings (indirect PM pathway)
            self.forward_all_to_all(self.perception_ids, self.unit_id('Target'), 0); % EM!!!
            self.forward_all_to_all(self.unit_id('Target'), self.unit_id('PM Response'), self.TARGET_TO_RESPONSE);
            self.forward_all_to_all(self.unit_id('Target'), self.response_ids, self.TARGET_TO_RESPONSE_INHIBITION);
            
            % attention to perception
            from = self.unit_id('Attend Word');
            to = cellfun(@self.unit_id, strcat('see:', {
                'tortoise', 'history', ...
                'mother', 'crocodile', 'football', 'sheep'
                }')');
            self.forward_all_to_all(from, to, self.ATTENTION_TO_PERCEPTION);

            from = self.unit_id('Attend Category');
            to = cellfun(@self.unit_id, strcat('see:', {
                'a subject', 'an animal', 'a sport', 'a relative'
                }')');
            self.forward_all_to_all(from, to, self.ATTENTION_TO_PERCEPTION);
            
            from = self.unit_id('Attend Syllables');
            to = cellfun(@self.unit_id, strcat('see:', {
                'tor', 'foot'
                }')');
            self.forward_all_to_all(from, to, self.ATTENTION_TO_PERCEPTION);

            % raw inputs to perception (cont'd)
            self.forward_parallel(self.input_ids, self.perception_ids, self.INPUT_TO_PERCEPTION);
            
            % target monitoring to target detection
            self.forward_parallel(self.monitor_ids, self.target_ids, self.MONITOR_TO_TARGET);

            % target detection to task monitoring (task switch)
            self.forward_all_to_all(self.target_ids, self.task_ids, 0); % EM!!!
            
            % forward inhibitions
            self.forward_all_to_all(self.perception_ids, self.response_ids, self.PERCEPTION_TO_RESPONSE_INHIBITION);
            self.forward_all_to_all(self.task_ids, self.response_ids, self.TASK_TO_RESPONSE_INHIBITION);
            self.forward_all_to_all(self.response_ids, self.response_ids, self.RESPONSE_TO_OUTPUT_INHIBITION);

            % lateral inhibitions
            self.lateral_inhibition(self.perception_ids, self.PERCEPTION_INHIBITION);
            self.lateral_inhibition(self.response_ids, self.RESPONSE_INHIBITION);
            self.lateral_inhibition(self.output_ids, self.OUTPUT_INHIBITION);
            self.lateral_inhibition(self.task_ids, self.TASK_INHIBITION);
            self.lateral_inhibition(self.monitor_ids, self.MONITOR_INHIBITION);
            self.lateral_inhibition(self.attention_ids, self.ATTENTION_INHIBITION);

            % self excitations
            self.self_excitation(self.task_ids, self.TASK_SELF);
            self.self_excitation(self.monitor_ids, self.MONITOR_SELF);
            self.self_excitation(self.attention_ids, self.ATTENTION_SELF);
            
            % self inibitions
            self.self_excitation(self.output_ids, self.OUTPUT_TO_SELF);
            self.self_excitation(self.target_ids, self.TARGET_TO_SELF);
            self.self_excitation(self.response_ids, self.RESPONSE_TO_SELF);

            % generate weight matrix from defined connections
            self.weights = sparse(self.connections(:,1), self.connections(:,2), self.connections(:,3), ...
                self.N, self.N);

            % biases
            self.bias = zeros(1, self.N);
            self.bias(self.perception_ids) = self.BIAS_FOR_PERCEPTION;
            self.bias(self.response_ids) = self.BIAS_FOR_RESPONSES;
            self.bias(self.output_ids) = self.BIAS_FOR_OUTPUTS;
            self.bias(self.task_ids) = self.BIAS_FOR_TASK;
            self.bias(self.monitor_ids) = self.BIAS_FOR_MONITOR;
            self.bias(self.target_ids) = self.BIAS_FOR_TARGET;
            self.bias(self.attention_ids) = self.BIAS_FOR_ATTENTION;
        end
        
        function EM = print_EM(self)
            EM = full(self.weights(self.perception_ids, self.target_ids));
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
