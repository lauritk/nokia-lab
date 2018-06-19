function [ out ] = extractRippleChAndAnalogCh( filename, varargin )
%	EXTRACTRIPPLECHANDANALOGCH Extract ripple channel according to 
%	.loadch -file. Use delimiter ; for channel numbers in .loadch -file.
%   VERSION: 19.12.2017
%   ----------------------------------------------------------------------
%   DISCLAMER:
%   Comes with no warranty! Always be sure that the data is correct!
%   Script may have problems with different kinds of recordings.
%   Report bugs to lauri.t.kantola@jyu.fi.
%   ----------------------------------------------------------------------
%   Passes arguments to 'loadMCDtoStruct' function. Use same arguments, see 
%	loadMCDtoStruct.m for more info.
%
%	NOTE!
%	Doesn't work other than Electrode Raw Data stream and Analog Raw Data 
%	stream.

	% loads data with selected arguments
	fullData = loadMCDtoStruct(filename, varargin{:});

	% extracts filename
	[~,name,~] = fileparts(filename);

	% loads ';' delimated channel numbers from .loadch -file. Filename should be same as original .mcd -file, but the extensions is different
	chsFromFile = sprintf('%s.loadch',name);
	selectedCh = dlmread(chsFromFile,';')';

	% declare empty structure
	out = struct;

	% select right data to output
	out.electrodeSelectedChannels = fullData.ElectrodeRawData{1}.data(selectedCh,:);
	out.electrodeChannelIDs = selectedCh;
	out.analogChannels = fullData.AnalogRawData{1}.data;
	out.analogChannelNames = fullData.correctedChNames{2,1};

	% saves data to .mat -files
	saveName = sprintf('%s_RippleAnalogCHs.mat',name);
	save(saveName, 'out');

end

