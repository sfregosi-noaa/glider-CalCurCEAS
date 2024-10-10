function plotSubTimeTracks(subTime, vTk, phones, path_shp) 

% -------- MAP SETTINGS --------------------

latLim = [32.6 33.2];
lonLim = [-119.35 -118.5];

latLimWide = [32 34];
lonLimWide = [-120 -118];


% plot
figure(21)
clf

% load bathy contour data
[Z, refvec] = etopo([path_shp 'etopo1\etopo1_ice_c_i2.bin'], ...
    1, latLimWide, lonLimWide);
Z(Z >= 1) = 10;
Zy = [32:1/60:34];
Zx = [-120:1/60:-118];

levels = [-2000:200:50];

ax1 = axes;
[C, h] = contourf(ax1, Zx(1:120), Zy(1:120), Z, levels, ...
    'LineColor', repmat(0.6,1,3), 'LineWidth', 0.2);

ax2 = axes;
%"jiggle" the phones

scatter(ax2,phones.lon,phones.lat, 8,'^k')
hold on

% add glider
load('C:\Users\selene\OneDrive\projects\AFFOGATO\finDE\profiles\sg158_interpLocations.mat');
sgInterpSub = sgInterp(isbetween(sgInterp.dateTime, subTime(1), subTime(2)),:);
color_line3(sgInterpSub.longitude, sgInterpSub.latitude, ...
        datenum(sgInterpSub.dateTime), datenum(sgInterpSub.dateTime),'LineWidth', 2);

for g = 1:length(vTk)
    lat = vTk(g).nest.lat;
    lon = vTk(g).nest.lon;
    scatter(ax2, vTk(g).nest.lon,vTk(g).nest.lat,3,[vTk(g).nest.timeDN],'filled')
    % IF YOU WANT TO HAVE NUMBERS FOR EACH TRACK -- COMMENT BELOW ON
% text(lon(1),lat(1),num2str(vTk(g).trnum))
end

% link the axes and turn off top layer
linkaxes([ax1 ax2])
ax2.Visible = 'off';
ax2.XTick = [];
ax2.YTick = [];

% define colormaps
cmap = cmocean('gray');
cmap = cmap(150:255,:);
cmap = [cmap; 0 0 0];
colormap(ax1, cmap)

colormap(ax2,'parula')
caxis([datenum(subTime(1)) datenum(subTime(2))]);

% clean up because SCORE phones
set(ax1,'xticklabel',{[]},'yticklabel',{[]})
xlabel(ax1,'longitude')
ylabel(ax1,'latitude')
xticks(ax1, [])
yticks(ax1, [])
% title([]);
axis([-119.35 -118.5 32.6 33.2 ]);  %SCORE

set(ax1, 'FontSize', 14)
set([ax1, ax2], 'Position', [.18 .11 .66 .815]);

% add colorbars
cb1 = colorbar(ax1,'Position',[.1 .11 .04 .815]);
% cb1.Ticks = [datenum(subTime(1)):(10/24):datenum(subTime(2))];
% cb1.TickLabels = [0:10:90];
cb1.Label.String = 'depth [m]';
cb1.Label.FontSize = 14;
cb1.FontSize = 14;

cb2 = colorbar(ax2,'Position',[.86 .11 .04 .815]);
cb2.Ticks = [datenum(subTime(1)):(10/24):datenum(subTime(2))];
cb2.TickLabels = [0:10:90];
cb2.Label.String = 'hour';
cb2.Label.FontSize = 14;
cb2.FontSize = 14;

end
