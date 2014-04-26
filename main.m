warning('off', 'MATLAB:ClassInstanceExists');
clear classes % ! super important ! if you don't do this, MATLAB won't reload your classes

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
nosession = 10;
statweight = ones(1, length(goalstat));
parange = repmat([-5 5], length(startpar), 1);

[par, val] = fitparam('EM2005', startpar, goalstat, typestat, ...
    randiter, optiter, tuneiter, nosession, statweight, parange);

%fits;