classdef Simulator < Model
    % Class for simulating trials with different inputs and outputs
    % and potentially different model parameters than the default ones
    %
    
    properties (Access = public)
        wm_capacity = 2;
        net_input;
        net_input_avg;
        accumulators;
        Nout;
    end
    
    methods
        function self = Simulator()
            self.Nout = size(self.output_ids, 2);
            self.accumulators = zeros(1, self.Nout);
            self.net_input = zeros(1, self.N);
            self.net_input_avg = zeros(1, self.N);
        end
        
        function ids = string_to_ids(self, stimulus)
            units = strsplit(stimulus, ',');
            ids = [];
            for i=1:size(units, 2)
                active_unit = units{i};
                ids = [ids, self.unit_id(active_unit)];
            end
        end
        
        % from Jon's 1990 Stroop paper
        function act = logistic(self, net)
            act = 1 ./ (1 + exp(-net));
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

        function [responses, RTs, activation_log, accumulators_log] = trial(self, stimuli)
            % initialize activations and outputs
            activation = zeros(1, self.N);
            trial_duration = sum(cat(2, stimuli{:, 2})) * self.CYCLES_PER_SEC;
            activation_log = zeros(trial_duration, self.N);
            accumulators_log = zeros(trial_duration, self.Nout);
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
                %activation(:) = 0;
                self.net_input_avg = zeros(1, self.N);
                self.accumulators = zeros(1, size(self.output_ids, 2));
                
                % default output is timeout
                output_id = self.unit_id('timeout');
                RT = timeout;
                
                % simulate response to stimulus
                responded = false;
                is_settled = false;
                for cycle=1:timeout
                    % set input activations
                    activation(self.input_ids) = 0;                    
                    if is_settled
                        activation(active_ids) = self.INPUT_ACTIVATION;
                    end
                    % set feature attention activations
                    activation(self.attention_ids) = 0;
                    %activation(self.unit_id('Attend Word')) = self.MAXIMUM_ACTIVATION; % TODO ongoing task is hardcoded
                    %activation(self.unit_id('Attend Category')) = self.MAXIMUM_ACTIVATION; % TODO ongoing task is hardcoded
                    %activation(self.unit_id('Attend Syllables')) = self.MAXIMUM_ACTIVATION; % TODO ongoing task is hardcoded
                    % set task attention activations
                    activation(self.task_ids) = 0;
                    %activation(self.unit_id('Word Categorization')) = self.MAXIMUM_ACTIVATION; % TODO ongoing task is hardcoded
                    % Einstein 2005: high emph (= 0.25) / low emph (= 0)
                    %activation(self.unit_id('Monitor')) = 0.3;
                    
                    % log activation for plotting
                    activation_log(cycles + cycle, :) = activation;
                    accumulators_log(cycles + cycle, :) = self.accumulators;
                    
                    % see if network has settled
                    if cycle > self.SETTLE_LEEWAY && ~is_settled
                        from = cycles + cycle - self.SETTLE_LEEWAY + 1;
                        to = cycles + cycle - 1;
                        m = activation_log(from:to,:) - activation_log(from-1:to-1,:);
                        m = abs(mean(m, 2));
                        %fprintf('%d -> %.6f, %6f\n', cycle, mean(m), std(m));
                        if mean(m) < self.SETTLE_EPS
                            is_settled = true;
                        end
                    end
                    
                    % calculate net inputs for all units
                    self.net_input = activation * self.weights + self.bias;
                    
                    % add noise to net inputs (except input units)
                    noise = normrnd(0, self.NOISE_SIGMA, 1, self.N);
                    noise(self.input_ids) = 0;
                    self.net_input = self.net_input + noise;
                    
                    % average net inputs
                    self.net_input_avg = self.TAU * self.net_input + (1 - self.TAU) * self.net_input_avg;
                    
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
                    activation = self.logistic(self.net_input_avg);
                    
                    % update evidence accumulators (after network has
                    % settled)
                    if is_settled
                        act_sorted = sort(activation(self.output_ids), 'descend');
                        act_max = ones(1, size(self.output_ids, 2)) * act_sorted(1);
                        act_max(activation(self.output_ids) == act_sorted(1)) = act_sorted(2);
                        mu = self.EVIDENCE_ACCUM_ALPHA * (activation(self.output_ids) - act_max);
                        add = normrnd(mu, ones(size(mu)) * self.EVIDENCE_ACCUM_SIGMA);
                        self.accumulators = self.accumulators + add;

                        % check if activation threshold is met
                        [v, id] = max(self.accumulators);
                        if ~responded && v > self.EVIDENCE_ACCUM_THRESHOLD
                            % save response and response time
                            output_id = self.output_ids(id);
                            RT = cycle;
                            responded = true;
                            break;
                        end
                    end
                end

                % record response and response time
                output = self.units{output_id};
                responses = [responses; {output}];
                RTs = [RTs; RT];
                cycles = cycles + cycle;
            end
            
            activation_log(cycles:end,:) = [];
            accumulators_log(cycles:end,:) = [];
        end
    end
end