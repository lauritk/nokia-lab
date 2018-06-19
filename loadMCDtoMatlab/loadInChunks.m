function [ out ] = loadInChunks( hdr, streamid, stream, startPoint, endPoint, zeroAD, recordedChannels, orderByHwID, toMuVolt, remap)
%   LOADINCHUNKS Helper for loadMCDtoStruct. Reads data in 1s chunks
%   VERSION: 25.8.2017
%   ----------------------------------------------------------------------
%   DISCLAMER:
%   Comes with no warranty! Always be sure that the data is correct!
%   Script may have problems with different kinds of recordings.
%   Report bugs to lauri.t.kantola@jyu.fi.
%   ----------------------------------------------------------------------

        % chunk read not implemented for Avg Trigger
        if any(strfind((stream), 'Avg Trigger')) || any(strfind((stream), 'Digital Data'))
            out = loadStreamData( hdr, streamid, stream, startPoint, endPoint, zeroAD, recordedChannels, orderByHwID, toMuVolt, remap);
        else
            length = endPoint - startPoint;

            chunk = 100000; % change if recording is shorter than 100000 ms. 100000 ms chunk is quite good in performance
            chunks = length / chunk; 
            chunkStart = startPoint;
            chunkEnd = chunkStart + chunk;

            % preallocate if slow
            chunkData.data = [];
            chunkData.startend = [startPoint, endPoint];

            % Load data in chunks
            for i = 1:chunks+1 %test 2:chunks-1
                loadChunk = loadStreamData( hdr, streamid, stream, chunkStart, chunkEnd, zeroAD, recordedChannels, orderByHwID, toMuVolt, remap);
                chunkData.data = [chunkData.data loadChunk.data];
                chunkStart = chunkStart + chunk;
                chunkEnd = chunkEnd + chunk;
                if chunkStart > endPoint
                    break;
                end
                if chunkEnd > endPoint
                    chunkEnd = endPoint;
                end
            end

            out = chunkData;

        end
    end