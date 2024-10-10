% WORKFLOW_PLOT_DASBRS_AND_GLIDERS.M
%	Script to make a map of the DASBRs and the gliders, colorized by time
%
%	Description:
%
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
%	Updated:        09 October 2024
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% add agate to the path
addpath(genpath('C:\Users\Selene.Fregosi\Documents\MATLAB\agate'))
path_repo = 'C:\Users\Selene.Fregosi\Documents\GitHub\glider-CalCurCEAS\';

%% set up the basemap

% set colors
col_sg639 = [1 1 0];   % yellow - inshore A
col_sg680 = [1 0 0];   % red - inshore B
col_sg679 = [1 0.4 0]; % orange - offshore
dasbrs = [0 1 0];	   % green - dasbrs

% load any config file to get started.
cnfFile = ['C:\Users\Selene.Fregosi\Documents\GitHub\glider-CalCurCEAS\' ...
	'MATLAB\fregosi_config_files\agate_config_sg639_CalCurCEAS_Sep2024.cnf'];
CONFIG = agate(cnfFile);

% cannot use createBasemap because axes need to NOT be a map axis to
% colorize the trackline by a z value (time). But pull pieces from it

% get axis limits
CONFIG.map.latLim
CONFIG.map.lonLim
% rounded limits (for bathy loading) to make sure all right sizes
latLimWide = [40 46];
lonLimWide = [-130 -122];

% load bathy/contour data
	[Z, refvec] = readgeoraster(CONFIG.map.bathyFile, 'OutputType', 'double', ...
		'CoordinateSystemType', 'geographic');
	[Z, refvec] = geocrop(Z, refvec, latLimWide, lonLimWide);

	Z(Z >= 10) = 100;
	% define axes limits (can't use refvec in non-map axes)
	Zy = [latLimWide(1):1/60/4:latLimWide(2)];
	Zx = [lonLimWide(1):1/60/4:lonLimWide(2)];

	% add contours (modify these!)
	levels = [-6000:500:50];

	% plot
figure(21)
clf

% contours
ax1 = axes;
[C, h] = contourf(ax1, Zx(1:size(Z,2)), Zy(1:size(Z,1)), Z, levels, ...
    'LineColor', repmat(0.6,1,3), 'LineWidth', 0.2);

% add glider tracks
ax2 = axes;
hold on; 

% sg639
targetsSimple = fullfile(CONFIG.path.mission, 'targets_A_Nearshore_2024-09-30');
[targets, ~] = readTargetsFile(CONFIG, targetsSimple);
h(1) = plot(targets.lon, targets.lat, 'Marker', 'o', 'MarkerSize', 4, ...
	'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0 0], 'Color', [0 0 0], ...
	'HandleVisibility', 'off');
text(targets.lon-0.1, targets.lat+0.1, targets.name, 'FontSize', 10)
% pull properly formatted locations for pp
load(fullfile(CONFIG.path.mission, 'flightStatus', ['diveTracking_' ...
	CONFIG.glider '.mat']));
[lat, lon] = ppToGPSSurf(CONFIG, pp);
h(2) = plot(lon, lat, 'Color', col_sg639, 'LineWidth', 1.5, ...
	'DisplayName', CONFIG.glider);




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

%% Plot each glider's most current track (
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
targetsSimple = fullfile(CONFIG.path.mission, 'targets_A_Nearshore_2024-09-30');
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
% Dive 121-123 had 5 bad GPS readings so dist over ground calc is bad
% manually set and saved based on 12 km btwn end 121 and end 123. 
% only have to run once or again if pp is not preloaded. 
% pp.dog_km(122) = 6;
% pp.dog_km(123) = 6;

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
















