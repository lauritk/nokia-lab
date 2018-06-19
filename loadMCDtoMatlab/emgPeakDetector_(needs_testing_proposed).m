function [ out ] = emgPeakDetector( data, thr, minpeak_w, safe_zone )
%EMGPEAKDETECTOR Summary of this function goes here
%   Input data needs to be 2000 Hz and 'double' type

    % Makes envelope from signal
    envelope_rms = envelope(data,50,'rms');
    
    
    % Smoothing envelope
    rms_smooth = smooth(envelope_rms,10,'sgolay',2)';
    rms_medsmooth = medfilt1(rms_smooth,100);
    
    smooth_data = (rms_medsmooth - min(rms_medsmooth)) / ( max(rms_medsmooth) - min(rms_medsmooth));

    movmedian_diff = movmedian(smooth_data,20000)-median(smooth_data);
    start_thr = movmedian_diff + std(smooth_data) * thr;
    end_thr = movmedian_diff + std(smooth_data) * (thr - 0.3);

    %minpeak_w = 400;
    maxgap_w = 0;
    %maxpeak_w = 1200;
    %safe_zone = 2000; % 2000 datapoints for 1s (2kHz)

    n = length(smooth_data);
    detection = false(1,n);
    
    i = 1;
    while i <= n

        if smooth_data(i) > start_thr(i)
            detection(i) = true;
        end

        if i > 1 && ~detection(i) && detection(i-1) && smooth_data(i) > end_thr(i)
            detection(i) = true;
        end

        i = i + 1;
    end



    count_p = 0;
    count_g = 0;

    j = 1;
    while j < n

        while ~detection(j) && j < n
            count_g = count_g + 1;
            j = j + 1;
        end

        if count_g < maxgap_w && count_g > 0
            detection(j-count_g:j) = true;
            j = j - count_g;
            count_g = 0;
        else
            count_g = 0;
        end    

        while detection(j) && j < n
            count_p = count_p + 1;
            j = j + 1;
        end

        if count_p < minpeak_w && count_p > 0
            detection(j-count_p:j) = false;        
            j = j - count_p;
            count_p = 0;
        else
            count_p = 0;
        end    

    end    
    
    
    % datapoints to time
    
    timepoints = [];
    
    z = 1;
    while z < n
        
        tmp = zeros(1,3);
       
        while ~detection(z) && z < n
            z = z + 1;
        end
        
        if detection(z) && z < n
            tmp(1) = z;
        end            
        
        while detection(z) && z < n
            z = z + 1;
        end
        
        if ~detection(z) && z < n
            tmp(2) = z;
        end
        
        if tmp(1) && tmp(2)
            [~,tmp(3)] = max(smooth_data(tmp(1):tmp(2)));
            tmp(3) = tmp(3) + tmp(1);
        end
        
        if tmp(1) && tmp(2) && tmp(3)
            timepoints = [timepoints ; tmp];
        end
        
        z = z + 1;
    end
    
    for c = 2 : size(timepoints,1)
        
        if timepoints(c,1) <= (timepoints(c-1,1) + safe_zone)
            timepoints(c,:) = 1;
        end        
    end
    
    out = timepoints;
    

end

