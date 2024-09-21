
%% add our tools
here = pwd;
addpath(genpath(fullfile(here,'my_models')));
addpath(genpath(fullfile(here,'my_functions')));

%% define the caracteristics of the task

ntrials =  40;
nruns   =  10;

%% first we need to simulate some data (because we do not have real one)
sim_alpha    = 0.3;
sim_inv_temp = 1.5;

[sim_ch, sim_r] = Qmodel (sim_alpha, sim_inv_temp, ntrials, nruns);


%% second we test if our parameter estimation process finds the same results

% here we test with a full grid search
[est_alpha, est_temp] = estimateQ_gridsearch(sim_ch, sim_r, nruns);


% here we test with an optimization function
x0 = [3 0.1]; % initial point of the exploration 5 temp and 0.5 alpha
xmin = [0 0]; % min values of each parameter
xmax = [5 1]; % max value of each parameter

% we define the options of the optimization function 
options = optimset('Algorithm', 'interior-point', 'Display', 'iter-detailed', 'MaxIter', 10000); % These increase the number of iterations to ensure the convergence


[parameters,nll,~,~,~]       = fmincon(@(x) estimateQ(x,sim_ch,sim_r, nruns),x0,[],[],[],[],xmin,xmax,[],options);
