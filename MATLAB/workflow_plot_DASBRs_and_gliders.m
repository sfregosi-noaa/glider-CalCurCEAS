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
%	Updated:        15 October 2024
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% add agate to the path
% addpath(genpath('C:\Users\Selene.Fregosi\Documents\MATLAB\agate'))
% path_repo = 'C:\Users\Selene.Fregosi\Documents\GitHub\glider-CalCurCEAS\';

addpath(genpath('C:\Users\selene\Documents\MATLAB\agate'))
path_repo = 'C:\Users\selene\Documents\GitHub\glider-CalCurCEAS\';
%% set up the basemap

% set colors
col_sg639 = [1 1 0];   % yellow - inshore A
col_sg680 = [1 0 0];   % red - inshore B
col_sg679 = [1 0.4 0]; % orange - offshore
dasbrs = [0 1 0];	   % green - dasbrs

% load any config file to get started.
cnfFile = fullfile(path_repo, 'MATLAB', 'fregosi_config_files', ...
    'agate_config_sg639_CalCurCEAS_Sep2024.cnf');
CONFIG = agate(cnfFile);

% cannot use createBasemap because axes need to NOT be a map axis to
% colorize the trackline by a z value (time). But pull pieces from it

% get axis limits
CONFIG.map.latLim;
CONFIG.map.lonLim;
% rounded limits (for bathy loading) to make sure all right sizes
latLimWide = [40 48];
lonLimWide = [-130 -122];

% load bathy/contour data
CONFIG.map.bathyFile = 'C:\Users\selene\onedrive\GIS\etopo\ETOPO2022_ice_15arcsec_OR_wide.tiff';
	[Z, refvec] = readgeoraster(CONFIG.map.bathyFile, 'OutputType', 'double', ...
		'CoordinateSystemType', 'geographic');
	[Z, refvec] = geocrop(Z, refvec, latLimWide, lonLimWide);
% this is upsidedown for some reason. flip it
Z = flipud(Z);

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

%% add glider tracks
ax2 = axes;
hold on; 

% sg639
% targetsSimple = fullfile(CONFIG.path.mission, 'targets_A_Nearshore_2024-09-30');
targetsSimple = fullfile(path_repo, 'mission_planning', 'targets_A_Nearshore_2024-09-30');
[targets, ~] = readTargetsFile(CONFIG, targetsSimple);
h(1) = plot(targets.lon, targets.lat, 'Marker', 'o', 'MarkerSize', 4, ...
	'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0 0], 'Color', [0 0 0], ...
	'HandleVisibility', 'off');
text(targets.lon-0.1, targets.lat+0.1, targets.name, 'FontSize', 6)
% pull properly formatted locations for pp
load(fullfile(CONFIG.path.mission, 'flightStatus', ['diveTracking_' ...
	CONFIG.glider '.mat']));
surfSimp = ppToGPSSurf(CONFIG, pp);
writetable(surfSimp, fullfile(path_repo, 'maps', 'sg639_CalCurCEAS_Sep24_simpleSurfaceGPS.csv'))
h(2) = color_line3(surfSimp.longitude, surfSimp.latitude, ...
	surfSimp.time_UTC, surfSimp.time_UTC, 'LineWidth', 1.5, ...
	'DisplayName', CONFIG.glider);
% colormap(hot);

% sg680
cnfFile = fullfile(path_repo, 'MATLAB', 'fregosi_config_files', ...
    'agate_config_sg680_CalCurCEAS_Sep2024.cnf');
CONFIG = agate(cnfFile);
% targetsSimple = fullfile(CONFIG.path.mission, 'targets_B_Nearshore_2024-10-14');
targetsSimple = fullfile(path_repo, 'mission_planning', 'targets_B_Nearshore_2024-10-14');
[targets, ~] = readTargetsFile(CONFIG, targetsSimple);
h(3) = plot(targets.lon, targets.lat, 'Marker', 'o', 'MarkerSize', 4, ...
	'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0 0], 'Color', [0 0 0], ...
	'HandleVisibility', 'off');
text(targets.lon-0.1, targets.lat+0.1, targets.name, 'FontSize', 6)
% pull properly formatted locations for pp
load(fullfile(CONFIG.path.mission, 'flightStatus', ['diveTracking_' ...
	CONFIG.glider '.mat']));
surfSimp = ppToGPSSurf(CONFIG, pp);
writetable(surfSimp, fullfile(path_repo, 'maps', 'sg680_CalCurCEAS_Aug24_simpleSurfaceGPS.csv'))
h(4) = color_line3(surfSimp.longitude, surfSimp.latitude, ...
	surfSimp.time_UTC, surfSimp.time_UTC, 'LineWidth', 1.5, ...
	'DisplayName', CONFIG.glider);
% colormap(hot);

% sg679
cnfFile = fullfile(path_repo, 'MATLAB', 'fregosi_config_files', ...
    'agate_config_sg679_CalCurCEAS_Aug2024.cnf');
CONFIG = agate(cnfFile);
% targetsSimple = fullfile(CONFIG.path.mission, 'targets_C_Offshore_2024-08-15');
targetsSimple = fullfile(path_repo, 'mission_planning', 'targets_C_Offshore_2024-08-15');
[targets, ~] = readTargetsFile(CONFIG, targetsSimple);
h(5) = plot(targets.lon, targets.lat, 'Marker', 'o', 'MarkerSize', 4, ...
	'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0 0], 'Color', [0 0 0], ...
	'HandleVisibility', 'off');
text(targets.lon-0.1, targets.lat+0.1, targets.name, 'FontSize', 6)
% pull properly formatted locations for pp
load(fullfile(CONFIG.path.mission, 'flightStatus', ['diveTracking_' ...
	CONFIG.glider '.mat']));
surfSimp = ppToGPSSurf(CONFIG, pp);
% remove the bad fixes for SG679
surfSimp(244:245,:) = [];
writetable(surfSimp, fullfile(path_repo, 'maps', 'sg679_CalCurCEAS_Sep24_simpleSurfaceGPS.csv'))
h(6) = color_line3(surfSimp.longitude, surfSimp.latitude, ...
	surfSimp.time_UTC, surfSimp.time_UTC, 'LineWidth', 1.5, ...
	'DisplayName', CONFIG.glider);
% colormap(hot);


%% add DASBR tracks
% dasbrs = kml2struct(fullfile(path_repo, 'DASBRs', ...
% 	'CalCurCEAS_2024_DASBR_and_effort_thru_Sep26.kml'));

dasbrList = dir(fullfile(path_repo, 'DASBRs', '*.csv'));


for f = 1:length(dasbrList)
    dasbr = readtable(fullfile(dasbrList(f).folder, dasbrList(f).name));
	dasbrs(f).Number = f;
	h(6+f) = plot(dasbrs(f).Lon, dasbrs(f).Lat, 'Color', 'white', ...
		'LineWidth', 1.5, 'DisplayName', dasbrs(f).Name);

end
%% link the axes and turn off top layer
linkaxes([ax1 ax2])
ax2.Visible = 'off';
% ax2.XTick = [];
% ax2.YTick = [];

% define colormaps
cmap = cmocean('gray');
cmap = cmap(150:255,:);
cmap = [cmap; 0 0 0];
colormap(ax1, cmap)

colormap(ax2,'jet')
% caxis([datenum(subTime(1)) datenum(subTime(2))]);




%% Save all glider map

exportgraphics(gcf, fullfile(path_repo, 'maps', 'DASBRs_and_gliders.png'), ...
	'Resolution', 300);
















