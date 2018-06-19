function [ out ] = loadStreamData( hdr, streamID, streamName, startMs, endMs, zeroAD, recordedChannels, orderByHwID, toMuVolt, remap )
%LOADSTREAMDATA Stream data loader for loadMCDtoStruct and convertMCDtoDat
%   VERSION: 23.8.2017
%   ----------------------------------------------------------------------
%   DISCLAIMER:
%   Comes with no warranty! Always be sure that the data is correct!
%   Script may have problems with different kinds of recordings.
%   Report bugs to lauri.t.kantola@jyu.fi.
%   ----------------------------------------------------------------------

    try
        % loads the data
        convData = nextdata(hdr,'startend',[startMs,endMs],'streamname',streamName);
    catch ME
        % Simple exception catch for errors in MCStreamSupport. Corrupted
        % recordings may trip this also.
        if (strcmp(ME.identifier,'MATLAB:unexpectedCPPexception'))
            msg = '.mcd file MAY be corrupted or it is too long to read in one piece. Try shorter length or replay recording in MC_RACK';
            causeException = MException('MATLAB:mcstreamsupport:unknownex',msg);
            ME = addCause(ME,causeException);
        end
        rethrow(ME)
    end

    % get some samplerates and calculate datapoints for checking
    samplerate = getfield(hdr,'MillisamplesPerSecond2')/1000;
    samplerate = samplerate(streamID);
    trueLength = samplerate * ((endMs - startMs) / 1000);
    ADConv = getfield(hdr,'MicrovoltsPerAD2');

    % Looks for Avg Trigger streams
    if any(strfind((streamName), 'Avg Trigger'))            
        %Crop empty rows
        convData.values = convData.values(any(convData.values,2),:);
        
        % checks if any of the values are same or larger than AD zeropoint.
        % Corrects values if so.
        if any(convData.values >= zeroAD(streamID))
            convData.values = convData.values - zeroAD(streamID);
        end      

        % checks if less rows than there is channels. reshapes data.
        if size(convData.values,2) < recordedChannels(streamID)
            if toMuVolt
                convData.values = reshape(convData.values  * ADConv(streamID),recordedChannels(streamID),[]);
            else
                convData.values = cast(reshape(convData.values,recordedChannels(streamID),[]),'int16'); % cast data as int16
            end
        else
            if toMuVolt
                convData.values = convData.values * ADConv(streamID);
            else
                convData.values = cast(convData.values,'int16'); % cast data as int16
            end
        end

        % converts times to datapoints (time * datapoints per ms)
        convData.dataPoints = convData.times * (samplerate / 1000);  
        
    % Looks for Digital Data streams
    elseif any(strfind((streamName), 'Digital Data'))
         % this is for 'Digital Data', which is binary (zeros and ones)
        convData.data = logical(convData.data);

        % checks if any of the rows and columns have values
        if any(any(convData.data,2), 1)
            %Crop empty rows (Disabled for now, needs testing)
            convData.data = convData.data(any(convData.data,2),:);
        else
            convData.data = convData.data(1:recordedChannels(streamID),:);
        end

    % Looks for Raw Data streams and Filtered Data streams
    elseif any(strfind((streamName), 'Analog Raw Data')) || any(strfind((streamName), 'Electrode Raw Data')) || any(strfind((streamName), 'Filtered Data'))
        % gets real value by subtracting stream zeroAD (mostly max int16 + 1 => 32768) value from datapoint values.
        % .mcd data is positive uint32, this converts it int16.
        % MC_RACK binary files (.dat, .bin) uses int16.                    

        % Crop empty rows, because some datasets have them (for some
        % reasons). If data is (for some reasons) transposed, we don't 
        % want to do this (may cause 'OUT OF MEMORY' with very large datasets). 
        % 'size(convData.data,1) < 256' is quick and dirty trick to 
        % prevent this. There is no larger amount of channels than 256 
        % in MCS systems? Can also be 512.
        if size(convData.data,1) < 256 && size(convData.data,1) > recordedChannels(streamID)
            convData.data = convData.data(any(convData.data,2),:);
        end
        
        % Checks if any of the values are same or larger than AD zeropoint.
        % Corrects values if so. Some datasets have zeropoint as 0.
        % This takes care of that.
        if any(convData.data(:) >= zeroAD(streamID))
            convData.data = convData.data - zeroAD(streamID);
        end

        % Checks if rows (channel count) are correct or not. 
        % Reshapes data if needed.
        if size(convData.data,1) ~= recordedChannels(streamID)
            if toMuVolt
                convData.data = reshape(convData.data  * ADConv(streamID),recordedChannels(streamID),[]);
            else
                convData.data = cast(reshape(convData.data,recordedChannels(streamID),[]),'int16'); % cast data as int16
            end
        else
            if toMuVolt
                convData.data = convData.data * ADConv(streamID);
            else
                convData.data = cast(convData.data,'int16'); % cast data as int16
            end
        end

        % Checks data length and fixes it if too long. Some datasets/streams
        % have problems with this.
        if size(convData.data, 2) > trueLength
           disp('Stream data length too long, fixing (check the data!)...')
           convData.data = convData.data(:,1:trueLength);
        end
        
        % Reorder channels by hardware channel id's. Channels are in
        % different order in different systems. E.g. W2100 channels are in 
        % order, but 64 USB -systems channels are not. MC_DataTool seems 
        % to do this automaticly. Disable this, if you don't want fix
        % channel order.
        if orderByHwID
            hwid = getfield(hdr,'HardwareChannelID2');
            convData.data = reorderChannels(convData.data, hwid{streamID});
        end
        
        % Remap channels
        if remap && (any(strfind((streamName), 'Electrode Raw Data')) || any(strfind((streamName), 'Filtered Data')))
            [~,file,~] = fileparts(getfield(hdr,'filename'));
            convData.data = remapChannels(convData.data, file);
        end

    else
        fprintf('%s stream not yet supported. Skipping...', streamName);
    end
    out = convData;
end      