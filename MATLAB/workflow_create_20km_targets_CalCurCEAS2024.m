% WORKFLOW_CREATE_20KM_TARGETS for CalCurCEAS 2024 Glider Missions
%	Mission-ready targets with waypoints no more than 20 km apart
%
%   Used Google Earth to input additonal waypoints between long transects
%   so no waypoints are more than 20 km apart (to help glider stay on
%   path). Used the Measure Path tool in Google Earth to trace over the
%   existing trackline but added a vertex every ~20 km. Saved this as the
%   same name but with `20kmSpacing` in the name. 
%
%   Created a 'names' text file that just lists all waypoint names, using
%   the original prefix/number names (e.g., AN01, AN02, ... RECV) and then
%   putting intermediate names between for all new waypoints that use
%   prefix/numbers (e.g., AN01, ANaa, ANab, AN02, ANba, ANbb, RECV)
%
%   Then, used this script to generate a new targets file.
%
%   No plots/maps made because with this many waypoints they are very busy!
% 
%	See also
%
%	Authors:
%		S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%	FirstVersion: 	22 August 2024
%	Updated:        14 September 2024
%
%	Created with MATLAB ver.: 9.13.0.2166757 (R2022b) Update 4
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
path_repo = 'C:\Users\Selene.Fregosi\Documents\GitHub\glider-CalCurCEAS';
addpath(genpath('C:\Users\Selene.Fregosi\Documents\MATLAB\agate'))


%% SG639 - Track A - Nearshore
CONFIG = agate(fullfile(path_repo, 'MATLAB', 'fregosi_config_files', ...
	'agate_config_sg639_CalCurCEAS_Sep2024.cnf'));

% (1) Generate targets file from Google Earth path saved as .kmml
kmlFile = fullfile(path_repo, 'mission_planning',  ...
	'A_Nearshore_2024-09-30_withMidpoints.kml');
radius = 2000;

% original targets file was created with prefix based naming but need to
% use file-based method here to preserve 'primary' waypoint names and just
% fill in the rest with intermediate names
% use a text file with list of waypoint names; will prompt to select .txt
targetsOut = makeTargetsFile(CONFIG, kmlFile, 'file', radius);

%% SG680 - Track B - Nearshore
CONFIG = agate(fullfile(path_repo, 'MATLAB', 'fregosi_config_files', ...
	'agate_config_sg680_CalCurCEAS_Sep2024.cnf'));

% (1) Generate targets file from Google Earth path saved as .kmml
kmlFile = fullfile(path_repo, 'mission_planning', ...
	'B_Nearshore_2024-09-14_withMidpoints.kml');
radius = 2000;

% original targets file was created with prefix based naming but need to
% use file-based method here to preserve 'primary' waypoint names and just
% fill in the rest with intermediate names
% use a text file with list of waypoint names; will prompt to select .txt
targetsOut = makeTargetsFile(CONFIG, kmlFile, 'file', radius);


%% SG679 - Track C - Offshore
CONFIG = agate(fullfile(path_repo, 'MATLAB', 'agate_config_sg679_CalCurCEAS_Aug2024.cnf'));

% (1) Generate targets file from Google Earth path saved as .kmml
kmlFile = fullfile(path_repo, 'mission_planning', ...
	'C_Offshore_2024-08-14_withMidpoints.kml');
radius = 2000;

% original targets file was created with prefix based naming but need to
% use file-based method here to preserve 'primary' waypoint names and just
% fill in the rest with intermediate names
% use a text file with list of waypoint names; will prompt to select .txt
targetsOut = makeTargetsFile(CONFIG, kmlFile, 'file', radius);


