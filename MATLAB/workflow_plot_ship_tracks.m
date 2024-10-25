% WORKFLOW_PLOT_SHIP_TRACKS.M
%	One-line description here, please
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
%	FirstVersion: 	16 October 2024
%	Updated:
%
%	Created with MATLAB ver.: 9.10.0.1739362 (R2021a) Update 5
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath('C:\Users\selene\Documents\MATLAB\agate'))
path_repo = 'C:\Users\selene\Documents\GitHub\glider-CalCurCEAS\';

cnfFile = fullfile(path_repo, 'MATLAB', 'fregosi_config_files', ...
    'agate_config_sg639_CalCurCEAS_Sep2024_pseudorca.cnf');
CONFIG = agate(cnfFile);

% colors
% col_ship = [1 1 0.5]; % yellow
col_ship = [0.6 0 0.6]; % purple


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


% addship tracks
ship = kml2struct(fullfile(path_repo, 'DASBRs', 'CalCurCEAS_effort_through20241014.kml'));
% readgeotable(fullfile(path_repo, 'DASBRs', 'CalCurCEAS_effort_through20241014.kml'));

for f = 1:length(ship)
plotm(ship(f).Lat, ship(f).Lon, 'Color', col_ship, 'LineWidth', 2);
end

exportgraphics(gcf, fullfile(path_repo, 'maps', 'ship_tracks_purple_thick.png'), ...
	'Resolution', 300);



