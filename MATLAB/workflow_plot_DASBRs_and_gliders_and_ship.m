% WORKFLOW_PLOT_DASBRS_AND_GLIDERS_AND_SHIP.M
%	Script to make a map of the DASBRs, gliders and ship colored by time
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
%	Updated:   10 January 2025
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% add agate to the path
addpath(genpath('C:\Users\Selene.Fregosi\Documents\MATLAB\agate'))
path_repo = 'C:\Users\Selene.Fregosi\Documents\GitHub\glider-CalCurCEAS\';

%% set up the basemap

% set colors
col_sg639 = [1 1 0];   % yellow - inshore A
col_sg680 = [1 0 0];   % red - inshore B
col_sg679 = [1 0.4 0]; % orange - offshore
col_dasbr = [0 1 0];	   % green - dasbrs

% load any config file to get started.
cnfFile = fullfile(path_repo, 'MATLAB', 'fregosi_config_files', ...
    'agate_config_sg639_CalCurCEAS_Sep2024.cnf');
CONFIG = agate(cnfFile);

% cannot use createBasemap because axes need to NOT be a map axis to
% colorize the trackline by a z value (time). But pull pieces from that
% function to assemble fig

% get axis limits
% CONFIG.map.latLim;
% CONFIG.map.lonLim;
latLim = [40.25 45];
lonLim = [-129 -123.1];

% rounded limits (for bathy loading) to make sure all right sizes
latLimWide = [40 48];
lonLimWide = [-130 -122];

% load bathy/contour data
CONFIG.map.bathyFile = ['C:\Users\Selene.Fregosi\Documents\GIS\etopo\' ...
    'ETOPO2022_ice_15arcsec_OR_wide.tiff'];
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

% get min/max dates from SG679 (out first)
minDatenum = min(surfSimp.time_UTC);
maxDatenum = max(surfSimp.time_UTC);

hCount = 6; % for keeping track of h objects
%% add DASBR tracks
% dasbrs = kml2struct(fullfile(path_repo, 'DASBRs', ...
% 	'CalCurCEAS_2024_DASBR_and_effort_thru_Sep26.kml'));

dasbrList = dir(fullfile(path_repo, 'DASBRs', '*.csv'));

% for f = 1:length(dasbrList)
% loop through just the ones that fall within the map axes
for f = [3, 5:15, 18]
    hCount = hCount + 1;
    dasbr = readtable(fullfile(dasbrList(f).folder, dasbrList(f).name));
    dasbr.datenum = datenum(dasbr.UTC);
    % h(6+f) = plot(dasbr.Longitude, dasbr.Latitude, 'Color', 'white', ...
    % 	'LineWidth', 1.5, 'DisplayName', 'dasbr');
    h(hCount) = color_line3(dasbr.Longitude, dasbr.Latitude, ...
        dasbr.datenum, dasbr.datenum, 'LineWidth', 1.5, ...
        'DisplayName', ['dasbr' num2str(f)]);

    text(dasbr.Longitude(1)-0.05, dasbr.Latitude(1)+0.05, ['d' num2str(f)], ...
        'FontSize', 10, 'Color', 'white')
    text(dasbr.Longitude(end)-0.05, dasbr.Latitude(end)+0.05, ['d' num2str(f)], ...
        'FontSize', 10, 'Color', 'white')
    % dasbrs(f).Number = f;
    % h(6+f) = plot(dasbrs(f).Lon, dasbrs(f).Lat, 'Color', 'white', ...
    % 	'LineWidth', 1.5, 'DisplayName', dasbrs(f).Name);

    % check date min/max against each dasbr
    if min(dasbr.datenum) < minDatenum
        minDatenum = min(dasbr.datenum);
    end
    if max(dasbr.datenum) > maxDatenum
        maxDatenum = max(dasbr.datenum);
    end
end

%% add the ship
ship = readtable(fullfile(path_repo, 'secret', 'ship_effort.csv'));
ship.datenum = datenum(ship.DateTime_UTC);

% trim to just the area we want (otherwise color axis will be off)
trimIdx = find(ship.Lat >= latLim(1) & ship.Lat <= latLim(2) & ...
    ship.Lon >= lonLim(1) & ship.Lon <= lonLim(2));
% trimIdx = unique([latIdx; lonIdx]);
shipTrim = ship(trimIdx,:);

% % loop through each segment separately so they aren't connected
% for f = 1:max(shipTrim.SegID)
%     shipSeg = shipTrim(shipTrim.SegID == f,:);
%     hCount = hCount + 1;
%     % first plot as white slightly thicker
%     line(shipSeg.Lon, shipSeg.Lat, 'Color', 'black', 'LineWidth', 2);
%     % then plot colorized
%     h(hCount) = color_line3(shipSeg.Lon, shipSeg.Lat, shipSeg.datenum, ...
%         shipSeg.datenum, 'LineWidth', 1, 'DisplayName', 'ship');
% end

% loop through each segment separately so they aren't connected
for f = 1:max(shipTrim.SegID)
    shipSeg = shipTrim(shipTrim.SegID == f,:);
    hCount = hCount + 1;
    h(hCount) = color_line3(shipSeg.Lon, shipSeg.Lat, shipSeg.datenum, ...
        shipSeg.datenum, 'LineWidth', 1.5, 'DisplayName', 'ship');
end

% check min/max dates
if min(shipTrim.datenum) < minDatenum
    minDatenum = min(shipTrim.datenum);
end
if max(shipTrim.datenum) > maxDatenum
    maxDatenum = max(shipTrim.datenum);
end

%%  add some other labels
% add newport label
scatter(-124.05, 44.64, 300, 'white', 'p', 'filled', 'MarkerEdgeColor', 'black');
text(-124.05, 44.48, 'Newport, OR', 'FontSize', 12, 'Color', 'white');
% add Eureka label
scatter(-124.16, 40.8, 300, 'white', 'p', 'filled', 'MarkerEdgeColor', 'black');
text(-124.02, 40.8, 'Eureka, CA', 'FontSize', 12, 'Color', 'white');

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

xlim(lonLim)
ylim(latLim)
% set the axis ratio.
dLon = 111*cosd(40);
ratio = dLon/111;
pbaspect(ax1, [ratio 1 1])
pbaspect(ax2, [ratio 1 1])

% add colorbar
% Position has to be manually set so first set size then cb posit
set(gcf, 'Position', [40 50 920 940]);
cb2 = colorbar(ax2, 'Position', [.85 .11 .04 .815]);
% set up ticks/labels to be readable
colTicks = linspace(minDatenum, maxDatenum, 10); % 10 ticks
colTickLabels = datestr(colTicks, 'mmm dd');
cb2.Ticks = colTicks;
cb2.TickLabels = colTickLabels;
cb2.Label.String = 'date';
cb2.Direction = 'reverse';
% cb2.Label.FontSize = 14;
% cb2.FontSize = 14;

%% Save all glider map

% set position/size
set(gcf, 'Position', [40 50 920 940]);
exportgraphics(gcf, fullfile(path_repo, 'maps', 'DASBRs_and_gliders_and_ship_coloredByTime.png'), ...
    'Resolution', 300);
















