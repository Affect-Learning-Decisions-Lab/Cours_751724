function [nLL] = estimateD (params, ch, r, nruns)




% read in the parameters that we will use for the simulation
inv_temp = params(1);
alphaE   = params(2);
alphaI   = params(3);

% read in the specifics of the task
ntrials = size(ch,1); % we read in the choices of the participant



% définir la valeur initiale
Q0  = [0 0];

% initialisation des variables input
PA  = nan(ntrials, 1);
lik = NaN(ntrials,1);
Qt  = nan(ntrials+1,2);
PE  = nan(ntrials, 1);

%value before learning start
Qt(1,:)  = Q0;

% simulations valeur
for t = 1:ntrials

    if  mod(t,(ntrials/nruns)) == 0
        % initialize value for each run
        Qt(t,:)  = Q0;
    end


    % 1 calculer la probabilité de choisir A
    PA(t)   = 1./(1+exp(-inv_temp.*(Qt(t,2)-Qt(t,1))));

    
    % voir à quel point le choix du modèle correspond au choix du
    % participant
    if ch(t) == 1 % si le participants a choisit B
        lik(t) = 1 - PA(t);
    elseif ch(t) == 2 % si le particiapnts a choisit A
        lik(t) = PA(t);
    end

    % calculer l'erreur de prédiction sur la base de la récompense
    % délivré au participant (r)
    dv    = r(t) - Qt(t,ch(t));
    PE(t) = dv;


    % 5 mise à jour de la valeur RW dual learning

    if dv > 0 % si l'erreur de prédiction est positive
        Qt(t+1,ch(t))   = Qt(t,ch(t)) + alphaE.*dv;    % colonne ch(t) = choisie (1 ou 2)
        Qt(t+1,3-ch(t)) = Qt(t,3-ch(t)); % colonne 3-ch(t) = non choisie (2 ou 1)
    else % si l'erreur de prédiction est négative
        Qt(t+1,ch(t))   = Qt(t,ch(t)) + alphaI.*dv;    % colonne ch(t) = choisie (1 ou 2)
        Qt(t+1,3-ch(t)) = Qt(t,3-ch(t)); % colonne 3-ch(t) = non choisie (2 ou 1)
    end

end

% calculer à quel point les choix du participants étaient probables
% avec ces parametres du modèle
nLL = -sum(log(lik(:)));



end