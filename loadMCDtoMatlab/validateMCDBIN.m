function [ out ] = validateMCDBIN( filename1, filename2 )
%   Validates equality of two MCD binary files.
%   VERSION: 17.8.2017
%   ----------------------------------------------------------------------
%   DISCLAIMER:
%   Comes with no warranty! Always be sure that the data is correct!
%   Script may have problems with different kinds of recordings.
%   Report bugs to lauri.t.kantola@jyu.fi.
%   ----------------------------------------------------------------------
%   HOW TO USE:
%   validateMCDBIN(binary-file1, binary-file2);
%   e.g. validateMCDBIN('403_Random1000_CC2.dat','403_Random1000_CC2.raw');
%   
%   Use MC_DataTool to create binary file 1 and e.g. convertMCDtoDat to 
%   create file 2. Select all channels from selected stream in MC_DataTool. 
%   Also tap 'Signed 16bit' from MC_DataTool.

    data = [];
    equal = 'isequal(';

    for i = 1 : 2
        file = eval(sprintf('filename%d',i));
        fileID = fopen(file);
        data = [data;fread(fileID,[1,Inf],'int16=>int16')];
        fclose(fileID);
        equal = strcat(equal, sprintf('data(%d,:),',i));
    end
    
    equal = strcat(equal(1:end-1), ');');
    
    if eval(equal)
        disp('Files are identical!')
        out = true;
    else
        error('Files are different!');
    end
    
end

