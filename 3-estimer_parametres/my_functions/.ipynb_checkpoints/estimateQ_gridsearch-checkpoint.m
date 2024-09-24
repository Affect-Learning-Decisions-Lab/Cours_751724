function [est_alpha, est_temp] = estimateQ_gridsearch(ch, r, nruns)


%% définir les caractéristiques de la tâche

% définir la valeur initiale
Q0  = [0 0]; 

% nombre d'essais
ntrials = size(ch,1); % on détermine le nombre d'essais à partir du nombre de choix du participant



%%  Définir l'espace que l'on veut explorer

% taux d'apprentissage alpha varie entre 0 et 1 avec 501 étapes
alpha_mat = linspace(0,1, 501);

% température inverse varie entre 0 et 1 avec 501 étapes
temp_mat  = linspace(0, 5, 501);

% initialiser la matrice de vraisemblance pour chaque combinaison de paramètres
nLL = NaN(numel(alpha_mat),numel(temp_mat));


%% explorer 

% commençons par explorer la vraisemblance des choix avec toutes les
% combinaisons possibles

for a = 1:size(alpha_mat,2)

    alpha = alpha_mat(a); % sélectionner une valeur possible du taux d'apprentissage

    for b = 1:size(temp_mat,2)

        inv_temp = temp_mat(b); % sélectionner une valeur possible de température


        % initialiser les variables du modèle
        PA = NaN(ntrials,1);
        lik = NaN(ntrials,1);
        Qt = NaN(ntrials,2);
        PE = NaN(ntrials,1);

        % valeur avant le début de l'apprentissage
        Qt(1,:)  = Q0;

        for t = 1:ntrials

            if  mod(t,(ntrials/nruns)) == 0
                % initialiser la valeur pour chaque série
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
        nLL(a,b) = -sum(log(lik(:)));


    end % fin température

end % fin taux d'apprentissage


% obtenir les valeurs de alpha et de la température estimées

[I,J] = find(nLL == min(min(nLL)));

est_alpha = alpha_mat(I);
est_temp = temp_mat(J);

%% plot des résultats du grid search

figure


imagesc(flipud(nLL))
hold on
xlabel('inverse temperature')
ylabel('learning rate')

xt = linspace(1,length(temp_mat),11);
xtl = linspace(min(temp_mat),max(temp_mat),11);

yt = linspace(1,length(alpha_mat),11);
ytl = linspace(min(alpha_mat),max(alpha_mat),11);

set(gca,'XLim',[1 length(temp_mat)],...
    'XTick',xt,...
    'XTickLabel',xtl,...
    'YLim',[1 length(alpha_mat)],...
    'YTick',yt,...
    'YTickLabel',fliplr(ytl))


cb= colorbar();
ylabel(cb,'nLL','FontSize',14)


[I,J] = find(nLL == min(min(nLL)));

disp(strcat('alpha = ',num2str(alpha_mat(I))))
disp(strcat('inv. temp = ',num2str(temp_mat(J))))


plot(J,length(alpha_mat)-I,'o',...
    'MarkerFaceColor',[1,0,0],...
    'MarkerEdgeColor',[1,0,0])



c = jet(50);
colormap(c);

end