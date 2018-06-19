function [ out ] = loadRemapConfig_mcsHDF5(remapFile)
%REMAPCHANNELS 
%   Channel remapper for MCS HDF5 to binary file converter
%   Use text-file to define remap channels. Delimate with semicolon ';'. Text e.g. '9;7;11;5;13 ... '
%   VERSION: 16.6.2018
%   ----------------------------------------------------------------------
%   DISCLAMER:
%   Comes with no warranty! Always be sure that the data is correct!
%   Script may have problems with different kinds of recordings.
%   Report bugs to lauri.t.kantola@jyu.fi.
%   ----------------------------------------------------------------------


	[path,name,~] = fileparts(remapFile); % Parse filename
    remapFile = fullfile(path, sprintf('%s.remap', name));
    tmp_map = dlmread(remapFile,';')';
    map = zeros(size(tmp_map,1),1);
    for i = 1 : size(tmp_map,1)
        map(tmp_map(i)) = i; 
    end
    
    out = map;
    
end

