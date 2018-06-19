function [file] = saveBinaryHDF5(data,filename,type)
%SAVEBINARYMCS
%   Saves MCS HDF5 data loaded in MATLAB to MCS Binary Int16 -file
%   VERSION: 14.6.2018
%   ----------------------------------------------------------------------
%   DISCLAIMER:
%   Comes with no warranty! Always be sure that the data is correct!
%   Script may have problems with different kinds of recordings.
%   Report bugs to lauri.t.kantola@jyu.fi.
%   ----------------------------------------------------------------------

    [path,name,~] = fileparts(filename); % Parse filename
    filename = fullfile(path, sprintf('%s.dat',name)); % Format new filename
    fileID = fopen(filename,type); % Opens new binary file. Type first 'w' then append 'a'
    dataType = class(data); % Set datatype for binary file
    fwrite(fileID,data,dataType);   % Write binary file
    fclose(fileID); % Closes binary file
    file = filename; % Returns filename

end
