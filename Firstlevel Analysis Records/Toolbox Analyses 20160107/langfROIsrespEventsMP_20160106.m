
%There are two places to specify info! Right here, and below at the struct specification
%ADDITIONALLY, before running you should make sure that you are using the correct version of the
%SPM toolbox if it is something other than the standard. At the bottom I am putting key paths to 
%stuff I know about.

%On run, we habitually set Minimal ROI-level overlap to 0 and Explicit masking to None.  Those should be
%specified somewhere below instead!!

%Pre-run checklist
% firstlevel loc folder
% first level crit folder
% subjects
% OUTPUT FOLDER
% loc and crit contrasts
% ROIs

%%%
%Specify the first level data that will be used for the loc (find the space) and crit (measure it)

experiments(1)=struct(...
    'name','loc',...% language localizer 
    'pwd1','/mindhive/evlab/u/mekline/Desktop/EventsMP/Data',...  % path to the data directory
    'pwd2','firstlevel_langlocSN',... % path to the first-level analysis directory for the lang localizer
    'data',{{'FED_20150720a_3T2','FED_20150820a_3T2','FED_20150823_3T2','FED_20151118a_3T1','FED_20151119a_3T1','FED_20151120b_3T1'}}); % subject IDs
experiments(2)=struct(...
    'name','crit',...% non-lang expt
    'pwd1','/mindhive/evlab/u/mekline/Desktop/EventsMP/Data',...
    'pwd2','firstlevel_EventsMP',...  % path to the first-level analysis directory for the critical task
    'data',{{'FED_20150720a_3T2','FED_20150820a_3T2','FED_20150823_3T2','FED_20151118a_3T1','FED_20151119a_3T1','FED_20151120b_3T1'}});
%%%

localizer_spmfiles={};
for nsub=1:length(experiments(1).data),
    localizer_spmfiles{nsub}=fullfile(experiments(1).pwd1,experiments(1).data{nsub},experiments(1).pwd2,'SPM.mat');
end

effectofinterest_spmfiles={};
for nsub=1:length(experiments(2).data),
    effectofinterest_spmfiles{nsub}=fullfile(experiments(2).pwd1,experiments(2).data{nsub},experiments(2).pwd2,'SPM.mat');
end

%%%
%Specify the analysis that you will run.  Definitely include: 
%'swd' output folder for the results -DONT FORGET TO CHANGE THIS!!
%'EffectOfInterest_contrasts' - Probably a lot.  All or anything of the first-level cons that were calculated before
%'Localizer_contrasts' - Usually just one! How are you finding the subject-specific region.
%'Localizer_thr_type' and 'Localizer_thr_p' Various choices here: 
%   For top 10% of voxels found in the parcels: 'percentile-ROI-level' and .1
%   For top N voxels: 'Nvoxels-ROI-level' and 50 (for 50 voxels) (check this)
%'type' and 'ManualROIs' - the parcels to find the subject-specific activations in!  Usually we
%set 'type'='mROI', and then specify the path to the parcel you want to use. It will be an img file.

ss=struct(...
    'swd','/mindhive/evlab/u/mekline/Desktop/EventsMP/Toolbox/langfROIsrespEventsMP_20160106_RESULTS',...   % output directory
    'EffectOfInterest_spm',{effectofinterest_spmfiles},...
    'Localizer_spm',{localizer_spmfiles},...
	  'EffectOfInterest_contrasts',{{'SameAll','SameMan','SamePath','SameAg','DiffAll','Cont','DiffAll-Cont','SameMan-Cont','SamePath-Cont', 'SameAg-Cont','SameAll-Cont','All-Cont','DiffAll-SameAll','DiffAll-SameMan','DiffAll-SamePath','DiffAll-SameAg', 'SameMan-SameAll','SamePath-SameAll','SameAg-SameAll'  }},...    % contrasts of interest
    'Localizer_contrasts',{{'S-N'}},...                     % localizer contrast 
    'Localizer_thr_type','percentile-ROI-level',...
    'Localizer_thr_p',.1,... 
    'type','mROI',...                                       % can be 'GcSS', 'mROI', or 'voxel'
    'ManualROIs','/users/evelina9/fMRI_PROJECTS/ROIS/LangParcels_n220_LH.img',...
    'model',1,...                                           % can be 1 (one-sample t-test), 2 (two-sample t-test), or 3 (multiple regression)
    'estimation','OLS',...
    'overwrite',true,...
    'ask','missing');                                       % can be 'none' (any missing information is assumed to take default values), 'missing' (any missing information will be asked to the user), 'all' (it will ask for confirmation on each parameter)

%%%
%mk addition! Add the version of spm that you intend to use right here!
addpath('/users/evelina9/fMRI_PROJECTS/spm_ss_vE/') %The usual one
%addpath('users/evelina9/fMRI_PROJECTS/spm_ss_Jun18-2015/') %This one has the N-top-voxels options (?)

%%%
%...and now SPM actually runs!
ss=spm_ss_design(ss);                                          % see help spm_ss_design for additional information
ss=spm_ss_estimate(ss);

%%%
%USEFUL INFO!
%%%

% Parcels 
% '/users/evelina9/fMRI_PROJECTS/ROIS/LangParcels_n220_LH.img' - the standard Lang parcels, use contrast {{'S-N'}} 
% '/users/evelina9/fMRI_PROJECTS/ROIS/MDfROIs.img' - the standard MD parcels, use contrast {{'H-E'}}
% 



