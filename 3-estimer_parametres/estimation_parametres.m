
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

[sim_ch, sim_r] = Qmodel(sim_alpha, sim_inv_temp, ntrials, nruns);


%% Méthode 1: Grid Search

[est_alpha, est_temp] = estimateQ_gridsearch(sim_ch, sim_r, nruns);


%% Méthode 2: Optimisation avec vraisamblance

x0   = [ 3 0.1];   % point initial : la première valeur correspond à la température, la deuxième valeur correspond à alpha
xmin = [ 0 0  ];   % valeurs minimales : la première valeur correspond à la température, la deuxième valeur correspond à alpha
xmax = [10 1  ];   % valeurs maximales : la première valeur correspond à la température, la deuxième valeur correspond à alpha

% On définit les options de la fonction d'optimisation 
options = optimset('Algorithm', 'interior-point', 'Display', 'iter-detailed', 'MaxIter', 10000); % Ces valeurs augmentent le nombre d'itérations pour s'assurer d'avoir une convergence

[parameters,nll,~,~,~]       = fmincon(@(x) estimateQ(x,sim_ch,sim_r, nruns),x0,[],[],[],[],xmin,xmax,[],options);

%% Méthode 3: Optimisation avec log posterior

% temperature inverse
g                = [3.5 1]; % parameters of the gamma prior
param(1).name    = 'inverse temperature';
param(1).logpdf  = @(x) sum(log(gampdf(x, g(1), g(2))));  % log density function for prior
param(1).lb      = 0;   % limite inférieure
param(1).ub      = 5;   % limite supérieure

% taux d'apprentissage 
b                = [2.5, 2.5]; % hyper parameters of beta prior
param(2).name    = 'learning rate';
param(2).logpdf  = @(x) sum(log(betapdf(x, b(1), b(2)))); % log density function for prior
param(2).lb      = 0;
param(2).ub      = 1;

% number de fois ou on comment
nstarts          = 3;       

% mettre les données dans une structure
data.ch          = sim_ch;  
data.r           = sim_r;
data.nruns       = nruns;

% executer la function qui combine fmincon avec les priors
recovered        = mf_optimize(@estimateQ, data, param, nstarts);
recovered.param
