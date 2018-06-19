function [ out ] = loadMCDtoStruct( filename, varargin )
%LOADMCDTOSTRUCT
%   Simplified MultiChannelSystems -file loader for MATLAB.
%   VERSION: 23.8.2017
%   ----------------------------------------------------------------------
%   DISCLAMER:
%   Comes with no warranty! Always be sure that the data is correct!
%   Script may have problems with different kinds of recordings.
%   Report bugs to lauri.t.kantola@jyu.fi.
%   ----------------------------------------------------------------------
%   HOW TO USE:
%   [ stuct ] = loadMCDtoStruct(filename,<options>)
%
%   Example:
%   data = loadMCDtoStruct('testData.mcd','selectStream','Electrode Raw
%   Data','startPoint',100);
%   
%   Additional <options>:
%   'loadStream'        'true' or 'false', default is 'true'. You can load
%                       all the other data than "data" itself, by setting 
%                       this to 'false'.
%
%   'startPoint'        Default is 0. Value must be number. Defines 
%                       starting point for loading data in milliseconds.
%
%   'endPoint'          Default is recording length in ms. 
%                       Otherwise same as above, but it is the ending.
%
%   'selectStream'      Default is 'all'. You also can load only selected
%                       stream types by setting this e.g. 'Electrode Raw 
%                       Data' or 'Avg Trigger'.
%
%   'orderByHwID'       Default is 'true'. This will reorder channels by
%                       hardware channel ids. Channel order is different in 
%                       different systems, this will fix it. When 'true',
%                       read channel ids from correctedChIDs field and
%                       channel names from correctedChNames. To disable,
%                       use 'false' and read id from hwChannelIDs and names
%                       from hwChannelNames.
%                       
%   'toMuVolt'          Default is 'false'. Converts AD -values to
%                       microvolts by using streams AD multiplier. May be
%                       incorrect, when UnitSign in OLE-read file is
%                       'unknown'.
%   'remap'             Default is 'false'. Remaps channels by order of
%                       '.remap' -file.
%   ----------------------------------------------------------------------
%   NOTE:
%   Script return struct that contains all the data from the recording.
%   Script doesn't rearrange channels, so be sure to validate your
%   channel ids from 'channelIDs' and 'hwChannelIDs' -fields. These may
%   be different in different systems. Also be sure that other values are
%   also valid. I take no responsibility for correctness of values in
%   data recorded in different systems. Script needs still testing.
%   ----------------------------------------------------------------------
%   INSTALL:
%   Uses MCSStreamSupport API for MATLAB found in MC_Rack installation.
%   Put MCStreamSupport mcintfac-folder in MATLAB path.
%   e.g. "addpath 'C:\Program Files (x86)\Multi Channel Systems\MC_Rack\
%                  MCStreamSupport\matlab\meatools\mcintfac' "
%   Also put this script folder to MATLAB path. 
%   Folder must cointain files:
%   loadMCDtoStruct.m, loadStreamData.m, loadRecordingInfo.m
    
    % number of arguments
    nVarargs = length(varargin);

    % checks if least filename is typed
    if nargin < 1
       error('No parameters. Type least filename');
    end
    
    % checks if the file exists
    if exist(filename, 'file') == 0
       error('File not found: %s', filename);
    end

    disp('Loading .mcd file')    
    global hdr;
    global data;
    hdr = datastrm(filename);
    disp('Header loaded')
    
    data = loadRecordingInfo(hdr);
    
    disp('Recording info loaded')
    
    % Default settings:
    loadStream = true;
    selectStream = 'all';
    orderByHwID = true;
    toMuVolt = false;
    remap = false;
    % channel selection needs to be implemented
    
    % loops every second argument (every other is value of argument)
    for i = 1:2:nVarargs
       % checks if arguments are strings/characters
       if ~ischar(varargin{i})
           error('Some of the arguments are not valid');
       end
       % sets options
       switch(lower(varargin{i}))
           case 'loadstream'
               loadStream = char(varargin{i+1});
               if strcmp(loadStream, 'true')
                   loadStream = true;
               elseif strcmp(loadStream, 'false')
                   loadStream = false;
               else
                   error('LoadStream is nor true or false');
               end
           case 'startpoint'
               data.startMs = varargin{i+1};
               if ~isfloat(data.startMs)
                   error('Startpoint is not a number');
               end
           case 'endpoint'
               data.endMs = varargin{i+1};
               if ~isfloat(data.endMs)
                   error('Endpoint is not a number');
               end
           case 'selectstream' % refactor if time
               selectStream = char(varargin{i+1});
               if strcmp(selectStream, 'Analog Raw Data')
                   fprintf('%s selected\n', selectStream);
               elseif strcmp(selectStream, 'Avg Trigger')
                   fprintf('%s selected\n', selectStream);
               elseif strcmp(selectStream, 'Digital Data')
                   fprintf('%s selected\n', selectStream);
               elseif strcmp(selectStream, 'Filtered Data')
                   fprintf('%s selected\n', selectStream);
               elseif strcmp(selectStream, 'Electrode Raw Data')
                   fprintf('%s selected\n', selectStream);
               else
                   error('%s stream no supported yet!', selectStream);                   
               end
           case 'orderbyhwid'
               orderByHwID = char(varargin{i+1});
               if strcmp(orderByHwID, 'false')
                   orderByHwID = false;
                   fprintf('OrderByHwID is disabled!');
               end
           case 'tomuvolt'
               toMuVolt = char(varargin{i+1});
               if strcmp(toMuVolt, 'true')
                   toMuVolt = true;
                   fprintf('toMuVolt is true. Converts all AD values to µV!');
               end
           case 'remap'
               remap = char(varargin{i+1});
               if strcmp(remap, 'true')
                   remap = true;
                   fprintf('Remap is enabled!');
               end
           otherwise
               error('%s argument not valid!',char(varargin{i}));
       end   
    end    
    
    if loadStream                
        
        % needs refactoring if time (some repetition)
        if strcmp(selectStream, 'all')
            
            disp('Loading data from streams:')
            disp(data.streamNames)
        
            for i = 1 : data.streamCount

                stream = char(data.streamNames(i));

                if any(strfind((stream), 'Analog Raw Data'))
                    disp('Loading Analog Raw Data:')
                    disp(stream)
                    if ~isfield(data, 'AnalogRawData')
                        data.AnalogRawData = {loadInChunks(hdr, i, stream, data.startMs, data.endMs, data.zeroAD, data.recordedChannels, orderByHwID, toMuVolt, remap)}; % load stream data to field, i = stream id, stream = stream name
                    else
                        data.AnalogRawData(end+1) = {loadInChunks(hdr, i, stream, data.startMs, data.endMs, data.zeroAD, data.recordedChannels, orderByHwID, toMuVolt, remap)};
                    end
                    disp('Analog Raw Data loaded')        

                elseif any(strfind((stream), 'Avg Trigger'))
                    disp('Loading Avg Trigger:')
                    disp(stream)
                    if ~isfield(data, 'AvgTrigger')
                        data.AvgTrigger = {loadInChunks(hdr, i, stream, data.startMs, data.endMs, data.zeroAD, data.recordedChannels, orderByHwID, toMuVolt, remap)}; % load stream data to field, i = stream id, stream = stream name
                    else
                        data.AvgTrigger(end+1) = {loadInChunks(hdr, i, stream, data.startMs, data.endMs, data.zeroAD, data.recordedChannels, orderByHwID, toMuVolt, remap)};
                    end
                    disp('Avg Trigger loaded')      

                elseif any(strfind((stream), 'Digital Data'))
                    disp('Loading Digital Data:')
                    disp(stream)
                    if ~isfield(data, 'DigitalData')
                        data.DigitalData = {loadInChunks(hdr, i, stream, data.startMs, data.endMs, data.zeroAD, data.recordedChannels, orderByHwID, toMuVolt, remap)}; % load stream data to field, i = stream id, stream = stream name
                    else
                        data.DigitalData(end+1) = {loadInChunks(hdr, i, stream, data.startMs, data.endMs, data.zeroAD, data.recordedChannels, orderByHwID, toMuVolt, remap)};
                    end
                    disp('Digital Data loaded')

                elseif any(strfind((stream), 'Electrode Raw Data'))
                    disp('Loading Electrode Raw Data:')
                    disp(stream)
                    if ~isfield(data, 'ElectrodeRawData')
                        data.ElectrodeRawData = {loadInChunks(hdr, i, stream, data.startMs, data.endMs, data.zeroAD, data.recordedChannels, orderByHwID, toMuVolt, remap)}; % load stream data to field, i = stream id, stream = stream name
                    else
                        data.ElectrodeRawData(end+1) = {loadInChunks(hdr, i, stream, data.startMs, data.endMs, data.zeroAD, data.recordedChannels, orderByHwID, toMuVolt, remap)};
                    end
                    disp('Electrode Raw Data loaded')

                elseif any(strfind((stream), 'Filtered Data'))
                    disp('Loading Filtered Data:')
                    disp(stream)
                    if ~isfield(data, 'FilteredData')
                        data.FilteredData = {loadInChunks(hdr, i, stream, data.startMs, data.endMs, data.zeroAD, data.recordedChannels, orderByHwID, toMuVolt, remap)}; % load stream data to field, i = stream id, stream = stream name
                    else
                        data.FilteredData(end+1) = {loadInChunks(hdr, i, stream, data.startMs, data.endMs, data.zeroAD, data.recordedChannels, orderByHwID, toMuVolt, remap)};
                    end
                    disp('Filtered Data loaded')
                else
                    fprintf('%s stream not yet supported. Skipping...\n', stream);
                end
            end            
        % else is for single selection
        else            
            disp('Loading data from stream:')
            disp(selectStream)            
            
            found = false;
            for ij = 1 : data.streamCount
                stream = char(data.streamNames(ij));
                if any(strfind((stream), selectStream))
                    found = true;
                    fprintf('Loading %s:\n', selectStream);
                    disp(stream)
                    fieldName = strrep(selectStream,' ','');
                    if ~isfield(data, fieldName)
                        data.(fieldName) = {loadInChunks(hdr, ij, stream, data.startMs, data.endMs, data.zeroAD, data.recordedChannels, orderByHwID, toMuVolt, remap)}; % load stream data to field, i = stream id, stream = stream name
                    else
                        data.(fieldName)(end+1) = {loadInChunks(hdr, ij, stream, data.startMs, data.endMs, data.zeroAD, data.recordedChannels, orderByHwID, toMuVolt, remap)};
                    end
                    fprintf('%s loaded\n', selectStream);
                end
            end
            if ~found
                fprintf('%s streams not found. Check the stream listing.\n', selectStream);
            end
        end
    else
        disp('LoadStream is false, so only recording info loaded')
    end        
    
    out = data;

end

