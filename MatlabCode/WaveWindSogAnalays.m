clc; clearvars; close all;

%% load data
path = './Mausund221241/';
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

windDataAngles = interp1(windData.timestamp, ssa(windData.angle,'deg' ),gps_data.timestamp);
windDataSpeed = interp1(windData.timestamp, windData.speed,gps_data.timestamp);
AbsoluteWind_int = interp1(AbsoluteWind.timestamp, ssa(AbsoluteWind.dir,'deg'),gps_data.timestamp);
cog_data = [];
sog_data = [];
wind_data = [];
wave_data = [];
wave_size_data = [];
wind_angle_data = [];
wind_speed_data = [];
psi_data= [];
windDir_data = [];
wave_data_2 = [];
wind_data_2 = [];
wave_data_3 = [];
wind_data_3 = [];

x = 0;
y = 0;
disp('Done formating')
disp('Start running through data')
%% run
for min = 60 : length(gps_data.sog) - 60
    if ~mod(gps_data.utc_time(min),60)
        curr_hour = floor(double(gps_data.utc_time(min))/3600) ...
            + 24*(double(gps_data.utc_day(min)) - 1);
        avrager = 30;
        lat = mean(rad2deg(gps_data.lat(min-avrager:min+avrager)));
        lon = mean(rad2deg(gps_data.lon(min-avrager:min+avrager)));
        cog = rad2deg(mean(gps_data.cog(min-avrager:min+avrager)));
        psi = rad2deg(mean(EstimatedState.psi(min-avrager:min+avrager)));
        sog = mean(gps_data.sog(min-avrager:min+avrager));
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
        wind_dir = ssa(windDir(x,y,curr_hour+1),'deg');
        windangle = mean(windDataAngles(min-avrager:min+avrager));
        windspeed = mean(windDataSpeed(min-avrager:min+avrager));
        if waveSize(x, y, curr_hour + 1) > 0.001
            cog_data = cat(1, cog_data,cog);
            psi_data = cat(1, psi_data,psi);
            sog_data = cat(1, sog_data,sog);
            wave_data = cat(1, wave_data,ssa(psi+wave_dir, 'deg'));
            wave_data_2 = cat(1, wave_data_2, ssa(ssa(wave_dir + 180,'deg') - psi , 'deg'));
            wind_data_2 = cat(1, wind_data_2, ssa(ssa(wind_dir + 180,'deg') - psi , 'deg'));
            wave_data_3 = cat(1, wave_data_3, ssa(ssa(wave_dir + 180,'deg') - cog , 'deg'));
            wind_data_3 = cat(1, wind_data_3, ssa(ssa(wind_dir + 180,'deg') - cog , 'deg'));
            windDir_data = cat(1, windDir_data, wind_dir);
            wave_size_data = cat(1, wave_size_data,waveSize(x, y, curr_hour + 1));
            wind_angle_data = cat(1, wind_angle_data, windangle);
            wind_speed_data = cat(1, wind_speed_data, windspeed);
            AwindDir = mean(AbsoluteWind_int(min-avrager:min+avrager));
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
scatter3(wave_data_2,wave_size_data,sog_data)
xlabel 'Relative wave direction',ylabel 'Wave Size',zlabel 'SOG';
figure(4)
scatter3(wave_data_3,wave_size_data,sog_data)
xlabel 'Relative wave direction to Cog',ylabel 'Wave Size',zlabel 'SOG';
figure(2)
scatter3(wave_data_2,wind_angle_data, sog_data)
xlabel 'Relative wave direction',ylabel 'Relative Wind Angle',zlabel 'SOG';
figure(3)
scatter3(wind_speed_data,wind_angle_data, sog_data)
xlabel 'Wind Speed',ylabel 'Relative Wind Angle',zlabel 'SOG';
