% How to use:
% Install MCS HDF5 extension for MATLAB
% Define .remap remapping file for your h5 recording
% First filename, then select stream (stream 2 seems to be electrode data),
% select channels (selection is after remapping)
% Example:

data = load_mcsHDF5('C:\MyTemp\hdf5_to_raw_binary_converter\test_data\hdf5\TIM18SDM002_280518_001.h5', 2, [9:32]);
convert_mcsHDF5_to_binary('C:\MyTemp\hdf5_to_raw_binary_converter\test_data\hdf5\TIM18SDM002_280518_001.h5', 2, [9:32]);