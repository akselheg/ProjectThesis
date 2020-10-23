clc;
close all;
clear all;

RAD2DEG = 180/pi;

% Location of data. Only data saved as csv was considered here.
data_path = '/home/henning/AutoNaut/Data/2020070113_AutoNaut_Mausund_Long/L2/20200701/181204_Mausund_1806_3/mra/csv';

% Unique ID for saving current data to .mat file
id = '20200701_181204_Mausund_1806_3';

% Load Data
GpsFix = read_csv_file('GpsFix.csv', data_path);
gps_timest_original = GpsFix.timestamp_secondsSince01_01_1970_-GpsFix.timestamp_secondsSince01_01_1970_(1);

path_latitude = GpsFix.lat_rad_(:)*RAD2DEG;
path_longitude = GpsFix.lon_rad_(:)*RAD2DEG;

% Extract current for the path given by the GPS. 
[current_components, current_time] = get_current_components(GpsFix,id);

% This shows time from the test started. 'current_time' shows the actuial
% time of the day 
hours_from_start = [0:length(current_time)-1];


figure
subplot(2,1,1)
plot(hours_from_start,current_components(:,1))
xlabel('Time [h]')
ylabel('Current velcoity [m/s]')
grid on
title('Current north-component')

subplot(2,1,2)
plot(hours_from_start,current_components(:,2))
xlabel('Time [h]')
ylabel('Current velcoity [m/s]')
grid on
title('Current east-component')

% Use interpolation to get the current corresponing to each individual GPS
% measurement.
current_north_long = interp1(hours_from_start, current_components(:,1), gps_timest_original);

