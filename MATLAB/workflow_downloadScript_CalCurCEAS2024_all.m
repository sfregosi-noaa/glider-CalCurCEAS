% WORKFLOW_DOWNLOADSCRIPT_CALCURCEAS2024_ALL.M
%	Download basestation files and generate piloting/monitoring plots
%      **For all three gliders**
%
%	Description:
%		This script provides a workflow that may be useful during an active
%		mission to assist with piloting. The idea is that the entire script
%		can be run after a glider surfacing to automate the process of
%		checking on the glider status
%
%       It has the following sections:
%       (1) any new basestation files to the local computer, including .nc,
%       .log, .dat, cmdfiles, pdos any acoustic .eng or detection files
%       (2) extracts useful data from local basestation .nc and .log files
%       and compiles into a summary table, variable 'pp', and saves to a
%       .xlsx and .mat
%       (3) generates several piloting monitoring plots and saves as .pngs
%       (4) prints out calculated mission speeds and estimates of total
%       duration
%
%       It requires an agate configuration file during agate initialization
%
%	Notes
%
%	See also
%
%
%	Authors:
%		S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%	Created with MATLAB ver.: 9.13.0.2166757 (R2022b) Update 4
%
%	FirstVersion: 	01 June 2023
%	Updated:        15 September 2024
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add agate to the path
addpath(genpath('C:\Users\Selene.Fregosi\Documents\MATLAB\agate'))
path_repo = 'C:\Users\Selene.Fregosi\Documents\GitHub\glider-CalCurCEAS\';

% specify planned recovery date and time
recovery = '2024-10-24 09:00:00';
recTZ = 'America/Los_Angeles';

%% set up an All glider map

% set colors
col_sg639 = [1 1 0];   % yellow - inshore A 
col_sg680 = [1 0 0];   % red - inshore B
col_sg679 = [1 0.4 0]; % orange - offshore
 
% load any config file to get started.
cnfFile = ['C:\Users\Selene.Fregosi\Documents\GitHub\glider-CalCurCEAS\' ...
	'MATLAB\fregosi_config_files\agate_config_sg639_CalCurCEAS_Sep2024.cnf'];
CONFIG = agate(cnfFile);

% create basemap plot
[baseFigAll] = createBasemap(CONFIG, 'bathy', 1, 'contourOn', 0, 'figNum', 20);
mapFigPosition = [60   60   900    650];
baseFigAll.Position = mapFigPosition;

% add newport label
scatterm(44.64, -124.05, 200, 'white', 'p', 'filled', 'MarkerEdgeColor', 'black');
textm(44.48, -124.05, 'Newport, OR', 'FontSize', 10, 'Color', 'white');
% add Eureka label
scatterm(40.8, -124.16, 300, 'white', 'p', 'filled', 'MarkerEdgeColor', 'black');
textm(40.8, -124.02, 'Eureka, CA', 'FontSize', 10, 'Color', 'white');


%% SG639
fprintf('\n\nDownloading/processing SG639 ... \n')
% initialize agate
cnfFile = ['C:\Users\Selene.Fregosi\Documents\GitHub\glider-CalCurCEAS\' ...
	'MATLAB\fregosi_config_files\agate_config_sg639_CalCurCEAS_Sep2024.cnf'];
CONFIG = agate(cnfFile);

% define flightStatus path
path_status = fullfile(CONFIG.path.mission, 'flightStatus'); % where to store output plots/tables

% (1) download files from the basestation
downloadBasestationFiles(CONFIG);

% (2) extract piloting parameters
% create piloting parameters (pp) table from downloaded basestation files
pp = extractPilotingParams(CONFIG, fullfile(CONFIG.path.mission, 'basestationFiles'), ...
	fullfile(CONFIG.path.mission, 'flightStatus'), 1);
% change last argument from 0 to 1 to load existing data and append new dives/rows

% save it to the default location as .mat and .xlsx
save(fullfile(CONFIG.path.mission, 'flightStatus', ['diveTracking_' ...
	CONFIG.glider '.mat']), 'pp');
writetable(pp, fullfile(path_status, ['diveTracking_' CONFIG.glider '.xlsx']));

% (3) generate and save plots

% print map **SLOWISH** - figNumList(1)
% loaded targets file (interpolated waypoints)
targetsLoaded = fullfile(CONFIG.path.mission, 'targets');
% simple targets file (waypoints only at 'turns')
targetsSimple = fullfile(CONFIG.path.mission, 'targets_A_Nearshore_2024-09-14');
plotGliderPath_etopo(CONFIG, pp, targetsSimple, CONFIG.map.bathyFile);

% add newport label
scatterm(44.64, -124.05, 200, 'white', 'p', 'filled', 'MarkerEdgeColor', 'black');
textm(44.48, -124.05, 'Newport, OR', 'FontSize', 10, 'Color', 'white');
% add Eureka label
scatterm(40.8, -124.16, 300, 'white', 'p', 'filled', 'MarkerEdgeColor', 'black');
textm(40.8, -124.02, 'Eureka, CA', 'FontSize', 10, 'Color', 'white');

% save it as a .fig (for zooming)
savefig(fullfile(path_status, [CONFIG.glider '_map.fig']))
% and as a .png (for quick/easy view)
exportgraphics(gca, fullfile(path_status, [CONFIG.glider '_map.png']), ...
    'Resolution', 300)

% (4) print mission summary
% print errors reported on most recent dive
printErrors(CONFIG, size(pp,1), pp)
% print mission/recovery stats
tm = printTravelMetrics(CONFIG, pp, fullfile(CONFIG.path.mission, 'targets'), 1);
tm = printRecoveryMetrics(CONFIG, pp, fullfile(CONFIG.path.mission, 'targets'), ...
recovery, recTZ, 1);

% (5) Add to ALL glider map
set(0, 'currentfigure', baseFigAll);
[targets, ~] = readTargetsFile(CONFIG, targetsSimple); 
h(1) = plotm(targets.lat, targets.lon, 'Marker', 'o', 'MarkerSize', 4, ...
	'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0 0], 'Color', [0 0 0], ...
	'HandleVisibility', 'off');
textm(targets.lat+0.1, targets.lon-0.1, targets.name, 'FontSize', 10)
% pull properly formatted locations for pp
[lat, lon] = ppToGPSSurf(CONFIG, pp);
h(2) = plotm(lat, lon, 'Color', col_sg639, 'LineWidth', 1.5, ...
	'DisplayName', CONFIG.glider);


%% SG679
fprintf('\n\nDownloading/processing SG679 ... \n')
% initialize agate
cnfFile = ['C:\Users\Selene.Fregosi\Documents\GitHub\glider-CalCurCEAS\' ...
	'MATLAB\fregosi_config_files\agate_config_sg679_CalCurCEAS_Aug2024.cnf'];
CONFIG = agate(cnfFile);

% define flightStatus path
path_status = fullfile(CONFIG.path.mission, 'flightStatus'); % where to store output plots/tables

% (1) download files from the basestation
downloadBasestationFiles(CONFIG);

% (2) extract piloting parameters
% create piloting parameters (pp) table from downloaded basestation files
pp = extractPilotingParams(CONFIG, fullfile(CONFIG.path.mission, 'basestationFiles'), ...
	fullfile(CONFIG.path.mission, 'flightStatus'), 1);
% change last argument from 0 to 1 to load existing data and append new dives/rows

% save it to the default location as .mat and .xlsx
save(fullfile(CONFIG.path.mission, 'flightStatus', ['diveTracking_' ...
	CONFIG.glider '.mat']), 'pp');
writetable(pp, fullfile(path_status, ['diveTracking_' CONFIG.glider '.xlsx']));

% (3) generate and save plots
% print map **SLOWISH** - figNumList(1)
% loaded targets file (interpolated waypoints)
targetsLoaded = fullfile(CONFIG.path.mission, 'targets');
% simple targets file (waypoints only at 'turns')
targetsSimple = fullfile(CONFIG.path.mission, 'targets_C_Offshore_2024-08-15');
plotGliderPath_etopo(CONFIG, pp, targetsSimple, CONFIG.map.bathyFile);

% add newport label
scatterm(44.64, -124.05, 200, 'white', 'p', 'filled', 'MarkerEdgeColor', 'black');
textm(44.48, -124.05, 'Newport, OR', 'FontSize', 10, 'Color', 'white');
% add Eureka label
scatterm(40.8, -124.16, 300, 'white', 'p', 'filled', 'MarkerEdgeColor', 'black');
textm(40.8, -124.02, 'Eureka, CA', 'FontSize', 10, 'Color', 'white');

% save it as a .fig (for zooming)
savefig(fullfile(path_status, [CONFIG.glider '_map.fig']))
% and as a .png (for quick/easy view)
exportgraphics(gca, fullfile(path_status, [CONFIG.glider '_map.png']), ...
    'Resolution', 300)

% (4) print mission summary
% print errors reported on most recent dive
printErrors(CONFIG, size(pp,1), pp)
% print mission/recovery stats
tm = printTravelMetrics(CONFIG, pp, fullfile(CONFIG.path.mission, 'targets'), 1);
tm = printRecoveryMetrics(CONFIG, pp, fullfile(CONFIG.path.mission, 'targets'), ...
recovery, recTZ, 1);

% (5) Add to ALL glider map
set(0, 'currentfigure', baseFigAll);
[targets, ~] = readTargetsFile(CONFIG, targetsSimple); 
h(1) = plotm(targets.lat, targets.lon, 'Marker', 'o', 'MarkerSize', 4, ...
	'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0 0], 'Color', [0 0 0], ...
	'HandleVisibility', 'off');
textm(targets.lat+0.1, targets.lon-0.1, targets.name, 'FontSize', 10)
% pull properly formatted locations for pp
[lat, lon] = ppToGPSSurf(CONFIG, pp);
% remove the bad fix for SG679
lat(244:245) = [];
lon(244:245) = [];
h(2) = plotm(lat, lon, 'Color', col_sg679, 'LineWidth', 1.5, ...
	'DisplayName', CONFIG.glider);

%% SG680
fprintf('\n\nDownloading/processing SG680 ... \n')
% initialize agate
cnfFile = ['C:\Users\Selene.Fregosi\Documents\GitHub\glider-CalCurCEAS\' ...
	'MATLAB\fregosi_config_files\agate_config_sg680_CalCurCEAS_Sep2024.cnf'];
CONFIG = agate(cnfFile);

% define flightStatus path
path_status = fullfile(CONFIG.path.mission, 'flightStatus'); % where to store output plots/tables

% (1) download files from the basestation
downloadBasestationFiles(CONFIG);

% (2) extract piloting parameters
% create piloting parameters (pp) table from downloaded basestation files
pp = extractPilotingParams(CONFIG, fullfile(CONFIG.path.mission, 'basestationFiles'), ...
	fullfile(CONFIG.path.mission, 'flightStatus'), 1);
% change last argument from 0 to 1 to load existing data and append new dives/rows

% save it to the default location as .mat and .xlsx
save(fullfile(CONFIG.path.mission, 'flightStatus', ['diveTracking_' ...
	CONFIG.glider '.mat']), 'pp');
writetable(pp, fullfile(path_status, ['diveTracking_' CONFIG.glider '.xlsx']));

% (3) generate and save plots
% print map **SLOWISH** - figNumList(1)
% loaded targets file (interpolated waypoints)
targetsLoaded = fullfile(CONFIG.path.mission, 'targets');
% simple targets file (waypoints only at 'turns')
targetsSimple = fullfile(CONFIG.path.mission, 'targets_B_Nearshore_2024-09-14');
plotGliderPath_etopo(CONFIG, pp, targetsSimple, CONFIG.map.bathyFile);

% add newport label
scatterm(44.64, -124.05, 200, 'white', 'p', 'filled', 'MarkerEdgeColor', 'black');
textm(44.48, -124.05, 'Newport, OR', 'FontSize', 10, 'Color', 'white');
% add Eureka label
scatterm(40.8, -124.16, 300, 'white', 'p', 'filled', 'MarkerEdgeColor', 'black');
textm(40.8, -124.02, 'Eureka, CA', 'FontSize', 10, 'Color', 'white');

% save it as a .fig (for zooming)
savefig(fullfile(path_status, [CONFIG.glider '_map.fig']))
% and as a .png (for quick/easy view)
exportgraphics(gca, fullfile(path_status, [CONFIG.glider '_map.png']), ...
    'Resolution', 300)

% (4) print mission summary
% print errors reported on most recent dive
printErrors(CONFIG, size(pp,1), pp)
% print mission/recovery stats
tm = printTravelMetrics(CONFIG, pp, fullfile(CONFIG.path.mission, 'targets'), 1);
tm = printRecoveryMetrics(CONFIG, pp, fullfile(CONFIG.path.mission, 'targets'), ...
recovery, recTZ, 1);

% (5) Add to ALL glider map
set(0, 'currentfigure', baseFigAll);
[targets, ~] = readTargetsFile(CONFIG, targetsSimple); 
h(1) = plotm(targets.lat, targets.lon, 'Marker', 'o', 'MarkerSize', 4, ...
	'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0 0], 'Color', [0 0 0], ...
	'HandleVisibility', 'off');
textm(targets.lat+0.1, targets.lon-0.1, targets.name, 'FontSize', 10)
% pull properly formatted locations for pp
[lat, lon] = ppToGPSSurf(CONFIG, pp);
h(2) = plotm(lat, lon, 'Color', col_sg680, 'LineWidth', 1.5, ...
	'DisplayName', CONFIG.glider);

%% Save all glider map

set(0, 'currentfigure', baseFigAll);
exportgraphics(gca, fullfile(path_repo, 'maps', 'allGliders_progressMap.png'), ...
    'Resolution', 300);
















