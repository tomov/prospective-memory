function s = getstats(OG_ONLY, FOCAL, EMPHASIS, responses, RTs, is_target, correct)

OG_count = 0;
PM_count = 0;
OG_correct_RTs = [];
PM_hit_RTs = [];
false_alarm_RTs = [];
OG_wrong_RTs = [];
PM_miss_RTs = [];
OG_timeout_RTs = [];
PM_timeout_RTs = [];

for i=1:size(responses, 1)
    if strcmp(responses{i}, correct{i}) == 1
        % right answer
        if is_target(i) == 0
            % OG correct
            OG_count = OG_count + 1;
            OG_correct_RTs = [OG_correct_RTs; RTs(i)];
        else
            % PM hit
            PM_count = PM_count + 1;
            PM_hit_RTs = [PM_hit_RTs; RTs(i)];
        end
    else
        % wrong answer
        if is_target(i) == 0
            OG_count = OG_count + 1;
            % timeout
            if strcmp(responses{i}, 'timeout') == 1
                OG_timeout_RTs = [OG_timeout_RTs; RTs(i)];
                continue;
            end
            if strcmp(responses{i}, 'PM') == 1
                % false alarm
                false_alarm_RTs = [false_alarm_RTs; RTs(i)];
            else
                % OG wrong
                OG_wrong_RTs = [OG_wrong_RTs; RTs(i)];
            end
        else
            PM_count = PM_count + 1;
            % timeout
            if strcmp(responses{i}, 'timeout') == 1
                PM_timeout_RTs = [PM_timeout_RTs; RTs(i)];
                continue;
            end
            % PM miss
            PM_miss_RTs = [PM_miss_RTs; RTs(i)];
        end
    end
end


%{
RTs
responses
OG_count
PM_count
%}

if OG_ONLY
    og_string = 'No PM task';
else
    og_string = 'PM task';
end
if FOCAL
    if EMPHASIS
        fprintf('\n ----> focal, high emphasis, %s ----\n', og_string);
    else
        fprintf('\n ----> focal, low emphasis, %s ----\n', og_string);
    end
else
    if EMPHASIS
        fprintf('\n ----> nonfocal, high emphasis, %s ----\n', og_string);
    else
        fprintf('\n ----> nonfocal, low emphasis, %s ----\n', og_string);
    end
end

%if ~OG_ONLY
    fprintf('mean OG correct RTs = %.4f (%.4f)\n', mean(OG_correct_RTs), std(OG_correct_RTs));
    fprintf('mean PM hit RTs = %.4f (%.4f)\n', mean(PM_hit_RTs), std(PM_hit_RTs));
    fprintf('OG accuracy = %.4f%%\n', size(OG_correct_RTs, 1) / OG_count * 100);
    fprintf('PM hit rate = %.4f%%\n', size(PM_hit_RTs, 1) / PM_count * 100);
%end


% save stats for fits

RT = mean(OG_correct_RTs);
% http://en.wikipedia.org/wiki/Standard_error !!!
SD = std(OG_correct_RTs) / sqrt(size(OG_correct_RTs, 2));
% !!!!
OG = size(OG_correct_RTs, 1) / OG_count * 100;
PM = size(PM_hit_RTs, 1) / PM_count * 100;

s = [RT SD OG PM];