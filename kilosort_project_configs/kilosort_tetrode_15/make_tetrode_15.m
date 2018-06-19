%  create a channel map file

Nchannels = 60;
chanMap = [1:1:Nchannels]; % all the used channels in ascending order. remapping is done in remap_config variable
connected = true(Nchannels, 1);

%remove all the channels that are not used from the remap_config list
remap_config = [2 3 4 9 1 10 11 32 12 13 30 31 14 15 16 29 17 18 19 28 20 21 26 27 22 23 24 25 ... 
    37 38 39 40 34 35 36 41 33 42 43 64 44 45 62 63 46 47 48 61 49 50 51 60 52 53 58 59 54 55 56 57 ];

xcoords   = repmat([1 2 3 4]', 1, Nchannels/4);
xcoords   = xcoords(:);
ycoords   = repmat(1:Nchannels/4, 4, 1);
ycoords   = ycoords(:);
kcoords   = repmat(1:Nchannels/4, 4, 1);
kcoords   = kcoords(:);


save(fullfile(ops.outputFolder, 'chanMap.mat'), ...
    'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'remap_config')
%%

% kcoords is used to forcefully restrict templates to channels in the same
% channel group. An option can be set in the master_file to allow a fraction 
% of all templates to span more channel groups, so that they can capture shared 
% noise across all channels. This option is

% ops.criterionNoiseChannels = 0.2; 

% if this number is less than 1, it will be treated as a fraction of the total number of clusters

% if this number is larger than 1, it will be treated as the "effective
% number" of channel groups at which to set the threshold. So if a template
% occupies more than this many channel groups, it will not be restricted to
% a single channel group. 