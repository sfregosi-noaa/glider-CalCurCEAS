% WORKFLOW_PROCESSWISPR_TESTING.M
%	Workflow to test different DAT to FLAC conversion and decimation approaches
%
%	Description:
%		Following finding bugs in previous versions of convertWispr and
%		decimate (that did not account for reference voltage and 24-bit
%		sampling), this script runs some final tests to compare the updated
%		functions. 
%
%       More detail: https://docs.google.com/document/d/1IWv6gnWxNAQfPrPPZ0gfGWl6l4DJ31MYO0dc37gJW8M
%
%	Authors:
%		S. Fregosi <selene.fregosi@gmail.com> <https://github.com/sfregosi>
%
%	Updated:       22 April 2025
%
%	Created with MATLAB ver.: 24.2.0.2740171 (R2024b) Update 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('C:\Users\Selene.Fregosi\Documents\MATLAB\agate'))
% addpath(genpath('C:\Users\selene.fregosi\Documents\MATLAB\wispr3'))
path_repo = 'C:\Users\Selene.Fregosi\Documents\GitHub\glider-CalCurCEAS';

% test data is 198 files (6.6 GB) from sg639 on 240925 from 00:00 to 03:32
% initialize agate
% will prompt to select a config file -> select empty/blank config so
% convert process will prompt to select input and output folders
CONFIG = agate; 

%% convert!
% will prompt to select input and output folders

% to flac
convertWispr(CONFIG, 'showProgress', true, 'outExt', '.flac');
% converted all 198 files, size 4.78 GB, took 8 mins (72% compression)

% to wav
convertWispr(CONFIG, 'showProgress', true, 'outExt', '.wav');
% converted all 198 files, size 6.6 GB, took 8 mins

%% decimate

% decimate FLACs with native/int32 method
decimateDir(500);
% took 3.5 mins, 11.5 MB

% decimate FLACs with default/double method
decimateDir_double(500);
% took 1.5 mins, 11.5 MB

