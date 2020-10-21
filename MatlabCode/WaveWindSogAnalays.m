%% Clear workspace
clc; clearvars; close all;

%% Data That can be downladed from neptus that are relevant
% AbsoluteWind,Depth,DesiredHeading,DesiredPath,DesiredSpeed,DesiredZ,GpsFix,RelativeWind,RemoteSensorInfo,EstimatedState,EulerAngles
% GpsFix,RelativeWind,EulerAngles
%% load data
path = './Trondheim111728/';
addpath(path);
gpsFix = load('GpsFix.mat');
gps_data = gpsFix.GpsFix;
RelativeWind = load('RelativeWind.mat');
windData = RelativeWind.RelativeWind;
EulerAngles = load('EulerAngles.mat');
EulerAngles = EulerAngles.EulerAngles;
EulerAngles.psi = ssa(EulerAngles.psi,'deg');
rmpath(path)
%load('weatherData_2020-7-1_2020-7-2.mat')
load('weatherData_2020-2-20_2020-2-20.mat')
%load('weatherData_2020-5-28_2020-5-28.mat')
disp('Done loading data')
%% Format and interpolations

messuredRelWindDir = interp1(windData.timestamp, ssa(windData.angle,'deg' ),gps_data.timestamp);
messuredRelWindSpeed = interp1(windData.timestamp, windData.speed,gps_data.timestamp);

% Data to be saved for plots
cog_data = [];
sog_data = [];
wind_data = [];
waveDir_data = [];
ForecastWaveSize_data = [];
messuredRelWindDir_data = [];
messuredRelWindSpeed_data = [];
psi_data = [];
ForecastWindDir_data = [];
relWaveDir_data = [];
relWindDir_data = [];
relWaveDirToCog_data = [];
relWindDirToCog_data = [];
ForecastWaveFreq_data = [];
ForcastWindSpeed_data = [];

x = 0;
y = 0;
avrager = 20;
first = true;
[latSize,longSize] = size(latitudeMapWave);

disp('Done formating')
disp('Start running through data')
%% run
for min = (2*avrager) : length(gps_data.sog) - (2*avrager)
    if ~mod(gps_data.utc_time(min),avrager)
        curr_hour = floor(double(gps_data.utc_time(min))/3600) ...
            + 24*(double(gps_data.utc_day(min)-gps_data.utc_day(1)));
        
        lat = mean(rad2deg(gps_data.lat(min-avrager:min+avrager)));
        lon = mean(rad2deg(gps_data.lon(min-avrager:min+avrager)));

        
        increment = 0.0001; % resolution lat and lon in gps
        num_increments = 0;
        indexes_found = false;
        
        % Find closest
        while ~indexes_found
            for ii = 1:latSize
                for jj = 1:longSize
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
        
        cog = rad2deg(mean(gps_data.cog(min-avrager:min+avrager)));
        psi = rad2deg(mean(EulerAngles.psi(min-avrager:min+avrager)));
        sog = mean(gps_data.sog(min-avrager:min+avrager));
        curWaveDir = ssa(waveDir(x,y,curr_hour+1),'deg');
        curWindDir = ssa(windDir(x,y,curr_hour+1),'deg');
        ForcastWindSpeed = windSpeed(x,y,curr_hour + 1);
        curMessuredRelWindDir = mean(messuredRelWindDir(min-avrager:min+avrager));
        curMessuredRelWindSpeed = mean(messuredRelWindSpeed(min-avrager:min+avrager));
        
        
        if waveSize(x, y, curr_hour + 1) < 0.001
            ForecastWaveSize_data = cat(1, ForecastWaveSize_data, ForecastWaveSize_data(end));
        else
            ForecastWaveSize_data = cat(1, ForecastWaveSize_data, waveSize(x, y, curr_hour + 1));
        end
        if waveHZ(x,y,curr_hour+1) > 12
            ForecastWaveFreq_data = cat(1,ForecastWaveFreq_data, ForecastWaveFreq_data(end));
        else
            ForecastWaveFreq_data = cat(1,ForecastWaveFreq_data, waveHZ(x,y,curr_hour+1));
        end
        
        % Save current data
        cog_data = cat(1, cog_data,cog);
        psi_data = cat(1, psi_data,psi);
        sog_data = cat(1, sog_data,sog);
        waveDir_data = cat(1, waveDir_data, ssa(psi+curWaveDir, 'deg'));
        relWaveDir_data = cat(1, relWaveDir_data, ssa(ssa(curWaveDir + 180,'deg') - psi , 'deg'));
        relWindDir_data = cat(1, relWindDir_data, ssa(ssa(curWindDir + 180,'deg') - psi , 'deg'));
        relWaveDirToCog_data = cat(1, relWaveDirToCog_data, ssa(ssa(curWaveDir + 180,'deg') - cog , 'deg'));
        relWindDirToCog_data = cat(1, relWindDirToCog_data, ssa(ssa(curWindDir + 180,'deg') - cog , 'deg'));
        ForecastWindDir_data = cat(1, ForecastWindDir_data, curWindDir);;
        messuredRelWindDir_data = cat(1, messuredRelWindDir_data, curMessuredRelWindDir);
        messuredRelWindSpeed_data = cat(1, messuredRelWindSpeed_data, curMessuredRelWindSpeed);
        ForcastWindSpeed_data = cat(1, ForcastWindSpeed_data, ForcastWindSpeed);

        if ~mod(gps_data.utc_time(min),3600) || first
            str = sprintf('| Day: %d \t | Hour: %d \t |', ...
                (floor(curr_hour/24)+1), (mod(curr_hour,24)));
            disp(str)
            first = false;
        end
    end
    
end
disp('Run Success')
%%
disp('Plotting Data')
figure(1)
for i = 1:length(relWaveDir_data)
    if (ForecastWaveFreq_data(i) < 8)
        scatter3(relWaveDir_data(i),ForecastWaveSize_data(i),sog_data(i), 'b')
    elseif (ForecastWaveFreq_data(i) < 9)
        scatter3(relWaveDir_data(i),ForecastWaveSize_data(i),sog_data(i), 'r')
    else
        scatter3(relWaveDir_data(i),ForecastWaveSize_data(i),sog_data(i), 'g')
    end
    hold on
end
xlabel 'Relative wave direction',ylabel 'Wave Size',zlabel 'SOG';
hold off
figure(4)
scatter3(relWaveDir_data,ForecastWaveFreq_data,sog_data)
xlabel 'Relative wave direction',ylabel 'Wave period',zlabel 'SOG';
figure(2)
scatter3(relWaveDir_data,relWindDir_data, sog_data)
xlabel 'Relative wave direction',ylabel 'Relative Wind Angle',zlabel 'SOG';
figure(3)
scatter3(messuredRelWindSpeed_data,messuredRelWindDir_data, sog_data)
xlabel 'Wind Speed',ylabel 'Relative Wind Angle',zlabel 'SOG';
figure(5)
scatter3(ForecastWaveSize_data,ForecastWaveFreq_data, sog_data)
xlabel 'Wave Size',ylabel 'Wave period',zlabel 'SOG';
disp('Done')
