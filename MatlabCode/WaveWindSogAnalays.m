clc;clearvars; close all;

%% load data
addpath('./Mausund181204/');
gpsFix = load('GpsFix.mat');
RelativeWind = load('RelativeWind.mat');
windData = RelativeWind.RelativeWind;
load('weatherData_2020-7-1_2020-7-2.mat')
EulerAngles = load('EulerAngles.mat');
EulerAngles = EulerAngles.EulerAngles;
rmpath('./Mausund181204/')
disp('Done loading data')
%% Format and interpolations
gps_data = gpsFix.GpsFix;
windDataAngles = interp1(windData.timestamp, windData.angle,gps_data.timestamp);
windDataSpeed = interp1(windData.timestamp, windData.speed,gps_data.timestamp);
cog_data = [];
sog_data = [];
wind_data = [];
wave_data = [];
wave_size_data = [];
wind_angle_data = [];
wind_speed_data = [];
x = 0;
y = 0;
disp('Done formating')
disp('Start running through data')
%% run
for min = 60 : length(gps_data.sog)
    if ~mod(gps_data.utc_time(min),60)
        curr_hour = floor(double(gps_data.utc_time(min))/3600) + 24*(double(gps_data.utc_day(min)) - 1);
        lat = rad2deg(gps_data.lat(min));
        lon = rad2deg(gps_data.lon(min));
        cog = rad2deg(mean(gps_data.cog(min-10:min+10)));
        psi = rad2deg(mean(EulerAngles.psi(min-10:min+10)));
        sog = mean(gps_data.sog(min-10:min+10));
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
        wave_dir = waveDir(x,y,curr_hour+1);
        if abs(waveDir(x,y,curr_hour+1))> 180
            wavedir = waveDir(x,y,curr_hour+1) - sign(waveDir(x,y,curr_hour+1))*360;
        else
            wavedir = waveDir(x,y,curr_hour+1);
        end
        windangle = mean(windDataAngles(min-10:min+10));
        windspeed = mean(windDataSpeed(min-10:min+10));

        if waveSize(x,y,curr_hour+1) < 10 && waveSize(x,y,curr_hour+1) > 0.01
            cog_data = cat(1, cog_data,cog);
            sog_data = cat(1, sog_data,sog);
            wave_data = cat(1, wave_data,ssa(psi-wave_dir, 'deg'));
            wave_size_data = cat(1, wave_size_data,waveSize(x, y, curr_hour + 1));
            wind_angle_data = cat(1, wind_angle_data, windangle);
            wind_speed_data = cat(1, wind_speed_data, windspeed);
        end
        if ~mod(gps_data.utc_time(min),3600)
            str = sprintf('| Day: %d \t | Hour: %d \t |', (floor(curr_hour/24)+1), (mod(curr_hour,24)));
            disp(str)
        end
    end
    
end
disp('Run Success')
%%
disp('plotting Data')
figure(1)
scatter3(wave_data,wave_size_data,sog_data)
xlabel 'Wavedir',ylabel 'waveSize',zlabel 'sog';
figure(2)
scatter3(wave_data,wind_angle_data, sog_data)
xlabel 'Wavedir',ylabel 'windangle',zlabel 'sog';
figure(3)
scatter3(wind_speed_data,wind_angle_data, sog_data)
xlabel 'WindSpeed',ylabel 'windangle',zlabel 'sog';
