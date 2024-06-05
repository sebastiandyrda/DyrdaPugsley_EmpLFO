%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script reproduces figures and table from the paper "The Rise of 
% Pass-throughs: An Empirical Investigation" by Sebastian Dyrda
% (University of Toronto) and Benjamin Puglsey (University of Notre Dame). 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear all
close all

% Read in the census data on the LFO transitions
rdc_output_file = '../data/restricted/disclosed/req10739_20230720/disclosure_output_post.xlsx';
bds_file_st = '../data/bds/bds2020_st_postabbrev.xlsx';
bds_file_ind = '../data/bds/bds2020_vcn4_reshape.xlsx';
cf_file = '../data/decomp/figure_cf_series2.xls';
cf_file_noz = '../data/decomp/figure_cf_series_noz.xls';


% Load the BDS NAICS data
opts = detectImportOptions('../data/bds/bds2020_sec_naics2.csv');  % Detect import options from the file
opts = setvartype(opts, 'sector', 'char');  % Set 'sector' variable to be read as character
data_bds = readtable('../data/bds/bds2020_sec_naics2.csv', opts);  % Read the data with the modified options

% Read the SUSB data
filename_susb = '../data/susb/susb_all_years.xlsx';

font_text_1pane = 17;
font_text_2pane = 18;
font_axes_1pane = 17;
font_axes_2pane = 18;
figpos = [100, 100, 600, 7/8*600];
setfigdefaults

addpath('toolbox/labelpoints');
addpath('toolbox/export_fig');
addpath('toolbox/linspecer');
years = 1982:2015;

NumLines   = 6;
Colors = linspecer(NumLines,'qualitative'); 
marker_size = 7;
markers = {'none','square','diamond','*'};


%%

%
% FIGURE 1a : aggregate pass through sshares
%
passthru_share_eq = readmatrix(cf_file, 'Range','B2:B35')*100;
passthru_share_emp = readmatrix(rdc_output_file,'Sheet','decomposition_US_emp_weighted_T','Range','B2:B35')*100;

FigHandle = figure;
set(gcf,'PaperPositionMode','auto')
set(FigHandle, 'Position', figpos);
set(groot,'DefaultTextFontSize',font_text_1pane)
set(groot,'DefaultAxesFontSize',font_axes_1pane)
axes('NextPlot','replacechildren', 'ColorOrder',Colors);
plot(years, passthru_share_eq);
hold on
plot(years, passthru_share_emp, 'Marker',markers{2},'MarkerSize',marker_size);
hold off
axis([1980 2015 10 70])
legend ('Equally weighted', 'Employment weighted', 'location', 'SouthEast')
legend boxoff
ylabel('Percent')
print('-depsc2',fullfile(pwd,'../output/figures','fig_1a_agg_passthru'))
fprintf('wrote figure 1a to output/figures/fig_1a_agg_passthru.eps\n')

%%

%
% FIGURE 1b : constant industry and state composition
%
passthru_share_eq = readmatrix(cf_file, 'Range','B2:B35')*100;
passthru_share_eq_constind = passthru_share_eq;
passthru_share_eq_conststate = passthru_share_eq;
passthru_share_eq_constind(2:end) = readmatrix(rdc_output_file, 'Sheet', 'decomposition_US_constant_naics', 'Range', 'B2:B34')*100;
passthru_share_eq_conststate(2:end) = readmatrix(rdc_output_file, 'Sheet', 'decomposition_US_constant_state', 'Range', 'B2:B34')*100;

FigHandle = figure;
set(gcf,'PaperPositionMode','auto')
set(FigHandle, 'Position', [100, 100, 600, 7/8*600]);
set(groot,'DefaultTextFontSize',font_text_1pane)
set(groot,'DefaultAxesFontSize',font_axes_1pane)
axes('NextPlot','replacechildren', 'ColorOrder',Colors);
plot(years, passthru_share_eq);
hold on
plot(years, passthru_share_eq_constind,'Marker',markers{2},'MarkerSize',marker_size); 
plot(years, passthru_share_eq_conststate,'Marker',markers{3},'MarkerSize',marker_size);
axis([1980 2015 30 70])
legend ('Actual', 'Constant Industry Weights', 'Constant State Weights', 'location', 'SouthEast')
legend boxoff
ylabel('Percent')
print('-depsc2',fullfile(pwd,'../output/figures','fig_1b_agg_constcomp'))
fprintf('wrote figure 1b to output/figures/fig_1b_agg_constcomp.eps\n')

%%

%
% FIGURE 1c : scatter of changes vs initial shares across states
%
tmpbufnum = readmatrix(rdc_output_file, 'Sheet', 'heatmap_state_T13T26', 'Range', 'B2:C52')*100;
[state_estabs, state_labels] = xlsread(bds_file_st, 'sorted', 'E2:F52');
idx_nolabels = ismember(state_labels,' ');
state_early = tmpbufnum(:,1);
state_late = tmpbufnum(:,2);
state_growth = log(state_late)-log(state_early);

state_corr = corr(state_early,state_growth);
state_growth_hat = [ones(51,1),state_early]*([ones(51,1),state_early]\state_growth);
[~,id2] = sort(state_early);

FigHandle = figure;
set(gcf,'PaperPositionMode','auto')
set(FigHandle, 'Position', [100, 100, 600, 7/8*600]);
set(groot,'DefaultTextFontSize',font_text_2pane)
set(groot,'DefaultAxesFontSize',font_axes_2pane)
scatter(state_early(idx_nolabels),state_growth(idx_nolabels),state_estabs(idx_nolabels)/sum(state_estabs)*70e3, 'LineWidth' ,0.4)
hold on
s=scatter(state_early(~idx_nolabels),state_growth(~idx_nolabels),state_estabs(~idx_nolabels)/sum(state_estabs)*70e3);
s.MarkerEdgeColor = '#0072BD';
s.LineWidth=2;
hold off    
labelpoints(state_early(~idx_nolabels),state_growth(~idx_nolabels),state_labels(~idx_nolabels),'Center','FontSize',13);
ylabel('Log Change in Share 1982 to 2015') 
xlabel('1982 Pass-Through Share (Percent)')
axis([20 60 0 1])

hold on
line(state_early(id2),state_growth_hat(id2),'LineWidth',1.5,'LineStyle','--','color','red');
hold off  
text(45,0.8,sprintf('corr = %0.2f',state_corr),'color','red')
print('-depsc2',fullfile(pwd,'../output/figures','fig_1c_agg_stateconv_lfit'))
fprintf('wrote figure 1c to output/figures/fig_1c_agg_stateconv_lfit.eps\n')

%%

%
% FIGURE 1d : scatter of changes vs initial shares across industry
%
tmpbufnum = readmatrix(rdc_output_file, 'Sheet', 'heatmap_naics_T13T26', 'Range', 'B2:C277')*100;
opts = spreadsheetImportOptions;
opts.VariableNames = {'match','naics','estabs'};
opts.VariableTypes = {'int32','char','double'};
opts.Sheet = 'sorted';
opts.DataRange = 'A2:C277';
[ind_match, ind_labels, ind_estabs] = readvars(bds_file_ind, opts);
ind_match = ind_match; %& ~ismember('8139', ind_labels) & ~ismember('8131',ind_labels);
ind_early = tmpbufnum(:,1);
ind_late = tmpbufnum(:,2);
ind_growth = log(ind_late)-log(ind_early);

ind_corr = corr(ind_early,ind_growth);
ind_growth_hat = [ones(276,1),ind_early]*([ones(276,1),ind_early]\ind_growth);
[~,id1] = sort(ind_early);

FigHandle = figure;
set(gcf,'PaperPositionMode','auto')
set(FigHandle, 'Position', [100, 100, 600, 7/8*600]);
set(groot,'DefaultTextFontSize',font_text_2pane)
set(groot,'DefaultAxesFontSize',font_axes_2pane)

idx_nolabels = ind_match == 1 & ind_estabs < 1e5 & ind_growth > 0 & ind_early > 2.5;
idx_labels = ind_match == 1 & (ind_estabs >= 1e5 | ind_growth <= 0 | ind_early <= 1.5);
scatter(ind_early(idx_nolabels),ind_growth(idx_nolabels),ind_estabs(idx_nolabels)/sum(ind_estabs(ind_match == 1))*70e3, 'LineWidth' ,0.4)
hold on
s=scatter(ind_early(idx_labels),ind_growth(idx_labels),ind_estabs(idx_labels)/sum(ind_estabs(ind_match == 1))*70e3);
s.MarkerEdgeColor = '#0072BD';
s.LineWidth=2;
hold off    
labelpoints(ind_early(idx_labels),ind_growth(idx_labels),ind_labels(idx_labels),'Center','FontSize',13);
axis([0 80 0 2])
ylabel('Log Change in Share 1982 to 2015') 
xlabel('1982 Pass-Through Share (Percent)')

hold on
line(ind_early(id1),ind_growth_hat(id1),'LineWidth',1.5,'LineStyle','--','color','red');
hold off  
text(45,1.5,sprintf('corr = %0.2f',ind_corr),'color','red')
print('-depsc2',fullfile(pwd,'../output/figures','fig_1d_agg_indconv_lfit'))
fprintf('wrote figure 1d to output/figures/fig_1d_agg_indconv_lfit.eps\n')

%%

%
% FIGURE 3a: MAIN DECOMPOSITION  
%
tmpbuf = table2array(readtable(cf_file, 'Range', 'A2:F35','readvariablenames',false));
idx_years = 1:34;
years_oldrelease = tmpbuf(idx_years,1);
passthru_actual = tmpbuf(idx_years,2)*100;
passthru_cf_G = tmpbuf(idx_years,3)*100; % convergence (hold all)
passthru_cf_GF = tmpbuf(idx_years,4)*100; % + firm dynamics (hold both)
passthru_cf_GFR = tmpbuf(idx_years,5)*100; % + reorg dynamics (hold entry)
passthru_cf_GFI = tmpbuf(idx_years,6)*100; % - reorg dynamics + initial (hold reorg)
passthru_cf_GFRI = passthru_actual;

FigHandle = figure;
set(gcf,'PaperPositionMode','auto')
set(FigHandle, 'Position', [100, 100, 600, 7/8*600]);
set(groot,'DefaultTextFontSize',font_text_1pane)
set(groot,'DefaultAxesFontSize',font_axes_1pane)
axes('NextPlot','replacechildren', 'ColorOrder',Colors);
plot(years_oldrelease, passthru_actual);
hold on
% set(plot1(1),'DisplayName','+ Entry Organization = Actual','MarkerSize',5);
% set(plot1(2),'DisplayName','+ Reorganization','Marker','+');
% set(plot1(3),'DisplayName','+ Firm Dynamics','Marker','diamond');
% set(plot1(4),'DisplayName','Convergence','Marker','*');
plot(years_oldrelease,passthru_cf_GFR, 'Marker',markers{2},'MarkerSize',marker_size);
plot(years_oldrelease, passthru_cf_GF, 'Marker',markers{3},'MarkerSize',marker_size);
plot(years_oldrelease, passthru_cf_G, 'Marker',markers{4},'MarkerSize',marker_size);
hold off
axis([1980 2015 30 70])
legend ('+ Entry Organization = Actual', '+ Reorganization', '+ Firm Dynamics', 'Convergence', 'location', 'NorthWest')
legend boxoff
ylabel('Percent') 
print('-depsc2',fullfile(pwd,'../output/figures','fig_3a_cf_main'))
fprintf('wrote figure 3a to output/figures/fig_3a_cf_main.eps\n')

%%

%
% FIGURE/TABLE 3b: MAIN DECOMPOSITION TABLE
%
tmpbuf = table2array(readtable(cf_file, 'Range', 'A2:F35','readvariablenames',false));
idx_years = 1:34;
passthru_actual = tmpbuf(idx_years,2)*100;
passthru_cf_G = tmpbuf(idx_years,3)*100; % convergence (hold all)
passthru_cf_GF = tmpbuf(idx_years,4)*100; % + firm dynamics (hold both)
passthru_cf_GFR = tmpbuf(idx_years,5)*100; % + reorg dynamics (hold entry)
passthru_cf_GFI = tmpbuf(idx_years,6)*100; % - reorg dynamics + initial (hold reorg)
passthru_cf_GFRI = passthru_actual;

idx_8290_start = 1;
idx_8290_end = 9;

change_8290_actual = passthru_actual(idx_8290_end)-passthru_actual(idx_8290_start);
change_8290_G = passthru_cf_G(idx_8290_end)-passthru_cf_G(idx_8290_start);
change_8290_GF = passthru_cf_GF(idx_8290_end)-passthru_cf_GF(idx_8290_start) ;
change_8290_GFR = passthru_cf_GFR(idx_8290_end)-passthru_cf_GFR(idx_8290_start);
change_8290_GFRI = passthru_cf_GFRI(idx_8290_end)-passthru_cf_GFRI(idx_8290_start);

idx_9000_start = 9;
idx_9000_end = 19;

change_9000_actual = passthru_actual(idx_9000_end)-passthru_actual(idx_9000_start);
change_9000_G = passthru_cf_G(idx_9000_end)-passthru_cf_G(idx_9000_start);
change_9000_GF = passthru_cf_GF(idx_9000_end)-passthru_cf_GF(idx_9000_start) ;
change_9000_GFR = passthru_cf_GFR(idx_9000_end)-passthru_cf_GFR(idx_9000_start);
change_9000_GFRI = passthru_cf_GFRI(idx_9000_end)-passthru_cf_GFRI(idx_9000_start);

idx_0015_start = 19;
idx_0015_end = 34;

change_0015_actual = passthru_actual(idx_0015_end)-passthru_actual(idx_0015_start);
change_0015_G = passthru_cf_G(idx_0015_end)-passthru_cf_G(idx_0015_start);
change_0015_GF = passthru_cf_GF(idx_0015_end)-passthru_cf_GF(idx_0015_start) ;
change_0015_GFR = passthru_cf_GFR(idx_0015_end)-passthru_cf_GFR(idx_0015_start);
change_0015_GFRI = passthru_cf_GFRI(idx_0015_end)-passthru_cf_GFRI(idx_0015_start);

idx_8215_start = 1;
idx_8215_end = 34;

change_8215_actual = passthru_actual(idx_8215_end)-passthru_actual(idx_8215_start);
change_8215_G = passthru_cf_G(idx_8215_end)-passthru_cf_G(idx_8215_start);
change_8215_GF = passthru_cf_GF(idx_8215_end)-passthru_cf_GF(idx_8215_start) ;
change_8215_GFR = passthru_cf_GFR(idx_8215_end)-passthru_cf_GFR(idx_8215_start);
change_8215_GFRI = passthru_cf_GFRI(idx_8215_end)-passthru_cf_GFRI(idx_8215_start);

fid = fopen('../output/tables/table_3b_main_decomp.txt','w');
fprintf(fid, '---COPY LATEX CODE INTO TABLE---\n');
fprintf(fid, ' & 82-90 & 90-00 & 00-15 & \\textbf{82-15} \\\\ \n');
fprintf(fid, '\\midrule ');
fprintf(fid, 'Convergence & %6.1f & %6.1f & %6.1f & \\textbf{%6.1f} \\\\ \n', ...
    change_8290_G, change_9000_G, change_0015_G, change_8215_G);
fprintf(fid, '$\\Delta$ Firm dynamics & %6.1f & %6.1f & %6.1f & \\textbf{%6.1f} \\\\ \n', ...
    change_8290_GF - change_8290_G, ...
    change_9000_GF - change_9000_G, ...
    change_0015_GF - change_0015_G, ...
    change_8215_GF - change_8215_G);
fprintf(fid, '$\\Delta$ Reorganization & %6.1f & %6.1f & %6.1f & \\textbf{%6.1f} \\\\ \n', ...
    change_8290_GFR - change_8290_GF, ...
    change_9000_GFR - change_9000_GF, ...
    change_0015_GFR - change_0015_GF, ...
    change_8215_GFR - change_8215_GF);
fprintf(fid, '$\\Delta$ Entry org. & %6.1f & %6.1f & %6.1f & \\textbf{%6.1f} \\\\ \n', ...
    change_8290_GFRI - change_8290_GFR, ...
    change_9000_GFRI - change_9000_GFR, ...
    change_0015_GFRI - change_0015_GFR, ...
    change_8215_GFRI - change_8215_GFR);
fprintf(fid, '\\midrule ');
fprintf(fid, '\\textbf{Total} & \\textbf{%6.1f} & \\textbf{%6.1f} & \\textbf{%6.1f} & \\textbf{%6.1f} \\\\ \n', ...
    change_8290_actual, change_9000_actual, change_0015_actual, change_8215_actual);
fclose(fid);
fprintf('wrote table 3b to output/tables/table_3b_main_decomp.txt\n')


%%

%
% FIGURE 4a: SLOW DIFFUSION
%
tmpbuf = table2array(readtable(cf_file, 'Range', 'A2:M35','readvariablenames',false));
idx_years = 1:34;
years_oldrelease = tmpbuf(idx_years,1);
passthru_actual = tmpbuf(idx_years,2)*100;
passthru_cf_slow = tmpbuf(idx_years,7)*100;

FigHandle = figure;
set(gcf,'PaperPositionMode','auto')
set(FigHandle, 'Position', [100, 100, 600, 7/8*600]);
set(groot,'DefaultTextFontSize',font_text_1pane)
set(groot,'DefaultAxesFontSize',font_axes_1pane)
axes('NextPlot','replacechildren', 'ColorOrder',Colors);
plot(years_oldrelease, passthru_actual);
hold on
plot(years_oldrelease, passthru_cf_slow, 'Marker',markers{2},'MarkerSize',marker_size);
axis([1980 2015 30 70])
legend ('Actual', 'No post 1990 changes','location', 'NorthWest')
legend boxoff
ylabel('Percent') 
print('-depsc2',fullfile(pwd,'../output/figures','fig_4a_cf_slow'))
fprintf('wrote figure 4a to output/figures/fig_4a_cf_slow.eps\n');

%
% FIGURE 4b: entrant organization choice
%
entrant_actual = tmpbuf(idx_years,8)*100;
entrant_cf_slow = tmpbuf(idx_years,11)*100;
FigHandle = figure;
set(gcf,'PaperPositionMode','auto')
set(FigHandle, 'Position', [100, 100, 600, 7/8*600]);
set(groot,'DefaultTextFontSize',font_text_1pane)
set(groot,'DefaultAxesFontSize',font_axes_1pane)
axes('NextPlot','replacechildren', 'ColorOrder',Colors);
plot(years_oldrelease, entrant_actual);
hold on
plot(years_oldrelease, entrant_cf_slow, 'Marker',markers{2}, 'MarkerSize',marker_size);
axis([1980 2015 40 80])
ylabel('Percent') 
print('-depsc2',fullfile(pwd,'../output/figures','fig_4b_entrant_cf_slow'))
fprintf('wrote figure 4b to output/figures/fig_4b_entrant_cf_slow.eps\n');

%
% FIGURE 4c: C->P conversion flow
%
reorg_ctop_actual = tmpbuf(idx_years,9)*100;
reorg_ctop_cf_slow = tmpbuf(idx_years,12)*100;
entrant_actual = tmpbuf(idx_years,8)*100;
entrant_cf_slow = tmpbuf(idx_years,11)*100;
FigHandle = figure;
set(gcf,'PaperPositionMode','auto')
set(FigHandle, 'Position', [100, 100, 600, 7/8*600]);
set(groot,'DefaultTextFontSize',font_text_1pane)
set(groot,'DefaultAxesFontSize',font_axes_1pane)
axes('NextPlot','replacechildren', 'ColorOrder',Colors);
plot(years_oldrelease, reorg_ctop_actual);
hold on
plot(years_oldrelease, reorg_ctop_cf_slow, 'Marker',markers{2}, 'MarkerSize',marker_size);
axis([1980 2015 0 7])
ylabel('Percent') 
print('-depsc2',fullfile(pwd,'../output/figures','fig_4c_reorg_ctop_cf_slow'))
fprintf('wrote figure 4c to output/figures/fig_4c_reorg_ctop_cf_slow.eps\n');

%
% FIGURE 4d: P->C conversion flow
%
reorg_ptoc_actual = tmpbuf(idx_years,10)*100;
reorg_ptoc_cf_slow = tmpbuf(idx_years,13)*100;
FigHandle = figure;
set(gcf,'PaperPositionMode','auto')
set(FigHandle, 'Position', [100, 100, 600, 7/8*600]);
set(groot,'DefaultTextFontSize',font_text_1pane)
set(groot,'DefaultAxesFontSize',font_axes_1pane)
axes('NextPlot','replacechildren', 'ColorOrder',Colors);
plot(years_oldrelease, reorg_ptoc_actual);
hold on
plot(years_oldrelease, reorg_ptoc_cf_slow, 'Marker',markers{2}, 'MarkerSize',marker_size);
axis([1980 2015 0 7])
ylabel('Percent') 
print('-depsc2',fullfile(pwd,'../output/figures','fig_4d_reorg_ptoc_cf_slow'))
fprintf('wrote figure 4d to output/figures/fig_4d_reorg_ptoc_cf_slow.eps\n');


%%

%
% FIGURE 5a/b: NO STARTUP DEFICIT COUNTERFACTUAL 
%

tmpbuf = table2array(readtable(cf_file, 'Range', 'A2:S35','readvariablenames',false));
idx_years = 1:34;
years_oldrelease = tmpbuf(idx_years,1);
passthru_actual = tmpbuf(idx_years,2)*100;
passthru_cf_nostartupdef = tmpbuf(idx_years,19)*100;

tmpbuf = table2array(readtable(cf_file, 'Range', 'A2:W35','readvariablenames',false));
startup_rate_t = tmpbuf(idx_years,22)*100;
startup_rate_cf_t = tmpbuf(idx_years,23)*100;

%
% FIGURE 5a: STARTUP RATES
%
FigHandle = figure;
set(gcf,'PaperPositionMode','auto')
set(FigHandle, 'Position', [100, 100, 600, 7/8*600]);
set(groot,'DefaultTextFontSize',font_text_1pane)
set(groot,'DefaultAxesFontSize',font_axes_1pane)
axes('NextPlot','replacechildren', 'ColorOrder',Colors);
plot(years_oldrelease, startup_rate_t);
hold on
plot(years_oldrelease, startup_rate_cf_t, 'Marker',markers{2}, 'MarkerSize',marker_size);
axis([1980 2015 08 16])
yticks(8:16)
ylabel('Percent') 
print('-depsc2',fullfile(pwd,'../output/figures','fig_5a_startup_rate'))
fprintf('wrote figure 5a to output/figures/fig_5a_startup_rate\n');

%
% FIGURE 5b: PASS THROUGH SHARES 
%
FigHandle = figure;
set(gcf,'PaperPositionMode','auto')
set(FigHandle, 'Position', [100, 100, 600, 7/8*600]);
set(groot,'DefaultTextFontSize',font_text_1pane)
set(groot,'DefaultAxesFontSize',font_axes_1pane)
axes('NextPlot','replacechildren', 'ColorOrder',Colors);
plot(years_oldrelease, passthru_actual);
hold on
plot(years_oldrelease, passthru_cf_nostartupdef, 'Marker',markers{2}, 'MarkerSize',marker_size);
hold off
axis([1980 2015 30 80])
legend ('Actual', 'No startup deficit','location', 'NorthWest')
legend boxoff
ylabel('Percent') 
print('-depsc2',fullfile(pwd,'../output/figures','fig_5b_cf_nostartupdef'))
fprintf('wrote figure 5b to output/figures/fig_5b_cf_nostartupdef\n');

%%

%
% FIGURE 5c/d: EFFECTS OF BUSINESS AGE COMPOSITION
%

reorg_age_time_raw = readmatrix(rdc_output_file,'Sheet','reorg_age_time_US_T13T26','Range','B2:O9')*100;
c_to_p_age = mean(reorg_age_time_raw(:,1:2:13),1);
p_to_c_age = mean(reorg_age_time_raw(:,2:2:14),1);
c_to_p_time = [mean(reorg_age_time_raw(:,[1,3]),2)';
    mean(reorg_age_time_raw(:,5:2:11),2)';
    reorg_age_time_raw(:,13)'];
p_to_c_time = [mean(reorg_age_time_raw(:,[2,4]),2)';
    mean(reorg_age_time_raw(:,6:2:12),2)';
    reorg_age_time_raw(:,14)'];

passthru_ageconst_raw = readmatrix(rdc_output_file,'Sheet','decomposition_US_constant_age_T','Range','B2:B34')*100;
tmpbuf = table2array(readtable(cf_file, 'Range', 'A2:F35','readvariablenames',false));
idx_years = 1:34;
years_oldrelease = tmpbuf(idx_years,1);
passthru_actual = tmpbuf(idx_years,2)*100;
passthru_ageconst = passthru_actual;
passthru_ageconst(2:end) = passthru_ageconst_raw;

%
% FIGURE 5c : CONVERSION OVER LIFECYCLE
%
FigHandle = figure;
set(gcf,'PaperPositionMode','auto')
set(FigHandle, 'Position', [100, 100, 600, 7/8*600]);
set(groot,'DefaultTextFontSize',font_text_2pane)
set(groot,'DefaultAxesFontSize',font_axes_2pane)
axes('NextPlot','replacechildren', 'ColorOrder',Colors);
plot(1:7, c_to_p_age)
hold on
plot(1:7, p_to_c_age, 'Marker',markers{2}, 'MarkerSize', marker_size)
hold off
ax = gca(FigHandle);
%ax.XAxis.FontSize = 15;
axis([1 7 1 6])
xticklabels({'0','1','2','3','4','5','6+'})
ylabel('Percent') 
%xlabel('Business Age')
legend('C corporation to pass-through','Pass-through to C corporation', 'location', 'ne')
legend box off
print('-depsc2',fullfile(pwd,'../output/figures','fig_5c_cp_pc_lifecycle_age'))
fprintf('wrote figure 5c to output/figures/fig_5c_cp_pc_lifecycle_age.eps\n');

%
% FIGURE 5d : CONSTANT AGE COMPOSITION
%
FigHandle = figure;
set(gcf,'PaperPositionMode','auto')
set(FigHandle, 'Position', [100, 100, 600, 7/8*600]);
set(groot,'DefaultTextFontSize',font_text_1pane)
set(groot,'DefaultAxesFontSize',font_axes_1pane)
axes('NextPlot','replacechildren', 'ColorOrder',Colors);
plot(years_oldrelease, passthru_actual);
hold on
plot(years_oldrelease,passthru_ageconst, 'Marker', markers{2}, 'MarkerSize', marker_size);
hold off
axis([1980 2015 30 80])
legend ('Actual', 'Constant age composition', 'location', 'NorthWest')
legend boxoff
ylabel('Percent') 
print('-depsc2',fullfile(pwd,'../output/figures','fig_5d_cf_ageconst'))
fprintf('wrote figure 5c to output/figures/fig_5d_cf_ageconst.eps\n');

%% APPENDIX FIGURES AND TABLES

%%

%
% APPENDIX TABLE B.1: SUMMARY STATISTICS
%
passthru_all_share_eq = readmatrix(cf_file, 'Range','X2:Z35')*100;
passthru_enter_share_eq = NaN + zeros(size(passthru_all_share_eq));
passthru_enter_share_eq(2:end,:) = readmatrix(cf_file, 'Range','AA3:AC35')*100;

fid = fopen('../output/tables/table_b1_summary.txt','w');
fprintf(fid, '------COPY LATEX CODE BELOW -----------------\n');
fprintf(fid, ' & \\multicolumn{2-10}{c}{\\textit{A. Share of All Businesses (Percent)} \\\\ \n');
fprintf(fid, '\\cmidrule(lr){4-8}\n');
fprintf(fid, 'C corporations ($c$) & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f \\\\\n', ...
    mean(passthru_all_share_eq(1:4,1)), ...
    mean(passthru_all_share_eq(5:8,1)), ...
    mean(passthru_all_share_eq(9:12,1)), ...
    mean(passthru_all_share_eq(13:16,1)), ...
    mean(passthru_all_share_eq(17:20,1)), ...
    mean(passthru_all_share_eq(21:24,1)), ...
    mean(passthru_all_share_eq(25:28,1)), ...
    mean(passthru_all_share_eq(29:32,1)), ...
    mean(passthru_all_share_eq(33:34,1)));
fprintf(fid, 'Pass-through ($p$) & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f \\\\\n', ...
    mean(passthru_all_share_eq(1:4,2)), ...
    mean(passthru_all_share_eq(5:8,2)), ...
    mean(passthru_all_share_eq(9:12,2)), ...
    mean(passthru_all_share_eq(13:16,2)), ...
    mean(passthru_all_share_eq(17:20,2)), ...
    mean(passthru_all_share_eq(21:24,2)), ...
    mean(passthru_all_share_eq(25:28,2)), ...
    mean(passthru_all_share_eq(29:32,2)), ...
    mean(passthru_all_share_eq(33:34,2)));   
fprintf(fid, 'Other ($z$) & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f \\\\\n', ...
    mean(passthru_all_share_eq(1:4,3)), ...
    mean(passthru_all_share_eq(5:8,3)), ...
    mean(passthru_all_share_eq(9:12,3)), ...
    mean(passthru_all_share_eq(13:16,3)), ...
    mean(passthru_all_share_eq(17:20,3)), ...
    mean(passthru_all_share_eq(21:24,3)), ...
    mean(passthru_all_share_eq(25:28,3)), ...
    mean(passthru_all_share_eq(29:32,3)), ...
    mean(passthru_all_share_eq(33:34,3)));      
fprintf(fid, ' & \\multicolumn{2-10}{c}{\\textit{B. Share of Entering Businesses (Percent)} \\\\ \n');
fprintf(fid, '\\cmidrule(lr){4-8}\n');
fprintf(fid, 'C corporations ($c$) & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f \\\\\n', ...
    mean(passthru_enter_share_eq(2:4,1)), ...
    mean(passthru_enter_share_eq(5:8,1)), ...
    mean(passthru_enter_share_eq(9:12,1)), ...
    mean(passthru_enter_share_eq(13:16,1)), ...
    mean(passthru_enter_share_eq(17:20,1)), ...
    mean(passthru_enter_share_eq(21:24,1)), ...
    mean(passthru_enter_share_eq(25:28,1)), ...
    mean(passthru_enter_share_eq(29:32,1)), ...
    mean(passthru_enter_share_eq(33:34,1)));
fprintf(fid, 'Pass-through ($p$) & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f \\\\\n', ...
    mean(passthru_enter_share_eq(2:4,2)), ...
    mean(passthru_enter_share_eq(5:8,2)), ...
    mean(passthru_enter_share_eq(9:12,2)), ...
    mean(passthru_enter_share_eq(13:16,2)), ...
    mean(passthru_enter_share_eq(17:20,2)), ...
    mean(passthru_enter_share_eq(21:24,2)), ...
    mean(passthru_enter_share_eq(25:28,2)), ...
    mean(passthru_enter_share_eq(29:32,2)), ...
    mean(passthru_enter_share_eq(33:34,2)));   
fprintf(fid, 'Other ($z$) & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f & %5.1f \\\\\n', ...
    mean(passthru_enter_share_eq(2:4,3)), ...
    mean(passthru_enter_share_eq(5:8,3)), ...
    mean(passthru_enter_share_eq(9:12,3)), ...
    mean(passthru_enter_share_eq(13:16,3)), ...
    mean(passthru_enter_share_eq(17:20,3)), ...
    mean(passthru_enter_share_eq(21:24,3)), ...
    mean(passthru_enter_share_eq(25:28,3)), ...
    mean(passthru_enter_share_eq(29:32,3)), ...
    mean(passthru_enter_share_eq(33:34,3)));      
fclose(fid);
fprintf('wrote table B.1 to output/tables/table_b1_summary.txt\n');

%%

%
% APPENDIX FIGURE B.1 : SUSB vs LBD-TLFO DATA
%

% specify sheet name
sheet = 'susb_input';

% read the data into a table
susbTable = readtable(filename_susb, 'Sheet', sheet);

% number of years
n = length(susbTable.year);

% select the last n elements from the passthru_share_eq array
passthru_share_eq_modified = passthru_share_eq(end-n+1:end);
passthru_share_emp_modified = passthru_share_emp(end-n+1:end);


%
% APPENDIX FIUGURE B.1a: SUSB vs. TLFO-LBD DATA SHARE OF BUSINESSES
%

FigHandle = figure;
set(gcf,'PaperPositionMode','auto')
set(FigHandle, 'Position', figpos);
set(groot,'DefaultTextFontSize',font_text_1pane)
set(groot,'DefaultAxesFontSize',font_axes_1pane)

% now plot
plot1 = plot(susbTable.year, susbTable.estabs_susb, 'DisplayName', 'SUSB');
hold on
plot2 = plot(susbTable.year, passthru_share_eq_modified, 'Marker',markers{2},'MarkerSize',marker_size, 'DisplayName', 'LBD-TLFO');

% set y-axis limits
ylim([50 80]);

% add a legend
legend1 = legend([plot1, plot2], 'Location', 'southeast');

% Remove legend box and background
box(legend1,'off');
legend1.Color = 'none';
print('-depsc2',fullfile(pwd,'../output/figures','fig_b1a_estabs_susb_lbd'));
fprintf('wrote figure B.1a to output/figures/fig_b1a_estabs_susb_lbd.eps\n');


%
% APPENDIX FIUGURE B.1b: SUSB vs. TLFO-LBD DATA SHARE OF EMPLOYMNET
%

FigHandle = figure;
set(gcf,'PaperPositionMode','auto')
set(FigHandle, 'Position', figpos);
set(groot,'DefaultTextFontSize',font_text_1pane)
set(groot,'DefaultAxesFontSize',font_axes_1pane)

% now plot
plot1 = plot(susbTable.year, susbTable.emp_susb, 'DisplayName', 'SUSB');
hold on
plot2 = plot(susbTable.year, passthru_share_emp_modified, 'Marker',markers{2},'MarkerSize',marker_size, 'DisplayName', 'LBD-TLFO');

% set y-axis limits
ylim([30 60]);

print('-depsc2',fullfile(pwd,'../output/figures','fig_b1b_emp_susb_lbd'));
fprintf('wrote figure B.1b to output/figures/fig_b1b_emp_susb_lbd.eps\n');


%%

%
% APPENDIX FIGURE C.1 : NO Z FLOW COMPARISON
%
passthru_share_eq = readmatrix(cf_file, 'Range','B2:B35')*100;
passthru_share_eq_noz = readmatrix(cf_file_noz, 'Range','B2:B35')*100;

FigHandle = figure;
set(gcf,'PaperPositionMode','auto')
set(FigHandle, 'Position', figpos);
set(groot,'DefaultTextFontSize',font_text_1pane)
set(groot,'DefaultAxesFontSize',font_axes_1pane)
axes('NextPlot','replacechildren', 'ColorOrder',Colors);
plot(years, passthru_share_eq);
hold on
plot(years, passthru_share_eq_noz, 'Marker',markers{2},'MarkerSize',marker_size);
axis([1980 2015 40 70])
legend ('with Z flows', 'No Z flows', 'location', 'SouthEast')
legend boxoff
ylabel('Percent')
print('-depsc2',fullfile(pwd,'../output/figures','fig_c1_actual_compare_noz'))
fprintf('wrote figure C.1 to output/figures/fig_c1_actual_compare_noz.eps\n');

%%

%
% APPENDIX FIGURE C.2 : MAIN DECOMPOSITION AGAINST MORE GRANULAR
%
tmpbuf = table2array(readtable(cf_file, 'Range', 'A2:F35','readvariablenames',false));
idx_years = 1:34;
years_oldrelease = tmpbuf(idx_years,1);
passthru_actual = tmpbuf(idx_years,2)*100;
passthru_cf_G = tmpbuf(idx_years,3)*100; % convergence (hold all)
passthru_cf_GF = tmpbuf(idx_years,4)*100; % + firm dynamics (hold both)
passthru_cf_GFR = tmpbuf(idx_years,5)*100; % + reorg dynamics (hold entry)
passthru_cf_GFI = tmpbuf(idx_years,6)*100; % - reorg dynamics + initial (hold reorg)
passthru_cf_GFRI = passthru_actual;

passthru_eq_granular = readmatrix(rdc_output_file,'Sheet','decomposition_US_num_weighted_T','Range','B2:D34')*100;
passthru_cf_G_granular = passthru_actual;
passthru_cf_GF_granular = passthru_actual;
passthru_cf_GFR_granular = passthru_actual;

passthru_cf_G_granular(2:end) = passthru_eq_granular(:,3);
passthru_cf_GF_granular(2:end) = passthru_eq_granular(:,2);
passthru_cf_GFR_granular(2:end) = passthru_eq_granular(:,1);

FigHandle = figure;
set(gcf,'PaperPositionMode','auto')
set(FigHandle, 'Position', [100, 100, 600, 7/8*600]);
set(groot,'DefaultTextFontSize',font_text_1pane)
set(groot,'DefaultAxesFontSize',font_axes_1pane)
axes('NextPlot','replacechildren', 'ColorOrder',Colors);
p1 = plot(years_oldrelease, passthru_actual);
hold on
p2 = plot(years_oldrelease,passthru_cf_GFR,'color',Colors(2,:), 'Marker', markers{2}, 'MarkerSize', marker_size);
plot(years_oldrelease,passthru_cf_GFR_granular,':','color',Colors(2,:), 'Marker', markers{2}, 'MarkerSize', marker_size);
p3 = plot(years_oldrelease, passthru_cf_GF,'color',Colors(3,:), 'Marker', markers{3}, 'MarkerSize', marker_size);
plot(years_oldrelease,passthru_cf_GF_granular,':','color',Colors(3,:), 'Marker', markers{3}, 'MarkerSize', marker_size);
p4 = plot(years_oldrelease, passthru_cf_G,'color',Colors(4,:), 'Marker', markers{4}, 'MarkerSize', marker_size);
plot(years_oldrelease,passthru_cf_G_granular,':','color',Colors(4,:), 'Marker', markers{4}, 'MarkerSize', marker_size);
hold off
axis([1980 2015 30 70])
legend ([p1 p2 p3 p4], {'$GFRE$=Actual', '$GFR$', '$GF$', '$G$'}, 'location', 'NorthWest')
legend boxoff
ylabel('Percent') 
print('-depsc2',fullfile(pwd,'../output/figures','fig_c2_cf_main_granular'))
fprintf('wrote figure C.2 to output/figures/fig_c2_cf_main_granular.eps\n');

%%

%
% APPENDIX TABLE C.1 : MAIN DECOMPOSITION DETAIL (GRANULAR)
%
passthru_eq_granular = readmatrix(rdc_output_file,'Sheet','decomposition_US_num_weighted_T','Range','B2:D34')*100;

passthru_cf_G_granular = passthru_actual;
passthru_cf_GF_granular = passthru_actual;
passthru_cf_GFR_granular = passthru_actual;
passthru_cf_GFRI_granular = passthru_actual;

passthru_cf_G_granular(2:end) = passthru_eq_granular(:,3);
passthru_cf_GF_granular(2:end) = passthru_eq_granular(:,2);
passthru_cf_GFR_granular(2:end) = passthru_eq_granular(:,1);

idx_8290_start = 1;
idx_8290_end = 9;

change_8290_actual = passthru_actual(idx_8290_end)-passthru_actual(idx_8290_start);
change_8290_G = passthru_cf_G_granular(idx_8290_end)-passthru_cf_G_granular(idx_8290_start);
change_8290_GF = passthru_cf_GF_granular(idx_8290_end)-passthru_cf_GF_granular(idx_8290_start) ;
change_8290_GFR = passthru_cf_GFR_granular(idx_8290_end)-passthru_cf_GFR_granular(idx_8290_start);
change_8290_GFRI = passthru_cf_GFRI_granular(idx_8290_end)-passthru_cf_GFRI_granular(idx_8290_start);

idx_9000_start = 9;
idx_9000_end = 19;

change_9000_actual = passthru_actual(idx_9000_end)-passthru_actual(idx_9000_start);
change_9000_G = passthru_cf_G_granular(idx_9000_end)-passthru_cf_G_granular(idx_9000_start);
change_9000_GF = passthru_cf_GF_granular(idx_9000_end)-passthru_cf_GF_granular(idx_9000_start) ;
change_9000_GFR = passthru_cf_GFR_granular(idx_9000_end)-passthru_cf_GFR_granular(idx_9000_start);
change_9000_GFRI = passthru_cf_GFRI_granular(idx_9000_end)-passthru_cf_GFRI_granular(idx_9000_start);

idx_0015_start = 19;
idx_0015_end = 34;

change_0015_actual = passthru_actual(idx_0015_end)-passthru_actual(idx_0015_start);
change_0015_G = passthru_cf_G_granular(idx_0015_end)-passthru_cf_G_granular(idx_0015_start);
change_0015_GF = passthru_cf_GF_granular(idx_0015_end)-passthru_cf_GF_granular(idx_0015_start) ;
change_0015_GFR = passthru_cf_GFR_granular(idx_0015_end)-passthru_cf_GFR_granular(idx_0015_start);
change_0015_GFRI = passthru_cf_GFRI_granular(idx_0015_end)-passthru_cf_GFRI_granular(idx_0015_start);

idx_8215_start = 1;
idx_8215_end = 34;

change_8215_actual = passthru_actual(idx_8215_end)-passthru_actual(idx_8215_start);
change_8215_G = passthru_cf_G_granular(idx_8215_end)-passthru_cf_G_granular(idx_8215_start);
change_8215_GF = passthru_cf_GF_granular(idx_8215_end)-passthru_cf_GF_granular(idx_8215_start) ;
change_8215_GFR = passthru_cf_GFR_granular(idx_8215_end)-passthru_cf_GFR_granular(idx_8215_start);
change_8215_GFRI = passthru_cf_GFRI_granular(idx_8215_end)-passthru_cf_GFRI_granular(idx_8215_start);

fid = fopen('../output/tables/table_c1_main_decomp_granular.txt','w');
fprintf(fid, '------COPY LATEX CODE BELOW--(GRANULAR VERSION)-----------------\n');
fprintf(fid, 'Period 1982-1990 & %6.1f & %6.1f & %6.1f & %6.1f & \\textbf{%6.1f} \\\\ \n', ...
    change_8290_G, ...
    change_8290_GF - change_8290_G, ...
    change_8290_GFR - change_8290_GF, ...
    change_8290_GFRI - change_8290_GFR, ...
    change_8290_actual);
fprintf(fid, 'Period 1990-2000 & %6.1f & %6.1f & %6.1f & %6.1f & \\textbf{%6.1f} \\\\ \n', ...
    change_9000_G, ...
    change_9000_GF - change_9000_G, ...
    change_9000_GFR - change_9000_GF, ...
    change_9000_GFRI - change_9000_GFR, ...
    change_9000_actual);
fprintf(fid, 'Period 2000-2015 & %6.1f & %6.1f & %6.1f & %6.1f & \\textbf{%6.1f} \\\\ \n', ...
    change_0015_G, ...
    change_0015_GF - change_0015_G, ...
    change_0015_GFR - change_0015_GF, ...
    change_0015_GFRI - change_0015_GFR, ...
    change_0015_actual);
fprintf(fid, '\\midrule\n');
fprintf(fid, 'Entire period 1982-2015 & \\textbf{%6.1f} & \\textbf{%6.1f} & \\textbf{%6.1f} & \\textbf{%6.1f} & \\textbf{%6.1f} \\\\ \n', ...
    change_8215_G, ...
    change_8215_GF - change_8215_G, ...
    change_8215_GFR - change_8215_GF, ...
    change_8215_GFRI - change_8215_GFR, ...
    change_8215_actual);
fclose(fid);
fprintf('wrote table C.1 to output/tables/table_c1_main_decomp_granular.txt\n');

%%

%
% APPENDIX FIGURE C.3 : MAIN DECOMPOSITION WITH AGE DEPENDENCE
%
tmpbuf = table2array(readtable(cf_file, 'Range', 'A2:F35','readvariablenames',false));
idx_years = 1:34;
years_oldrelease = tmpbuf(idx_years,1);
passthru_actual = tmpbuf(idx_years,2)*100;

passthru_eq_granular = readmatrix(rdc_output_file,'Sheet','decomposition_US_num_weighted_T','Range','B2:D34')*100;
passthru_cf_G_granular = passthru_actual;
passthru_cf_GF_granular = passthru_actual;
passthru_cf_GFR_granular = passthru_actual;
passthru_cf_GFRI_granular = passthru_actual;
passthru_cf_G_granular(2:end) = passthru_eq_granular(:,3);
passthru_cf_GF_granular(2:end) = passthru_eq_granular(:,2);
passthru_cf_GFR_granular(2:end) = passthru_eq_granular(:,1);

passthru_eq_age= readmatrix(rdc_output_file,'Sheet','decomposition_US_constant_age_T','Range','C2:E34')*100;
passthru_cf_G_age = passthru_actual;
passthru_cf_GF_age = passthru_actual;
passthru_cf_GFR_age = passthru_actual;
passthru_cf_GFRI_age = passthru_actual;
passthru_cf_G_age(2:end) = passthru_eq_age(:,3);
passthru_cf_GF_age(2:end) = passthru_eq_age(:,2);
passthru_cf_GFR_age(2:end) = passthru_eq_age(:,1);

FigHandle = figure;
set(gcf,'PaperPositionMode','auto')
set(FigHandle, 'Position', [100, 100, 600, 7/8*600]);
set(groot,'DefaultTextFontSize',font_text_1pane)
set(groot,'DefaultAxesFontSize',font_axes_1pane)
axes('NextPlot','replacechildren', 'ColorOrder',Colors);
p1 = plot(years_oldrelease, passthru_actual);
hold on
p2 = plot(years_oldrelease,passthru_cf_GFR_granular,'color',Colors(2,:), 'Marker', markers{2}, "MarkerSize", marker_size);
plot(years_oldrelease,passthru_cf_GFR_age,':','color',Colors(2,:), 'Marker', markers{2}, "MarkerSize", marker_size);
p3 = plot(years_oldrelease, passthru_cf_GF_granular,'color',Colors(3,:), 'Marker', markers{3}, "MarkerSize", marker_size);
plot(years_oldrelease,passthru_cf_GF_age,':','color',Colors(3,:), 'Marker', markers{3}, "MarkerSize", marker_size);
p4 = plot(years_oldrelease, passthru_cf_G_granular,'color',Colors(4,:), 'Marker', markers{4}, "MarkerSize", marker_size);
plot(years_oldrelease,passthru_cf_G_age,':','color',Colors(4,:), 'Marker', markers{4}, "MarkerSize", marker_size);
hold off
axis([1980 2015 30 70])
legend ([p1 p2 p3 p4], {'$GFRE$=Actual', '$GFR$', '$GF$', '$G$'}, 'location', 'NorthWest')
legend boxoff
ylabel('Percent') 
print('-depsc2',fullfile(pwd,'../output/figures','fig_c3_cf_main_granular_age'))
fprintf('wrote figure C.3 to output/figures/fig_c3_cf_main_granular_age.eps\n');

%%

%
% APPENDIX TABLE C.2 : MAIN DECOMPOSITION DETAIL (GRANULAR AND AGE)
%
tmpbuf = table2array(readtable(cf_file, 'Range', 'A2:F35','readvariablenames',false));
idx_years = 1:34;
years_oldrelease = tmpbuf(idx_years,1);
passthru_actual = tmpbuf(idx_years,2)*100;

passthru_eq_age= readmatrix(rdc_output_file,'Sheet','decomposition_US_constant_age_T','Range','C2:E34')*100;
passthru_cf_G_age = passthru_actual;
passthru_cf_GF_age = passthru_actual;
passthru_cf_GFR_age = passthru_actual;
passthru_cf_GFRI_age = passthru_actual;
passthru_cf_G_age(2:end) = passthru_eq_age(:,3);
passthru_cf_GF_age(2:end) = passthru_eq_age(:,2);
passthru_cf_GFR_age(2:end) = passthru_eq_age(:,1);

idx_8290_start = 1;
idx_8290_end = 9;

change_8290_actual = passthru_actual(idx_8290_end)-passthru_actual(idx_8290_start);
change_8290_G = passthru_cf_G_age(idx_8290_end)-passthru_cf_G_age(idx_8290_start);
change_8290_GF = passthru_cf_GF_age(idx_8290_end)-passthru_cf_GF_age(idx_8290_start) ;
change_8290_GFR = passthru_cf_GFR_age(idx_8290_end)-passthru_cf_GFR_age(idx_8290_start);
change_8290_GFRI = passthru_cf_GFRI_age(idx_8290_end)-passthru_cf_GFRI_age(idx_8290_start);

idx_9000_start = 9;
idx_9000_end = 19;

change_9000_actual = passthru_actual(idx_9000_end)-passthru_actual(idx_9000_start);
change_9000_G = passthru_cf_G_age(idx_9000_end)-passthru_cf_G_age(idx_9000_start);
change_9000_GF = passthru_cf_GF_age(idx_9000_end)-passthru_cf_GF_age(idx_9000_start) ;
change_9000_GFR = passthru_cf_GFR_age(idx_9000_end)-passthru_cf_GFR_age(idx_9000_start);
change_9000_GFRI = passthru_cf_GFRI_age(idx_9000_end)-passthru_cf_GFRI_age(idx_9000_start);

idx_0015_start = 19;
idx_0015_end = 34;

change_0015_actual = passthru_actual(idx_0015_end)-passthru_actual(idx_0015_start);
change_0015_G = passthru_cf_G_age(idx_0015_end)-passthru_cf_G_age(idx_0015_start);
change_0015_GF = passthru_cf_GF_age(idx_0015_end)-passthru_cf_GF_age(idx_0015_start) ;
change_0015_GFR = passthru_cf_GFR_age(idx_0015_end)-passthru_cf_GFR_age(idx_0015_start);
change_0015_GFRI = passthru_cf_GFRI_age(idx_0015_end)-passthru_cf_GFRI_age(idx_0015_start);

idx_8215_start = 1;
idx_8215_end = 34;

change_8215_actual = passthru_actual(idx_8215_end)-passthru_actual(idx_8215_start);
change_8215_G = passthru_cf_G_age(idx_8215_end)-passthru_cf_G_age(idx_8215_start);
change_8215_GF = passthru_cf_GF_age(idx_8215_end)-passthru_cf_GF_age(idx_8215_start) ;
change_8215_GFR = passthru_cf_GFR_age(idx_8215_end)-passthru_cf_GFR_age(idx_8215_start);
change_8215_GFRI = passthru_cf_GFRI_age(idx_8215_end)-passthru_cf_GFRI_age(idx_8215_start);

fid = fopen('../output/tables/table_c2_main_decomp_age.txt','w');
fprintf(fid,'------COPY LATEX CODE BELOW--(AGE DEPENDENT VERSION)-----------------\n');
fprintf(fid,'Period 1982-1990 & %6.1f & %6.1f & %6.1f & %6.1f & \\textbf{%6.1f} \\\\ \n', ...
    change_8290_G, ...
    change_8290_GF - change_8290_G, ...
    change_8290_GFR - change_8290_GF, ...
    change_8290_GFRI - change_8290_GFR, ...
    change_8290_actual);
fprintf(fid,'Period 1990-2000 & %6.1f & %6.1f & %6.1f & %6.1f & \\textbf{%6.1f} \\\\ \n', ...
    change_9000_G, ...
    change_9000_GF - change_9000_G, ...
    change_9000_GFR - change_9000_GF, ...
    change_9000_GFRI - change_9000_GFR, ...
    change_9000_actual);
fprintf(fid,'Period 2000-2015 & %6.1f & %6.1f & %6.1f & %6.1f & \\textbf{%6.1f} \\\\ \n', ...
    change_0015_G, ...
    change_0015_GF - change_0015_G, ...
    change_0015_GFR - change_0015_GF, ...
    change_0015_GFRI - change_0015_GFR, ...
    change_0015_actual);
fprintf(fid,'\\midrule\n');
fprintf(fid,'Entire period 1982-2015 & \\textbf{%6.1f} & \\textbf{%6.1f} & \\textbf{%6.1f} & \\textbf{%6.1f} & \\textbf{%6.1f} \\\\ \n', ...
    change_8215_G, ...
    change_8215_GF - change_8215_G, ...
    change_8215_GFR - change_8215_GF, ...
    change_8215_GFRI - change_8215_GFR, ...
    change_8215_actual);
fclose(fid);
fprintf('wrote table C.2 to output/tables/table_c2_main_decomp_age.txt\n');

%%

%
% APPENDIX FIGURE C.4 : NO STARTUP DEF CF WITH AGE COMP 
%
tmpbuf = table2array(readtable(cf_file, 'Range', 'A2:S35','readvariablenames',false));
idx_years = 1:34;
years_oldrelease = tmpbuf(idx_years,1);
passthru_actual = tmpbuf(idx_years,2)*100;
passthru_cf_nostartupdef = tmpbuf(idx_years,19)*100;
% version adjusting for age composition
passthru_cf_nostartupdef2 = passthru_cf_nostartupdef;
passthru_cf_nostartupdef2(2:end) = readmatrix(rdc_output_file,'Sheet','decomposition_US_constant_age_T','Range','F2:F34')*100;


FigHandle = figure;
set(gcf,'PaperPositionMode','auto')
set(FigHandle, 'Position', [100, 100, 600, 7/8*600]);
set(groot,'DefaultTextFontSize',font_text_1pane)
set(groot,'DefaultAxesFontSize',font_axes_1pane)
axes('NextPlot','replacechildren', 'ColorOrder',Colors);
plot(years_oldrelease, passthru_actual);
hold on
plot(years_oldrelease, passthru_cf_nostartupdef, 'Marker', markers{2}, "MarkerSize", marker_size);
plot(years_oldrelease, passthru_cf_nostartupdef2, 'Marker', markers{3}, "MarkerSize", marker_size);
hold off
axis([1980 2015 30 80])
legend ('Actual', 'No startup deficit', 'Age composition adjustment', 'location', 'NorthWest')
legend boxoff
ylabel('Percent') 
print('-depsc2',fullfile(pwd,'../output/figures','fig_c4_cf_nostartupdef2'))
fprintf('wrote figure C.4 to output/figures/fig_c4_cf_nostartupdef2.eps\n');


%%

%
% FIGURE C.5 : LONG RUN 
%

tmpbuf = table2array(readtable(cf_file, 'Range', 'A2:R35','readvariablenames',false));
idx_years = 1:34;
years_oldrelease = tmpbuf(idx_years,1);
passthru_actual = tmpbuf(idx_years,2)*100;
passthru_actual_lr = tmpbuf(idx_years,14)*100;
passthru_cf_G_lr = tmpbuf(idx_years,15)*100; % convergence (hold all)
passthru_cf_GF_lr = tmpbuf(idx_years,16)*100; % + firm dynamics (hold both)
passthru_cf_GFR_lr = tmpbuf(idx_years,17)*100; % + reorg dynamics (hold entry)
passthru_cf_GFI_lr = tmpbuf(idx_years,18)*100; % - reorg dynamics + initial (hold reorg)

%
% FIGURE C.5a : LONG RUN actual vs LR
%
FigHandle = figure;
set(gcf,'PaperPositionMode','auto')
set(FigHandle, 'Position', [100, 100, 600, 7/8*600]);
set(groot,'DefaultTextFontSize',font_text_1pane)
set(groot,'DefaultAxesFontSize',font_axes_1pane)
axes('NextPlot','replacechildren', 'ColorOrder',Colors);
colormap = get(gca,'colororder');
plot(years_oldrelease, passthru_actual, ...
    years_oldrelease, passthru_actual_lr, ':', 'color',colormap(1,:));
axis([1980 2015 30 80])
legend ('Actual', 'Implied long run', 'Location', 'NorthWest')
legend boxoff
ylabel('Percent') 
print('-depsc2',fullfile(pwd,'../output/figures','fig_c5a_agg_lr'))
fprintf('wrote figure C.5a to output/figures/fig_c5a_agg_lr.eps\n');

%
% FIGURE C.5b : LONG RUN DECOMP
%

FigHandle = figure;
set(gcf,'PaperPositionMode','auto')
set(FigHandle, 'Position', [100, 100, 600, 7/8*600]);
set(groot,'DefaultTextFontSize',font_text_1pane)
set(groot,'DefaultAxesFontSize',font_axes_1pane)
axes('NextPlot','replacechildren', 'ColorOrder',Colors);
plot(years_oldrelease, passthru_actual_lr, ':');
hold on
plot(years_oldrelease, passthru_cf_GFR_lr, ':', 'Marker', markers{2}, "MarkerSize", marker_size);
plot(years_oldrelease, passthru_cf_GF_lr, ':', 'Marker', markers{3}, "MarkerSize", marker_size);
plot(years_oldrelease, passthru_cf_G_lr, ':', 'Marker', markers{4}, "MarkerSize", marker_size);
axis([1980 2015 30 80])
legend ('$GFRE$=Actual', '$GFR$', '$GF$', '$G$', 'location', 'NorthWest')
legend boxoff
ylabel('Percent') 
print('-depsc2',fullfile(pwd,'../output/figures','fig_c5b_cf_main_lr'))
fprintf('wrote figure C.5b to output/figures/fig_c5b_cf_main_lr.eps\n');

%%

%
% APPENDIX FIGURE D.1: SHARE OF MANUFACTURING IN BDS DATA
%

% Add up the total number of firms and employment for each year
total_estabs = varfun(@sum, data_bds, 'GroupingVariables', 'year', 'InputVariables', 'estabs');
total_firms = varfun(@sum, data_bds, 'GroupingVariables', 'year', 'InputVariables', 'firms');
total_employment = varfun(@sum, data_bds, 'GroupingVariables', 'year', 'InputVariables', 'emp');

% Join total_firms, total_employment and total_estabs into a single table on 'year'
totals = join(total_firms, total_employment);
totals = join(totals, total_estabs);

% Compute the share of firms and emp for each sector in each year
data_bds.firms_share = NaN(height(data_bds), 1);
data_bds.emp_share = NaN(height(data_bds), 1);
data_bds.estabs_share = NaN(height(data_bds), 1);

for i = 1:height(data_bds)
    year = data_bds.year(i);
    total_for_year = totals(totals.year == year, :);
    data_bds.firms_share(i) = data_bds.firms(i) / total_for_year.sum_firms;
    data_bds.emp_share(i) = data_bds.emp(i) / total_for_year.sum_emp;
    data_bds.estabs_share(i) = data_bds.estabs(i) / total_for_year.sum_estabs;
end

% Subset the data
subset = data_bds(data_bds.year >= 1982 & data_bds.year <= 2015 & strcmp(data_bds.sector, '31-33'), :);

FigHandle = figure;
set(gcf,'PaperPositionMode','auto')
set(FigHandle, 'Position', figpos);
set(groot,'DefaultTextFontSize',font_text_1pane)
set(groot,'DefaultAxesFontSize',font_axes_1pane)
plot(subset.year, subset.estabs_share*100, 'LineWidth', 2);
hold on
plot(subset.year, subset.emp_share*100, 'LineWidth', 2, 'Marker', markers{2}, "MarkerSize", marker_size);
legend ('Businesses', 'Employment', 'location', 'NorthEast')
legend boxoff
xlabel('Year')
ylabel('Shares in Total (\%)')
xlim([1980 2015]);
xticks(1980:5:2015);
print('-depsc2',fullfile(pwd,'../output/figures','fig_d1_manufacturing_bds'))
fprintf('wrote figure D.1 to output/figures/fig_d1_manufacturing_bds.eps\n');


%
% APPENDIX FIGURE D.2: EXIT RATES BY TLFO
%
tmpbuf = table2array(readtable(cf_file, 'Range', 'A2:U35','readvariablenames',false));
passthru_actual = tmpbuf(idx_years,2)*100;
ccorp_exit = tmpbuf(idx_years,21)*100;
passthru_exit = tmpbuf(idx_years,20)*100;

FigHandle = figure;
set(gcf,'PaperPositionMode','auto')
set(FigHandle, 'Position', [100, 100, 600, 7/8*600]);
set(groot,'DefaultTextFontSize',font_text_1pane)
set(groot,'DefaultAxesFontSize',font_axes_1pane)
axes('NextPlot','replacechildren', 'ColorOrder',Colors);
plot(years_oldrelease, passthru_exit);
hold on
plot(years_oldrelease, ccorp_exit, 'Marker', markers{2}, "MarkerSize", marker_size);
axis([1980 2015 0 30 ])
legend ('Pass through exit rate', 'C Corp exit rate','location', 'NorthEast')
legend boxoff
ylabel('Percent') 
print('-depsc2',fullfile(pwd,'../output/figures','fig_d5_exitrates'))
fprintf('wrote figure D.5 to output/figures/fig_d5_exitrates.eps\n');



