% How long will it take to run a combination of various parameters?
% Assume an average of one minute per trial

% If we run one trial for each of the following scenarios, we get


% Number of change points: 1, 10, 20    3

% Guess points             1, 10, 30    3

% Theta: -.9, -.5, 0, .5, .9            5

% Psi: -.9, -.5, 0, .5, .9              5

% Phi: Same as number of change points  3

% Obs per seg 50, 100                   2

% Iterations 5000, 10000                2 

% Trials per scenario                   5


zw = [ 3,3,5,5,3,2,2,5]; prod(zw)/60;

hoursOfprocessing = prod(zw)/60 %This many estimated hours to do all combinations

days = hoursOfprocessing/24

parallelDays = days/4

parallel_at_5_hrs_per_day = parallelDays*24/5

