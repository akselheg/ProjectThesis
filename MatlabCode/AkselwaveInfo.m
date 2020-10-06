clc;clearvars;%close all;


addpath('./Mausund221241/');
gpsFix = load('GpsFix.mat');
load('weatherData_2020-7-1_2020-7-2.mat')
gps_data = gpsFix.GpsFix;
num_days = double(gps_data.utc_day(end) - gps_data.utc_day(1));
gps_start_time = floor(gps_data.utc_time(1)/3600);
gps_end_hour = floor(gps_data.utc_time(end)/3600);
gps_end_time =  24*(num_days) + gps_end_hour;


lon_max = rad2deg(max(gps_data.lon));
lat_max = rad2deg(max(gps_data.lat));
lon_min = rad2deg(min(gps_data.lon));
lat_min = rad2deg(min(gps_data.lat));
x = [];
y = [];
test = false;
for i = 1:178
    for j = 1:688
        if latitudeMapWave(i,j) > lat_min && latitudeMapWave(i,j) < lat_max ...
                && longitudeMapWave(i,j) > lon_min && longitudeMapWave(i,j) < lon_max
            test = true;
        end
    end
    if test
       x = cat(1,x,i); 
       test = false;
    end
end
disp('break')
test = false;
for i = 1:688
    for j = 1:178
        if latitudeMapWave(j,i) > lat_min && latitudeMapWave(j,i) < lat_max ...
                && longitudeMapWave(j,i) > lon_min && longitudeMapWave(j,i) < lon_max
            test = true;
        end
    end
    if test
       y = cat(1,y,i); 
       test = false;
    end
end

figure(1);
figure(2);
for i = gps_start_time:gps_end_time
    figure(1);
    surf(waveSize(x,y,i+1));
    figure(2);
    surf(waveDir(x,y,i+1));
    pause(0.2)
end

