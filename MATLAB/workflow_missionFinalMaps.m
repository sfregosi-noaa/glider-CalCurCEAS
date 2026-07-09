% WORKFLOW_MISSIONFINALMAPS.M
%	Create various final maps of WHICEAS glider mission 
%
%	Description:
%       May include ships, DASBRs, sperm whales, etc. 
%       (1) Gliders single color + ship tracks white
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
%	Updated:   19 August 2025
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% add agate to the path
addpath(genpath('C:\Users\Selene.Fregosi\Documents\MATLAB\agate'))
path_repo = 'C:\Users\Selene.Fregosi\Documents\GitHub\glider-CalCurCEAS\';

%% some global things

% set colors
col_sg639 = [1 1 0];   % yellow - inshore A
col_sg680 = [1 0 0];   % red - inshore B
col_sg679 = [1 0.4 0]; % orange - offshore
% col_dasbr = [0 1 0];	   % green - dasbrs
col_ship = [1 1 1]; % white


%% (1) Gliders single color + ship tracks white

% load any config file to get started.
cnfFile = fullfile(path_repo, 'MATLAB', 'fregosi_config_files', ...
    'agate_config_sg639_CalCurCEAS_Sep2024.cnf');
CONFIG = agate(cnfFile);

% create basemap plot
[baseFigAll] = createBasemap(CONFIG, 'bathy', 1, 'contourOn', 1, 'figNum', 28);
mapFigPosition = [60   60   900    650];
baseFigAll.Position = mapFigPosition;

% add newport label
scatterm(44.64, -124.05, 200, 'white', 'p', 'filled', 'MarkerEdgeColor', 'black');
textm(44.48, -124.05, 'Newport, OR', 'FontSize', 10, 'Color', 'white');
% add Eureka label
scatterm(40.8, -124.16, 300, 'white', 'p', 'filled', 'MarkerEdgeColor', 'black');
textm(40.8, -124.02, 'Eureka, CA', 'FontSize', 10, 'Color', 'white');

% add ship tracks
ship = readtable(fullfile(path_repo, 'secret', 'ship_effort.csv'));
% trim to just this plot for speed
trimIdx = ship.Lat >= CONFIG.map.latLim(1) & ship.Lat <= CONFIG.map.latLim(2) & ...
    ship.Lon >= CONFIG.map.lonLim(1) & ship.Lon <= CONFIG.map.lonLim(2);
shipTrim = ship(trimIdx,:);

segIDs = unique(shipTrim.SegID);
% convert to a structure
for f = 1:numel(segIDs)-1
    % Extract the subset of rows for this SegID
    tempSeg = shipTrim(shipTrim.SegID == segIDs(f), :);   % this is still a table
    shipStruct(f) = table2struct(tempSeg, 'ToScalar', true);
    shipStruct(f).SegID = segIDs(f);
end
for f = 1:numel(shipStruct)
    plotm(shipStruct(f).Lat, shipStruct(f).Lon, 'Color', col_ship, ...
        'LineWidth', 2, 'HandleVisibility', 'off');
end
% plot last one with legend name
% h(1) = plotm(shipStruct(numel(shipStruct)).Lat, shipStruct(numel(shipStruct)).Lon, ...
%     'Color', col_ship,  'LineWidth', 2, 'DisplayName', 'Ship');
% dummy line with black edge but white inside, only for legend
h(1) = plot(nan, nan, 'w', 'LineWidth', 2, 'MarkerEdgeColor','k', 'DisplayName', 'Ship');

% sg639
CONFIG = agate(fullfile(path_repo, 'MATLAB', 'fregosi_config_files', ...
    'agate_config_sg639_CalCurCEAS_Sep2024.cnf'));
[targets, ~] = readTargetsFile(CONFIG, ...
    fullfile(CONFIG.path.mission, 'targets_A_Nearshore_2024-09-30'));
plotm(targets.lat, targets.lon, 'Marker', 'o', 'MarkerSize', 4, ...
    'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0 0], 'Color', [0 0 0], ...
    'HandleVisibility', 'off');
textm(targets.lat+0.1, targets.lon-0.1, targets.name, 'FontSize', 6)

load(fullfile(CONFIG.path.mission, 'profiles', [CONFIG.gmStr '_gpsSurfaceTable.mat']));
h(2) = plotm(gpsSurfT.startLatitude, gpsSurfT.startLongitude, ...
	'Color', col_sg639(1,:), 'LineWidth', 1.5, 'DisplayName', 'SG639');

% sg679
CONFIG = agate(fullfile(path_repo, 'MATLAB', 'fregosi_config_files', ...
    'agate_config_sg679_CalCurCEAS_Aug2024.cnf'));
[targets, ~] = readTargetsFile(CONFIG,  ...
    fullfile(CONFIG.path.mission, 'targets_C_Offshore_2024-10-21_corrected'));
plotm(targets.lat, targets.lon, 'Marker', 'o', 'MarkerSize', 4, ...
    'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0 0], 'Color', [0 0 0], ...
    'HandleVisibility', 'off');
textm(targets.lat+0.1, targets.lon-0.1, targets.name, 'FontSize', 6)

load(fullfile(CONFIG.path.mission, 'profiles', [CONFIG.gmStr '_gpsSurfaceTable.mat']));
h(3) = plotm(gpsSurfT.startLatitude, gpsSurfT.startLongitude, ...
	'Color', col_sg679(1,:), 'LineWidth', 1.5, 'DisplayName', 'SG679');

% sg680
CONFIG = agate(fullfile(path_repo, 'MATLAB', 'fregosi_config_files', ...
    'agate_config_sg680_CalCurCEAS_Sep2024.cnf'));
[targets, ~] = readTargetsFile(CONFIG, ...
    fullfile(CONFIG.path.mission, 'targets_B_Nearshore_2024-10-14'));
plotm(targets.lat, targets.lon, 'Marker', 'o', 'MarkerSize', 4, ...
    'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0 0], 'Color', [0 0 0], ...
    'HandleVisibility', 'off');
textm(targets.lat+0.1, targets.lon-0.1, targets.name, 'FontSize', 6)

load(fullfile(CONFIG.path.mission, 'profiles', [CONFIG.gmStr '_gpsSurfaceTable.mat']));
h(4) = plotm(gpsSurfT.startLatitude, gpsSurfT.startLongitude, ...
	'Color', col_sg680(1,:), 'LineWidth', 1.5, 'DisplayName', 'SG680');

hLeg = legend(h, 'Location', 'east', 'FontSize', 12, 'Color', 'k', ...
    'TextColor', 'w', 'EdgeColor', 'w');

exportgraphics(gcf, fullfile(path_repo, 'maps', 'allGliders_withShip_white.png'), ...
    'Resolution', 300);



%% (2) Gliders single color + ship tracks white + DASBRs grey
