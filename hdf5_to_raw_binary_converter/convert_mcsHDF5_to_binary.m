function convert_mcsHDF5_to_binary( filename, streamid, selected )
%convert_mcsHDF5_to_binary
%   Convert MCS HDF5 files to raw binary and remap channels. Converts all the channels.
%   Channels selected after remap
%   VERSION: 15.6.2018
%   ----------------------------------------------------------------------
%   DISCLAIMER:
%   Comes with no warranty! Always be sure that the data is correct!
%   Script may have problems with different kinds of recordings.
%   Report bugs to lauri.t.kantola@jyu.fi.
%   ----------------------------------------------------------------------

	cfg = [];
	cfg.dataType = 'raw'; % set data loading in original int16 format 'raw'
	cfg.selectedStream = streamid;

	data = McsHDF5.McsData(filename, cfg);
	data_out = struct();
	% Cast data from int32 to int16. Should keep values correct. Change if values are clipping.
	% Loads selected analog stream.
	data_out.ch_data = cast(data.Recording{1}.AnalogStream{cfg.selectedStream}.ChannelData(:,:), 'int16');
	
	data_out.ch_ids = data.Recording{1}.AnalogStream{cfg.selectedStream}.Info.ChannelID;
	data_out.ch_remap_order = loadRemapConfig_mcsHDF5(filename);
	data_out.row_index = data.Recording{1}.AnalogStream{cfg.selectedStream}.Info.RowIndex;
	data_out.ch_labels = data.Recording{1}.AnalogStream{cfg.selectedStream}.Info.Label;

	data_out.ch_data = reorderChannels_mcsHDF5(data_out.ch_data, data_out.ch_remap_order);
	data_out.ch_data = data_out.ch_data(selected,:);

	saveBinaryHDF5(data_out.ch_data, filename, 'w');
	
end