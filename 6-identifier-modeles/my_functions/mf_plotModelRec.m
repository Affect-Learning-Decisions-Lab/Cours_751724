function [] = plotModelRec(data_path, models, files_id)




% find files
dir_flnm = dir(fullfile(data_path, files_id));


% count interation
n_fl  = length(dir_flnm);


N_mod = length(models);

%% initialise variables

% bic
bm_bic   = zeros(N_mod, N_mod, n_fl);

%  exceedance probability matrices
ep_bic   = zeros(N_mod, N_mod, n_fl);



%% format data

for k_fl = 1:n_fl % for each iteration (or file, fl)
    
    % get data
    load(fullfile(data_path, dir_flnm(k_fl).name))
    
    % get exceedance probability and best model
    for k_sim = 1: N_mod % for each model simulation
        
           
        % based on BIC
        bmc_res_bic = bms_results.bic(k_sim);              % get BMC output
        ep_bic(k_sim, :, k_fl) = 100 * bmc_res_bic.xp;  % get exceedance probability
        
        [~, ln_max_bic] = max(bmc_res_bic.xp);
        bm_bic(k_sim, ln_max_bic, k_fl) = 1;
        
    end


end


mean_ep_bic  = squeeze(mean(ep_bic, 3));
n_goodcl_bic = squeeze(sum(bm_bic, 3));



%% Figure 1 confusion matrixes


h1 = figure('Units', 'pixels',...
    'Position', [400 200 700 265]);
set(h1, 'Color', [1, 1, 1])

    for k = 1:2

        subplot(1, 2, k)

        switch k
            
            case 1
                mtp = mean_ep_bic;
                lbl = 'Exceedance probability (%) based on BIC';
            case 2
                mtp = n_goodcl_bic;
                lbl = '% Best model based on BIC';
        end

        colormap(flipud(gray))
        imagesc(flipud(mtp))
        ylabel('Simulated model #')
        xlabel('Estimated model #')
        set(gca,'XTick', 1:N_mod, ...
            'YTick', 1:N_mod, ...
            'XTickLabel', (1:N_mod), ...
            'YTickLabel', fliplr(1:N_mod), ...
            'FontSize', 12, ...
            'FontName', 'Arial')
        c = colorbar;
        c.Label.String = lbl;


    end



end