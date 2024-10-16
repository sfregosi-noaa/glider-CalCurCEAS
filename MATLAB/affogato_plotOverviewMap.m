function plotOverviewMap(path_shp,path_out) 

% -------- MAP SETTINGS --------------------

latLim = [32.45 33.15];
lonLim = [-119.4 -118.2];

latLimWide = [32 34];
lonLimWide = [-120 -117];

fontName = 'MyriadPro-Regular';

states = shaperead([path_shp 'NaturalEarthData\version5.0.0\10m_cultural\ne_10m_admin_1_states_provinces_lakes'], ...
    'UseGeoCoords', true, 'BoundingBox', [lonLimWide' latLimWide']);
statesBorder = shaperead([path_shp 'NaturalEarthData\version5.0.0\10m_cultural\ne_10m_admin_0_boundary_lines_land'], ...
    'UseGeoCoords', true);

addpath(genpath('C:\Users\selene\OneDrive\MATLAB\myFunctions'));

%% SET UP FIGURE

figure(26);
mapFig = gcf;

clf
cla reset;
ax1 = axesm('mercator', 'MapLatLim', latLim, 'MapLonLim', lonLim, ...
    'Frame', 'on');
tightmap
set(gcf, 'Position', [100 100 1000 750])

%% LOAD AND PLOT BATHYMETRY
% bathymetry
[Z, refvec] = etopo([path_shp 'etopo1\etopo1_ice_c_i2.bin'], ...
    1, latLimWide, lonLimWide);
Z(Z >= 1) = 10;
levels = [-2000:200:-50];

[C, h] = contourfm(Z, refvec, levels,'LineColor', repmat(0.6,1,3), ...
    'LineWidth', 0.2);
[C1000, h1000] = contourm(Z, refvec, -1000, 'LineColor', repmat(0.4,1,3), ...
    'LineWidth', 0.5);
[C500, h500] = contourm(Z, refvec, -500, 'LineColor', repmat(0.6,1,3), ...
    'LineWidth', 0.5);

cmap = cmocean('gray');
cmap = cmap(100:240,:);
colormap(cmap)
brighten(.6);

% v = [-2000:200:-200];
v = [-1000 -500 -200];
cl = clabelm(C, h, v, 'LabelSpacing', 400);
set(cl, 'Color', repmat(0.4,1,3), 'BackgroundColor', 'none', 'FontSize', 10);

% % contour line lables
% v = [-2200:200:-50];
% cl = clabelm(C, h, v, 'LabelSpacing', 200);
% set(cl, 'Color', repmat(0.4,1,3), 'BackgroundColor', 'none');

geoshow(states, 'FaceColor', [0.2 0.2 0.2], 'EdgeColor', [0.8 0.8 0.8])



%% CLEAN UP MAP
gridm('PLineLocation', 0.2, 'MLineLocation', 0.2);
% gridm('off')
plabel('PLabelLocation', 0.2, 'PLabelRound', -1, 'FontSize', 14);
mlabel('MLabelLocation', 0.2, 'MLabelRound', -1, ...
    'MLabelParallel', 'south', 'FontSize', 14);
na = northarrow('latitude', 33.05, 'longitude', -119.35);
scaleruler on
setm(handlem('scaleruler1'), 'RulerStyle', 'patches', ...
    'XLoc', 0.0045, 'YLoc', 0.600, 'MajorTick', [0:10:20], ...
    'MinorTick', [0:5], 'FontSize', 14);

textm(32.95, -118.4, sprintf('San Clemente\nIsland'), ...
    'Color', [0 0 0], 'FontSize', 14, 'HorizontalAlignment', 'Center')

tightmap

%% add glider
load('C:\Users\selene\OneDrive\projects\AFFOGATO\finDE\profiles\sg158_interpLocations.mat');
plotm(sgInterp.latitude, sgInterp.longitude, 'LineWidth', 3, 'Color', [0 0 0])
textm(33.05, -119, sprintf('glider\ndeployed'), ...
    'Color', [0 0 0], 'FontSize', 12)
textm(32.62, -118.39, sprintf('glider\nrecovered'), ...
    'Color', [0 0 0], 'FontSize', 12)


%% add outline for SCORE

scoreOutline = [32.88 -119.22;
    33.12 -118.86;
    32.81 -118.57;
    32.62 -118.79;
    32.88 -119.22];
    
    
plotm(scoreOutline(:,1), scoreOutline(:,2),'--', 'LineWidth', 2, 'Color', [1 1 1]);

% plotm(phones.lat,phones.lon,'.k')



%% inset
gInset = axes('position', [0.16 0.20 .22 .20], 'Visible', 'off');
ax2 = axesm('mercator', 'MapLatLim', [32.2 34.8], 'MapLonLim', [-121.5 -116.5], ...
    'Frame', 'on', 'FLineWidth',1);
plabel off; mlabel off;
setm(ax2, 'FFaceColor', [.9 .9 .9]);
% geoshow(L, 'FaceColor', [.4 .67 .78], 'EdgeColor', 'none')
geoshow(states, 'FaceColor', [0.3 0.3 0.3], 'EdgeColor', 'none')
geoshow(statesBorder, 'DisplayType', 'line', 'Color', [0 0 0]);
plotm(latLim([1 2 2 1 1]), lonLim([2 2 1 1 2]), ...
    'Color', 'k', 'LineWidth', 1.5)
tightmap





%% PRINT
% 
% print([path_out 'map_overviewMap.png'], '-dpng')
% export_fig([path_out 'map_overviewMap.eps'], '-eps', '-painters');
% 

