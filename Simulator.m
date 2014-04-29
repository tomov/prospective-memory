classdef Simulator < Model
    % Class for simulating trials with different inputs and outputs
    % and potentially different model parameters than the default ones
    %
    
    properties (Access = public)
        wm_capacity = 2;
        attention_factor = 0; % obsolete... for now
        net_input;
        net_input_avg;
        accumulators;
        activation;
        wm_act;
        wm_net;
        Nout;
    end
    
    methods
        function self = Simulator(FOCAL, EMPHASIS, OG_ONLY, params)
            self = self@Model(FOCAL, EMPHASIS, OG_ONLY, params);
            self.Nout = size(self.output_ids, 2);
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
            to(to_ids) = self.MAXIMUM_ACTIVATION;
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
            % add noise
            % ... TODO a little artificial at the end but whatever
            % also noise sigma is hardcoded and made up
            %self.weights(self.perception_ids, self.task_ids) = self.weights(self.perception_ids, self.task_ids) ...
            %    + normrnd(0, 3, size(self.perception_ids, 2), size(self.task_ids, 2));
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

        function [responses, RTs, activation_log, accumulators_log, onsets, net_log] = trial(self, stimuli)
            % initialize activations and outputs
            trial_duration = sum(cat(2, stimuli{:, 2})) * self.CYCLES_PER_SEC;
            self.accumulators = zeros(1, self.Nout);
            self.net_input = zeros(1, self.N);
            self.net_input_avg = zeros(1, self.N);
            activation_log = zeros(trial_duration, self.N);
            accumulators_log = zeros(trial_duration, self.Nout);
            net_log = zeros(trial_duration, self.N);
            self.activation = zeros(1, self.N);
            self.wm_act = zeros(1, size(self.wm_ids, 2));
            self.wm_net = zeros(1, size(self.wm_ids, 2));
            self.net_input_avg = zeros(1, self.N);
            responses = [];
            RTs = [];
            onsets = [];
            cycles = 0;
            switched_to_PM_task = false;
            
            % for each input from the time series
            for ord=1:size(stimuli, 1)
                % get active input units for given stimulus
                % each stimulus string must be a comma-separated list of names of
                % input units
                stimulus = stimuli{ord, 1};
                active_ids = self.string_to_ids(stimulus);
                timeout = stimuli{ord, 2} * self.CYCLES_PER_SEC;
                
                % reset feedforward part of the network
                %self.activation(self.ffwd_ids) = 0;
                %self.net_input_avg(self.ffwd_ids) = -10;
                
                % reset response, output, and monitoring activations
                self.accumulators = zeros(1, size(self.output_ids, 2));
                
                % default output is timeout
                output_id = self.unit_id('timeout');
                RT = timeout;
                
                % simulate response to stimulus
                responded = false;
                is_settled = false;
                settle_cycles = 0;
                for cycle=1:timeout
                    % set input activations
                    self.activation(self.input_ids) = 0;                    
                    if is_settled
                        self.activation(active_ids) = self.INPUT_ACTIVATION;
                    end
                    
                    % hack for testing different activations
                    %self.wm_act = self.init_wm;
                    %self.activation(self.wm_ids) = (self.wm_act + 5) / 10;%self.logistic(self.wm_act);
                    
                    % initialize WM at beginning of block (i.e. first
                    % trial),
                    % or after a PM switch
                    if cycle == 1 && (ord == 1 || switched_to_PM_task)
                        self.wm_act = self.init_wm;
                        self.activation(self.wm_ids) = (self.wm_act + 5) / 10;%self.logistic(self.wm_act);
                    end

                    % log activation for plotting
                    activation_log(cycles + cycle, :) = self.activation;
                    accumulators_log(cycles + cycle, :) = self.accumulators;
                    net_log(cycles + cycle, :) = self.net_input;
                    
                    % see if network has settled
                    if cycle > self.SETTLE_LEEWAY && ~is_settled
                        from = cycles + cycle - self.SETTLE_LEEWAY + 1;
                        to = cycles + cycle - 1;
                        m = activation_log(from:to,:) - activation_log(from-1:to-1,:);
                        m = abs(mean(m, 2));
                        %fprintf('%d -> %.6f, %6f\n', cycle, mean(m), std(m));
                        if mean(m) < self.SETTLE_MEAN_EPS && std(m) < self.SETTLE_STD_EPS
                            is_settled = true;
                            settle_cycles = cycle;
                            % save stimulus onset
                            onsets = [onsets; cycles + cycle];
                        end
                    end
                    
                    % calculate net inputs for all units
                    self.net_input(self.ffwd_ids) = self.activation * self.weights(:, self.ffwd_ids) ...
                        + self.bias(self.ffwd_ids);
                    self.net_input(self.wm_ids) = self.activation(self.ffwd_ids) * self.weights(self.ffwd_ids, self.wm_ids) ...
                        + self.wm_act * self.weights(self.wm_ids, self.wm_ids) ...
                        + self.bias(self.wm_ids);
                    % for debugging...
                    %if cycles + cycle < 10
                    %    fprintf('%d: %.4f %.4f\n', cycles + cycle, self.activation(1), self.net_input(self.unit_id('PM Task')));
                    %end
                                        
                    % add noise to net inputs (except input units)
                    noise = normrnd(0, self.NOISE_SIGMA, 1, self.N);
                    noise(self.input_ids) = 0;
                    % TODO no noise... for now
                    %self.net_input = self.net_input + noise;
                    
                    % update activation levels for feedforward part of the
                    % network
                    self.net_input_avg(self.ffwd_ids) = self.TAU * self.net_input(self.ffwd_ids) + (1 - self.TAU) * self.net_input_avg(self.ffwd_ids);
                    self.activation(self.ffwd_ids) = self.logistic(self.net_input_avg(self.ffwd_ids));
                    
                    % same for WM module
                    self.wm_act = self.wm_act + self.STEP_SIZE * self.net_input(self.wm_ids);
                    self.wm_act(self.wm_act > self.MAX_WM_ACT) = self.MAX_WM_ACT;
                    self.wm_act(self.wm_act < self.MIN_WM_ACT) = self.MIN_WM_ACT;
                    self.activation(self.wm_ids) = (self.wm_act + 5) / 10;%self.logistic(self.wm_act);
                    
                    % update evidence accumulators (after network has
                    % settled)
                    if is_settled
                        act_sorted = sort(self.activation(self.output_ids), 'descend');
                        act_max = ones(1, size(self.output_ids, 2)) * act_sorted(1);
                        act_max(self.activation(self.output_ids) == act_sorted(1)) = act_sorted(2);
                        mu = self.EVIDENCE_ACCUM_ALPHA * (self.activation(self.output_ids) - act_max);
                        add = normrnd(mu, ones(size(mu)) * self.EVIDENCE_ACCUM_SIGMA);
                        self.accumulators = self.accumulators + add;

                        % check if activation threshold is met
                        [v, id] = max(self.accumulators);
                        if ~responded && v > self.EVIDENCE_ACCUM_THRESHOLD
                            % save response and response time
                            output_id = self.output_ids(id);
                            RT = cycle - settle_cycles;
                            responded = true;
                            % a bit hacky, ALSO TODO does not work after
                            % timeout
                            break;
                        end
                    end
                end
                
                %switched_to_PM_task = (self.activation(self.unit_id('PM Task')) > self.activation(self.unit_id('OG Task')));
                % TODO hacky...
                switched_to_PM_task = (self.wm_act(2) > self.init_wm(2) + 0.1);
                %switched_to_PM_task = true;

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