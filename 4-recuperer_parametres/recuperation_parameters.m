
%% add our tools
here = pwd;
addpath(genpath(fullfile(here,'my_models')));
addpath(genpath(fullfile(here,'my_functions')));

%% input variables

nsub    = 300; % number of participants (or subjects, sub)

ntrials =  100; % number of trials
nruns   =  50; % number of runs

%% initialise parameters

simulated_param = nan(nsub,2);
recovered_param = nan(nsub,2);


%% initialise the distribution from which we will sample the free parameters


% number of initial point from which the search starts
nstarts = 50;

xmin    = [0 0]; % min values of each parameter
xmax    = [5 1]; % max value of each parameter

% we define the options of the optimization function
options = optimset('Algorithm', 'interior-point', 'Display', 'iter-detailed', 'MaxIter', 10000, 'Display','off'); % These increase the number of iterations to ensure the convergence
warning off all



pd = makedist('Gamma',1.2,1.2);   % Define the distribution object    
pdt = truncate(pd,xmin(1),xmax(1)) ;

for ksub = 1:nsub


    disp (['-------  synthetic participant  ' num2str(ksub) '   -------']);


    % sample a set of free parameters from the distribution for the current
    % participant

    sim_param(ksub).alpha     = random('Beta', 1.2, 1.2);
    sim_param(ksub).inv_temp  = random(pdt);

    % save the sampled paramaeters

    simulated_param(ksub,:) = [sim_param(ksub).inv_temp,sim_param(ksub).alpha];

    % simulate synthetic participant behavior
    [sim_ch, sim_r] = Qmodel(sim_param(ksub).alpha, sim_param(ksub).inv_temp, ntrials, nruns);

    % estimate free parameters

    % we try multiple starting point not to get stack in local minima

    nll = nan(nstarts,1);
    for strt = 1:nstarts

         
        x0 = unifrnd(xmin,xmax);
    

        [rec_param(strt,:),nll(strt),~,~,~] = fmincon(@(x) estimateQ(x,sim_ch,sim_r, nruns),x0,[],[],[],[],xmin,xmax,[],options);


    end

    % trouver le min loglike avec les different paramentres
    minnLL = find(min(nll));

    recovered_param(ksub,:) = rec_param (minnLL,:);

end


%% plot results


figure


%--------------------------------------------------------------------------
% pannel 1 : beta estimates


% -------------- subpannel 1 regression with individual datapoints
subplot(2, 2, 1) 

hold on

   
xl = [0 5];

xlabel(strcat('Simulated \beta'));
ylabel(strcat('Estimated \beta'));

X = simulated_param(:, 1);
Y = recovered_param(:, 1);


% plot line r = 1
plot( xl, xl, ':k', 'LineWidth', 2); 

% plot correlation between estimated and simulated
plot( X(:), Y(:), 'o', ...
        'MarkerFaceColor', [1, 1, 1], ...
        'MarkerEdgeColor', [0, 0, 0])

% compute the glm to plot the intrapolation line
[b, ~, stats]      = glmfit(X(:), Y(:), 'normal');
XX             = linspace(min(X(:)), max(X(:)), 1000);
[Yf, Yl, Yh]   = glmval(b, XX, 'identity', stats, 'confidence', 0.95);
XXX            = sortrows([XX', Yf, Yf-Yl, Yf+Yh], 1);
alpha(0.5)
plot(XXX(:,1), XXX(:,2), '-', 'Color', .5 * [1,0,0],'LineWidth', 2);


% -------------- subpannel 2 regression estimates
subplot(2, 2, 2) 

hold on

bar(stats.beta, 'FaceColor', .9 .* [1, 1, 1])
errorbar(stats.beta,stats.se, 'k', 'LineStyle', 'none')


%--------------------------------------------------------------------------
% pannel 1 : alpha estimates

% -------------- subpannel 1 regression with individual datapoints
subplot(2, 2, 3) 

hold on


xlabel(strcat('Simulated \alpha'));
ylabel(strcat('Estimated \alpha'));


X = simulated_param(:, 2);
Y = recovered_param(:, 2);

xl = [0 1];

% plot line r = 1
plot( xl, xl, ':k', 'LineWidth', 2);  

% plot correlation between estimated and simulated
plot( X(:), Y(:), 'o', 'MarkerFaceColor', [1, 1, 1], ...
        'MarkerEdgeColor', [0, 0, 0])

% compute the glm to plot the intrapolation line
[b, ~, stats]      = glmfit(X(:), Y(:), 'normal');
XX             = linspace(min(X(:)), max(X(:)), 1000);
[Yf, Yl, Yh]   = glmval(b, XX, 'identity', stats, 'confidence', 0.95);
XXX            = sortrows([XX', Yf, Yf-Yl, Yf+Yh], 1);
alpha(0.5)
plot(XXX(:,1), XXX(:,2), '-', 'Color', .5 * [1,0,0],'LineWidth', 2);


% -------------- subpannel 2 regression estimates
subplot(2, 2, 4) 

hold on

bar(stats.beta, 'FaceColor', .9 .* [1, 1, 1])
errorbar(stats.beta,stats.se, 'k', 'LineStyle', 'none')
set(gca,'YLim', [0 1], ...
        'XLim', [0 3], ...
        'XTick', [1 2], ...
        'XTickLabel', {'\beta_0','\beta_1'}, ...
        'FontSize', 12, ...
        'FontName', 'Arial')


