function [animal1,animal2] = readMCDRabbitCombo_v1(filename)
%Loads 2 rabbit recordings. Use e.g. "[kani1,kani2] =
%readMCDRabbitCombo_v1('419_420_CSAlone.mcd');". Needs MCStreamSupport in
%Matlab path e.g. "addpath 'C:\Program Files (x86)\Multi Channel
%Systems\MC_Rack\MCStreamSupport'"

    disp('Loading rabbits...')
    
    dataHeader = datastrm(filename);
    disp('Header loaded...')
    
    [animal1,animal2] = loadToStruct(dataHeader,filename);
    
    disp('All done and went better than expected!')

end

function [animal1,animal2] = loadToStruct(dataHeader,filename)

    samplerates = getfield(dataHeader,'MillisamplesPerSecond2')/1000;
    disp('Samplerate loaded.')
    
    recordingStartDate = datestr(getfield(dataHeader,'recordingdate'),0);
    recordingStopDate = datestr(getfield(dataHeader,'recordingStopDate'),0);    
    disp('Date loaded.')
    
    length = getfield(dataHeader,'sweepStopTime');
    disp('Length loaded.')
    
    streams = getfield(dataHeader,'StreamNames');
    
    stream = '';
    streamId = 0;

    %Finds stream for LFP data
    for i = 1 : size(streams,1)
        if strfind(char(streams(i)), 'Filtered Data')
            stream = char(streams(i));
            streamId = i;
            break;
        end
    end
    
    if isempty(stream)
        error('Error. No correct stream found!')
    end
    
    if streamId < 1
        error('Error. No stream ID!')
    end
    
    %Finds stream for Digital data
    digitalStream = '';
    digitalStreamId = 0;
    
    for i = 1 : size(streams,1)    
        if strfind(char(streams(i)), 'Digital Data')
            digitalStream = char(streams(i));
            digitalStreamId = i;
            break;
        end
    end
    
    if isempty(digitalStream)
        error('Error. No correct ''Digital'' stream found!')
    end
    
    if streamId < 1
        error('Error. No digital stream ID!')
    end
    
    %Finds stream for Triggers
    triggerStream = '';
    triggerStreamId = 0;
    
    for i = 1 : size(streams,1)    
        if strfind(char(streams(i)), 'Avg Trigger')
            triggerStream = char(streams(i));
            triggerStreamId = i;
            break;
        end
    end
    
    if isempty(triggerStream)
        error('Error. No correct ''Trigger'' stream found!')
    end
    
    if streamId < 1
        error('Error. No trigger stream ID!')
    end
    
    disp('All stream info loaded!')
    
		
	nChannels = getfield(dataHeader,'NChannels2',streamId);
    channelNumbers = cell2mat(getfield(dataHeader,'HardwareChannelID2',streamId));
    
    disp('Channel ID information loaded.')
    
    dataStruct = nextdata(dataHeader,'startend',[0 length],'streamname',stream);
    dataUnordered = dataStruct.data - 32768; %MCD file values are "int16 max + 1" larger than real values
    
    disp('Data loaded!')
    
    orderedData = zeros(size(dataUnordered));
   	
	% Fixing channel order and extract EMG and EKG
    for i = 1 : nChannels
        chNum = channelNumbers(i);
        if chNum <= nChannels
            orderedData(chNum,:) = dataUnordered(i,:);
        elseif chNum > nChannels			
            switch chNum
            	case -1
                	error('Something went terrible wrong.')
                case 61
                    emg1 = dataUnordered(i,:);
                case 62
                    ekg1 = dataUnordered(i,:);
                case 63
                    emg2 = dataUnordered(i,:); 
                case 64
                    ekg2 = dataUnordered(i,:);
                otherwise
                    error('Something went terrible wrong. Index was %d.',chNum)
            end
        else
            error('No rule for channel number %s 1',chNum)
        end
    end
        
    %Crop empty rows
    orderedData = orderedData(any(orderedData,2),:);
    
     disp('Data ordered!')
        	
    digitalDataStruct = nextdata(dataHeader,'startend',[0 length],'streamname',digitalStream);
    digitalData =  digitalDataStruct.data;
    
    disp('Marker binary data loaded.')
    
    triggerDataStruct = nextdata(dataHeader,'startend',[0 length],'streamname',triggerStream);
    triggerData =  triggerDataStruct.times;
    triggerDataTimePoints = triggerData * (samplerates(triggerStreamId) / 1000);
    
    disp('Markers loaded.')
    
    
    % Not needed?
    %{
    %Find timepoints for markers
    digitalMarkersTemp = find(digitalData);
    
    n = size(digitalMarkersTemp,2);
    i = 1;
    digitalMarkers(i) = digitalMarkersTemp(i)-1; %Markers starts from last zero
    i = i + 1;
    while i <= n
        while digitalMarkersTemp(i) == digitalMarkersTemp(i-1) + 1
            i = i + 1;
        end
        digitalMarkers(i) = digitalMarkersTemp(i)-1; %Markers starts from last zero
    end
    %}    
    
    %Parse names
    [~,name,~] = fileparts(filename);
    names = strsplit(name,'_'); 
    
     disp('Names extracted.')
	
    animal1 = struct('AnimalNumber',names(1),'RecordingStartDate',recordingStartDate,'RecordingStopDate',recordingStopDate,'FilteredDataSamplingRate',samplerates(streamId),'LengthInMs',length,'EmgData',emg1,'EkgData',ekg1,'LfpData',orderedData(1:8,:),'DigitalMarkers',triggerDataTimePoints,'DigitalMarkersInMs',triggerData,'MarkersBinary',digitalData,'OriginalFullData',dataUnordered,'OriginalChannelNumbers',channelNumbers);
	animal2 = struct('AnimalNumber',names(2),'RecordingStartDate',recordingStartDate,'RecordingStopDate',recordingStopDate,'FilteredDataSamplingRate',samplerates(streamId),'LengthInMs',length,'EmgData',emg2,'EkgData',ekg2,'LfpData',orderedData(9:16,:),'DigitalMarkers',triggerDataTimePoints,'DigitalMarkersInMs',triggerData,'MarkersBinary',digitalData,'OriginalFullData',dataUnordered,'OriginalChannelNumbers',channelNumbers); 
end
    