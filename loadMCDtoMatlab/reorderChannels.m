function [ out ] = reorderChannels( data, hwIDs )
%REORDERCHANNELS
%   Channel reorder helper for loadMCDtoStruct and convertMCDtoDat
%   VERSION: 17.8.2017
%   ----------------------------------------------------------------------
%   DISCLAIMER:
%   Comes with no warranty! Always be sure that the data is correct!
%   Script may have problems with different kinds of recordings.
%   Report bugs to lauri.t.kantola@jyu.fi.
%   ----------------------------------------------------------------------

    data(:,end+1) = hwIDs; % Adds hardware channel ids to end of rows
    data = sortrows(data,size(data,2)); % Sort rows by hw channel ids 
    data = data(:,1:end-1); % Removes channel ids from the end after sorting
    
    out = data; % Returns sorted data
end