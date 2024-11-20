%--------------------------------------------------------------------------
% Identifier  les modèles
% -------------------------------------------------------------------------


%% add our tools
here = pwd;
addpath(genpath(fullfile(here,'my_models')));
addpath(genpath(fullfile(here,'my_functions')));

%% input variables

nsub    = 100; % number of participants (or subjects, sub)
ntrials = 100; % number of trials
nruns   =  50; % number of runs
n_it    =  30; % number of recovery iteration

%% define parameters

% inverse temperature
g                = [2 1]; % parameters of the gamma prior
param(1).name    = 'inverse temperature';
param(1).logpdf  = @(x) sum(log(gampdf(x, g(1), g(2))));  % log density function for prior
param(1).lb      = 0;    % lower bound
param(1).ub      = 10;   % upper bound

% learning rate
b                = [2.2, 2.2]; % parameters of beta prior
param(2).name    = 'learning rate';
param(2).logpdf  = @(x) sum(log(betapdf(x, b(1), b(2)))); 
param(2).lb      = 0;
param(2).ub      = 1;

% excitatory learning rate
b                = [2.2, 2.2]; % parameters of beta prior
param(3).name    = 'excitatory learning rate';
param(3).logpdf  = @(x) sum(log(betapdf(x, b(1), b(2)))); 
param(3).lb      = 0;
param(3).ub      = 1;

% inhibitory learning rate 
b                = [2.2, 2.2]; % parameters of beta prior
param(4).name    = 'inhibitory learning rate';
param(4).logpdf  = @(x) sum(log(betapdf(x, b(1), b(2)))); 
param(4).lb      = 0;
param(4).ub      = 1;

% models to fit  
models     = {'Q','D'}; % Q : q learning single learning rate; D : dual learning rate
nmodels    = [  1, 2 ];


%% define the distribution from which we will sample the free parameters

% number of initial point from which the search starts
nstarts = 5 ;

% Define the distribution object for the sampling of the inverse temp
pd = makedist('Gamma',3.5,1);
pdt = truncate(pd,param(1).lb,param(1).ub) ;

%% start procedure

for k_it = 1:n_it % for each iteration

    disp (['--------------   interation number ' num2str(k_it) ' ---------------------------', newline, '', newline, '']);

    for ksub = 1:nsub % for each simulated participant

        disp (['************ synthetic participant number ' num2str(ksub) ' *************', newline, ' ', newline, ' ']);

        %% 1. Simulate behavior with the two models

        %------------------------------------------------------------------
        % sample free parameters

        % sample a set of free parameters from the distribution
        sim_param(ksub).alpha    = random('Beta', 2.2, 2.2);
        sim_param(ksub).alphaE   = random('Beta', 2.2, 2.2);
        sim_param(ksub).alphaI   = random('Beta', 2.2, 2.2);
        sim_param(ksub).inv_temp = random(pdt);

        %------------------------------------------------------------------
        % simulate behavior with Q model
        [Q.ch, Q.r] = Qmodel(sim_param(ksub).alpha, sim_param(ksub).inv_temp, ntrials, nruns);
         Q.nruns = nruns;    
            
        %------------------------------------------------------------------
        % simulate behavior with dual learning model
        [D.ch, D.r] = Dmodel(sim_param(ksub).alphaE, sim_param(ksub).alphaI, sim_param(ksub).inv_temp, ntrials, nruns);
         D.nruns = nruns;    
        
        % save output
        models_sim = { Q , D };
        
        %% 2. Fit the behavior

        % the idea here is to fit the choices simulated with the two model
        % retrive the best parameters and see what is the best logliklihood
        % of the model. If the procedure works well the best likelihood of
        % the model that generated the choices should be better than the
        % best likelihood of the model that did not.

        for simd = 1:length(models)

            mdl_data = char(models(simd));

            disp ('-------------- -------------- -------------- -------------- ')
            disp (['--------------   Using simulated data from ' mdl_data ' --------------'])

            % ----------------------------------------------------------------------
            disp ([' fitting model:  Q',   newline, ''])

            % fit Q model
            data  = models_sim{simd};
            Qfit  = mf_optimize (@estimateQ, data, param([1 2]), nstarts);

            % save output for bayesian model comparison
            recovered(simd).Q.K                = Qfit.K;
            recovered(simd).Q.logpost(ksub)    = Qfit.logp;
            recovered(simd).Q.loglik(ksub)     = Qfit.loglik;
            recovered(simd).Q.bic(ksub)        = Qfit.bic;
            recovered(simd).Q.aic(ksub)        = Qfit.aic;
            recovered(simd).Q.H{ksub}          = Qfit.H;

            % ----------------------------------------------------------------------
            disp ([' fitting model:  Dual', newline, ''])

            % fit Dual model
            data  = models_sim{simd};
            Dfit  = mf_optimize (@estimateD, data, param([1 3 4]), nstarts);

            % save output for bayesian model comparison
            recovered(simd).D.K                = Dfit.K;
            recovered(simd).D.logpost(ksub)    = Dfit.logp;
            recovered(simd).D.loglik(ksub)     = Dfit.loglik;
            recovered(simd).D.bic(ksub)        = Dfit.bic;
            recovered(simd).D.H{ksub}          = Dfit.H;

        end % end each data simulation from each model

    end % end participant

    %% 3. do the model recovery
    for ksim = 1:length(nmodels)

        % format data
        for i = 1:length(fieldnames(recovered(ksim)))
            names         = fieldnames(recovered(ksim));
            name          = char(cellstr(names(i)));
            databms(i)    = recovered(ksim).(name); 
        end

        % perform bayesian model selection 
        bms_results.bic(ksim) = mf_bms_bic(databms);

    end

    %% 4. save simulation data 
    xt         = datetime;
    add_rnd    = round(100 * rand());
    flnm       = strcat('Sim_', datestr(xt, 'yyyymmddTHHMMSS'), '_', num2str(add_rnd), '.mat');

    disp(datetime)

    full_flnm  = fullfile(here,'my_recoveries',flnm);
    save(full_flnm, 'bms_results')

end

%% 5. Plot data
data_path = fullfile(here,'my_recoveries');

mf_plotModelRec(data_path, models, 'Sim_*')
