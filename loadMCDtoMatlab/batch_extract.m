files = dir('*.mcd');

for i = 1 : size(files, 1)
   
   [~,filename,~] = fileparts(files(i).name);
    
   if exist(sprintf('%s.mcd', filename)) == 2 && exist(sprintf('%s.loadch', filename)) && not(exist(sprintf('%s_RippleAnalogCHs.mat', filename)))
        extractRippleChAndAnalogCh(sprintf('%s.mcd', filename));
   end
    
end