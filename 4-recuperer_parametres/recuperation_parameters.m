
%% add our tools
here = pwd;
addpath(genpath(fullfile(here,'my_models')));
addpath(genpath(fullfile(here,'my_functions')));

%% input variables

nsub    = 500; % number of participants (or subjects, sub)

ntrials =  24; % number of trials
nruns   =  50; % number of runs

%% initialise parameters

simulated_param = nan(nsub,2);
recovered_param = nan(nsub,2);


%% initialise the distribution from which we will sample the free parameters


% here we test with an optimization function
x0 = [3 0.1]; % initial point of the exploration 5 temp and 0.5 alpha
xmin = [0 0]; % min values of each parameter
xmax = [5 1]; % max value of each parameter

% we define the options of the optimization function
options = optimset('Algorithm', 'interior-point', 'Display', 'iter-detailed', 'MaxIter', 10000); % These increase the number of iterations to ensure the convergence




for ksub = 1:nsub


    disp (['-------  synthetic participant  ' num2str(ksub) '   -------']);


    % sample a set of free parameters from the distribution for the current
    % participant

    sim_param(ksub).alpha     = random('Beta', 1.2, 1.2);
    sim_param(ksub).inv_temp  = random('Gamma', 1.5, 1);

    % save the sampled paramaeters

    simulated_param(ksub,:) = [sim_param(ksub).inv_temp,sim_param(ksub).alpha];

    % simulate synthetic participant behavior
    [sim_ch, sim_r] = Qmodel(sim_param(ksub).alpha, sim_param(ksub).inv_temp, ntrials, nruns);

    % estimate free parameters
    [recovered_param(ksub,:),nll,~,~,~]       = fmincon(@(x) estimateQ(x,sim_ch,sim_r, nruns),x0,[],[],[],[],xmin,xmax,[],options);



end


%% plot results


figure
hold

subplot(2, 1, 1) % beta

x = 0:0.01:5;   distr_tp = gampdf(x, 2, 1);    xl = [0 5];

xlabel(strcat('Simulated \beta'));
ylabel(strcat('Estimated \beta'));

X = simulated_param(:, 1);
Y = recovered_param(:, 1);


plot( xl, xl, ':k', 'LineWidth', 2); % plot horizonal line
hold
plot( X(:), Y(:), 'o', ...
        'MarkerFaceColor', [1, 1, 1], ...
        'MarkerEdgeColor', [0, 0, 0])

subplot(2, 1, 2) % alpha
x = 0:0.01:1;   distr_tp = betapdf(x, 1.2, 1.2);  xl = [0 1];

xlabel(strcat('Simulated \alpha'));
ylabel(strcat('Estimated \alpha'));


X = simulated_param(:, 2);
Y = recovered_param(:, 2);


plot( xl, xl, ':k', 'LineWidth', 2);  % plot horizonal line

hold
plot( X(:), Y(:), 'o', ...
        'MarkerFaceColor', [1, 1, 1], ...
        'MarkerEdgeColor', [0, 0, 0])







ax1 = gca; % current axes

    plot(ax1, x, distr_tp, 'Color', .5 * [1, 1, 1])
    set(ax1, 'XLim', xl, ...
        'XAxisLocation', 'top', ...
        'YAxisLocation', 'right', ...
        'XTickLabel', [], ...
        'YTickLabel', [], ...
        'FontSize', 12, ...
        'FontName', 'Arial')
    ax1_pos = ax1.Position;
    ax2 = axes('Position', ax1_pos, ...
        'YLim', xl, ...
        'XAxisLocation', 'bottom', ...
        'YAxisLocation', 'left', ...
        'Color', 'none', ...
        'XLim', xl, ...
        'FontSize', 12, ...
        'FontName', 'Arial');
    xlabel(strcat(['Simulated ', LAB{k}]));
    ylabel(strcat(['Estimated ', LAB{k}]));

    hold on

    X = simulated_param(:, k);
    Y = recovered_param(:, k);


    plot(ax2, xl, xl, ':k', ...
        'LineWidth', 2)

    %     plot(ax2,mean(X(:))*ones(1,2),[xl(1),xl(2)],':k')
    plot(ax2, X(:), Y(:), 'o', ...
        'MarkerFaceColor', [1, 1, 1], ...
        'MarkerEdgeColor', [0, 0, 0])

    [b, ~, stats]      = glmfit(X(:), Y(:), 'normal');
    STORE_REG(k).b     = b;
    STORE_REG(k).stats = stats;

    XX             = linspace(min(X(:)), max(X(:)), 1000);
    [Yf, Yl, Yh]   = glmval(b, XX, 'identity', stats, 'confidence', 0.95);
    XXX            = sortrows([XX', Yf, Yf-Yl, Yf+Yh], 1);

    Xfill = [XXX(:,1); flipud(XXX(:,1))];
    fill(Xfill, [XXX(:,3); flipud(XXX(:,4))], .7 * [1,1,1], 'EdgeColor', 'none', ...
        'Parent', ax2)
    alpha(0.5)
    hModel = plot(ax2, XXX(:,1), XXX(:,2), '-', ...
        'Color', .5 * [1,0,0], ...
        'LineWidth', 2);


    set(ax2, 'Position', ax1_pos)


end