%function stat = EM2005_analyze_stats( subjects, subjects_extra)
% get stats from subjects and analyze so you can fit with fitparam()
%{
 samples variable order = 
    1 - OG_ONLY,
    2 - FOCAL, 
    3 - EMPHASIS
 statistics order = 
    4 - OG_RT, 
    5 - OG_Hit, 
    6 - PM_RT, 
    7 - PM_Hit,
    8 - PM_miss_OG_hit
 (see EM2005)
%}

DO_PLOT = false;


PM_hit = subjects(:, 7);

% --- PM hit rate in focal vs. nonfocal ----

PM_hit_focal = PM_hit(subjects(:, 2) == 1);
PM_hit_nonfocal = PM_hit(subjects(:, 2) == 0);
%p = anova1([PM_hit_focal PM_hit_nonfocal]);

PM_hit_focal_M = mean(PM_hit_focal(~isnan(PM_hit_focal)));
PM_hit_focal_SD = std(PM_hit_focal(~isnan(PM_hit_focal)));  % / sqrt(sum(~isnan(PM_hit_focal)))
PM_hit_nonfocal_M = mean(PM_hit_nonfocal(~isnan(PM_hit_nonfocal)));
PM_hit_nonfocal_SD = std(PM_hit_nonfocal(~isnan(PM_hit_nonfocal)));  % / sqrt(sum(~isnan(PM_hit_nonfocal)))


% --- PM hit rate in high emphasis vs. low emphasis ----

PM_hit_low = PM_hit(subjects(:, 3) == 0);
PM_hit_high = PM_hit(subjects(:, 3) == 1);
%p = anova1([PM_hit_high PM_hit_low]);

PM_hit_low_M = mean(PM_hit_low(~isnan(PM_hit_low)));
PM_hit_low_SD = std(PM_hit_low(~isnan(PM_hit_low)));  %/ sqrt(sum(~isnan(PM_hit_low)));
PM_hit_high_M = mean(PM_hit_high(~isnan(PM_hit_high)));
PM_hit_high_SD = std(PM_hit_high(~isnan(PM_hit_high)));  %/ sqrt(sum(~isnan(PM_hit_high)));

% --- PM hit rate in high emph vs. low emph. for different focalities ----
% anova2? interaction between the two variables

% plot em' -- for each focality, show high emph & low epmoh next to each
% other
%p = anovan(PM_hit, {subjects(:, 2) subjects(:, 3)}, 'model','interaction');

barweb([10 50; 60 70], [5 5; 5 5], 1, {'Focal', 'Nonfocal'}, 'title', 'xlabel', 'PM Hit rate (%)');





% --------------------------------------------- the big plot -----------------------------------------



% -------------- define the empirical stats (Table 1 from E&M 2005)

%{
 stats variable order = 
    1 - OG_ONLY,
    2 - FOCAL, 
    3 - EMPHASIS
 statistics order = 
    4 - OG_RT_M,
    5 - OG_RT_SD,
    6 - OG_Hit_M,
    7 - OG_Hit_SD,
    8 - PM_RT_M,
    9 - PM_RT_SD
    10 - PM_Hit_M,
    11 - PM_Hit_SD
%}
SD_cols = [5 7 9 11];

subjects_per_condition = 24;
empirical_stats = [
    1 1 0, 1073.25, 112.04, 97, 2, NaN, NaN, NaN, NaN;  % no-PM, focal,    low emph
    0 1 0, 1120.87, 116.48, 97, 2, NaN, NaN, 88, 16;    % PM,    focal,    low emph
    1 1 1, 1149.25, 137.58, 97, 2, NaN, NaN, NaN, NaN;  % no-PM, focal,    high emph
    0 1 1, 1239.17, 175.42, 97, 2, NaN, NaN, 92, 16;    % PM,    focal,    high emph
    1 0 0, 1140.92, 172.87, 97, 2, NaN, NaN, NaN, NaN;  % no-PM, nonfocal, low emph
    0 0 0, 1425.39, 378.52, 97, 2, NaN, NaN, 53, 34;    % PM,    nonfocal, low emph
    1 0 1, 1183.17, 164.43, 97, 2, NaN, NaN, NaN, NaN;  % no-PM, nonfocal, high emph
    0 0 1, 1593.43, 300.86, 97, 2, NaN, NaN, 81, 27;    % PM,    nonfocal, high emph 
];

% convert SD's to SEM's in empirical data
empirical_stats(:, SD_cols) = empirical_stats(:, SD_cols) / sqrt(subjects_per_condition);

% ------------- calculate simulation stats (Table 1 from E&M 2005)

simulation_stats = [];
for FOCAL = 1:-1:0
    for EMPHASIS = 0:1
        for OG_ONLY = 1:-1:0            
            stat = [OG_ONLY, FOCAL, EMPHASIS];
            for col = 4:7
                samples = subjects(subjects(:, 1) == OG_ONLY & subjects(:, 2) == FOCAL & subjects(:, 3) == EMPHASIS, col);
                M = mean(samples);
                SD = std(samples);
                stat = [stat, M, SD];
            end
            simulation_stats = [simulation_stats; stat];
        end
    end
end

% convert SD's to SEM's in simulation data
simulation_stats(:, SD_cols) = simulation_stats(:, SD_cols) / sqrt(subjects_per_condition);

% -------------- run linear regression to find slope and intercept for RT's

empirical_RTs = empirical_stats(:, 4);
simulation_cycles = simulation_stats(:, 4);

p = polyfit(simulation_cycles, empirical_RTs, 1);
RT_slope = p(1);
RT_intercept = p(2);
yfit = polyval(p, simulation_cycles);

yresid = empirical_RTs - yfit;
SSresid = sum(yresid.^2);
SStotal = (length(empirical_RTs)-1) * var(empirical_RTs);
rsq = 1 - SSresid/SStotal;

if DO_PLOT
    scatter(simulation_cycles, empirical_RTs);
    clear xlabel ylabel;
    xlabel('Simulation RTs (cycles)');
    ylabel('Empirical RTs (msec)');
    lsline
    title(sprintf('R^2 = %.4f', rsq));
end


% ------------------ plot the all the good stuff


if DO_PLOT
    figure;

    subplot(3, 2, 1);
    title('Empirical Data (Einstein & McDaniel 2005)');
    ylabel('OG RT (msec)');
    plot_all_conditions(empirical_stats(:, [1:3 4 5]), 1000, 1700, 1, 0, true);

    subplot(3, 2, 2);
    title('Simulation Data');
    ylabel(sprintf('OG RT (msec = cycles * %.1f + %.1f)', RT_slope, RT_intercept));
    plot_all_conditions(simulation_stats(:, [1:3 4 5]), 1000, 1700, RT_slope, RT_intercept, false);

    subplot(3, 2, 3);
    ylabel('OG Accuracy (%)');
    plot_all_conditions(empirical_stats(:, [1:3 6 7]), 40, 100, 1, 0, false);

    subplot(3, 2, 4);
    plot_all_conditions(simulation_stats(:, [1:3 6 7]), 40, 100, 1, 0, false);

    subplot(3, 2, 5);
    ylabel('PM Hit Rate (%)');
    plot_all_conditions(empirical_stats(:, [1:3 10 11]), 40, 100, 1, 0, false);

    subplot(3, 2, 6);
    plot_all_conditions(simulation_stats(:, [1:3 10 11]), 40, 100, 1, 0, false);
end