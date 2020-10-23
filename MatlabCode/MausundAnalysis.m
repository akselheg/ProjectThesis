%% Clear workspace
clc; clearvars; close all;

%% Data That can be downladed from neptus that are relevant
% AbsoluteWind,Depth,DesiredHeading,DesiredPath,DesiredSpeed,DesiredZ,GpsFix,RelativeWind,RemoteSensorInfo,EstimatedState,EulerAngles
% GpsFix,RelativeWind,EulerAngles



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

avrager = 4*60; % average over x min
for i = 1: 9
    %% load data
    if i == 1
        path = './Mausund200701_181204/';
        addpath(path);
        gpsFix = load('GpsFix.mat');
        RelativeWind = load('RelativeWind.mat');
        EulerAngles = load('EulerAngles.mat');
        rmpath(path)
        load('weatherData_2020-7-1_2020-7-2.mat')
        disp('Done loading data')
    end
    if i == 2
        path = './Mausund200701_221241/';
        addpath(path);
        gpsFix = load('GpsFix.mat');
        RelativeWind = load('RelativeWind.mat');
        EulerAngles = load('EulerAngles.mat');
        rmpath(path)
        disp('Done loading data')
    end
    if i == 3
        path = './Mausund200703_062402/';
        addpath(path);
        gpsFix = load('GpsFix.mat');
        RelativeWind = load('RelativeWind.mat');
        EulerAngles = load('EulerAngles.mat');
        rmpath(path)
        load('weatherData_2020-7-3_2020-7-4.mat')
        disp('Done loading data')
    end
    if i == 4
        path = './Mausund200703_080820/';
        addpath(path);
        gpsFix = load('GpsFix.mat');
        RelativeWind = load('RelativeWind.mat');
        EulerAngles = load('EulerAngles.mat');
        rmpath(path)
        disp('Done loading data')
    end
    if i == 5
        path = './Mausund200703_132548/';
        addpath(path);
        gpsFix = load('GpsFix.mat');
        RelativeWind = load('RelativeWind.mat');
        EulerAngles = load('EulerAngles.mat');
        rmpath(path)
        disp('Done loading data')
    end
    if i == 6
        path = './Mausund200703_215938/';
        addpath(path);
        gpsFix = load('GpsFix.mat');
        RelativeWind = load('RelativeWind.mat');
        EulerAngles = load('EulerAngles.mat');
        rmpath(path)
        disp('Done loading data')
    end
    if i == 7
        path = './Mausund200705_120030/';
        addpath(path);
        gpsFix = load('GpsFix.mat');
        RelativeWind = load('RelativeWind.mat');
        EulerAngles = load('EulerAngles.mat');
        rmpath(path)
        load('weatherData_2020-7-5_2020-7-5.mat')
        disp('Done loading data')
    end
    if i == 8
        path = './Mausund200706_154608/';
        addpath(path);
        gpsFix = load('GpsFix.mat');
        RelativeWind = load('RelativeWind.mat');
        EulerAngles = load('EulerAngles.mat');
        rmpath(path)
        load('weatherData_2020-7-6_2020-7-6.mat')
        disp('Done loading data')
    end
     if i == 9
        path = './Mausund200709_53748/';
        addpath(path);
        gpsFix = load('GpsFix.mat');
        RelativeWind = load('RelativeWind.mat');
        EulerAngles = load('EulerAngles.mat');
        rmpath(path)
        load('weatherData_2020-7-9_2020-7-9.mat')
        disp('Done loading data')
    end
    %% Format and interpolations
    gps_data = gpsFix.GpsFix;
    windData = RelativeWind.RelativeWind;
    EulerAngles = EulerAngles.EulerAngles;
    EulerAngles.psi = ssa(EulerAngles.psi,'deg');
    messuredRelWindDir = interp1(windData.timestamp, ssa(windData.angle,'deg' ),gps_data.timestamp);
    messuredRelWindSpeed = interp1(windData.timestamp, windData.speed,gps_data.timestamp);
    [latSize,longSize] = size(latitudeMapWave);
    first = true;

    x = 0;
    y = 0;
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
            
            ForecastWaveFreq_data = cat(1,ForecastWaveFreq_data, waveHZ(x,y,curr_hour+1));

            % Save current data
            cog_data = cat(1, cog_data,cog);
            psi_data = cat(1, psi_data,psi);
            sog_data = cat(1, sog_data,sog);
            waveDir_data = cat(1, waveDir_data, ssa(psi+curWaveDir, 'deg'));
            relWaveDir_data = cat(1, relWaveDir_data, ssa(ssa(curWaveDir + 180,'deg') - psi , 'deg'));
            relWindDir_data = cat(1, relWindDir_data, ssa(ssa(curWindDir + 180,'deg') - psi , 'deg'));
            relWaveDirToCog_data = cat(1, relWaveDirToCog_data, ssa(ssa(curWaveDir + 180,'deg') - cog , 'deg'));
            relWindDirToCog_data = cat(1, relWindDirToCog_data, ssa(ssa(curWindDir + 180,'deg') - cog , 'deg'));
            ForecastWindDir_data = cat(1, ForecastWindDir_data, curWindDir);
            messuredRelWindDir_data = cat(1, messuredRelWindDir_data, curMessuredRelWindDir);
            messuredRelWindSpeed_data = cat(1, messuredRelWindSpeed_data, curMessuredRelWindSpeed);
            ForcastWindSpeed_data = cat(1, ForcastWindSpeed_data, ForcastWindSpeed);

            if ~mod(gps_data.utc_time(min),3600) || first
                str = sprintf('| Day: %d \t | Hour: %d \t |', ...
                    (floor(curr_hour/24)+1) + gps_data.utc_day(1)-1, (mod(curr_hour,24)));
                disp(str)
                first = false;
            end
        end

    end
    disp('Run Success')
end
nninputs = [ForecastWaveSize_data relWaveDir_data relWindDir_data ...
    ForcastWindSpeed_data ForecastWaveFreq_data];
%%
disp('Plotting Data')
figure(1)
scatter3(relWaveDir_data,ForecastWaveSize_data,sog_data)
% for i = 1:length(relWaveDir_data)
%     if (ForecastWaveFreq_data(i) < 8)
%         scatter3(relWaveDir_data(i),ForecastWaveSize_data(i),sog_data(i), 'b')
%     elseif (ForecastWaveFreq_data(i) < 9)
%         scatter3(relWaveDir_data(i),ForecastWaveSize_data(i),sog_data(i), 'r')
%     else
%         scatter3(relWaveDir_data(i),ForecastWaveSize_data(i),sog_data(i), 'g')
%     end
%     hold on
% end
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


