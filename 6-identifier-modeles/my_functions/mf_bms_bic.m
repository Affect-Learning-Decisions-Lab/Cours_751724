function bms_results = mf_bms_bic(rec_data)
    
    % Bayesian model selection for group studies based on bic
    % uses bms.m of sam gersham
    
    
    for j = 1:length(rec_data)
        lme0(:,j) = -0.5*(rec_data(j).bic - rec_data(j).K*log(2*pi));
    end
    
    lme = lme0; % just bic 
    
    lme(any(isnan(lme)|isinf(lme),2),:) = [];

    [bms_results.alpha, bms_results.exp_r, ...
        bms_results.xp, bms_results.pxp, bms_results.bor] = bms(lme);