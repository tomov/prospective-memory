warning('off', 'MATLAB:ClassInstanceExists');
clear classes % ! super important ! if you don't do this, MATLAB won't reload your classes

% best parameters so far...
% KEEP I_WM equal for both task and feature units

%{
params = 
  [WM units focal, low emph ...
   WM units focal, high emph ...
   WM units nonfocal, low emph ...
   WM units nonfocal, high emph ...
   WM bias,
   WM bias];
where
  WM units = [
    OG Task     PM Task     OG features     Monitor tortoise    Monitor tor
  ];
%}

startpar = [1  0       1    0, ...      % focal, low emph
            1  0       1    0.7, ...    % focal, high emph
            1  0.3   0.7    0.5, ...    % nonfocal, low emph
            1  0.4   0.6    0.5, ...    % nonfocal, high emph
            4 4 4];

        
debug_mode = false;


[data, extra] = EM2005(startpar, 1, debug_mode);
data

if debug_mode
	m = Model(startpar, false);
    wm_ids = m.wm_ids;
    context_ids = m.context_ids;
    act = extra{1, 8};
    nets = extra{1, 12};
   % figure;
   % plot([act(1:100, context_ids), nets(1:100, context_ids)]);
else
    save('rondo-run-data-exp-1.mat');
    EM2005_with_stats_exp1
end


        
%{
[data, ~] = EM2005(startpar, 1);
data
save('rondo-run-data-exp-1.mat');
EM2005_with_stats_exp1
save('rondo-run-data-exp-1-with-stats.mat');


data_exp1 = data;


[data, ~] = EM2005(startpar, 2);
data
save('rondo-run-data-exp-12.mat');
EM2005_with_stats_exp2
save('rondo-run-data-exp-12-with-stats.mat');


data_exp2 = data;


[data, ~] = EM2005(startpar, 3);
data
save('rondo-run-data-exp-123.mat');
%EM2005_with_stats_exp1
%save('rondo-run-data-exp-123-with-stats.mat');


data_exp3 = data;

save('goodmorning.mat');
            
            
%}
            

%% ----- BIG TODOs ----

%{
make experiment 5 gather relevant data



make number of subjects normal

go and make sure there are no hacks left (FIXME) and no hardcoded numbers
  
send them all as jobs 
%}

