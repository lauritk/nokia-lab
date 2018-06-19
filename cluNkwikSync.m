% i.e. cluNkwikSync('381_RP_rest1.kwik','381_RP_rest1.clu.0');
function data = cluNkwikSync(kwik_filename,clu_filename)

%Read kwik-file
%Change these
%kwik_filename = '381_RP_CC1.kwik';
kwik_dataset = '/channel_groups/0/spikes/time_samples';

kwik_data = h5read(kwik_filename,kwik_dataset);

%Read clu.0-file
%Change this
%clu_filename = '381_RP_CC1.clu.0';

clu_fID = fopen(clu_filename);
clu_data = textscan(clu_fID,'%d','HeaderLines',1);

%Combine data
pre_data = zeros(length(kwik_data),2);
pre_data(:,1) = clu_data{:,1};
pre_data(:,2) = kwik_data;

%Final data only from value over 1 on 2nd column
data = pre_data(pre_data(:,1) > 1,:);

%Write data
dataID = fopen('clu_kwik_synced.txt','w');
fprintf(dataID,'%d\t%d\r\n',[data(:,1),data(:,2)]');

end