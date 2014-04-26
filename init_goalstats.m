% initialize goal statistics of model for E&M 2005 experiment 1

% PM task

emp_foc_low_RT = 1120.87;
emp_foc_low_SD = 116.48;
emp_foc_low_OG = 97;
emp_foc_low_PM = 88;

emp_foc_high_RT = 1239.17;
emp_foc_high_SD = 175.42;
emp_foc_high_OG = 97;
emp_foc_high_PM = 92;

emp_nonfoc_low_RT = 1425.39;
emp_nonfoc_low_SD = 379.52;
emp_nonfoc_low_OG = 97;
emp_nonfoc_low_PM = 53;

emp_nonfoc_high_RT = 1593.43;
emp_nonfoc_high_SD = 300.86;
emp_nonfoc_high_OG = 97;
emp_nonfoc_high_PM = 81;

% no PM task

emp_foc_low_RT_noPM = 1073.25;
emp_foc_low_SD_noPM = 112.04;
emp_foc_low_OG_noPM = 97;
emp_foc_low_PM_noPM = NaN;

emp_foc_high_RT_noPM = 1149.25;
emp_foc_high_SD_noPM = 137.58;
emp_foc_high_OG_noPM = 97;
emp_foc_high_PM_noPM = NaN;

emp_nonfoc_low_RT_noPM = 1140.92;
emp_nonfoc_low_SD_noPM = 172.87;
emp_nonfoc_low_OG_noPM = 97;
emp_nonfoc_low_PM_noPM = NaN;

emp_nonfoc_high_RT_noPM = 1183.17;
emp_nonfoc_high_SD_noPM = 164.43;
emp_nonfoc_high_OG_noPM = 97;
emp_nonfoc_high_PM_noPM = NaN;



goalstat = [
    % row order here is important -- should be consistent with order of params
    % in EM2005.m (i.e. order of conditions in for-loops)
    % column order should be same as in getstats.m (at the bottom)
    emp_foc_low_RT, emp_foc_low_SD, emp_foc_low_OG, emp_foc_low_PM, ...
    emp_foc_high_RT, emp_foc_high_SD, emp_foc_high_OG, emp_foc_high_PM, ...
    emp_nonfoc_low_RT, emp_nonfoc_low_SD, emp_nonfoc_low_OG, emp_nonfoc_low_PM, ...
    emp_nonfoc_high_RT, emp_nonfoc_high_SD, emp_nonfoc_high_OG, emp_nonfoc_high_PM, ...    
    emp_foc_low_RT_noPM, emp_foc_low_SD_noPM, emp_foc_low_OG_noPM, emp_foc_low_PM_noPM, ...
    emp_foc_high_RT_noPM, emp_foc_high_SD_noPM, emp_foc_high_OG_noPM, emp_foc_high_PM_noPM, ...
    emp_nonfoc_low_RT_noPM, emp_nonfoc_low_SD_noPM, emp_nonfoc_low_OG_noPM, emp_nonfoc_low_PM_noPM, ...
    emp_nonfoc_high_RT_noPM, emp_nonfoc_high_SD_noPM, emp_nonfoc_high_OG_noPM, emp_nonfoc_high_PM_noPM, ...
    ];

% this is a hack b/c fitparam doesn't work with NaNs
goalstat(isnan(goalstat)) = -100;