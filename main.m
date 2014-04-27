warning('off', 'MATLAB:ClassInstanceExists');
clear classes % ! super important ! if you don't do this, MATLAB won't reload your classes


% best parameters so far...
 bestpar = [5.0000   -2.0000    5.0000   -5.0000    ...
           2.6000   0    5.0000   -5.0000    ...
           5.0000   -3.0000   2.0000         0  ...
           3.0000    0.3750    2.0000     0];
% show us what we got
stat = EM2005(par);
fits;
       
% then start the search
startpar = [5 -2  5 -5 ...
               2  0  5 -5 ...
               5 -3  2  0 ...
               3  0  2  0];
init_goalstats;
typestat = [2 3 1 1, 2 3 1 1, 2 3 1 1, 2 3 1 1, ...
            2 3 1 1, 2 3 1 1, 2 3 1 1, 2 3 1 1];
randiter = 0;
optiter = 70;
tuneiter = 50;
nosession = 1;
statweight = [10 1 2 2, 10 1 2 2, 10 1 2 2, 10 1 2 2, ...
              1 1 1 1, 1 1 1 1, 1 1 1 1, 1 1 1 1];
parange = repmat([-5 5], length(startpar), 1);

[par, val] = fitparam('EM2005', startpar, goalstat, typestat, ...
    randiter, optiter, tuneiter, nosession, statweight, parange);


stat = EM2005(par)
fits;