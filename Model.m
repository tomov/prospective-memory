classdef Model < handle
    % All constants and predefined variables in the model
    %
    
    properties (Access = public)
        % PDP model parameters
        
        NOISE_SIGMA = 0.015;
        STEP_SIZE = 0.01;
        CYCLES_PER_SEC = 500;
        
        % activation levels

        MAXIMUM_ACTIVATION = 1;
        MINIMUM_ACTIVATION = -0.1;
        RESPONSE_THRESHOLD = 0.5;
        
        INPUT_ACTIVATION = 1;

        % --- begin connection weights ---
        
        % biases = leaks
        BIAS_FOR_PERCEPTION = -9;
        BIAS_FOR_RESPONSES = -1;
        BIAS_FOR_OUTPUTS = -0.5;
        BIAS_FOR_TASK = 0;
        BIAS_FOR_TARGET = 0;
        BIAS_FOR_ATTENTION = -1;
        
        % feedforward excitatory
        
        INPUT_TO_PERCEPTION = 9;
        PERCEPTION_TO_RESPONSE = 1;
        RESPONSE_TO_OUTPUT = 2;

        PERCEPTION_TO_TASK = 7;

        % feedforward inhibitory

        PERCEPTION_TO_RESPONSE_INHIBITION = 0;
        RESPONSE_TO_OUTPUT_INHIBITION = 0;
        
        % top-down (feedback?) excitatory
        
        TASK_TO_RESPONSE = 1;
        TARGET_TO_PERCEPTION = 7; % 9;
        ATTENTION_TO_PERCEPTION = 9;
        
        % top-down (feedback?) inhibitory
        
        TASK_TO_RESPONSE_INHIBITION = 0;

        % lateral intralayer inhibitory

        PERCEPTION_INHIBITION = 0;
        RESPONSE_INHIBITION = -2;
        OUTPUT_INHIBITION = -1;
        TASK_INHIBITION = 0;
        TARGET_INHIBITION = 0;
        ATTENTION_INHIBITION = 0;
        
        % self-excitatory
        
        TASK_SELF = 3;
        TARGET_SELF = 3;
        ATTENTION_SELF = 3;
        
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
        target_units
        attention_units
        
        input_ids
        perception_ids
        response_ids        
        output_ids
        task_ids
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
        
        
        function forward_connections(self, from, to, weight)
            assert(size(from, 2) == size(to, 2));
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
                'rate', 'fight', 'jail', 'herb', 'goal', ...
                'jaw', 'cite', 'gnaw', 'pluck', 'scarf', ...
                'seed', 'boost', 'halt', 'sphere', 'streak', 'church'
                };
            self.perception_units = strcat('see:', self.input_units')';
            self.response_units = {
                'noun', 'verb', '1 vowel', '2 vowels'
                };
            self.output_units = strcat('say:', self.response_units')';
            self.task_units = {
                'Lexical Category', 'Number of Vowels'
                };
            self.target_units = strcat('lookfor:', self.input_units')';
            self.attention_units = {
                'Attend Word'
                };
            self.units = [
                self.input_units, ...
                self.perception_units, ...
                self.response_units, ...
                self.output_units, ...
                self.task_units, ...
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
            self.target_ids = cellfun(@self.unit_id, self.target_units);
            self.attention_ids = cellfun(@self.unit_id, self.attention_units);
            
            self.wm_ids = [self.task_ids self.target_ids self.attention_ids];

            % specify connections between units
            
            self.connections = [
                % task monitoring to responses
                self.unit_id('Lexical Category')           , self.unit_id('noun')         , self.TASK_TO_RESPONSE;
                self.unit_id('Lexical Category')           , self.unit_id('verb')         , self.TASK_TO_RESPONSE;
                self.unit_id('Number of Vowels')           , self.unit_id('1 vowel')      , self.TASK_TO_RESPONSE;
                self.unit_id('Number of Vowels')           , self.unit_id('2 vowels')     , self.TASK_TO_RESPONSE;
            ];
            
            % perception to response mappings
            from = cellfun(@self.unit_id, strcat('see:', {
                'jail', 'herb', 'goal', 'jaw', 'scarf', ...
                'seed', 'sphere', 'streak', 'church'
                }')');
            to = self.unit_id('noun');
            self.forward_all_to_all(from, to, self.PERCEPTION_TO_RESPONSE);
            
            from = cellfun(@self.unit_id, strcat('see:', {
                'rate', 'fight', 'cite', 'gnaw', 'pluck', 'boost', 'halt'
                }')');
            to = self.unit_id('verb');
            self.forward_all_to_all(from, to, self.PERCEPTION_TO_RESPONSE);

            from = cellfun(@self.unit_id, strcat('see:', {
                'fight', 'herb', 'jaw', 'gnaw', 'pluck', 'scarf', ...
                 'halt',  'church'
                }')');
            to = self.unit_id('1 vowel');
            self.forward_all_to_all(from, to, self.PERCEPTION_TO_RESPONSE);
            
            from = cellfun(@self.unit_id, strcat('see:', {
                'rate', 'jail', 'goal', 'cite',  ...
                'seed', 'boost', 'sphere', 'streak'
                }')');
            to = self.unit_id('2 vowels');
            self.forward_all_to_all(from, to, self.PERCEPTION_TO_RESPONSE);
            
            % attention to perception
            from = self.unit_id('Attend Word');
            to = cellfun(@self.unit_id, strcat('see:', {
                'rate', 'fight', 'jail', 'herb', 'goal', ...
                'jaw', 'cite', 'gnaw', 'pluck', 'scarf', ...
                'seed', 'boost', 'halt', 'sphere', 'streak', 'church'
                }')');
            self.forward_all_to_all(from, to, self.ATTENTION_TO_PERCEPTION);
            
            % raw inputs to perception
            self.forward_connections(self.input_ids, self.perception_ids, self.INPUT_TO_PERCEPTION);

            % target monitoring to perception
            self.forward_connections(self.target_ids, self.perception_ids, self.TARGET_TO_PERCEPTION);

            % responses to outputs
            self.forward_connections(self.response_ids, self.output_ids, self.RESPONSE_TO_OUTPUT);

            % episodic memory
            self.forward_all_to_all(self.perception_ids, self.task_ids, 0);

            % forward inhibitions
            self.forward_all_to_all(self.perception_ids, self.response_ids, self.PERCEPTION_TO_RESPONSE_INHIBITION);
            self.forward_all_to_all(self.task_ids, self.response_ids, self.TASK_TO_RESPONSE_INHIBITION);
            self.forward_all_to_all(self.response_ids, self.response_ids, self.RESPONSE_TO_OUTPUT_INHIBITION);

            % lateral inhibitions
            self.lateral_inhibition(self.perception_ids, self.PERCEPTION_INHIBITION);
            self.lateral_inhibition(self.response_ids, self.RESPONSE_INHIBITION);
            self.lateral_inhibition(self.output_ids, self.OUTPUT_INHIBITION);
            self.lateral_inhibition(self.task_ids, self.TASK_INHIBITION);
            self.lateral_inhibition(self.target_ids, self.TARGET_INHIBITION);
            self.lateral_inhibition(self.attention_ids, self.ATTENTION_INHIBITION);

            % self excitations
            self.self_excitation(self.task_ids, self.TASK_SELF);
            self.self_excitation(self.target_ids, self.TARGET_SELF);
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
            self.bias(self.target_ids) = self.BIAS_FOR_TARGET;
            self.bias(self.attention_ids) = self.BIAS_FOR_ATTENTION;
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
