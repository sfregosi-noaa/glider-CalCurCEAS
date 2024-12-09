% WORKFLOW_PROCESSWISPR_CALCURCEAS2024.M
%	Workflow for processing raw WISPR data into .flac, CalCurCEAS 2024
%
%	Description:
%		Detailed description here, please
%
%	Notes
%
%	See also
%
%
%	Authors:
%		S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%	FirstVersion: 	04 December 2024
%	Updated:
%
%	Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('C:\Users\Selene.Fregosi\Documents\MATLAB\agate'))
addpath(genpath('C:\Users\selene.fregosi\Documents\MATLAB\wispr3'))
path_repo = 'C:\Users\Selene.Fregosi\Documents\GitHub\glider-CalCurCEAS';

missionStrs = {'sg639_CalCurCEAS_Sep2024';
	'sg679_CalCurCEAS_Aug2024';
    'sg680_CalCurCEAS_Sep2024'};

mtpNum = 1; % mission to process - UPDATE THIS TO RUN THROUGH EACH GLIDER
mtp = missionStrs{mtpNum};

% initialize agate
% make sure configuration file now has updated WISPR Settings section
% (not required during mission so may not be set yet)
CONFIG = agate(fullfile(path_repo, 'MATLAB', 'fregosi_config_files', ...
    ['agate_config_' mtp '.cnf']));


% convert!
convertWisprToFlac(CONFIG, 'showProgress', true, 'outExt', '.flac');