function logp = mf_nll2nlogp(x,param,likfun,ch,r,nruns)

% goes from negative log likelihood to negative log probability of parameters under the (unnormalized) posterior.

nll  = likfun(x,ch,r,nruns);
logp = -nll;

for i = 1:length(param)
    logp = logp + param(i).logpdf(x(:,i));
end
