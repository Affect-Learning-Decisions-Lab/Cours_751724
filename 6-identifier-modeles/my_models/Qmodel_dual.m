function [ch_all, r_all] = Qmodel_dual (alphaE, alphaI, inv_temp, ntrials, nruns)



% définir la valeur initiale
Q0  = [0 0];

% initialisation des variables input
Qt  = nan(ntrials+1, 2,nruns);
PE  = nan(ntrials, nruns);
ch  = nan(ntrials, nruns);
PA  = nan(ntrials, nruns);
r   = nan(ntrials, nruns);

for krun = 1:nruns

    % créer la randomisation des récompenses qui pourraient être obtenues
    RA = rand(ntrials,1)<0.8;
    RB = rand(ntrials,1)<0.2;
    O = [RB, RA];


    Qt(1,:,krun)  = Q0;  % initialiser les valeurs Q

    % simulations valeur
    for t = 1:ntrials

        % 1 calculer la probabilité de choisir A
        PA(t,krun)   = 1./(1+exp(-inv_temp.*(Qt(t,2,krun)-Qt(t,1,krun))));

        % 2 simuler le choix du modèle (1 = option B, 2 = option A)
        ch(t,krun)   = 1 + double(rand()<PA(t,krun));

        % 3 délivrer la récompense
        r(t,krun) = O(t,ch(t,krun));

        % 4 calculer l'erreur de prédiction

        dv         = r(t,krun) - Qt(t,ch(t,krun),krun);
        PE(t,krun) = dv;

        % 5 mise à jour de la valeur RW dual learning

        if dv > 0 % si l'erreur de prédiction est positive
            Qt(t+1,ch(t,krun),krun) = Qt(t,ch(t,krun),krun) + alphaE.*dv;    % colonne ch(t) = choisie (1 ou 2)
            Qt(t+1,3-ch(t,krun),krun) = Qt(t,3-ch(t,krun),krun); % colonne 3-ch(t) = non choisie (2 ou 1)
        else % si l'erreur de prédiction est négative
            Qt(t+1,ch(t,krun),krun) = Qt(t,ch(t,krun),krun) + alphaI.*dv;    % colonne ch(t) = choisie (1 ou 2)
            Qt(t+1,3-ch(t,krun),krun) = Qt(t,3-ch(t,krun),krun); % colonne 3-ch(t) = non choisie (2 ou 1)
        end

    end


end

% concaténer le vecteur avec le choix
ch_all = ch(:);

% concaténer le vecteur avec la récompense
r_all = r(:);

end