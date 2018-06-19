function [ remapped ] = remapChannels(chunkData,remapFile)
%REMAPCHANNELS 
%   Channel remapper for loadMCDtoStruct and convertMCDtoDat
%   Use text-file to define remap channels. Delimate with semicolon ';'. Text e.g. '9;7;11;5;13 ... '
%   VERSION: 23.8.2017
%   ----------------------------------------------------------------------
%   DISCLAMER:
%   Comes with no warranty! Always be sure that the data is correct!
%   Script may have problems with different kinds of recordings.
%   Report bugs to lauri.t.kantola@jyu.fi.
%   ----------------------------------------------------------------------


    remapFile = sprintf('%s.remap',remapFile);
    tmp_map = dlmread(remapFile,';')';
    map = zeros(size(tmp_map,1),1);
    for i = 1 : size(tmp_map,1)
        map(tmp_map(i)) = i; 
    end
    
    remapped = reorderChannels( chunkData, map );
    
end

