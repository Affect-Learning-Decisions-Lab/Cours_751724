
%% Ajouter les outils (modèle et fonctions)
here = pwd;
addpath(genpath(fullfile(here,'my_models')));
addpath(genpath(fullfile(here,'my_functions')));

%% Définir les caractéristiques de la tâche
ntrials =  40;
nruns   =  10;

%% D'abord, nous devons simuler des données (car nous n'avons pas de vraies données)
sim_alpha    = 0.3;
sim_inv_temp = 1.5;

[sim_ch, sim_r] = Qmodel (sim_alpha, sim_inv_temp, ntrials, nruns);


%% Ensuite, nous procedons avec le processus d'estimation des paramètres sur le comportement 

% grid search
[est_alpha, est_temp] = estimateQ_gridsearch(sim_ch, sim_r, nruns);


% fonction d'optimisation
x0   = [3 0.1]; % point initial : la première valeur correspond à la température, la deuxième valeur correspond à alpha
xmin = [0 0];   % valeurs minimales : la première valeur correspond à la température, la deuxième valeur correspond à alpha
xmax = [5 1];   % valeurs maximales : la première valeur correspond à la température, la deuxième valeur correspond à alpha

% On définit les options de la fonction d'optimisation 
options = optimset('Algorithm', 'interior-point', 'Display', 'iter-detailed', 'MaxIter', 10000); % Ces valeurs augmentent le nombre d'itérations pour s'assurer d'avoir une convergence

[parameters,nll,~,~,~]       = fmincon(@(x) estimateQ(x,sim_ch,sim_r, nruns),x0,[],[],[],[],xmin,xmax,[],options);

%% Use the optimisation function restraining the space of the parameters we want to explore

% define the parameters


% inverse temperature (is the first free parameter in our model)
g                = [2 1]; % parameters of the gamma prior
param(1).name    = 'inverse temperature';
param(1).logpdf  = @(x) sum(log(gampdf(x, g(1), g(2))));  % log density function for prior
param(1).lb      = 0;    % lower bound
param(1).ub      = 5;   % upper bound

% learning rate (is the second free parameter in our model)
b                = [2.2, 2.2]; % parameters of beta prior
param(2).name    = 'learning rate';
param(2).logpdf  = @(x) sum(log(betapdf(x, b(1), b(2)))); % log density function for prior
param(2).lb      = 0;
param(2).ub      = 1;


% define the input to use the function
nstarts    = 3;       % we want to have several starting points of our search
data.ch    = sim_ch;  % just put the data of the task and behavior in the same data structure
data.r     = sim_r;
data.nruns = nruns;


% Obtain the estimates with the optimization function
estimate  = model_fit_optimize (@estimateQ, data, param, nstarts);

estimate.param



