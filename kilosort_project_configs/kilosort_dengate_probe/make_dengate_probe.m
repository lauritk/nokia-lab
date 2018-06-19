%  create a channel map file

Nchannels = 24;
connected = true(Nchannels, 1);
chanMap = [ 1:1:Nchannels ];

xcoords = [0 -13 13 -20 20 -27 27 -34 ...
		   200 187 213 180 220 173 227 166 ...
		   400 387 413 380 420 373 427 366 ];
		   
ycoords = [0 20 40 60 80 100 120 140 ...
		   0 20 40 60 80 100 120 140 ...
		   0 20 40 60 80 100 120 140 ];
		   
kcoords = [1 1 1 1 1 1 1 1 ...
		   2 2 2 2 2 2 2 2 ...
		   3 3 3 3 3 3 3 3  ];


save(fullfile(ops.outputFolder, 'chanMap.mat'), ...
    'chanMap','connected', 'xcoords', 'ycoords', 'kcoords')
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