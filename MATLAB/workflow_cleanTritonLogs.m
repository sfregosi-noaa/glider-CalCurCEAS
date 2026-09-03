% WORKFLOW_CLEANTRITONLOGS.M
%	Clean Triton logs for event summary reports
%
%	Description:
%	   Clean up a Triton log to be used as an event table to make a PAMpal
%	   AcousticStudy object to feed into an Acoustic Event Summary Report,
%	   specifically this is for the CalCurCEAS 2024 glider mission. 
% 
%      This calls the agate function collapseTritonLog. Events that have 
%      multiple signal types (e.g., clicks and whistles) are compressed to
%      a single event. Events that have less than 15 mins (specified by 
%      eventGap) between them are merged into single events. Events with
%      different species ID that overlap in time are not merged/collapsed.
%
%	Notes
%
%	See also COLLAPSETRITONLOG
%
%
%	Authors:
%		S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%	Updated:   2026 September 3
%
%	Created with MATLAB ver.: 24.2.0.3212159 (R2024b) Update 9
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% add agate, set paths
baseDir = getenv('USERPROFILE');   % C:\Users\Selene.Fregosi locally

addpath(genpath(fullfile(baseDir, 'Documents', 'MATLAB', 'agate')));
path_logs_in = 'Q:\CalCurCEAS_fall_2024\analysis\triton_logs';
path_repo = 'C:\Users\pam_user\Documents\GitHub\glider-CalCurCEAS';

%% set glider, log names
glider = 'sg639'; mission = 'CalCurCEAS_Sep2024'; 
% glider = 'sg680'; mission = 'CalCurCEAS_Sep2024';
% glider = 'sg679'; mission = 'CalCurCEAS_Aug2024'; 

% logFile = fullfile(path_logs_in, [glider '_' mission '_Pm_mw.xlsx']);
logFile = fullfile(path_repo, 'cetaceans', 'triton_log_derived', ...
    [glider '_' mission '_Pm_mw_sfReview.xlsx']);
eventGap = 15;

%% collapse log events

[tl, tlm] = collapseTritonLog(logFile, eventGap);

% save as mat file
[~, lfName, ~] = fileparts(logFile);
save(fullfile(path_repo, 'cetaceans', 'triton_log_derived', ...
    [lfName '_collapsed.mat']), 'tl', 'tlm');

%% simplify format for PAMpal

% create new simplified table for PAMpal
tls = tritonLogToEventLog(tlm, glider);
writetable(tls, fullfile(path_repo, 'cetaceans', 'triton_log_products', ...
    [lfName '_collapsed_forPAMpal.csv']));

% add the eventID to tlm and re-save just in case
tlm.eventID = tls.id;  % carry the eventID back onto tlm for cross-referencing
save(fullfile(path_repo, 'cetaceans', 'triton_log_derived', ...
    [lfName '_collapsed.mat']), 'tl', 'tlm');
