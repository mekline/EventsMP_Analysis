%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% secondLevel_lastCsvToGraph(graph_title, cont_inds, cont_names)
%
% This takes in a your contrasts of interest (by index), reads the /last/ csv
%   outputted from the toolbox analysis, and returns a graph.  This last
%   csv has the information on all of the contrasts, in one file.
%
% INPUT:
%   title: string, the desired title of your graph. ex: 'Language fROIs:
%       response to freq.'
%   cont_inds: array, the indices of your desired contrasts (indexing into 
%       ss.EffectOfInterest_contrasts).  This is the order in which they'll
%       be displayed on the graph.
%   cont_names: cell array, same length and order as cont_inds.  Names of
%       your desired contrasts, to be displayed on the graph.
%
% Created: bpritche, 1/28/16
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function secondLevel_lastCsvToGraph(graph_title,cont_inds,cont_names)
%% CHANGE
% filename for the jpg that is saved
save_filename = sprintf('SyntCat_%s', graph_title);
% where to find the csv files to graph
csv_dir = fullfile(pwd, '..', 'syntcat2', 'RESULTS_syntcat_ev');
% how many contrasts were run on this subject (total)
total_num_contrasts = 23;

%% SETUP
% Handle input
if length(cont_names) ~= length(cont_inds)
    error('length(cont_names) = %d, length(cont_inds) = %d.\nShould be the same.\n', ...
        length(cont_names), length(cont_inds));
end

%%%% Initialize %%%
% CSV stuff
num_rois = 6;
curr_num_conts = length(cont_inds);
% Will be array of structs. Struct will have fields name, PSC, and stderr.
% Each element of array will represent one contrast
struct_template = struct('name', '', 'psc', nan(1,num_rois), 'stderr', nan(1,num_rois));
all_cont_info = repmat(struct_template,curr_num_conts,1);  
% define indices into csv array
name_i = [1,2]; %str, name of contrast
roi_start_row = 10;
psc_start_i_col = 5; %array, 6 PSCs (h, in csv), this is index into first one 
stderr_start_i_col = psc_start_i_col + total_num_contrasts; %array, 6 stderrs, this is index into first one 
csv_name = sprintf('spm_ss_mROI_results_%04d.csv', total_num_contrasts+1);
csv_fullname = fullfile(csv_dir, csv_name);
if ~exist(csv_fullname, 'file'), error('%s doesn''t exist!',csv_fullname); end
csv_contents = read_mixed_csv(csv_fullname, ',');

% Graph stuff
roi_pres_order = [6 4 5 2 1 3]'; % the order we want to display things in
roi_names = {'LPostTemp', 'LAntTemp', 'LAngG', 'LIFG', 'LMFG', 'LIFGorb'};
y_vals = nan(num_rois, curr_num_conts); 
stderr_vals = nan(num_rois, curr_num_conts);

%% CSV info
% Loop through and grab results for contrasts of interest
for i = 1:curr_num_conts
    iCont = cont_inds(i);
    cont_struct = struct;
    psc_i_col = psc_start_i_col + iCont - 1;
    stderr_i_col = stderr_start_i_col + iCont - 1;
    
    % pull out name of contrast (i.e. N, H-L)
    cont_struct.name = cont_names{i};
    
    % loop through rois, pull out psc and stderr for each
    cont_struct.psc = nan(1, num_rois);
    cont_struct.stderr = nan(1, num_rois);
    for j = 1:num_rois
        roi_row = roi_start_row+j-1;
        roi_psc = csv_contents{roi_row, psc_i_col};
        cont_struct.psc(j) = str2double(roi_psc);
        y_vals(j,i) = str2double(roi_psc);
        roi_stderr = csv_contents{roi_row, stderr_i_col};
        cont_struct.stderr(j) = str2double(roi_stderr);
        stderr_vals(j,i) = str2double(roi_stderr);
    end
    
    % save
    all_cont_info(i) = cont_struct;
end

%% Graph
clf
fig = figure(1);
% reorder
y_vals = y_vals(roi_pres_order,:);
roi_names = roi_names(roi_pres_order);
stderr_vals = stderr_vals(roi_pres_order,:);

% Values
hb = bar(y_vals);
% Error bars (annoying)
hold on;
groupwidth = min(0.8, curr_num_conts/(curr_num_conts+1.5));
for i = 1:curr_num_conts
      % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
      x = (1:num_rois) - groupwidth/2 + (2*i-1) * groupwidth / (2*curr_num_conts);  % Aligning error bar with individual bar
      errorbar(x, y_vals(:,i), stderr_vals(:,i), 'k', 'linestyle', 'none');
end

% label things
xlabel('fROI', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('% BOLD signal change', 'FontSize', 12, 'FontWeight', 'bold');
title(graph_title, 'FontSize', 16); 
set(gca, 'XTicklabel', roi_names);
legend(cont_names);

% Style
set(hb,'BarWidth',1);
set(gca,'YGrid', 'on');
set(gca, 'GridLineStyle','-');

% Save
save_dir = fullfile(csv_dir, 'figures');
if ~exist(save_dir, 'dir'), mkdir(save_dir); end
saveas(fig, fullfile(save_dir, save_filename), 'jpg');