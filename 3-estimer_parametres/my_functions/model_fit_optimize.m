function estimate = model_fit_optimize (likfun, data,param, nstarts)

%------------------------------ prepare -----------------------------------

% define the options of the optimization function
options = optimset('Algorithm', 'interior-point', 'Display', 'iter-detailed', 'MaxIter', 10000, 'Display','off'); % These increase the number of iterations to ensure the convergence
warning off all

% get behavioral data
ch      = data.ch; % choices
r       = data.r;  % reward
nruns   = data.nruns; % number of runs

% get number of free parameters
K          = length(param);
estimate.K = K;

% get upper and lower bounderis of the free parameters
xmin = [param.lb];
xmax = [param.ub];

% contruct the posterior function
f = @(x) -nll2nlogp(x,param,likfun,ch,r,nruns);

%------------------------------ execute -----------------------------------


% initialize
nlogp     = nan(nstarts,1);
h         = nan(2,2,nstarts);
rec_param = nan (nstarts, 2);

for strt = 1:nstarts

    x0 = unifrnd(xmin,xmax);

    [rec_param(strt,:),nlogp(strt),~,~,~,~, h(:,:,strt)] = fmincon(f,x0,[],[],[],[],xmin,xmax,[],options);

end


%------------------------------ save --------------------------------------

% find the position of the minimum loglikhood
minnLLp          = find(min(nlogp));

% fitted value of the parameters
estimate.param   = rec_param(minnLLp,:);

% loglik
nll              = likfun(estimate.param, ch, r, nruns);
estimate.loglik  = -nll;

% logp
estimate.logp    = -nlogp;

% hessian
estimate.H       = h(:,:,minnLLp);

% bic
estimate.bic     = K*log(length(data.ch)) - 2*estimate.loglik;

% aic
estimate.aic     = K*2 - 2*estimate.loglik;


end