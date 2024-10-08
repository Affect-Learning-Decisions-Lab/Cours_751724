function [est_alpha, est_temp] = estimateQ_gridsearch(ch, r, nruns)


%% define caracteristics of the task

% define initial value
Q0  = [0 0]; 

% n trials
ntrials = size(ch,1); % we read in the choices of the participant



%%  Define space we want to explore

% learning rate, varies from 0 to 1 with 201 steps
alpha_mat = linspace(0,1, 501);

% inverse temperature varies from 0 to 5 with 201 steps
temp_mat  = linspace(0, 5, 501);

% initialize the likelihood matrix for each combination of parameters
nLL = NaN(numel(alpha_mat),numel(temp_mat));


%% explore 

% let's start exploring the likelyhoold of the choices with all possible
% combination

for a = 1:size(alpha_mat,2)

    alpha = alpha_mat(a); % select one possible learning rate value

    for b = 1:size(temp_mat,2)

        inv_temp = temp_mat(b); % select one possible temperature value


        % initialise model variables
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
        nLL(a,b) = -sum(log(lik(:)));


    end % end temp

end % end learning rate


% get estimated alpha and temp

[I,J] = find(nLL == min(min(nLL)));

est_alpha = alpha_mat(I);
est_temp = temp_mat(J);

%% plot grid search results

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