function make_buzsakiProbe4x8ChannelMap(fpath)
% Makes channel map for Buzsaki probe 4x8 ( ATLAS Neuroengineering E32B-20-S4-L10-200).
% Mapping is made for ordered channels.
%
% VERSION: 20.12.2017 by Lauri Kantola, University of Jyväskylä.
%
% Probe specs:
%
% - 4 individual shanks with 8 electrodes. One shank is 87 mu (micrometer) wide and
%	the pitch between shank is 200 um. Numbering of the shanks is from left to right
%	(shanks tip pointing up) 1, 2, 3, 4. First electrode in shank is at the tip of the
%	shank and last electrode is last at the bottom. See electrode order below.
%
%
%					 ___
%					/ *1\
%				   /*2	 \
%				  /	    *3\
%				 / *4	   \
%				|		 *5 |
%			    | *6		|
%				|		  *7|
%				|*8         | 
%
%
% - Vertical distance (y) between electrodes from center to center is 20 um.
% - Horizontal distance (x) between electrodes from center to center is 7 um,
%	but distance between electrode 1 and 2 is 13 um, as it is between electrode 1 and 3.


% Channel order. If your channels are not in order, change this accordingly and Kilosort
% reorder your channels.
chanMap = [1 2 3 4 5 6 7 8 ...
		   9 10 11 12 13 14 15 16 ...
		   17 18 19 20 21 22 23 24 ...
		   25 26 27 28 29 30 31 32 ];

% Select channels that are used (connected) and are not dead or non-ephys data. Use 0 or false
% for the unselected and 1 or true for selected.
connected = true(32, 1);

% X- and Y-coordinates of the electrodes/channels. Use 'NaN' for the dead or non-ephys.
% Check probe specs if not sure if these are correct. I take no responsibility for the
% correctness of the coordinates. According to the developer, the scaling doesn't matter, but
% for the sake of clarity, use micrometers.

% This is for viwing shanks horizontaly
xcoords = [0 -13 13 -20 20 -27 27 -34 ...
		   200 187 213 180 220 173 227 166 ...
		   400 387 413 380 420 373 427 366 ...
		   600 587 613 580 620 573 627 566];

% This is for viwing shanks verticall
% xcoords = [0 -13 13 -20 20 -27 27 -34 ...
% 		   0 -13 13 -20 20 -27 27 -34 ...
% 		   0 -13 13 -20 20 -27 27 -34 ...
% 		   0 -13 13 -20 20 -27 27 -34];


% This is for viwing shanks horizontaly
ycoords = [0 20 40 60 80 100 120 140 ...
		   0 20 40 60 80 100 120 140 ...
		   0 20 40 60 80 100 120 140 ...
		   0 20 40 60 80 100 120 140];

% This is for viwing shanks vertically
% ycoords = [0 20 40 60 80 100 120 140 ...
% 		   200 220 240 260 280 300 320 340 ...
% 		   400 420 440 460 480 500 520 540 ...
% 		   600 620 640 660 680 700 720 740];

% Makes y-axis upside down, because reference image is also that way
ycoords = -ycoords;

% Groups each electrode to correct shank. Grouping prevents shanks to share same spikes.
% Grouping should improve clustering quality according to the developer. Use 'NaN' for the 
% dead or non-ephys.

kcoords = [1 1 1 1 1 1 1 1 ...
		   2 2 2 2 2 2 2 2 ...
		   3 3 3 3 3 3 3 3 ...
		   4 4 4 4 4 4 4 4];

% Saving
save(fullfile(fpath, 'chanMap.mat'), 'chanMap', 'connected', 'xcoords', 'ycoords', 'kcoords')