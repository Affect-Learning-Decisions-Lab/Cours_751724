function [ch_all, r_all] = Qmodel (alpha, inv_temp, ntrials, nruns)

%nrev = 4;

%ntrials_tot = ntrials*nrev;

% initial values
Q0  = [0 0];

% initiliasions of input variables
Qt  = nan(ntrials+1, 2,nruns);
PE  = nan(ntrials, nruns);
ch  = nan(ntrials, nruns);
PA  = nan(ntrials, nruns);
r   = nan(ntrials, nruns);

for krun = 1:nruns

    % créeer la randomisation des récompense qui pourraient être obtenue
    RA = rand(ntrials,1)<0.8;
    RB = rand(ntrials,1)<0.2;
    
    %hr = rand(ntrials,1)<0.8;
    %lr = rand(ntrials,1)<0.2;

    
    %RA = [hr;lr;hr;lr ];
    %RB = [lr;hr;lr;hr ];

    O = [RB, RA];


    Qt(1,:,krun)  = Q0;           % initalise Q values

    % value simulation
    for t = 1:ntrials

        % 1 calculer la probabilté de choisr A
        PA(t,krun)   = 1./(1+exp(-inv_temp.*(Qt(t,2,krun)-Qt(t,1,krun))));

        % 2 simuler le choix du modèle (1 = option B, 2 = option A)
        ch(t,krun)   = 1 + double(rand(1)<PA(t,krun));

        % 3 delivrer la récompense
        r(t,krun) = O(t,ch(t,krun));

        % 4 compute prediction error
        PE(t,krun) = r(t,krun) - Qt(t,ch(t,krun),krun);

        % 5 update value
        Qt(t+1,ch(t,krun),krun) = Qt(t,ch(t,krun),krun) + alpha.*PE(t,krun);    % column ch(t) = chosen (1 or 2)
        Qt(t+1,3-ch(t,krun),krun) = Qt(t,3-ch(t,krun),krun);                     % column 3-ch(t) = unchosen (2 or 1)

    end


end

% concatener le vecteur avec le choix
ch_all = ch(:);

% concatener le vecteur avec
r_all = r(:);

end