function stat = EM2005_analyze_stats( subjects, subjects_extra)
% get stats from subjects and analyze so you can fit with fitparam()
%{
 variable order = 
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

PM_hit = subjects(:, 7);

% --- PM hit rate in focal vs. nonfocal ----

PM_hit_focal = PM_hit(subjects(:, 2) == 1);
PM_hit_nonfocal = PM_hit(subjects(:, 2) == 0);
p = anova1([PM_hit_focal PM_hit_nonfocal]);

PM_hit_focal_M = mean(PM_hit_focal(~isnan(PM_hit_focal)))
PM_hit_focal_SD = std(PM_hit_focal(~isnan(PM_hit_focal)))  % / sqrt(sum(~isnan(PM_hit_focal)))
PM_hit_nonfocal_M = mean(PM_hit_nonfocal(~isnan(PM_hit_nonfocal)))
PM_hit_nonfocal_SD = std(PM_hit_nonfocal(~isnan(PM_hit_nonfocal)))  % / sqrt(sum(~isnan(PM_hit_nonfocal)))



% --- PM hit rate in high emphasis vs. low emphasis ----

PM_hit_low = PM_hit(subjects(:, 3) == 0);
PM_hit_high = PM_hit(subjects(:, 3) == 1);
p = anova1([PM_hit_high PM_hit_low]);

PM_hit_low_M = mean(PM_hit_low(~isnan(PM_hit_low)))
PM_hit_low_SD = std(PM_hit_low(~isnan(PM_hit_low)))  %/ sqrt(sum(~isnan(PM_hit_low)));
PM_hit_high_M = mean(PM_hit_high(~isnan(PM_hit_high)))
PM_hit_high_SD = std(PM_hit_high(~isnan(PM_hit_high)))  %/ sqrt(sum(~isnan(PM_hit_high)));

% --- PM hit rate in high emph vs. low emph. for different focalities ----
% anova2? interaction between the two variables

% plot em' -- for each focality, show high emph & low epmoh next to each
% other
p = anovan(PM_hit, {subjects(:, 2) subjects(:, 3)});


% --- 


end

