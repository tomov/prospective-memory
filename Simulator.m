classdef Simulator < Model
    % Class for simulating trials with different inputs and outputs
    % and potentially different model parameters than the default ones
    %
    
    properties (Access = public)
        wm_capacity = 2;
    end
    
    methods
        function self = Simulator()
        end
        
        function ids = string_to_ids(self, stimulus)
            units = strsplit(stimulus, ',');
            ids = [];
            for i=1:size(units, 2)
                active_unit = units{i};
                ids = [ids, self.unit_id(active_unit)];
            end
        end
        
        function instruction(self, targets, monitors, secs)
            target_ids = self.string_to_ids(targets);
            monitor_ids = self.string_to_ids(monitors);
            from = zeros(1, self.N);
            from(target_ids) = self.MAXIMUM_ACTIVATION;
            to = zeros(1, self.N);
            to(self.task_ids) = -self.MAXIMUM_ACTIVATION;
            to(monitor_ids) = self.MAXIMUM_ACTIVATION;
            duration = secs * self.CYCLES_PER_SEC;
            for cycle=1:duration
                % hebbian learning
                delta_w = self.LEARNING_RATE * from' * to;
                self.weights = self.weights + delta_w;
                
                % scale weights to fit model constraints
                sub = self.weights(self.perception_ids, self.task_ids);
                sub = sub * self.PERCEPTION_TO_TASK / max(sub(:));
                self.weights(self.perception_ids, self.task_ids) = sub;                
            end
            % TODO -- formalize this somehow; EM with learning inhibition,
            self.weights(self.perception_ids, self.task_ids) = self.weights(self.perception_ids, self.task_ids);
        end
        
        function bias = k_winner_take_all(self, k, net_inputs)
            arr = sort(net_inputs, 'descend');
            bias = - mean(arr(k:k+1));
        end
        
        function [responses, RTs, activation_log] = trial(self, stimuli, do_log)
            % initialize activations and outputs
            activation = zeros(1, self.N);
            trial_duration = sum(cat(2, stimuli{:, 2})) * self.CYCLES_PER_SEC;
            if do_log
                activation_log = zeros(trial_duration, self.N);
            end
            responses = [];
            RTs = [];
            cycles = 0;
            
            % for each input from the time series
            for ord=1:size(stimuli, 1)
                % get active input units for given stimulus
                % each stimulus string must be a comma-separated list of names of
                % input units
                stimulus = stimuli{ord, 1};
                active_ids = self.string_to_ids(stimulus);
                timeout = stimuli{ord, 2} * self.CYCLES_PER_SEC;
                
                % reset response, output, and monitoring activations
                activation(self.perception_ids) = 0;
                activation(self.response_ids) = 0;
                activation(self.output_ids) = 0;
                activation(self.task_ids) = 0;
                %activation(self.target_ids) = 0;
                activation(self.unit_id('Attend Number')) = self.MAXIMUM_ACTIVATION; % TODO ongoing task is hardcoded
                activation(self.unit_id('Magnitude')) = self.MAXIMUM_ACTIVATION; % TODO ongoing task is hardcoded
                %activation(self.unit_id('Monitor 7')) = self.MAXIMUM_ACTIVATION; % TODO target is hardcoded
                
                % default output is timeout
                output_id = self.unit_id('timeout');
                RT = timeout;
                
                % simulate response to stimulus
                responded = false;
                for cycle=1:timeout
                    % set input activations
                    activation(self.input_ids) = 0;
                    activation(active_ids) = self.INPUT_ACTIVATION;

                    % calculate net inputs for all units
                    net_input = activation * self.weights + self.bias;
                    
                    % add k-winner-take-all inhibition
                    kwta = self.k_winner_take_all(self.wm_capacity, net_input(self.wm_ids));
                    net_input(self.wm_ids) = net_input(self.wm_ids) + kwta;

                    % update activation levels
                    for i=1:self.N
                        if net_input(i) >= 0
                            delta_act = self.STEP_SIZE * net_input(i) * (self.MAXIMUM_ACTIVATION - activation(i));
                        else
                            delta_act = self.STEP_SIZE * net_input(i) * (activation(i) - self.MINIMUM_ACTIVATION);
                        end
                        activation(i) = activation(i) + delta_act;
                    end

                    % add noise to activations
                    noise = normrnd(0, self.NOISE_SIGMA, 1, self.N);
                    activation = activation + noise;
                    activation(activation > self.MAXIMUM_ACTIVATION) = self.MAXIMUM_ACTIVATION;
                    activation(activation < self.MINIMUM_ACTIVATION) = self.MINIMUM_ACTIVATION;

                    % log activation for plotting
                    if do_log
                        activation_log(cycles + cycle, :) = activation;
                    end

                    % check if activation threshold is met
                    [outputs, ix] = sort(activation(self.output_ids), 'descend');
                    if ~responded & outputs(1) - outputs(2) > self.RESPONSE_THRESHOLD
                        % save response and response time
                        output_id = self.output_ids(ix(1));
                        RT = cycle;
                        responded = true;
                    end
                end

                % record response and response time
                output = self.units{output_id};
                responses = [responses; {output}];
                RTs = [RTs; RT];
                cycles = cycles + cycle;
            end
            
            if do_log
                activation_log(cycles:end,:) = [];
            end
        end
    end
end