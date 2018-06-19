function [ out ] = convertMCDtoDat( filename, varargin )
%CONVERTMCDTODAT 
%   MATLAB converter for .mcd to binary .dat files.
%   VERSION: 25.8.2017
%   ----------------------------------------------------------------------
%   DISCLAMER:
%   Comes with no warranty! Always be sure that the data is correct!
%   Script may have problems with different kinds of recordings.
%   Report bugs to lauri.t.kantola@jyu.fi.
%   ----------------------------------------------------------------------
%   Uses MCSStreamSupport API for MATLAB found in MC_Rack installation.
%   Put MCStreamSupport in Matlab path
%   e.g. "addpath 'C:\Program Files (x86)\Multi Channel Systems\MC_Rack\
%   MCStreamSupport' "
%
%   HOW TO USE:
%   e.g. convertMCDtoDat( 'mcdfile.mcd','Electrode Raw Data');
%   Outputs mcdfile.bin -file with selected Data Stream from MCD.

    % The script works, but needs refactoring and some features. Loads and
    % writes data in chunks. May be useful to implement feature to
    % loadMCDtoStruct -script. 

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
    selectStream = 'Electrode Raw Data';
    orderByHwID = true;
    toMuVolt = false;
    remap = false;
    
    % loops every second argument (every other is value of argument)
    for i = 1:2:nVarargs
       if ~ischar(varargin{i})
           error('Some of the arguments are not valid');
       end
       switch(lower(varargin{i}))
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
           case 'orderbyhwid'
               orderByHwID = char(varargin{i+1});
               if strcmp(orderByHwID, 'false')
                   orderByHwID = false;
                   fprintf('OrderByHwID is disabled!');
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
    
    disp('Loading data from streams:')
    disp(data.streamNames)
    
    for y = 1 : data.streamCount
        stream = char(data.streamNames(y));
        if strfind((stream), selectStream)
            out = loadInChunks(hdr, stream,y,data.startMs,data.endMs,data.filename,data.zeroAD,data.recordedChannels, orderByHwID, toMuVolt, remap);
            break;
        else
            out = false;
        end
    end    
    
    if out == false
        error('Stream "%s" not found. Check available streams!', selectStream);
    end
    
    function [ out ] = loadInChunks( hdr, stream,streamid,startPoint,endPoint,filename, zeroAD, recordedChannels, orderByHwID, toMuVolt, remap)
        
        %tic
        % Define chunks
        
        length = endPoint - startPoint;
        
        chunk = 100000; % change if recording is shorter than 100000 ms. 100000 ms chunk is quite good in performance
        chunks = length / chunk; 
        chunkStart = startPoint;
        chunkEnd = chunkStart + chunk;

        % Create file and save empty file
        flatData = [];        
        saveBinaryMCS(flatData,filename,'w');
        clear flatData;

        % Load rest of the data in chunks
        for yx = 1:chunks+1 %test 2:chunks-1
            loadChunk = loadStreamData( hdr, streamid, stream, chunkStart, chunkEnd, zeroAD, recordedChannels, orderByHwID, toMuVolt, remap);
            chunkData = loadChunk.data;
            saveBinaryMCS(chunkData,filename,'a');
            clear chunkData;
            chunkStart = chunkStart + chunk;
            chunkEnd = chunkEnd + chunk;
            if chunkStart > endPoint
                break;
            end
            if chunkEnd > endPoint
                chunkEnd = endPoint;
            end
        end
        %toc
        % Out true if succes
        out = true;

    end
    
end

