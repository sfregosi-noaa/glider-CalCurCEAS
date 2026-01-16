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

addpath(genpath('C:\Users\Selene.Fregosi\Documents\MATLAB\agate'))
path_repo = 'C:\Users\Selene.Fregosi\Documents\GitHub\glider-CalCurCEAS';

% sg639
load('C:\Users\selene.fregosi\Desktop\sg639_CalCurCEAS_Sep2024\profiles\sg639_CalCurCEAS_Sep2024_locCalcT.mat')
load('C:\Users\selene.fregosi\Desktop\sg639_CalCurCEAS_Sep2024\profiles\sg639_CalCurCEAS_Sep2024_gpsSurfaceTable.mat')

% sg680
load('C:\Users\selene.fregosi\Desktop\sg680_CalCurCEAS_Sep2024\profiles\sg680_CalCurCEAS_Sep2024_locCalcT.mat')
load('C:\Users\selene.fregosi\Desktop\sg680_CalCurCEAS_Sep2024\profiles\sg680_CalCurCEAS_Sep2024_gpsSurfaceTable.mat')

% "fast" version that uses a vertical speed threshold
[des, asc] = splitProfilesFast(locCalcT, threshold);

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
% sg639
save('S:\glider_CalCurCEAS_fall_2024\sg639_CalCurCEAS_Sep2024\piloting\profiles\sg639_CalCurCEAS_Sep2024_splitProfileTable.mat', 'profileT');
writetable(profileT, 'S:\glider_CalCurCEAS_fall_2024\sg639_CalCurCEAS_Sep2024\piloting\profiles\sg639_CalCurCEAS_Sep2024_splitProfileTable.csv');

% sg680
save('S:\glider_CalCurCEAS_fall_2024\sg680_CalCurCEAS_Sep2024\piloting\profiles\sg680_CalCurCEAS_Sep2024_splitProfileTable.mat', 'profileT');
writetable(profileT, 'S:\glider_CalCurCEAS_fall_2024\sg680_CalCurCEAS_Sep2024\piloting\profiles\sg680_CalCurCEAS_Sep2024_splitProfileTable.csv');
