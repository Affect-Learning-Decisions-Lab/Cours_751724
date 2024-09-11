function [nLL] = estimateQ(params, ch, r, nruns)


% read in the parameters that we will use for the simulation
inv_temp = params(1);
alpha = params(2);

% read in the specifics of the task
ntrials = size(ch,1); % we read in the choices of the participant


% define initial value
Q0  = [0 0]; 


% initialise the model variable
PA = NaN(ntrials,1);
lik = NaN(ntrials,1);
Qt = NaN(ntrials,2);
PE = NaN(ntrials,1);

%value before learning start
Qt(1,:)  = Q0;


for t = 1:ntrials

    if  mod(t,(ntrials/nruns)) == 0
        % initialize value for each run
        Qt(t,:)  = Q0;
    end

    % calculer la probabilité de choisir A du modèle
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
    PE(t) = r(t) - Qt(t,ch(t));

    % update value
    Qt(t+1,ch(t)) = Qt(t,ch(t)) + alpha.*PE(t);     % column ch(t) = chosen (1 or 2)
    Qt(t+1,3-ch(t)) = Qt(t,3-ch(t));                % column 3-ch(t) = unchosen (2 or 1)


end

% calculer à quel point les choix du participants étaient probables
% avec ces parametres du modèle
nLL = -sum(log(lik(:)));

end