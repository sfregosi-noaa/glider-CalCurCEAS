% WORKFLOW_SPLITPROFILES.M
%	Split each dive into individual descent and ascent profiles
%
%	Description:
%		Extract the start and end time of each descent and ascent
%
%	Notes
%
%	See also
%
%
%	Authors:
%		S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%	Updated:   2026 January 15
%
%	Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

userName = 'pam_user';
addpath(genpath(fullfile('C:\Users', userName, 'Documents', 'MATLAB', 'agate')));
path_repo = fullfile('C:\Users\', userName, 'Documents', 'GitHub', 'glider-CalCurCEAS');

% sg639
load(fullfile('P:\glider', 'sg639_CalCurCEAS_Sep2024', 'piloting', 'profiles', ...
    'sg639_CalCurCEAS_Sep2024_locCalcT_pam.mat'));
load(fullfile('P:\glider', 'sg639_CalCurCEAS_Sep2024', 'piloting', 'profiles', ...
    'sg639_CalCurCEAS_Sep2024_gpsSurfaceTable.mat'));

% sg680
load(fullfile('P:\glider', 'sg680_CalCurCEAS_Sep2024', 'piloting', 'profiles', ...
    'sg680_CalCurCEAS_Sep2024_locCalcT_pam.mat'))
load(fullfile('P:\glider', 'sg680_CalCurCEAS_Sep2024', 'piloting', 'profiles', ...
    'sg680_CalCurCEAS_Sep2024_gpsSurfaceTable.mat'))

% "fast" version that uses a vertical speed threshold
% [des, asc] = splitProfilesFast(locCalcT, threshold);

% more detailed (final version) based on max depth
profileT = splitProfiles(gpsSurfT, locCalcT);

% plot check
figure(82); 
plot(locCalcT.time, -locCalcT.depth, 'k');
hold on;
xline(profileT.startTime, ':m');
xline(profileT.endTime, '--c');
xline(profileT.midTime, '-.g');
hold off;

figure(83); 
plot(locCalcT.longitude, locCalcT.latitude, 'k');
hold on;
scatter(profileT.startLongitude, profileT.startLatitude, 'm');
scatter(profileT.endLongitude, profileT.endLatitude, 'c^');
scatter(profileT.midLongitude, profileT.midLatitude, 'sg');
hold off;

% write to csv
% % sg639
% save('P:\glider\sg639_CalCurCEAS_Sep2024\piloting\profiles\sg639_CalCurCEAS_Sep2024_splitProfileTable.mat', 'profileT');
% writetable(profileT, 'P:\glider\sg639_CalCurCEAS_Sep2024\piloting\profiles\sg639_CalCurCEAS_Sep2024_splitProfileTable.csv');

% sg680
save('P:\glider\sg639_CalCurCEAS_Sep2024\piloting\profiles\sg680_CalCurCEAS_Sep2024_splitProfileTable.mat', 'profileT');
writetable(profileT, 'P:\glider\sg639_CalCurCEAS_Sep2024\piloting\profiles\sg680_CalCurCEAS_Sep2024_splitProfileTable.csv');


% add in trimming by PAM on/off
nProf = height(profileT);

% set as dupliacte of regular one
profileT.pamCoverage = true(nProf, 1);
profileT.pamStartTime = profileT.startTime;
profileT.pamStartDateTime = profileT.startDateTime;
profileT.pamStartLatitude = profileT.startLatitude;
profileT.pamStartLongitude = profileT.startLongitude;
profileT.pamEndTime = profileT.endTime;
profileT.pamEndDateTime = profileT.endDateTime;
profileT.pamEndLatitude = profileT.endLatitude;
profileT.pamEndLongitude = profileT.endLongitude;

% now adjust descent starts and ascent ends by PAM status
for f = 1:nProf
    % pull out this profile indices and check for pam
	inProf = locCalcT.time >= profileT.startTime(f) & ...
		locCalcT.time <= profileT.endTime(f);
	pamOn = inProf & locCalcT.pam == 1;

	if ~any(pamOn)
		profileT.pamCoverage(f) = false;
		continue
	end

	switch profileT.phase(f)
		case 'descent'
			idxOn = find(pamOn, 1, 'first');
			profileT.pamStartTime(f) = locCalcT.time(idxOn);
			profileT.pamStartDateTime(f) = locCalcT.dateTime(idxOn);
			profileT.pamStartLatitude(f) = locCalcT.latitude(idxOn);
			profileT.pamStartLongitude(f) = locCalcT.longitude(idxOn);
		case 'ascent'
			idxOn = find(pamOn, 1, 'last');
			profileT.pamEndTime(f) = locCalcT.time(idxOn);
			profileT.pamEndDateTime(f) = locCalcT.dateTime(idxOn);
			profileT.pamEndLatitude(f) = locCalcT.latitude(idxOn);
			profileT.pamEndLongitude(f) = locCalcT.longitude(idxOn);
	end
end

% any dives with no PAM? set to NAs
profileT.pamStartTime(~profileT.pamCoverage) = NaN;
profileT.pamStartDateTime(~profileT.pamCoverage) = NaT;
profileT.pamStartLatitude(~profileT.pamCoverage) = NaN;
profileT.pamStartLongitude(~profileT.pamCoverage) = NaN;
profileT.pamEndTime(~profileT.pamCoverage) = NaN;
profileT.pamEndDateTime(~profileT.pamCoverage) = NaT;
profileT.pamEndLatitude(~profileT.pamCoverage) = NaN;
profileT.pamEndLongitude(~profileT.pamCoverage) = NaN;

% recalculate mid points
% calculate pam mid times and mid locations for each phase
profileT.pamMidTime = profileT.pamStartTime + ...
	(profileT.pamEndTime - profileT.pamStartTime)/2;
profileT.pamMidDateTime = profileT.pamStartDateTime + ...
	(profileT.pamEndDateTime - profileT.pamStartDateTime)/2;
profileT.pamMidLatitude = profileT.pamStartLatitude + ...
	(profileT.pamEndLatitude - profileT.pamStartLatitude)/2;
profileT.pamMidLongitude = profileT.pamStartLongitude + ...
	(profileT.pamEndLongitude - profileT.pamStartLongitude)/2;

% check stuff
% what's the average time diff btwn
for i = 1:nProf
    switch profileT.phase(i)
        case 'descent'
            profileT.diff(i) = profileT.pamStartTime(i) - profileT.startTime(i);
        case 'ascent'
            profileT.diff(i) = profileT.endTime(i) - profileT.pamEndTime(i);
    end
end
profileT.diff = profileT.diff*(86400/60); % put in minutes
mean(profileT.diff, 'omitnan')
% about 4 mins

% plot check
figure(82); clf
plot(locCalcT.time, -locCalcT.depth, 'k');
hold on;
% color points by pam status for a visual double-check
scatter(locCalcT.time(locCalcT.pam == 1), -locCalcT.depth(locCalcT.pam == 1), ...
	4, 'g', 'filled');
scatter(locCalcT.time(locCalcT.pam == 0), -locCalcT.depth(locCalcT.pam == 0), ...
	4, [0.6 0.6 0.6], 'filled');
% original max-depth-based bounds
xline(profileT.startTime, ':m');
xline(profileT.endTime, '--c');
xline(profileT.midTime, '-.g');
% pam-trimmed bounds
xline(profileT.pamStartTime, ':r', 'LineWidth', 1.2);
xline(profileT.pamEndTime, '--b', 'LineWidth', 1.2);
xline(profileT.pamMidTime, '--g', 'LineWidth', 1.2);
hold off;
legend('depth trace', 'pam on', 'pam off', 'Location', 'best');
title('black = depth | m/c/g = orig start/end/mid | r/b = pam start/end');

figure(83); clf
plot(locCalcT.longitude, locCalcT.latitude, 'k');
hold on;
scatter(profileT.startLongitude, profileT.startLatitude, 'm');
scatter(profileT.endLongitude, profileT.endLatitude, 'c^');
scatter(profileT.midLongitude, profileT.midLatitude, 'sg');
scatter(profileT.pamStartLongitude, profileT.pamStartLatitude, 'r', 'filled');
scatter(profileT.pamEndLongitude, profileT.pamEndLatitude, 'b^', 'filled');
scatter(profileT.pamMidLongitude, profileT.pamMidLatitude, 'sg', 'filled');
hold off;
legend('track', 'start', 'end', 'mid', 'pam start', 'pam end', 'pam mid', 'Location', 'best');

% save and write to csv
% sg639
% save(['P:\glider\sg639_CalCurCEAS_Sep2024\piloting\profiles\', ...
%     'sg639_CalCurCEAS_Sep2024_splitProfileTable_pam.mat'], 'profileT');
% writetable(profileT, ['P:\glider\sg639_CalCurCEAS_Sep2024\piloting\profiles\', ...
%     'sg639_CalCurCEAS_Sep2024_splitProfileTable_pam.csv']);

% sg680
save(['P:\glider\sg680_CalCurCEAS_Sep2024\piloting\profiles\', ...
    'sg680_CalCurCEAS_Sep2024_splitProfileTable_pam.mat'], 'profileT');
writetable(profileT, ['P:\glider\sg680_CalCurCEAS_Sep2024\piloting\profiles\', ...
    'sg680_CalCurCEAS_Sep2024_splitProfileTable_pam.csv']);
