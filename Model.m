classdef Model < handle
    % All constants and predefined variables in the model
    %
    
    properties (Access = public)
        % PDP model parameters
        
        NOISE_SIGMA = 0.015;
        EXCITATION_STEP_SIZE = 0.05;
        DECAY_STEP_SIZE = 0.05;
        CYCLES_PER_SEC = 50;
        
        % activation levels

        MAXIMUM_ACTIVATION = 1;
        MINIMUM_ACTIVATION = -1;
        RESPONSE_THRESHOLD = 0.5;
        
        INPUT_ACTIVATION = 1.1;

        % connection weights
        
        BIAS_FOR_SEEN = 0;
        BIAS_FOR_RESPONSES = 0;
        BIAS_FOR_OUTPUTS = 0;
        BIAS_FOR_TASK_MONITORING = 0;
        BIAS_FOR_TARGET_MONITORING = 0;
        
        INPUT_TO_PERCEPTION = 10;
        PERCEPTION_TO_RESPONSE = 2;
        PERCEPTION_TO_RESPONSE_INHIBITION = 0;
        TARGET_TO_TASK = 0;
        TASK_TO_RESPONSE = 1;
        TASK_TO_RESPONSE_INHIBITION = 0;
        TARGET_TO_PERCEPTION = 0;
        ATTENTION_TO_PERCEPTION = 0;
        RESPONSE_TO_OUTPUT = 10;
        RESPONSE_TO_OUTPUT_INHIBITION = 0;
        
        TASK_INHIBITION = -1;
        TARGET_INHIBITION = 0;
        ATTENTION_INHIBITION = -1;
        RESPONSE_INHIBITION = 0;
        OUTPUT_INHIBITION = 0;
        
        TASK_SELF = 5;
        TARGET_SELF = 0;
        ATTENTION_SELF = 5;
        
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
                'See 7', 'See 8', 'See 9', 'See R', 'See G', ...                            % seen inputs (feature perception)
                'odd', 'even', '> 5', '< 5', 'red', 'green', ...                            % responses
                'button odd', 'button even', 'button < 5', 'button > 5', ...
                'button red', 'button green', 'timeout' ...                                 % outputs
                'Magnitude', 'Parity', 'Color' ...                                          % task monitoring
                'Monitor 1', 'Monitor 2', 'Monitor 3', 'Monitor 4', ...
                'Monitor 6', 'Monitor 7', 'Monitor 8', 'Monitor 9', ...
                'Monitor R', 'Monitor G', ...                                               % target monitoring
                'Attend Number', 'Attend Color'                                             % feature monitoring (focal/nonfocal)
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
            self.target_ids = [self.unit_id('Monitor R'), self.unit_id('Monitor G'), ...
                self.unit_id('Monitor 1'), self.unit_id('Monitor 2'), self.unit_id('Monitor 3'), self.unit_id('Monitor 4'), ...
                self.unit_id('Monitor 6'), self.unit_id('Monitor 7'), self.unit_id('Monitor 8'), self.unit_id('Monitor 9')];
            self.attention_ids = [self.unit_id('Attend Number'), self.unit_id('Attend Color')];
            self.wm_ids = [self.task_ids self.target_ids, self.attention_ids];

            self.connections = [
                % raw inputs to seen inputs
                self.unit_id('1')  , self.unit_id('See 1')            , self.INPUT_TO_PERCEPTION;
                self.unit_id('2')  , self.unit_id('See 2')            , self.INPUT_TO_PERCEPTION;
                self.unit_id('3')  , self.unit_id('See 3')            , self.INPUT_TO_PERCEPTION;
                self.unit_id('4')  , self.unit_id('See 4')            , self.INPUT_TO_PERCEPTION;
                self.unit_id('6')  , self.unit_id('See 6')            , self.INPUT_TO_PERCEPTION;
                self.unit_id('7')  , self.unit_id('See 7')            , self.INPUT_TO_PERCEPTION;
                self.unit_id('8')  , self.unit_id('See 8')            , self.INPUT_TO_PERCEPTION;
                self.unit_id('9')  , self.unit_id('See 9')            , self.INPUT_TO_PERCEPTION;
                
                self.unit_id('R')  , self.unit_id('See R')            , self.INPUT_TO_PERCEPTION;   % TODO focal/nonfocal is hardcoded
                self.unit_id('G')  , self.unit_id('See G')            , self.INPUT_TO_PERCEPTION;

                % seen inputs to outputs
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

                % target monitoring to perception
                self.unit_id('Monitor 1')  , self.unit_id('See 1')            , self.TARGET_TO_PERCEPTION;
                self.unit_id('Monitor 2')  , self.unit_id('See 2')            , self.TARGET_TO_PERCEPTION;
                self.unit_id('Monitor 3')  , self.unit_id('See 3')            , self.TARGET_TO_PERCEPTION;
                self.unit_id('Monitor 4')  , self.unit_id('See 4')            , self.TARGET_TO_PERCEPTION;
                self.unit_id('Monitor 6')  , self.unit_id('See 6')            , self.TARGET_TO_PERCEPTION;
                self.unit_id('Monitor 7')  , self.unit_id('See 7')            , self.TARGET_TO_PERCEPTION;
                self.unit_id('Monitor 8')  , self.unit_id('See 8')            , self.TARGET_TO_PERCEPTION;
                self.unit_id('Monitor 9')  , self.unit_id('See 9')            , self.TARGET_TO_PERCEPTION;
                self.unit_id('Monitor R')  , self.unit_id('See R')            , self.TARGET_TO_PERCEPTION;
                self.unit_id('Monitor G')  , self.unit_id('See G')            , self.TARGET_TO_PERCEPTION;
                
                % attention to perception
                self.unit_id('Attend Number')  , self.unit_id('See 1')            , self.ATTENTION_TO_PERCEPTION;
                self.unit_id('Attend Number')  , self.unit_id('See 2')            , self.ATTENTION_TO_PERCEPTION;
                self.unit_id('Attend Number')  , self.unit_id('See 3')            , self.ATTENTION_TO_PERCEPTION;
                self.unit_id('Attend Number')  , self.unit_id('See 4')            , self.ATTENTION_TO_PERCEPTION;
                self.unit_id('Attend Number')  , self.unit_id('See 6')            , self.ATTENTION_TO_PERCEPTION;
                self.unit_id('Attend Number')  , self.unit_id('See 7')            , self.ATTENTION_TO_PERCEPTION;
                self.unit_id('Attend Number')  , self.unit_id('See 8')            , self.ATTENTION_TO_PERCEPTION;
                self.unit_id('Attend Number')  , self.unit_id('See 9')            , self.ATTENTION_TO_PERCEPTION;
                self.unit_id('Attend Color')   , self.unit_id('See R')            , self.ATTENTION_TO_PERCEPTION;
                self.unit_id('Attend Color')   , self.unit_id('See G')            , self.ATTENTION_TO_PERCEPTION;
                
                % task monitoring to responses
                self.unit_id('Magnitude')           , self.unit_id('< 5')         , self.TASK_TO_RESPONSE;
                self.unit_id('Magnitude')           , self.unit_id('> 5')         , self.TASK_TO_RESPONSE;
                self.unit_id('Parity')              , self.unit_id('odd')         , self.TASK_TO_RESPONSE;
                self.unit_id('Parity')              , self.unit_id('even')        , self.TASK_TO_RESPONSE;
                self.unit_id('Color')               , self.unit_id('red')         , self.TASK_TO_RESPONSE;
                self.unit_id('Color')               , self.unit_id('green')       , self.TASK_TO_RESPONSE;

                % responses to outputs
                self.unit_id('odd')                 , self.unit_id('button odd')    , self.RESPONSE_TO_OUTPUT;
                self.unit_id('even')                , self.unit_id('button even')   , self.RESPONSE_TO_OUTPUT;
                self.unit_id('< 5')                 , self.unit_id('button < 5')    , self.RESPONSE_TO_OUTPUT;
                self.unit_id('> 5')                 , self.unit_id('button > 5')    , self.RESPONSE_TO_OUTPUT;
                self.unit_id('red')                 , self.unit_id('button red')    , self.RESPONSE_TO_OUTPUT;
                self.unit_id('green')               , self.unit_id('button green')  , self.RESPONSE_TO_OUTPUT;
            ];
            
            self.forward_connections(self.perception_ids, self.task_ids, 0); % inputs to EM-based prospective memory triggers
            self.forward_connections(self.perception_ids, self.response_ids, self.PERCEPTION_TO_RESPONSE_INHIBITION);
            self.forward_connections(self.task_ids, self.response_ids, self.TASK_TO_RESPONSE_INHIBITION);
            self.forward_connections(self.response_ids, self.response_ids, self.RESPONSE_TO_OUTPUT_INHIBITION);
            
            self.lateral_inhibition(self.task_ids, self.TASK_INHIBITION);
            self.lateral_inhibition(self.target_ids, self.TARGET_INHIBITION);
            self.lateral_inhibition(self.response_ids, self.RESPONSE_INHIBITION);
            self.lateral_inhibition(self.output_ids, self.OUTPUT_INHIBITION);
            self.lateral_inhibition(self.attention_ids, self.ATTENTION_INHIBITION);
            
            self.self_excitation(self.task_ids, self.TASK_SELF);
            self.self_excitation(self.target_ids, self.TARGET_SELF);
            self.self_excitation(self.attention_ids, self.ATTENTION_SELF);
            
            self.weights = sparse(self.connections(:,1), self.connections(:,2), self.connections(:,3), ...
                self.N, self.N); 

            self.bias = zeros(1, self.N);
            self.bias(self.perception_ids) = self.BIAS_FOR_SEEN;
            self.bias(self.response_ids) = self.BIAS_FOR_RESPONSES;
            self.bias(self.output_ids) = self.BIAS_FOR_OUTPUTS;
            self.bias(self.task_ids) = self.BIAS_FOR_TASK_MONITORING;
            self.bias(self.target_ids) = self.BIAS_FOR_TARGET_MONITORING;
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