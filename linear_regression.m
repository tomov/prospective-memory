cycles = stat(1:4:18);
RTs = goalstat(1:4:18);

scatter(cycles, RTs);
xlabel('Simulation RTs (cycles)');
ylabel('Empirical RTs (msec)');
lsline


p = polyfit(cycles, RTs, 1);
yfit = polyval(p, cycles);

yresid = RTs - yfit;
SSresid = sum(yresid.^2);
SStotal = (length(RTs)-1) * var(RTs);
rsq = 1 - SSresid/SStotal
