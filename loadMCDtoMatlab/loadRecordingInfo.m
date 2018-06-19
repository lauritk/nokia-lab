function [ out ] = loadRecordingInfo( hdr )
%LOADRECORDINGINFO loads recording info from .mcd file
%   Helper function for loadMCDtoStruct.
%   Returns data from file header in struct.
%   VERSION: 21.8.2017
%   ----------------------------------------------------------------------
%   DISCLAMER:
%   Comes with no warranty! Always be sure that the data is correct!
%   Script may have problems with different kinds of recordings.
%   Report bugs to lauri.t.kantola@jyu.fi.
%   ----------------------------------------------------------------------
    
    data = struct;

    % fileinfo
    data.filename = getfield(hdr,'filename');                              % type 'help datastrm' for detailed info
    
    % channel info
    %data.totalChannels = getfield(hdr,'TotalChannels');                   % number of HW channels
    data.recordedChannels = getfield(hdr,'NChannels2');                    % number of recorder channels
    data.channelIDs = getfield(hdr,'ChannelID2');                          % channel id's
    data.channelNames = getfield(hdr,'ChannelNames2');                     % channel names
    data.hwChannelIDs = getfield(hdr,'HardwareChannelID2');                % HW channel id's
    data.hwChannelNames = getfield(hdr,'HardwareChannelNames2');           % HW channel names
    
    % corrected channelids after reorder by hardware channel ids
    for i = 1 : size(data.hwChannelIDs, 1)
        data.correctedChIDs{i,1} = sort(data.hwChannelIDs{i});
        data.correctedChNames{i,1} = reorderChannels(data.hwChannelNames{i},num2cell(data.hwChannelIDs{i,1}));
    end 
    
    % recording info
    data.startDate = datestr(getfield(hdr,'recordingdate'),0);                  % recording start time and date
    data.stopDate = datestr(getfield(hdr,'recordingStopDate'),0);               % recording stop time and date
    data.startMs = getfield(hdr,'sweepStartTime'); 
    data.endMs = getfield(hdr,'sweepStopTime');                              % recording length in milliseconds
    data.microVoltsAD = getfield(hdr,'MicrovoltsPerAD2');                       % µV per AD unit (from doc: 'Get the unit value for a AD value step. Depending on the number of AD bits, the input voltage range, and the amplifier gain GetUnitsPerAD() returns the units per step. For example 0.833µV per step, when the range was set to -4086mV to 4085mV, and the gain was 1200 (typical for a MEA amplifier).')
                                                                                % Multiply microVoltsAD with streams zeroAD (e.g. 0,25) to get full voltage rang. 
                                                                                % Always compare it first with MC_Rack reading. It may be different (or wrong) in different systems! 
    data.zeroAD = getfield(hdr,'ZeroADValue2');                                 % zero position of the values (from doc: 'Get the AD value representing 0. For 12 bits the AD range is 0 .. 4095, AD zero is 2048. For 16 bits the range is 0 .. 65535, AD zero is 32768')
    data.samplingRatesPerSecond = getfield(hdr,'MillisamplesPerSecond2')/1000;  % samples per second
    data.msPerDatapoint = getfield(hdr, 'MicrosecondsPerTick')/1000;            % ms per datapoint
    
    % stream info
    data.streamCount = getfield(hdr,'StreamCount');                        % stream count
    data.streamNames = getfield(hdr,'StreamNames');                        % all stream names
    data.streamInfo = getfield(hdr, 'StreamInfo');                         % stream info
    
   	% stream id's from stream names    
    data.streamIDs = zeros(data.streamCount,1);               
    for i = 1 : data.streamCount
        data.streamIDs(i) = getstreamnumber(hdr,data.streamNames(i));      % uses stream name to find its ID
    end

    out = data;
    
end

