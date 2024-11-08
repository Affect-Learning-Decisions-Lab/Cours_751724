%--------------------------------------------------------------------------
% Identifier  les modèles
% -------------------------------------------------------------------------


%% add our tools
here = pwd;
addpath(genpath(fullfile(here,'my_models')));
addpath(genpath(fullfile(here,'my_functions')));

%% input variables

nsub    = 300; % number of participants (or subjects, sub)
ntrials = 100; % number of trials
nruns   =  50; % number of runs
n_it    =  30;  % number of recovery iteration
N_init  =  10;  % number of free parameter initialisation

%% initialise parameters

simulated_param = nan(2,3,nsub);
recovered_param = nan(2,3,nsub);

%% initialise the distribution from which we will sample the free parameters

% number of initial point from which the search starts
nstarts = 5 ;

% min and max of the two parametres
xmin    = [ 0 0 0 0];
xmax    = [10 1 1 1];

% we define the options of the optimization function
options = optimset('Algorithm', 'interior-point', 'Display', 'iter-detailed', 'MaxIter', 10000, 'Display','off'); % These increase the number of iterations to ensure the convergence
warning off all

% Define the distribution object
pd = makedist('Gamma',3.5,1);
pdt = truncate(pd,xmin(1),xmax(1)) ;

%% start procedure

for k_it = 1:n_it % for each iteration

    % display current interation
    disp (['--------------   interation number ' num2str(k_it) ' ---------------------------', newline, '', newline, '']);

    for ksub = 1:nsub % for each simulated participant

        % display current participant
        disp (['************ synthetic participant number ' num2str(ksub) ' *************', newline, ' ', newline, ' ']);

        %% 1. Simulate behavior with the two models
        
        %------------------------------------------------------------------
        % sample free parameters

        % sample a set of free parameters from the distribution 
        sim_param(ksub).alpha    = random('Beta', 2.2, 2.2);
        sim_param(ksub).alphaE   = random('Beta', 2.2, 2.2);
        sim_param(ksub).alphaI   = random('Beta', 2.2, 2.2);
        sim_param(ksub).inv_temp = random(pdt);

        % save the sampled paramaeters
        simulated_param(:,:,ksub) = [sim_param(ksub).inv_temp,sim_param(ksub).alpha, 0;
            sim_param(ksub).inv_temp, sim_param(ksub).alphaE, sim_param(ksub).alphaI];

        %------------------------------------------------------------------
        % simulate behavior with Q model
        [Q.sim_ch, Q.sim_r] = Qmodel(sim_param(ksub).alpha, sim_param(ksub).inv_temp, ntrials, nruns);

        %------------------------------------------------------------------
        % simulate behavior with dual learning model
        [D.sim_ch, D.sim_r] = Qmodel_dual(sim_param(ksub).alphaE, sim_param(ksub).alphaI, sim_param(ksub).inv_temp, ntrials, nruns);

        models_sim = {Q, D};
        models     = {'Q','D'};
        %% 2. Fit the behavior 

        % the idea here is to fit the choices simulated with the two model
        % retrive the best parameters and see what is the best logliklihood 
        % of the model. If the procedure works well the best likelihood of
        % the model that generated the choices should be better than the
        % best likelihood of the model that did not.

        for m = 1:length(models)

            mdl_data = char(models(m));
            
            disp ('******************************************************************************') 

            disp (['*************** Using simulated data from ' mdl_data ' ***********************'])

            disp (['******************************************************************************', newline, '']) 


            % ----------------------------------------------------------------------
            disp ([' fitting model:  Q',   newline, ''])



            % ----------------------------------------------------------------------
            disp ([' fitting model:  Dual', newline, ''])



        end

        


    end


end

