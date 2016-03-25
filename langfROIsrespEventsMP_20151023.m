
experiments(1)=struct(...
    'name','loc',...% language localizer 
    'pwd1','/mindhive/evlab/u/mekline/Desktop/EventsMP/Data',...  % path to the data directory
    'pwd2','firstlevel_langlocSN',... % path to the first-level analysis directory for the lang localizer
    'data',{{'FED_20150720a_3T2','FED_20150820a_3T2','FED_20150823_3T2'}}); % subject IDs
experiments(2)=struct(...
    'name','crit',...% non-lang expt
    'pwd1','/mindhive/evlab/u/mekline/Desktop/EventsMP/Data',...
    'pwd2','firstlevel_EventsMP',...  % path to the first-level analysis directory for the critical task
    'data',{{'FED_20150720a_3T2','FED_20150820a_3T2','FED_20150823_3T2'}});

localizer_spmfiles={};
for nsub=1:length(experiments(1).data),
    localizer_spmfiles{nsub}=fullfile(experiments(1).pwd1,experiments(1).data{nsub},experiments(1).pwd2,'SPM.mat');
end

effectofinterest_spmfiles={};
for nsub=1:length(experiments(2).data),
    effectofinterest_spmfiles{nsub}=fullfile(experiments(2).pwd1,experiments(2).data{nsub},experiments(2).pwd2,'SPM.mat');
end

ss=struct(...
    'swd','/mindhive/evlab/u/mekline/Desktop/EventsMP/Toolbox/langfROIsrespEventsMP_20151023_RESULTS',...   % output directory
    'EffectOfInterest_spm',{effectofinterest_spmfiles},...
    'Localizer_spm',{localizer_spmfiles},...
	  'EffectOfInterest_contrasts',{{'SameAll','SameMan','SamePath','SameAg','DiffAll','Cont','DiffAll-Cont','SameMan-Cont','SamePath-Cont', 'SameAg-Cont','SameAll-Cont','All-Cont','DiffAll-SameAll','DiffAll-SameMan','DiffAll-SamePath','DiffAll-SameAg', 'SameMan-SameAll','SamePath-SameAll','SameAg-SameAll'  }},...    % contrasts of interest; here you just indicate the names of the four conditions
    'Localizer_contrasts',{{'S-N'}},...                     % localizer contrast 
    'Localizer_thr_type','percentile-ROI-level',...
    'Localizer_thr_p',.1,... 
    'type','mROI',...                                       % can be 'GcSS', 'mROI', or 'voxel'
    'ManualROIs','/users/evelina9/fMRI_PROJECTS/ROIS/LangParcels_n220_LH.img',...
    'model',1,...                                           % can be 1 (one-sample t-test), 2 (two-sample t-test), or 3 (multiple regression)
    'estimation','OLS',...
    'overwrite',true,...
    'ask','missing');                                       % can be 'none' (any missing information is assumed to take default values), 'missing' (any missing information will be asked to the user), 'all' (it will ask for confirmation on each parameter)
ss=spm_ss_design(ss);                                          % see help spm_ss_design for additional information
ss=spm_ss_estimate(ss);




