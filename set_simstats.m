% set simulation statistics for nicely named variables from variable stat =
% EM2005(...) so they can be used by fit.m

% note that the order of the loops here should be exactly as that in EM2005.m !!!
% and that the order of the parameters is defined as in getstat.m
% this is basically the inverse of that

step = 1;

for OG_ONLY = 0:1
    for FOCAL = 1:-1:0
        for EMPHASIS = 0:1
            
            s = stat(step, step+3);
            RT = s(1);
            SD = s(2);
            OG = s(3);
            PM = s(4);

            if OG_ONLY
                if FOCAL
                    if EMPHASIS
                        sim_foc_high_RT_noPM = RT;
                        sim_foc_high_SD_noPM = SD;
                        sim_foc_high_OG_noPM = OG;
                        sim_foc_high_PM_noPM = PM;
                    else
                        sim_foc_low_RT_noPM = RT;
                        sim_foc_low_SD_noPM = SD;
                        sim_foc_low_OG_noPM = OG;
                        sim_foc_low_PM_noPM = PM;
                    end
                else
                    if EMPHASIS
                        sim_nonfoc_high_RT_noPM = RT;
                        sim_nonfoc_high_SD_noPM = SD;
                        sim_nonfoc_high_OG_noPM = OG;
                        sim_nonfoc_high_PM_noPM = PM;
                    else
                        sim_nonfoc_low_RT_noPM = RT;
                        sim_nonfoc_low_SD_noPM = SD;
                        sim_nonfoc_low_OG_noPM = OG;
                        sim_nonfoc_low_PM_noPM = PM;
                    end
                end
            else
                if FOCAL
                    if EMPHASIS
                        sim_foc_high_RT = RT;
                        sim_foc_high_SD = SD;
                        sim_foc_high_OG = OG;
                        sim_foc_high_PM = PM;
                    else
                        sim_foc_low_RT = RT;
                        sim_foc_low_SD = SD;
                        sim_foc_low_OG = OG;
                        sim_foc_low_PM = PM;
                    end
                else
                    if EMPHASIS
                        sim_nonfoc_high_RT = RT;
                        sim_nonfoc_high_SD = SD;
                        sim_nonfoc_high_OG = OG;
                        sim_nonfoc_high_PM = PM;
                    else
                        sim_nonfoc_low_RT = RT;
                        sim_nonfoc_low_SD = SD;
                        sim_nonfoc_low_OG = OG;
                        sim_nonfoc_low_PM = PM;
                    end
                end    
            end
            
        end
    end
end