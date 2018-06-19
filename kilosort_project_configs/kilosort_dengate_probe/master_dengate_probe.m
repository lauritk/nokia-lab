% default options are in parenthesis after the comment

addpath(genpath('C:\MyTemp\KiloSort-master-ephy-fixed')) % path to kilosort folder
addpath(genpath('C:\MyTemp\npy-matlab-master')) % path to npy-matlab scripts


pathToYourConfigFile = 'C:\MyTemp\kilosort_dengate_probe'; % take from Github folder and put it somewhere else (together with the master_file)

% Load configurations
run(fullfile(pathToYourConfigFile, 'config_dengate_probe.m'))

% Generate chanMap
run(fullfile(pathToYourConfigFile, 'make_dengate_probe.m'))

tic; % start timer

% Converting openEphys to raw binary. Comment out, if not needed.
if strcmp(ops.datatype , 'openEphys')
   ops = convertOpenEphysToRawBInary(ops);  % convert data, only for OpenEphys
end

% Apply CAR and "median trace correction" if enabled (see.
% https://github.com/cortex-lab/neuropixels/wiki/Recommended_preprocessing)
if ops.applyCAR
    median_trace = applyCARtoDat(ops.fbinary, ops.NchanTOT, ops.outputFolder);
    [~, name, ~] = fileparts(ops.fbinary);
    ops.fbinary = fullfile(ops.outputFolder, sprintf('%s_CAR.dat', name));
end

% Initializing GPU will take some time, so don't panic. 
if ops.GPU     
    gpuDevice(1); % initialize GPU (will erase any existing GPU arrays)
end

% Processing
[rez, DATA, uproj] = preprocessData(ops); % preprocess data and extract spikes for initialization
rez                = fitTemplates(rez, DATA, uproj);  % fit templates iteratively
rez                = fullMPMU(rez, DATA);% extract final spike times (overlapping extraction)

% save results as matlab variables to file
save(fullfile(ops.outputFolder,  'rez.mat'), 'rez', '-v7.3');

% save python results file for Phy
rezToPhy(rez, ops.outputFolder);

% Run post-hoc merge and save to different file
% rezToPhy overrides previous save, so be careful!
% rez = merge_posthoc2(rez);
% save(fullfile(ops.outputFolder,  'rez_post_hoc_merged.mat'), 'rez', '-v7.3');
% rezToPhy(rez, ops.outputFolder);

% remove temporary file
delete(ops.fproc);
toc
%%