classdef Simulator < Model
    % Class for simulating trials with different inputs and outputs
    % and potentially different model parameters than the default ones
    %
    
    properties (Access = public)
        wm_capacity = 2;
        net_input;
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
        
        function instruction(self, perceptions, targets, secs)
            from_ids = self.string_to_ids(perceptions);
            to_ids = self.string_to_ids(targets);
            from = zeros(1, self.N);
            from(from_ids) = self.MAXIMUM_ACTIVATION;
            to = zeros(1, self.N);
            to(self.target_ids) = -self.MAXIMUM_ACTIVATION;
            to(to_ids) = self.MAXIMUM_ACTIVATION;
            duration = secs * self.CYCLES_PER_SEC;
            for cycle=1:duration
                % hebbian learning
                delta_w = self.LEARNING_RATE * from' * to;
                self.weights = self.weights + delta_w;
                
                % scale weights to fit model constraints
                sub = self.weights(self.perception_ids, self.target_ids);
                sub = sub * self.PERCEPTION_TO_TARGET / max(sub(:));
                self.weights(self.perception_ids, self.target_ids) = sub;                
            end
            % add noise
            % ... TODO a little artificial at the end but whatever
            % also noise sigma is hardcoded and made up
            %self.weights(self.perception_ids, self.target_ids) = self.weights(self.perception_ids, self.target_ids) ...
            %    + normrnd(0, 3, size(self.perception_ids, 2), size(self.target_ids, 2));
        end
        
        % from http://grey.colorado.edu/CompCogNeuro/index.php/CCNBook/Networks/kWTA_Equations
        function kWTA_basic(self, k, ids)
            act = sort(self.net_input(ids), 'descend');
            if size(act, 2) <= k
                return
            end
            q = 0.5;
            threshold = act(k+1) + q*(act(k) - act(k+1));
            self.net_input(ids) = self.net_input(ids) - threshold;
        end

        function kWTA_average(self, k, ids)
            act = sort(self.net_input(ids), 'descend');
            if size(act, 2) <= k
                return
            end
            top = mean(act(1:k));
            bottom = mean(act(k+1:end));
            q = 0.5;
            threshold = bottom + q*(top - bottom);
            self.net_input(ids) = self.net_input(ids) - threshold;
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
                activation(self.monitor_ids) = 0;
                activation(self.target_ids) = activation(self.target_ids) / 2; % TODO DISCUSS WITH JON!!!
                
                % default output is timeout
                output_id = self.unit_id('timeout');
                RT = timeout;
                
                % simulate response to stimulus
                responded = false;
                for cycle=1:timeout
                    % set input activations
                    activation(self.input_ids) = 0;
                    activation(active_ids) = self.INPUT_ACTIVATION;
                    % TODO these should be moved outside
                    activation(self.unit_id('Attend Word')) = self.MAXIMUM_ACTIVATION; % TODO ongoing task is hardcoded
                    activation(self.unit_id('Attend Category')) = self.MAXIMUM_ACTIVATION; % TODO ongoing task is hardcoded
                    activation(self.unit_id('Attend Syllables')) = self.MAXIMUM_ACTIVATION / 3; % TODO ongoing task is hardcoded
                    activation(self.unit_id('Word Categorization')) = self.MAXIMUM_ACTIVATION; % TODO ongoing task is hardcoded
                    % Einstein 2005: high emph (= 0.5) / low emph (= 0)
                    activation(self.unit_id('Monitor')) = 0.25;

                    % calculate net inputs for all units
                    self.net_input = activation * self.weights + self.bias;
                    
                    % add k-winner-take-all inhibition
                    %self.kWTA_basic(1, self.output_ids);
                    %self.kWTA_basic(1, self.response_ids);
                    self.kWTA_basic(1, self.task_ids);
                    %self.kWTA_basic(1, self.monitor_ids);
                    self.kWTA_basic(2, self.attention_ids);
                    %self.kWTA_average(self.wm_capacity, self.wm_ids);
%                    self.kWTA_average(self.wm_capacity, self.wm_ids);
%                    self.kWTA_average(self.wm_capacity, self.wm_ids);

                    % update activation levels
                    for i=1:self.N
                        if self.net_input(i) >= 0
                            delta_act = self.STEP_SIZE * self.net_input(i) * (self.MAXIMUM_ACTIVATION - activation(i));% ...
                                %- self.DECAY * (activation(i) - 0);
                        else
                            delta_act = self.STEP_SIZE * self.net_input(i) * (activation(i) - self.MINIMUM_ACTIVATION);% ...
                                %- self.DECAY * (activation(i) - 0);
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
                        break;
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