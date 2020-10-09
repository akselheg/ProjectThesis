clc;clearvars; close all;

addpath('./Mausund221241//');
gpsFix = load('GpsFix.mat');
RelativeWind = load('RelativeWind.mat');
windData = RelativeWind.RelativeWind;
load('weatherData_2020-7-1_2020-7-2.mat')
EulerAngles = load('EulerAngles.mat');
EulerAngles = EulerAngles.EulerAngles;

rmpath('./Mausund221241/')
gps_data = gpsFix.GpsFix;
windDataAngles = interp1(windData.timestamp, windData.angle,gps_data.timestamp);
num_days = double(gps_data.utc_day(end) - gps_data.utc_day(1));
gps_start_time = floor(gps_data.utc_time(1)/3600);
gps_end_hour = floor(gps_data.utc_time(end)/3600);
gps_end_time =  24*(num_days) + gps_end_hour;
cog = [];
sog = [];
wind_dir = [];
wave_dir = [];

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
    cog = rad2deg(mean(gps_data.cog(index-10:index+10)));
    psi = rad2deg(mean(EulerAngles.psi(index-100:index+100)));
    sog = mean(gps_data.sog(index-100:index+100));
    increment = 0.0001; % resolution lat and lon in gps
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
    wave_dir = waveDir(x,y,i+1);
    if abs(waveDir(x,y,i+1))> 180
        wavedir = waveDir(x,y,i+1) - sign(waveDir(x,y,i+1))*360;
    else
        wavedir = waveDir(x,y,i+1);
    end
    windangle = mean(windDataAngles(index-100:index+100));
    
    
    disp(['| Day: ', num2str(floor(i/24)+1),'   | Hour: ', num2str(mod(i,24)), '  |  WaveSize: ', num2str(waveSize(x,y,i+1)),...
        '  |  WaveDir: ', num2str(wave_dir), '  |  Cog: ', num2str(psi), ...
           '  |  sog: ', num2str(sog), '  |', 'rel: ', num2str(ssa(psi-wave_dir,'deg')), '  |' ])
    
    if waveSize(x,y,i+1) < 10 && waveSize(x,y,i+1) > 0.01
        figure(1);
        scatter3(ssa(psi-wave_dir, 'deg'), waveSize(x,y,i+1), sog)
        hold on
        figure(2)
        scatter3(ssa(psi-wave_dir,'deg'), windangle, sog)
        hold on
    end
    
%     waveSize(x-1:x+1,y-1:y+1,i+1)
%     waveDir(x-1:x+1,y-1:y+1,i+1)
end
figure(1)
xlabel 'Wavedir',ylabel 'waveSize',zlabel 'sog';
figure(2)
xlabel 'Wavedir',ylabel 'windangle',zlabel 'sog';
