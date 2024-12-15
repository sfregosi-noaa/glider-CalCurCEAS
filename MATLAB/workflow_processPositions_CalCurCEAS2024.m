% WORKFLOW_PROCESSPOSITIONS_CALCURCEAS2024.M
%	Process glider positional data post CalCurCEAS 2024 mission.
%
%	Description:
%		Based off example workflow_processPositionalData, but works for
%		multiple missions
%
%       gpsSurfT - gps surface table
%       locCalcT - calculated location table (dead reckoned track)
%       Both tables are saved as .mat and .csv
%
%       It requires an agate configuration file during agate initialization
%
%   Sections
%       (0) Initialization - defines the mission strings, sets which
%       mission to process, and initializes agate with proper config file
%       (1) Extract positional data - create `locCalcT` and `gpsSurfT`
%       tables with glider timing, positions, speed, etc
%       (2) Simplify positional data into smaller .csvs for to include with
%       as metadata when sending sound files to NCEI
%       (3) Plot sound speed profiles
%       (4) PAM status get more accurate info on recording times and
%       durations from the files themselves, and update positional data
%       tables with a flag for PAM on or off at each sample or dive
%       (5) Extract location data for each individual PAM file
%       (6) Summarize acoustic effort by minutes, hours, and days
%
%	Notes
%
%	See also WORKFLOW_PROCESSPOSITIONALDATA
%
%
%	Authors:
%		S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%	Updated:        02 December 2024
%
%	Created with MATLAB ver.: 9.13.0.2166757 (R2022b) Update 4
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('C:\Users\Selene.Fregosi\Documents\MATLAB\agate'))
path_repo = 'C:\Users\Selene.Fregosi\Documents\GitHub\glider-CalCurCEAS';

missionStrs = {'sg639_CalCurCEAS_Sep2024';
    'sg679_CalCurCEAS_Aug2024';
    'sg680_CalCurCEAS_Sep2024'};

mtpNum = 2; % mission to process
mtp = missionStrs{mtpNum};

% initialize agate
CONFIG = agate(fullfile(path_repo, 'MATLAB', 'fregosi_config_files', ...
    ['agate_config_' mtp '.cnf']));

%% (1) Extract positional data
% This step can take some time to process through all .nc files

[gpsSurfT, locCalcT] = extractPositionalData(CONFIG, 1);
% 0 in plotOn argument will not plot 'check' figures, but change to 1 to
% plot basic figures for output checking

% manually fix the bad inshore fix for SG679 on Dives 122/123
if strcmp(mtp, 'sg679_CalCurCEAS_Aug2024')

    % remove end lat/lon of D122, start lat/lon D123
    gpsSurfT.endLatitude(122) = NaN;
    gpsSurfT.endLongitude(122) = NaN;
    gpsSurfT.startLatitude(123) = NaN;
    gpsSurfT.startLongitude(123) = NaN;

    % remove all calculated locs for D123
    badIdx = find(locCalcT.dive == 123);
    locCalcT.latitude(badIdx) = NaN;
    locCalcT.longitude(badIdx) = NaN;
    locCalcT.latitude_gsm(badIdx) = NaN;
    locCalcT.longitude_gsm(badIdx) = NaN;

end
% save as .mat and .csv
save(fullfile(CONFIG.path.mission, 'profiles', ...
    [CONFIG.gmStr, '_gpsSurfaceTable.mat']), 'gpsSurfT');
writetable(gpsSurfT,fullfile(CONFIG.path.mission, 'profiles', ...
    [CONFIG.gmStr, '_gpsSurfaceTable.csv']))

save(fullfile(CONFIG.path.mission, 'profiles', ...
    [CONFIG.gmStr, '_locCalcT.mat']),'locCalcT');
writetable(locCalcT, fullfile(CONFIG.path.mission, 'profiles', ...
    [CONFIG.gmStr, '_locCalcT.csv']));

%% (2) Simplify positional data for packaging for NCEI

% gps surface table - load file if var doesn't exist
if ~exist('gpsSurfT', 'var')
    load(fullfile(CONFIG.path.mission, 'profiles', ...
        [CONFIG.gmStr, '_gpsSurfaceTable.mat']));
end
keepCols = {'dive', 'startDateTime', 'startLatitude', 'startLongitude', ...
    'endDateTime', 'endLatitude', 'endLongitude'};
gpsSurfSimp = gpsSurfT(:,keepCols);
newNames = {'DiveNumber', 'StartDateTime_UTC', 'StartLatitude', 'StartLongitude', ...
    'EndDateTime_UTC', 'EndLatitude', 'EndLongitude'};
gpsSurfSimp.Properties.VariableNames = newNames;
writetable(gpsSurfSimp, fullfile(CONFIG.path.mission, 'profiles', ...
    [CONFIG.gmStr, '_GPSSurfaceTableSimple.csv']))

% location table - load file if var doesn't exist
if ~exist('locCalcT', 'var')
    load(fullfile(CONFIG.path.mission, 'profiles', ...
        [CONFIG.gmStr, '_locCalcT.mat']))
end
keepCols = {'dateTime', 'latitude', 'longitude', 'depth', 'dive'};
locCalcSimp = locCalcT(:,keepCols);
newNames = {'DateTime_UTC', 'Latitude', 'Longitude', 'Depth_m', 'DiveNumber'};
locCalcSimp.Properties.VariableNames = newNames;
writetable(locCalcSimp, fullfile(CONFIG.path.mission, 'profiles', ...
    [CONFIG.gmStr, '_CalculatedLocationTableSimple.csv']))

% environmental data
if ~exist('locCalcT', 'var')
    load(fullfile(CONFIG.path.mission, 'profiles', ...
        [CONFIG.gmStr, '_locCalcT.mat']))
end
keepCols = {'dive', 'dateTime', 'latitude', 'longitude', 'depth', ...
    'temperature', 'salinity', 'soundVelocity', 'density'};
locCalcEnv = locCalcT(:,keepCols);
newNames = {'DiveNumber', 'DateTime_UTC', 'Latitude', 'Longitude', 'Depth_m', ...
    'Temperature_C', 'Salinity_PSU', 'SoundSpeed_m_s', 'Density_kg_m3', };
locCalcEnv.Properties.VariableNames = newNames;
writetable(locCalcEnv, fullfile(CONFIG.path.mission, 'profiles', ...
    [CONFIG.gmStr, '_CTD.csv']))

%% (3) Plot sound speed profile
% load locCalcT if not already loaded
if ~exist('locCalcT', 'var')
    load(fullfile(CONFIG.path.mission, 'profiles', ...
        [CONFIG.gmStr, '_locCalcT.mat']))
end

plotSoundSpeedProfile(CONFIG, locCalcT);
exportgraphics(gcf, fullfile(CONFIG.path.mission, 'profiles', ...
    [CONFIG.gmStr, '_SSP.png']), 'resolution', 150)
exportgraphics(gcf, fullfile(CONFIG.path.mission, 'profiles', ...
    [CONFIG.gmStr, '_SSP.pdf']), 'ContentType', 'vector')

%% (4) Extract acoustic system status for each dive and sample time

if ~exist('locCalcT', 'var')
    load(fullfile(CONFIG.path.mission, 'profiles', ...
        [CONFIG.gmStr, '_locCalcT.mat']))
end
if ~exist('gpsSurfT', 'var')
    load(fullfile(CONFIG.path.mission, 'profiles', ...
        [CONFIG.gmStr, '_gpsSurfaceTable.mat']));
end

% longterm goal - make faster by using .eng files rather than reading
% individual sound files?

[gpsSurfT, locCalcT, pamFiles, pamByDive] = extractPAMStatus(CONFIG, ...
    gpsSurfT, locCalcT);

fprintf('Total PAM duration: %.2f hours\n', hours(sum(pamFiles.dur, 'omitnan')));

% save updated positional tables and pam tables
save(fullfile(CONFIG.path.mission, 'profiles', ...
    [CONFIG.gmStr, '_pamFiles.mat']), 'pamFiles');
save(fullfile(CONFIG.path.mission, 'profiles', ...
    [CONFIG.gmStr, '_pamByDive.mat']), 'pamByDive');

save(fullfile(CONFIG.path.mission, 'profiles', ...
    [CONFIG.gmStr, '_locCalcT_pam.mat']), 'locCalcT');
writetable(locCalcT, fullfile(CONFIG.path.mission, 'profiles', ...
    [CONFIG.glider '_' CONFIG.mission '_locCalcT_pam.csv']));

save(fullfile(CONFIG.path.mission, 'profiles', [CONFIG.glider '_' ...
    CONFIG.mission '_gpsSurfaceTable_pam.mat']), 'gpsSurfT');
writetable(gpsSurfT, fullfile(CONFIG.path.mission, 'profiles', ...
    [CONFIG.gmStr, '_gpsSurfaceTable_pam.csv']));


%% (5) Extract positional data for each sound file

if ~exist('locCalcT', 'var')
    load(fullfile(CONFIG.path.mission, 'profiles', ...
        [CONFIG.gmStr, '_locCalcT.mat']))
end
if ~exist('pamFiles', 'var')
    load(fullfile(CONFIG.path.mission, 'profiles', ...
        [CONFIG.gmStr, '_pamFiles.mat']))
end

timeBuffer = 180;
pamFilePosits = extractPAMFilePosits(pamFiles, locCalcT, timeBuffer);

% save it
save(fullfile(CONFIG.path.mission, 'profiles', ...
    [CONFIG.gmStr, '_pamFilePosits.mat']), 'pamFilePosits');
writetable(pamFilePosits, fullfile(CONFIG.path.mission, 'profiles', ...
    [CONFIG.gmStr, '_pamFilePosits.csv']));


%% (6) Summarize acoustic effort

if ~exist('gpsSurfT', 'var')
    load(fullfile(CONFIG.path.mission, 'profiles', ...
        [CONFIG.gmStr, '_gpsSurfaceTable.mat']))
end
if ~exist('pamFiles', 'var')
    load(fullfile(CONFIG.path.mission, 'profiles', ...
        [CONFIG.gmStr, '_pamFiles.mat']))
end
if ~exist('pamByDive', 'var')
    load(fullfile(CONFIG.path.mission, 'profiles', ...
        [CONFIG.gmStr, '_pamByDive.mat']))
end

% create byMin, minPerHour, minPerDay matrices
[pamByMin, pamMinPerHour, pamMinPerDay, pamHrPerDay] = calcPAMEffort(...
    CONFIG, gpsSurfT, pamFiles, pamByDive);

% save it
save(fullfile(CONFIG.path.mission, 'profiles', ...
    [CONFIG.gmStr, '_pamEffort.mat']), ...
    'pamByMin', 'pamMinPerHour', 'pamMinPerDay', 'pamHrPerDay');
