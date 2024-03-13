% same as run_dynamics, but condition out the Z BEFORE running decomp
clear;

range_dates_all = 1982:2015;
range_dates_early = 1982:1984;
range_dates_late = 2013:2015;
ranges_dates_pre_spike = 1983:1984;
ranges_dates_post_spike = 1991:1992;

range_index_early = range_dates_early - range_dates_all(1) + 1;
range_index_pre_spike = ranges_dates_pre_spike - range_dates_all(1) + 1; 
range_index_post_spike = ranges_dates_post_spike - range_dates_all(1) + 1; 

% t-1 to to flows labeled t, so don't use 1982 for mean flows since not defined
range_index_early_flows = range_index_early(2:end);

T = length(range_dates_all); 
N = 2; % number of LFO types: C-corp, Passthrough, Other

raw_file = '../data/restricted/disclosed/req10739_20230720/disclosure_output_post.xlsx';
outxls_file = '../data/decomp/figure_cf_series_noz.xls';

%% load in conversions, exits and entrants shares by type from file
P_t = NaN + zeros(N,N,T);
exit_rates_t = NaN + zeros(N,T);
entrant_shares_t  = NaN + zeros(N,T);
startup_rate_t = NaN + zeros(1,T);
initial_shares = zeros(N,1);

% entry rate
startup_rate_t(1,2:end) = readmatrix(raw_file,'Sheet','startuprate_T13T26','Range','B2:B34');
startup_rate_const = mean(startup_rate_t(range_index_early_flows))*ones(length(startup_rate_t),1);

% initial condition
initial_shares = readmatrix(raw_file,'Sheet','initial shares_T13T26','Range','B2:C2');
initial_shares = initial_shares / sum(initial_shares);

% transitions/exit
data_transitions = readmatrix(raw_file,'Sheet','transition matrix_T13T26','Range','C2:E133');


% census data are labeled by base year of t-1 to t flow 
% corresponding decomposition variables are dated t (since measurable in t)
% so LBD 1982 refers to 1982 to 1983 flows
% decomp 1983 refers to 1983 stocks and 1982-83 flows
for t=2:T
    lbd_t = t-1;
    data_year = data_transitions((lbd_t-1)*4+1:(lbd_t)*4,:); % load the next 4 x 3
    data_year_withz = [data_year,100-sum(data_year,2)]; % add the implied t+1 Z back
    P_t(:,:,t) = data_year_withz([1,3],[1,3])./sum(data_year_withz([1,3],[1,3]),2);
    exit_rates_t(:,t) = data_year_withz([1,3],2)/100;
    entrant_shares_t(:,t) = data_year_withz(2,[1,3])'/sum(data_year_withz(2,[1,3]),2);
end

% make sure rows sum to EXACTLY 1
P_t = bsxfun(@rdivide, P_t, sum(P_t,2)); 
% bsxfun is same as: 
% for t=1:T
%   for i=1:N
%       P(i,:,t) = P(i,:,t)/sum(P(i,:,t))
%   end
% end

% make sure shares sum to EXACTLY 1
entrant_shares_t = bsxfun(@rdivide,entrant_shares_t, sum(entrant_shares_t,1));


%%
shares_actual_t = zeros(N,T);
shares_actual_t(:,1) = initial_shares;

shares_cf_nostartupdef_t = shares_actual_t;
shares_cf_holdentry_t = shares_actual_t; % hold entry shares fixed at 80-83 avg
shares_cf_holdreorg_t = shares_actual_t; % hold transition matrix fixed at 80-83 avg
shares_cf_holdboth_t = shares_actual_t; % hold both fixed
shares_cf_holdall_t = shares_actual_t; % hold both fixed plus other margins
% shares_cf_holdsurate_t = shares_actual_t; % hold start-up rate fixed

shares_target_t = zeros(N,T);
shares_cf_target_holdentry_t = shares_target_t;
shares_cf_target_holdreorg_t = shares_target_t;
shares_cf_target_holdboth_t = shares_target_t;
shares_cf_target_holdall_t = shares_target_t;

% shares_cf_target_transient_t = shares_target_t; 
% shares_cf_target_permanent_t = shares_target_t; 
% shares_cf_target_nosurge_t = shares_target_t; 

firm_growth_t = zeros(N,T);
firm_growth_holdsurate_t = zeros(N,T);

% we include the "Z" state for the law of motion and then later integrate
% it out for the summary stats
for t=2:T
    firm_growth_t(t) = (1-shares_actual_t(:,t-1)'*exit_rates_t(:,t))/(1-startup_rate_t(t))-1;
    firm_growth_holdsurate_t(t) = (1-shares_actual_t(:,t-1)'*exit_rates_t(:,t))/(1-startup_rate_const(t))-1;
    
    shares_actual_t(:,t) = P_t(:,:,t)'*diag(1-exit_rates_t(:,t))*shares_actual_t(:,t-1)/(1+firm_growth_t(t)) + entrant_shares_t(:,t)*startup_rate_t(t);
%     shares_cf_holdsurate_t(:,t) = P_t(:,:,t)'*diag(1-exit_rates_t(:,t))*shares_cf_holdsurate_t(:,t-1)/(1+firm_growth_t(t)) + entrant_shares_t(:,t)*startup_rate_const(t);
end
%%
shares_cf_transient_reorg_t = shares_actual_t; % go back to pre-spike average
shares_cf_permanent_reorg_t = shares_actual_t; % go back to post-spike average
shares_cf_nosurge_reorg_t = shares_actual_t; % chop of the peak of the spike

shares_cf_transient_entry_t = shares_actual_t; % go back to pre-spike average
shares_cf_permanent_entry_t = shares_actual_t; % go back to post-spike average
shares_cf_nosurge_entry_t = shares_actual_t; % chop of the peak of the spike

shares_cf_transient_both_t = shares_actual_t; % go back to pre-spike average
shares_cf_permanent_both_t = shares_actual_t; % go back to post-spike average
shares_cf_nosurge_both_t = shares_actual_t; % chop of the peak of the spike

for t=2:T
    shares_target_t(:,t) = (eye(N) - P_t(:,:,t)'*diag(1-exit_rates_t(:,t))/(1+firm_growth_t(t)))\entrant_shares_t(:,t)*startup_rate_t(t);
    
    shares_cf_target_holdentry_t(:,t) = (eye(N) - P_t(:,:,t)'*diag(1-exit_rates_t(:,t))/(1+firm_growth_t(t)))\mean(entrant_shares_t(:,range_index_early_flows),2)*startup_rate_t(t);
    shares_cf_target_holdreorg_t(:,t) = (eye(N) - mean(P_t(:,:,range_index_early_flows),3)'*diag(1-exit_rates_t(:,t))/(1+firm_growth_t(t)))\entrant_shares_t(:,t)*startup_rate_t(t);
    shares_cf_target_holdboth_t(:,t) = (eye(N) - mean(P_t(:,:,range_index_early_flows),3)'*diag(1-exit_rates_t(:,t))/(1+firm_growth_t(t)))\mean(entrant_shares_t(:,range_index_early_flows),2)*startup_rate_t(t);
    shares_cf_target_holdall_t(:,t) = (eye(N) - mean(P_t(:,:,range_index_early_flows),3)'*diag(1-mean(exit_rates_t(:,range_index_early_flows),2))/(1+mean(firm_growth_t(range_index_early_flows))))\mean(entrant_shares_t(:,range_index_early_flows),2)*mean(startup_rate_t(range_index_early_flows));
    
    shares_cf_nostartupdef_t(:,t) = P_t(:,:,t)'*diag(1-exit_rates_t(:,t))*shares_cf_nostartupdef_t(:,t-1)/(1+firm_growth_holdsurate_t(t)) + entrant_shares_t(:,t)*startup_rate_const(t);
%     shares_cf_nostartupdef_t(:,t) = P_t(:,:,t)'*diag(1-exit_rates_const(:,t))*shares_cf_nostartupdef_t(:,t-1)/(1+firm_growth_holdsurate_t(t)) + entrant_shares_t(:,t)*startup_rate_const(t);
    shares_cf_holdentry_t(:,t) = P_t(:,:,t)'*diag(1-exit_rates_t(:,t))*shares_cf_holdentry_t(:,t-1)/(1+firm_growth_t(t)) + mean(entrant_shares_t(:,range_index_early_flows),2)*startup_rate_t(t);
    shares_cf_holdreorg_t(:,t) = mean(P_t(:,:,range_index_early_flows),3)'*diag(1-exit_rates_t(:,t))*shares_cf_holdreorg_t(:,t-1)/(1+firm_growth_t(t)) + entrant_shares_t(:,t)*startup_rate_t(t);
    shares_cf_holdboth_t(:,t) = mean(P_t(:,:,range_index_early_flows),3)'*diag(1-exit_rates_t(:,t))*shares_cf_holdboth_t(:,t-1)/(1+firm_growth_t(t)) + mean(entrant_shares_t(:,range_index_early_flows),2)*startup_rate_t(t);
    shares_cf_holdall_t(:,t) = mean(P_t(:,:,range_index_early_flows),3)'*diag(1-mean(exit_rates_t(:,range_index_early_flows),2))*shares_cf_holdall_t(:,t-1)/(1+mean(firm_growth_t(range_index_early_flows))) + mean(entrant_shares_t(:,range_index_early_flows),2)*mean(startup_rate_t(range_index_early_flows));
         
    if t >=  range_index_pre_spike(end)
        shares_cf_nosurge_reorg_t(:,t) = mean(P_t(:,:,range_index_post_spike),3)'*diag(1-exit_rates_t(:,t))*shares_cf_nosurge_reorg_t(:,t-1)/(1+firm_growth_t(t)) + entrant_shares_t(:,t)*startup_rate_t(t);
        shares_cf_nosurge_entry_t(:,t) = P_t(:,:,t)'*diag(1-exit_rates_t(:,t))*shares_cf_nosurge_reorg_t(:,t-1)/(1+firm_growth_t(t)) + mean(entrant_shares_t(:,range_index_post_spike),2)*startup_rate_t(t);
        shares_cf_nosurge_both_t(:,t) = mean(P_t(:,:,range_index_post_spike),3)'*diag(1-exit_rates_t(:,t))*shares_cf_nosurge_reorg_t(:,t-1)/(1+firm_growth_t(t))+ mean(entrant_shares_t(:,range_index_post_spike),2)*startup_rate_t(t);
    end

    if t >= range_index_post_spike(1)
        shares_cf_transient_reorg_t(:,t) = mean(P_t(:,:,range_index_pre_spike),3)'*diag(1-exit_rates_t(:,t))*shares_cf_transient_reorg_t(:,t-1)/(1+firm_growth_t(t)) + entrant_shares_t(:,t)*startup_rate_t(t);
        shares_cf_transient_entry_t(:,t) = P_t(:,:,t)'*diag(1-exit_rates_t(:,t))*shares_cf_transient_reorg_t(:,t-1)/(1+firm_growth_t(t)) + mean(entrant_shares_t(:,range_index_pre_spike),2)*startup_rate_t(t);
        shares_cf_transient_both_t(:,t) = mean(P_t(:,:,range_index_pre_spike),3)'*diag(1-exit_rates_t(:,t))*shares_cf_transient_reorg_t(:,t-1)/(1+firm_growth_t(t)) + mean(entrant_shares_t(:,range_index_pre_spike),2)*startup_rate_t(t);
        
        shares_cf_permanent_reorg_t(:,t) = mean(P_t(:,:,range_index_post_spike),3)'*diag(1-exit_rates_t(:,t))*shares_cf_permanent_reorg_t(:,t-1)/(1+firm_growth_t(t)) + entrant_shares_t(:,t)*startup_rate_t(t);
        shares_cf_permanent_entry_t(:,t) = P_t(:,:,t)'*diag(1-exit_rates_t(:,t))*shares_cf_permanent_reorg_t(:,t-1)/(1+firm_growth_t(t)) + mean(entrant_shares_t(:,range_index_post_spike),2)*startup_rate_t(t);
        shares_cf_permanent_both_t(:,t) = mean(P_t(:,:,range_index_post_spike),3)'*diag(1-exit_rates_t(:,t))*shares_cf_permanent_reorg_t(:,t-1)/(1+firm_growth_t(t)) + mean(entrant_shares_t(:,range_index_post_spike),2)*startup_rate_t(t);
    end 
   
end

%% flows

flow_entrant_actual = zeros(1,T);
flow_reorg_ctop_actual = zeros(1,T);
flow_reorg_ptoc_actual = zeros(1,T);

flow_entrant_actual(1) = NaN;
flow_reorg_ctop_actual(1) = NaN;
flow_reorg_ptoc_actual(1) = NaN;

flow_entrant_cf_permanent_both = flow_entrant_actual;
flow_reorg_ctop_cf_permanent_both = flow_reorg_ctop_actual;
flow_reorg_ptoc_cf_permanent_both = flow_reorg_ptoc_actual;

for t=2:T
    flow_entrant_actual(t) = sum(entrant_shares_t(2,t)); %/sum(entrant_shares_t(1:4,t));
    flow_reorg_ctop_actual(t) = P_t(1,2,t); %/sum(P_t(1,1:4,t));
    flow_reorg_ptoc_actual(t) = P_t(2,1,t);
    %sum(P_t(2,1,t)); %/sum(P_t(1,1:4,t)); % just use S
    
    flow_entrant_cf_permanent_both(t) = flow_entrant_actual(t);
    flow_reorg_ctop_cf_permanent_both(t) = flow_reorg_ctop_actual(t);
    flow_reorg_ptoc_cf_permanent_both(t) = flow_reorg_ptoc_actual(t);
    
    if t>=range_index_post_spike(1)
        flow_entrant_cf_permanent_both(t) = mean(sum(entrant_shares_t(2,range_index_post_spike),1),2);
        flow_reorg_ctop_cf_permanent_both(t) = mean(sum(P_t(1,2,range_index_post_spike),2),3);
        flow_reorg_ptoc_cf_permanent_both(t) = mean(sum(P_t(2,1,range_index_post_spike),2),3);
    end
end


%%

% function to condition out the z category
%getnozshares = @(shares_) shares_(1:end-1,:)./sum(shares_(1:end-1,:),1);
getnozshares = @(shares_) shares_;
getnozptshares = @(shares_) shares_(2,:);


%% export series to a file

outtab = table( ...,
    range_dates_all', ...
    getnozptshares(shares_actual_t)');

writetable(outtab,outxls_file);
