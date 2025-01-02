% WORKFLOW_MISSIONSUMMARIES_CALCURCEAS2024.M
%	Basic mission summary table for CalCurCEAS2024 (distances, days, etc.)
%
%	Description:
%		Generate glider performance/operational summary outputs. 
% 
%       (1) General Summary. Read in gpsSurfT tables for each glider, 
%       extract start/end dates, calculate number of days deployed, 
%       distance over ground covered, number of dives, and save as summary
%       table/csv. 
%       (2) Load in PAM effort tables and also summarize total
%       recording duration and the percent of possible hours with
%       recordings
%
%	Notes
%
%   TO DO:
%
%	See also
%
%
%	Authors:
%		S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%	Updated:   2024 December 10
%
%	Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

path_repo = 'C:\Users\Selene.Fregosi\Documents\GitHub\glider-CalCurCEAS';
path_out = fullfile(path_repo, 'outputs');

missionStrs = {'sg639_CalCurCEAS_Sep2024';
	'sg679_CalCurCEAS_Aug2024';
    'sg680_CalCurCEAS_Sep2024'};

%% (1) General summary

out_vars = [{'glider', 'string'}; ...
	{'startDateTime', 'datetime'}; ...
	{'endDateTime', 'datetime'}; ...
	{'numDives', 'double'}; ...
	{'durDays', 'double'}; ...
	{'dist_km', 'double'}];

out = table('size', [0, size(out_vars,1)], ...
	'VariableNames', out_vars(:,1), 'VariableTypes', out_vars(:,2));

for m = 1:length(missionStrs)
	missionStr = missionStrs{m};
	% pull year from string
	yrStr = missionStr(end-3:end);

	% define path to 'profiles' folder with processed tables
	% path_profiles = fullfile('\\piccrpnas\crp4', ['glider_MHI_spring_' yrStr], ...
	% 	missionStr, 'piloting', 'profiles');
    path_profiles = fullfile('C:\Users\selene.fregosi\Desktop', ...
		missionStr, 'profiles');

	% load locCalcT and gpsSurfaceTable
	% these were created with agate, using workflow_processPositionalData e.g.,
	% agate-public\agate\workflows\workflow_processPositionalData_sg639_MHI_Apr2023.m
	load(fullfile(path_profiles, [missionStr '_gpsSurfaceTable.mat']))
	% don't need locCalcT yet...
	% load(fullfile(path_profiles, [missionStr '_locCalcT.mat']));

	% calculate mission summary stats
	out.glider(m) = missionStr(1:5);
	out.startDateTime(m) = gpsSurfT.startDateTime(1);
	out.endDateTime(m) = gpsSurfT.endDateTime(end);
	out.numDives(m) = max(gpsSurfT.dive);
	out.durDays(m) = round(days(out.endDateTime(m)-out.startDateTime(m)));

	% get distance for each dive
	for f = 1:height(gpsSurfT)
		gpsSurfT.dog_km(f,1) = lldistkm([gpsSurfT.endLatitude(f) gpsSurfT.endLongitude(f)], ...
			[gpsSurfT.startLatitude(f) gpsSurfT.startLongitude(f)]);
	end
	out.dist_km(m) = round(sum(gpsSurfT.dog_km), 1);
end

writetable(out, fullfile(path_out, 'missionSummaryTable.csv'));



%% (2) Include PAM summary


out_vars = [{'recDur_hr', 'double'}; ...
% 	{'possHrs', 'double'}; ...
	{'recPercent', 'string'}; ...
	{'recDays', 'string'}];

	% load pam effort tables
	load(fullfile(path_profiles, [missionStr '_pamEffort.mat']));

	% pam summary stats
	out.recDur_hr(m) = round(sum(pamMinPerHour.pam, 'omitnan')/60, 1);
% 	out.possHrs(m) = hours(out.endDateTime(m) - out.startDateTime(m));
	out.recPercent{m} = sprintf('%i%%', ...
		round(out.recDur_hr(m)/ ...
		(hours(out.endDateTime(m) - out.startDateTime(m)))*100));
	out.recDays{m} = sprintf('%.1f of %i days', ...
		sum(pamMinPerDay.pam, 'omitnan')/(60*24), ...
			sum(~isnan(pamMinPerDay.pam)));

    writetable(out, fullfile(path_out, 'missionSummaryTable_PAM.csv'));