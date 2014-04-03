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
        
        INPUT_ACTIVATION = 0.7;

        % connection weights
        
        BIAS_FOR_SEEN = -9;
        BIAS_FOR_RESPONSES = -1;
        BIAS_FOR_OUTPUTS = -0.5;
        BIAS_FOR_TASK_MONITORING = 0;
        BIAS_FOR_TARGET_MONITORING = 0;
        
        INPUT_TO_SEEN_FOCAL = 18;
        INPUT_TO_SEEN_NONFOCAL = 9;
        INPUT_TO_RESPONSE = 1;
        INPUT_TO_RESPONSE_INHIBITION = 0;
        TARGET_TO_TASK_MONITORING = 7;
        TASK_MONITORING_TO_RESPONSE = 1;
        TASK_MONITORING_TO_RESPONSE_INHIBITION = 0;
        TARGET_MONITORING_TO_TARGET = 9;
        RESPONSE_TO_OUTPUT = 2;
        RESPONSE_TO_OUTPUT_INHIBITION = 0;
        
        TASK_MONITORING_INHIBITION = -3;
        TARGET_MONITORING_INHIBITION = -1;
        RESPONSE_INHIBITION = -2;
        OUTPUT_INHIBITION = -1;
        
        TASK_MONITORING_SELF = 3;
        TARGET_MONITORING_SELF = 0;
        
        % EM parameters
        
        LEARNING_RATE = 0.01;
                
        % variables
        
        units
        N
        unit_id
        
        input_ids
        seen_ids
        response_ids        
        output_ids
        task_monitor_ids
        target_monitor_ids
        
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
                'See 7', 'See 8', 'See 9', 'See R', 'See G', ...                            % seen (conscious) inputs
                'odd', 'even', '> 5', '< 5', 'red', 'green', ...                            % responses
                'button odd', 'button even', 'button < 5', 'button > 5', ...
                'button red', 'button green', 'timeout' ...                                 % outputs
                'Magnitude', 'Parity', 'Color' ...                                          % task monitoring
                'Monitor 1', 'Monitor 2', 'Monitor 3', 'Monitor 4', ...
                'Monitor 6', 'Monitor 7', 'Monitor 8', 'Monitor 9', ...
                'Monitor R', 'Monitor G', ...                                               % target monitoring
                'Super Inhibition'
                };
            
            self.N = size(self.units, 2);
            self.unit_id = containers.Map(self.units, 1:self.N);

            self.input_ids = [
                self.unit_id('1'), self.unit_id('2'), self.unit_id('3'), ...
                self.unit_id('4'), self.unit_id('6'), self.unit_id('7'), ...
                self.unit_id('8'), self.unit_id('9'), ...
                self.unit_id('R'), self.unit_id('G')];
            self.seen_ids = [
                self.unit_id('See 1'), self.unit_id('See 2'), self.unit_id('See 3'), ...
                self.unit_id('See 4'), self.unit_id('See 6'), self.unit_id('See 7'), ...
                self.unit_id('See 8'), self.unit_id('See 9'), ...
                self.unit_id('See R'), self.unit_id('See G')];
            self.response_ids = [
                self.unit_id('odd'), self.unit_id('even'), ...
                self.unit_id('> 5'), self.unit_id('< 5'), ...
                self.unit_id('red'), self.unit_id('green')];
            self.output_ids = [
                self.unit_id('button odd'), self.unit_id('button even'), ...
                self.unit_id('button < 5'), self.unit_id('button > 5'), ...
                self.unit_id('button red'), self.unit_id('button green')];
            self.task_monitor_ids = [self.unit_id('Magnitude'), self.unit_id('Parity'), self.unit_id('Color')];
            self.target_monitor_ids = [self.unit_id('Monitor R'), self.unit_id('Monitor G'), ...
                self.unit_id('Monitor 1'), self.unit_id('Monitor 2'), self.unit_id('Monitor 3'), self.unit_id('Monitor 4'), ...
                self.unit_id('Monitor 6'), self.unit_id('Monitor 7'), self.unit_id('Monitor 8'), self.unit_id('Monitor 9')];
            self.wm_ids = [self.task_monitor_ids self.target_monitor_ids];

            self.connections = [
                % raw inputs to seen inputs
                self.unit_id('1')  , self.unit_id('See 1')            , self.INPUT_TO_SEEN_FOCAL;
                self.unit_id('2')  , self.unit_id('See 2')            , self.INPUT_TO_SEEN_FOCAL;
                self.unit_id('3')  , self.unit_id('See 3')            , self.INPUT_TO_SEEN_FOCAL;
                self.unit_id('4')  , self.unit_id('See 4')            , self.INPUT_TO_SEEN_FOCAL;
                self.unit_id('6')  , self.unit_id('See 6')            , self.INPUT_TO_SEEN_FOCAL;
                self.unit_id('7')  , self.unit_id('See 7')            , self.INPUT_TO_SEEN_FOCAL;
                self.unit_id('8')  , self.unit_id('See 8')            , self.INPUT_TO_SEEN_FOCAL;
                self.unit_id('9')  , self.unit_id('See 9')            , self.INPUT_TO_SEEN_FOCAL;
                
                self.unit_id('R')  , self.unit_id('See R')            , self.INPUT_TO_SEEN_NONFOCAL;   % TODO focal/nonfocal is hardcoded
                self.unit_id('G')  , self.unit_id('See G')            , self.INPUT_TO_SEEN_NONFOCAL;

                % seen inputs to outputs
                self.unit_id('See 1')          , self.unit_id('< 5')          , self.INPUT_TO_RESPONSE;
                self.unit_id('See 2')          , self.unit_id('< 5')          , self.INPUT_TO_RESPONSE;
                self.unit_id('See 3')          , self.unit_id('< 5')          , self.INPUT_TO_RESPONSE;
                self.unit_id('See 4')          , self.unit_id('< 5')          , self.INPUT_TO_RESPONSE;
                self.unit_id('See 6')          , self.unit_id('> 5')          , self.INPUT_TO_RESPONSE;
                self.unit_id('See 7')          , self.unit_id('> 5')          , self.INPUT_TO_RESPONSE;
                self.unit_id('See 8')          , self.unit_id('> 5')          , self.INPUT_TO_RESPONSE;
                self.unit_id('See 9')          , self.unit_id('> 5')          , self.INPUT_TO_RESPONSE;

                self.unit_id('See 1')          , self.unit_id('odd')          , self.INPUT_TO_RESPONSE;
                self.unit_id('See 2')          , self.unit_id('even')         , self.INPUT_TO_RESPONSE;
                self.unit_id('See 3')          , self.unit_id('odd')          , self.INPUT_TO_RESPONSE;
                self.unit_id('See 4')          , self.unit_id('even')         , self.INPUT_TO_RESPONSE;
                self.unit_id('See 6')          , self.unit_id('even')         , self.INPUT_TO_RESPONSE;
                self.unit_id('See 7')          , self.unit_id('odd')          , self.INPUT_TO_RESPONSE;
                self.unit_id('See 8')          , self.unit_id('even')         , self.INPUT_TO_RESPONSE;
                self.unit_id('See 9')          , self.unit_id('odd')          , self.INPUT_TO_RESPONSE;

                self.unit_id('See R')          , self.unit_id('red')          , self.INPUT_TO_RESPONSE;
                self.unit_id('See G')          , self.unit_id('green')        , self.INPUT_TO_RESPONSE;

                % target monitoring to inputs
                self.unit_id('Monitor 1')  , self.unit_id('See 1')            , self.TARGET_MONITORING_TO_TARGET;
                self.unit_id('Monitor 2')  , self.unit_id('See 2')            , self.TARGET_MONITORING_TO_TARGET;
                self.unit_id('Monitor 3')  , self.unit_id('See 3')            , self.TARGET_MONITORING_TO_TARGET;
                self.unit_id('Monitor 4')  , self.unit_id('See 4')            , self.TARGET_MONITORING_TO_TARGET;
                self.unit_id('Monitor 6')  , self.unit_id('See 6')            , self.TARGET_MONITORING_TO_TARGET;
                self.unit_id('Monitor 7')  , self.unit_id('See 7')            , self.TARGET_MONITORING_TO_TARGET;
                self.unit_id('Monitor 8')  , self.unit_id('See 8')            , self.TARGET_MONITORING_TO_TARGET;
                self.unit_id('Monitor 9')  , self.unit_id('See 9')            , self.TARGET_MONITORING_TO_TARGET;
                self.unit_id('Monitor R')  , self.unit_id('See R')            , self.TARGET_MONITORING_TO_TARGET;
                self.unit_id('Monitor G')  , self.unit_id('See G')            , self.TARGET_MONITORING_TO_TARGET;
                
                % task monitoring to responses
                self.unit_id('Magnitude')           , self.unit_id('< 5')         , self.TASK_MONITORING_TO_RESPONSE;
                self.unit_id('Magnitude')           , self.unit_id('> 5')         , self.TASK_MONITORING_TO_RESPONSE;
                self.unit_id('Parity')              , self.unit_id('odd')         , self.TASK_MONITORING_TO_RESPONSE;
                self.unit_id('Parity')              , self.unit_id('even')        , self.TASK_MONITORING_TO_RESPONSE;
                self.unit_id('Color')               , self.unit_id('red')         , self.TASK_MONITORING_TO_RESPONSE;
                self.unit_id('Color')               , self.unit_id('green')       , self.TASK_MONITORING_TO_RESPONSE;

                % responses to outputs
                self.unit_id('odd')                 , self.unit_id('button odd')    , self.RESPONSE_TO_OUTPUT;
                self.unit_id('even')                , self.unit_id('button even')   , self.RESPONSE_TO_OUTPUT;
                self.unit_id('< 5')                 , self.unit_id('button < 5')    , self.RESPONSE_TO_OUTPUT;
                self.unit_id('> 5')                 , self.unit_id('button > 5')    , self.RESPONSE_TO_OUTPUT;
                self.unit_id('red')                 , self.unit_id('button red')    , self.RESPONSE_TO_OUTPUT;
                self.unit_id('green')               , self.unit_id('button green')  , self.RESPONSE_TO_OUTPUT;
            ];
            
            self.forward_connections(self.seen_ids, self.task_monitor_ids, 0); % inputs to EM-based prospective memory triggers
            self.forward_connections(self.seen_ids, self.response_ids, self.INPUT_TO_RESPONSE_INHIBITION);
            self.forward_connections(self.task_monitor_ids, self.response_ids, self.TASK_MONITORING_TO_RESPONSE_INHIBITION);
            self.forward_connections(self.response_ids, self.response_ids, self.RESPONSE_TO_OUTPUT_INHIBITION);
            
            self.lateral_inhibition(self.task_monitor_ids, self.TASK_MONITORING_INHIBITION);
            self.lateral_inhibition(self.target_monitor_ids, self.TARGET_MONITORING_INHIBITION);
            self.lateral_inhibition(self.response_ids, self.RESPONSE_INHIBITION);
            self.lateral_inhibition(self.output_ids, self.OUTPUT_INHIBITION);
            
            self.self_excitation(self.task_monitor_ids, self.TASK_MONITORING_SELF);
            self.self_excitation(self.target_monitor_ids, self.TARGET_MONITORING_SELF);
            
            self.weights = sparse(self.connections(:,1), self.connections(:,2), self.connections(:,3), ...
                self.N, self.N); 

            self.bias = zeros(1, self.N);
            self.bias(self.seen_ids) = self.BIAS_FOR_SEEN;
            self.bias(self.response_ids) = self.BIAS_FOR_RESPONSES;
            self.bias(self.output_ids) = self.BIAS_FOR_OUTPUTS;
            self.bias(self.task_monitor_ids) = self.BIAS_FOR_TASK_MONITORING;
            self.bias(self.target_monitor_ids) = self.BIAS_FOR_TARGET_MONITORING;
        end
        
        function EM = print_EM(self)
            EM = full(self.weights(self.seen_ids, self.task_monitor_ids));
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
