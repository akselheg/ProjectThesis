clc;clearvars; close all;

addpath('./Mausund221241/');
gpsFix = load('GpsFix.mat');
load('weatherData_2020-7-1_2020-7-2.mat')
gps_data = gpsFix.GpsFix;
num_days = double(gps_data.utc_day(end) - gps_data.utc_day(1));
gps_start_time = floor(gps_data.utc_time(1)/3600);
gps_end_hour = floor(gps_data.utc_time(end)/3600);
gps_end_time =  24*(num_days) + gps_end_hour;

%% Run 
for i = gps_start_time + 1 :gps_end_time
    ith_time = mod(i,24)*3600;
    ith_day = floor(i/24);
    [~,loc] = ismember(gps_data.utc_time, ith_time);
    indeces = find(loc);
    if length(indeces) > 1
        if ith_time < gps_data.utc_time(1) 
            index = indeces(ith_day);
        else
            index = indeces(ith_day + 1);
        end
    else
        index = indeces(1);
    end
    
    
    
    %% find closest wave_data
    lat = rad2deg(gps_data.lat(index));
    lon = rad2deg(gps_data.lon(index));
    increment = 0.0001;
    num_increments = 0;
    lon_ind = 0;
    lat_ind = 0;
    indexes_found = false;
    while ~indexes_found
        for ii = 1:178
            for jj = 1:688
                if abs(latitudeMapWave(ii, jj) - lat) <= num_increments*increment ...
                        && abs(longitudeMapWave(ii,jj) - lon) <= num_increments*increment
                    indexes_found = true;
                    x = ii;
                    y = jj;
                end
            end
        end
        num_increments = num_increments + 1;
    end
    if abs(waveDir(x,y,i+1))> 180
        wavedir = waveDir(x,y,i+1) - sign(waveDir(x,y,i+1))*360;
    else
        wavedir = waveDir(x,y,i+1);
    end
    disp(['| Day: ', num2str(floor(i/24)+1),'   | Hour: ', num2str(mod(i,24)), '  |  WaveSize: ', num2str(waveSize(x,y,i+1)),...
        '  |  WaveDir: ', num2str(wavedir), '  |', ])
       
    waveSize(x-1:x+1,y-1:y+1,i+1)
    waveDir(x-1:x+1,y-1:y+1,i+1)
end
