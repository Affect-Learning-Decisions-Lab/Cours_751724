function [nLL] = estimateQ(params, ch, r, nruns)


% récupérer les paramètres que nous allons utiliser pour la simulation
inv_temp = params(1);
alpha = params(2);

% récupérer les caractéristiques de la tâche
ntrials = size(ch,1); % récupérer les choix du participant


% définir la valeur initiale
Q0  = [0 0]; 


% initialiser les variables du modèle
PA = NaN(ntrials,1);
lik = NaN(ntrials,1);
Qt = NaN(ntrials,2);
PE = NaN(ntrials,1);

% valeur avant le début de l'apprentissage
Qt(1,:)  = Q0;


for t = 1:ntrials

    if  mod(t,(ntrials/nruns)) == 0
        % initialiser la valeur pour chaque bloc
        Qt(t,:)  = Q0;
    end

    % calculer la probabilité de choisir A du modèle
    PA(t)   = 1./(1+exp(-inv_temp.*(Qt(t,2)-Qt(t,1))));

    % voir à quel point le choix du modèle correspond au choix du
    % participant
    if ch(t) == 1 % si le participant a choisi B
        lik(t) = 1 - PA(t);
    elseif ch(t) == 2 % si le participant a choisi A
        lik(t) = PA(t);
    end

    % calculer l'erreur de prédiction sur la base de la récompense
    % délivrée au participant (r)
    PE(t) = r(t) - Qt(t,ch(t));

    % mise à jour de la valeur
    Qt(t+1,ch(t)) = Qt(t,ch(t)) + alpha.*PE(t);     % colonne ch(t) = choisie (1 ou 2)
    Qt(t+1,3-ch(t)) = Qt(t,3-ch(t));                % colonne 3-ch(t) = non choisie (2 ou 1)


end

% calculer à quel point les choix du participant étaient probables
% avec ces paramètres du modèle
nLL = -sum(log(lik(:)));

end