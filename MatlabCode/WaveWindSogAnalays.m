clc; clearvars; close all;

%% load data
path = './Mausund181204/';
addpath(path);
gpsFix = load('GpsFix.mat');
gps_data = gpsFix.GpsFix;
RelativeWind = load('RelativeWind.mat');
windData = RelativeWind.RelativeWind;
dir = append(path,'EstimatedState.mat');
EstimatedState = load(dir);
EstimatedState = EstimatedState.EstimatedState;
EstimatedState.psi = ssa(EstimatedState.psi,'deg');
dir = append(path, 'EulerAngles.mat');
EulerAngles = load('EulerAngles.mat');
EulerAngles = EulerAngles.EulerAngles;
AbsoluteWind = load('AbsoluteWind.mat');
AbsoluteWind = AbsoluteWind.AbsoluteWind;
rmpath(path)
load('weatherData_2020-7-1_2020-7-2.mat')

disp('Done loading data')
%% Format and interpolations

windDataAngles = interp1(windData.timestamp, ssa(windData.angle,'deg'),gps_data.timestamp);
windDataSpeed = interp1(windData.timestamp, windData.speed,gps_data.timestamp);
AbsoluteWind_int = interp1(AbsoluteWind.timestamp, ssa(AbsoluteWind.dir,'deg'),gps_data.timestamp);
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
for min = 60 : length(gps_data.sog) - 60
    if ~mod(gps_data.utc_time(min),60)
        curr_hour = floor(double(gps_data.utc_time(min))/3600) ...
            + 24*(double(gps_data.utc_day(min)) - 1);
        lat = mean(rad2deg(gps_data.lat(min-10:min+10)));
        lon = mean(rad2deg(gps_data.lon(min-10:min+10)));
        cog = rad2deg(mean(gps_data.cog(min-10:min+10)));
        psi = rad2deg(mean(EstimatedState.psi(min-10:min+10)));
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
        
        wave_dir = ssa(waveDir(x,y,curr_hour+1),'deg');
        windangle = mean(windDataAngles(min-10:min+10));
        windspeed = mean(windDataSpeed(min-10:min+10));
        if windspeed > 0.001
            cog_data = cat(1, cog_data,cog);
            sog_data = cat(1, sog_data,sog);
            wave_data = cat(1, wave_data,ssa(psi+wave_dir, 'deg'));
            wave_size_data = cat(1, wave_size_data,waveSize(x, y, curr_hour + 1));
            wind_angle_data = cat(1, wind_angle_data, windangle);
            wind_speed_data = cat(1, wind_speed_data, windspeed);
            AwindDir = mean(AbsoluteWind_int(min-10:min+10));
        end
        

        if ~mod(gps_data.utc_time(min),3600)
            str = sprintf('| Day: %d \t | Hour: %d \t |', ...
                (floor(curr_hour/24)+1), (mod(curr_hour,24)));
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
