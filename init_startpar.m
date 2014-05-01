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

startpar = [1  0    1  0.1  0, ...    % focal, low emph
            1  0    1  0.15  0, ...    % focal, high emph
            1  0.4  0.7  0    0.5, ...    % nonfocal, low emph
            1  0.6  0.7  0    0.5, ...    % nonfocal, high emph
            3 3];
        
[data, ~] = EM2005(startpar, 2);