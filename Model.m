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
        TASK_INHIBITION = -3;
        TARGET_INHIBITION = -0.5; %  -1;
        ATTENTION_INHIBITION = -1;
        
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
            self.units = {
                '1', '2', '3', '4', '6', '7', '8', '9', 'R', 'G', ...                       % raw inputs
                'See 1', 'See 2', 'See 3', 'See 4', 'See 6', ...
                'See 7', 'See 8', 'See 9', 'See R', 'See G', ...                            % seen (conscious) inputs
                'odd', 'even', '> 5', '< 5', 'red', 'green', ...                            % responses
                'button odd', 'button even', 'button < 5', 'button > 5', ...
                'button red', 'button green', 'timeout' ...                                 % outputs
                'Magnitude', 'Parity', 'Color' ...                                          % task monitoring
                'Monitor 1', 'Monitor 2', 'Monitor 3', 'Monitor 4', ...
                'Monitor 6', 'Monitor 7', 'Monitor 8', 'Monitor 9', ...
                'Monitor R', 'Monitor G', ...                                               % target monitoring
                'Attend Number', 'Attend Color', ...                                        % attention to perception
                'Super Inhibition'
                };
            
            self.N = size(self.units, 2);
            self.unit_id = containers.Map(self.units, 1:self.N);

            self.input_ids = [
                self.unit_id('1'), self.unit_id('2'), self.unit_id('3'), ...
                self.unit_id('4'), self.unit_id('6'), self.unit_id('7'), ...
                self.unit_id('8'), self.unit_id('9'), ...
                self.unit_id('R'), self.unit_id('G')];
            self.perception_ids = [
                self.unit_id('See 1'), self.unit_id('See 2'), self.unit_id('See 3'), ...
                self.unit_id('See 4'), self.unit_id('See 6'), self.unit_id('See 7'), ...
                self.unit_id('See 8'), self.unit_id('See 9'), ...
                self.unit_id('See R'), self.unit_id('See G')];
            self.response_ids = [
                self.unit_id('odd'), self.unit_id('even'), ...
                self.unit_id('< 5'), self.unit_id('> 5'), ...
                self.unit_id('red'), self.unit_id('green')];
            self.output_ids = [
                self.unit_id('button odd'), self.unit_id('button even'), ...
                self.unit_id('button < 5'), self.unit_id('button > 5'), ...
                self.unit_id('button red'), self.unit_id('button green')];
            self.task_ids = [self.unit_id('Magnitude'), self.unit_id('Parity'), self.unit_id('Color')];
            self.target_ids = [
                self.unit_id('Monitor 1'), self.unit_id('Monitor 2'), self.unit_id('Monitor 3'), ... 
                self.unit_id('Monitor 4'), self.unit_id('Monitor 6'), self.unit_id('Monitor 7'), ...
                self.unit_id('Monitor 8'), self.unit_id('Monitor 9'), ...
                self.unit_id('Monitor R'), self.unit_id('Monitor G')];
            self.attention_ids = [
                self.unit_id('Attend Number'), self.unit_id('Attend Color')
                ];
            self.wm_ids = [self.task_ids self.target_ids self.attention_ids];

            self.connections = [
                % perception to responses mappings
                self.unit_id('See 1')          , self.unit_id('< 5')          , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('See 2')          , self.unit_id('< 5')          , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('See 3')          , self.unit_id('< 5')          , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('See 4')          , self.unit_id('< 5')          , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('See 6')          , self.unit_id('> 5')          , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('See 7')          , self.unit_id('> 5')          , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('See 8')          , self.unit_id('> 5')          , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('See 9')          , self.unit_id('> 5')          , self.PERCEPTION_TO_RESPONSE;

                self.unit_id('See 1')          , self.unit_id('odd')          , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('See 2')          , self.unit_id('even')         , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('See 3')          , self.unit_id('odd')          , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('See 4')          , self.unit_id('even')         , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('See 6')          , self.unit_id('even')         , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('See 7')          , self.unit_id('odd')          , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('See 8')          , self.unit_id('even')         , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('See 9')          , self.unit_id('odd')          , self.PERCEPTION_TO_RESPONSE;

                self.unit_id('See R')          , self.unit_id('red')          , self.PERCEPTION_TO_RESPONSE;
                self.unit_id('See G')          , self.unit_id('green')        , self.PERCEPTION_TO_RESPONSE;

                % attention to perception
                self.unit_id('Attend Number')  , self.unit_id('See 1')            , self.ATTENTION_TO_PERCEPTION / 8; % TODO hardcoded normalization...
                self.unit_id('Attend Number')  , self.unit_id('See 2')            , self.ATTENTION_TO_PERCEPTION / 8;
                self.unit_id('Attend Number')  , self.unit_id('See 3')            , self.ATTENTION_TO_PERCEPTION / 8; % perhaps do something like
                self.unit_id('Attend Number')  , self.unit_id('See 4')            , self.ATTENTION_TO_PERCEPTION / 8; % dimensions ?
                self.unit_id('Attend Number')  , self.unit_id('See 6')            , self.ATTENTION_TO_PERCEPTION / 8; % and discrete values in each dimension?
                self.unit_id('Attend Number')  , self.unit_id('See 7')            , self.ATTENTION_TO_PERCEPTION / 8; % ...also it doesn't really work like this...
                self.unit_id('Attend Number')  , self.unit_id('See 8')            , self.ATTENTION_TO_PERCEPTION / 8;
                self.unit_id('Attend Number')  , self.unit_id('See 9')            , self.ATTENTION_TO_PERCEPTION / 8;

                self.unit_id('Attend Color')   , self.unit_id('See R')            , self.ATTENTION_TO_PERCEPTION / 2;
                self.unit_id('Attend Color')   , self.unit_id('See G')            , self.ATTENTION_TO_PERCEPTION / 2;

                % task monitoring to responses
                self.unit_id('Magnitude')           , self.unit_id('< 5')         , self.TASK_TO_RESPONSE;
                self.unit_id('Magnitude')           , self.unit_id('> 5')         , self.TASK_TO_RESPONSE;
                self.unit_id('Parity')              , self.unit_id('odd')         , self.TASK_TO_RESPONSE;
                self.unit_id('Parity')              , self.unit_id('even')        , self.TASK_TO_RESPONSE;
                self.unit_id('Color')               , self.unit_id('red')         , self.TASK_TO_RESPONSE;
                self.unit_id('Color')               , self.unit_id('green')       , self.TASK_TO_RESPONSE;
            ];
            
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
