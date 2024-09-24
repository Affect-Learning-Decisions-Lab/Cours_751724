
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


%% Ensuite, nous testons si le processus d'estimation des paramètres retrouve les mêmes résultats

% Test avec un grid search
[est_alpha, est_temp] = estimateQ_gridsearch(sim_ch, sim_r, nruns);


% Test avec une fonction d'optimisation
x0 = [3 0.1]; % point initial : la première valeur correspond à la température, la deuxième valeur correspond à alpha
xmin = [0 0]; % valeurs minimales : la première valeur correspond à la température, la deuxième valeur correspond à alpha
xmax = [5 1]; % valeurs maximales : la première valeur correspond à la température, la deuxième valeur correspond à alpha

% On définit les options de la fonction d'optimisation 
options = optimset('Algorithm', 'interior-point', 'Display', 'iter-detailed', 'MaxIter', 10000); % Ces valeurs augmentent le nombre d'itérations pour s'assurer d'avoir une convergence


[parameters,nll,~,~,~]       = fmincon(@(x) estimateQ(x,sim_ch,sim_r, nruns),x0,[],[],[],[],xmin,xmax,[],options);
