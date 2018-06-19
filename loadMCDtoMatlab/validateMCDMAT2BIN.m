function validateMCDMAT2BIN( filename1, stream, filename2)
%VALIDATEMCDMAT2BIN 
%   Validates equality of MCD binary and MCD file loaded to MATLAB 
%   with loadMCDtoStruct-script.
%   VERSION: 17.8.2017
%   ----------------------------------------------------------------------
%   DISCLAIMER:
%   Comes with no warranty! Always be sure that the data is correct!
%   Script may have problems with different kinds of recordings.
%   Report bugs to lauri.t.kantola@jyu.fi.
%   ----------------------------------------------------------------------
%   HOW TO USE:
%   validateMCDMAT2BIN(mcd-file,selected stream,binary-file);
%   e.g. validateMCDMAT2BIN('403_Random1000_CC2.mcd','Electrode Raw Data',
%   '403_Random1000_CC2.raw');
%   
%   Use MC_DataTool to create binary file. Select all channels from
%   selected stream. Also tap 'Signed 16bit' from MC_DataTool.

    dataStruct = loadMCDtoStruct(filename1,'selectStream',stream);
    data1 = eval(strrep(sprintf('dataStruct.%s{1,1}.data;',stream),' ',''));

    ch = size(data1,1);
    
    fileID = fopen(filename2);
    data2 = fread(fileID,[ch,Inf],'int16=>int16');
    fclose(fileID);
   
        
    if isequal(data1,data2)
        disp('Files are identical!')
        out = true;
    else
        error('Files are different!');
    end
    
end