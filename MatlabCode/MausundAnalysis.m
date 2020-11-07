%% Clear workspace
clc; clearvars; close all;

%% Data That can be downladed from neptus that are relevant
% AbsoluteWind,Depth,DesiredHeading,DesiredPath,DesiredSpeed,DesiredZ,GpsFix,RelativeWind,RemoteSensorInfo,EstimatedState,EulerAngles
% GpsFix,RelativeWind,EulerAngles

% Data to be saved for plots
cog_data = [];
sog_data = [];
psi_data = [];
ForecastWaveSize_data = [];
messuredRelWindDir_data = [];
messuredRelWindSpeed_data = [];
relWaveDir_data = [];
relWindDir_data = [];
ForecastWaveFreq_data = [];
ForcastWindSpeed_data = [];
CurrentDir_data = [];
CurrentSpeed_data = [];
speed_data = [];


avrager = 4*60; % average over x min
for i = 2:7
    disp('Loading new data')
    %% load data
%     if i == 1
%         path = './Mausund200701_181204/';
%         addpath(path);
%         gpsFix = load('GpsFix.mat');
%         RelativeWind = load('RelativeWind.mat');
%         EulerAngles = load('EulerAngles.mat');
%         rmpath(path)
%         load('weatherData_2020-7-1_2020-7-2.mat')
%         load('currentweatherData_2020-7-1_2020-7-3.mat')
%         disp('Done loading data')
%     end
    if i == 2
        path = './Mausund200701_221241/';
        addpath(path);
        gpsFix = load('GpsFix.mat');
        RelativeWind = load('RelativeWind.mat');
        EulerAngles = load('EulerAngles.mat');
        load('weatherData_2020-7-1_2020-7-2.mat')
        load('currentweatherData_2020-7-1_2020-7-3.mat')
        rmpath(path)
        disp('Done loading data')
    end
%     if i == 3
%         path = './Mausund200703_062402/';
%         addpath(path);
%         gpsFix = load('GpsFix.mat');
%         RelativeWind = load('RelativeWind.mat');
%         EulerAngles = load('EulerAngles.mat');
%         rmpath(path)
%         load('weatherData_2020-7-3_2020-7-4.mat')
%         load('currentweatherData_2020-7-3_2020-7-4.mat')
%         disp('Done loading data')
%     end
%     if i == 4
%         path = './Mausund200703_080820/';
%         addpath(path);
%         gpsFix = load('GpsFix.mat');
%         RelativeWind = load('RelativeWind.mat');
%         EulerAngles = load('EulerAngles.mat');
%         rmpath(path)
%         disp('Done loading data')
    %end
    if i == 3
        path = './Mausund200703_132548/';
        addpath(path);
        gpsFix = load('GpsFix.mat');
        RelativeWind = load('RelativeWind.mat');
        EulerAngles = load('EulerAngles.mat');
        load('weatherData_2020-7-3_2020-7-4.mat')
        load('currentweatherData_2020-7-3_2020-7-4.mat')
        rmpath(path)
        disp('Done loading data')
    end
    if i == 4
        path = './Mausund200703_215938/';
        addpath(path);
        gpsFix = load('GpsFix.mat');
        RelativeWind = load('RelativeWind.mat');
        EulerAngles = load('EulerAngles.mat');
        load('currentweatherData_2020-7-4_2020-7-5.mat')
        rmpath(path)
        disp('Done loading data')
    end
    if i == 5
        path = './Mausund200705_120030/';
        addpath(path);
        gpsFix = load('GpsFix.mat');
        RelativeWind = load('RelativeWind.mat');
        EulerAngles = load('EulerAngles.mat');
        rmpath(path)
        load('weatherData_2020-7-5_2020-7-5.mat')
        load('currentweatherData_2020-7-5_2020-7-5.mat')
        disp('Done loading data')
    end
    if i == 6
        path = './Mausund200706_154608/';
        addpath(path);
        gpsFix = load('GpsFix.mat');
        RelativeWind = load('RelativeWind.mat');
        EulerAngles = load('EulerAngles.mat');
        rmpath(path)
        load('weatherData_2020-7-6_2020-7-6.mat')
        load('currentweatherData_2020-7-6_2020-7-6.mat')
        disp('Done loading data')
    end
     if i == 7
        path = './Mausund200709_53748/';
        addpath(path);
        gpsFix = load('GpsFix.mat');
        RelativeWind = load('RelativeWind.mat');
        EulerAngles = load('EulerAngles.mat');
        rmpath(path)
        load('weatherData_2020-7-9_2020-7-9.mat')
        load('currentweatherData_2020-7-9_2020-7-9.mat')
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
    [curlatSize,curlongSize] = size(latitudeCurrentMap);
    first = true;
    disp('Done formating')
    disp('Start running through data')
    %% run
    for m = (20*120) : length(gps_data.sog) - (20*120)
        if ~mod(gps_data.utc_time(m),avrager)
            curr_hour = floor(double(gps_data.utc_time(m))/3600) ...
                + 24*(double(gps_data.utc_day(m)-gps_data.utc_day(1)));
            
            % Latidtude and longitude position of the vessel
            lat = mean(rad2deg(gps_data.lat(m-avrager:m+avrager)));
            lon = mean(rad2deg(gps_data.lon(m-avrager:m+avrager)));
            
            % Heading, Cog and Sog
            cog = rad2deg(mean(gps_data.cog(m-avrager:m+avrager)));
            psi = rad2deg(mean(EulerAngles.psi(m-avrager:m+avrager)));
            sog = mean(gps_data.sog(m-avrager:m+avrager));

            % Find position in wave data
            error_map = sqrt((latitudeMapWave - lat).^2 + (longitudeMapWave - lon).^2);
            [x,y] = find(error_map == min(error_map, [], 'all'));
            
            % Find position in Current data
            error_map = sqrt((latitudeCurrentMap - lat).^2 + (longitudeCurrentMap - lon).^2);
            [xcurrent,ycurrent] = find(error_map == min(error_map, [], 'all'));
            
            % Wind and wave directions and size at given time and postion
            curWaveDir = ssa(waveDir(x,y,curr_hour+1),'deg');
            curWindDir = ssa(windDir(x,y,curr_hour+1),'deg');
            ForcastWindSpeed = windSpeed(x,y,curr_hour + 1);
            
            if waveSize(x, y, curr_hour + 1) < 0.001
                ForecastWaveSize_data = cat(1, ForecastWaveSize_data, ForecastWaveSize_data(end));
            else
                ForecastWaveSize_data = cat(1, ForecastWaveSize_data, waveSize(x, y, curr_hour + 1));
            end
            
            % Wave frequency at given time and position
            ForecastWaveFreq_data = cat(1,ForecastWaveFreq_data, waveHZ(x,y,curr_hour+1));
            if waveHZ(x,y,curr_hour+1) < 0.1 
                disp([num2str(waveHZ(x,y,curr_hour+1)) num2str(lat) num2str(lon)])
            end
            % Current vector at given time and position
            currentNorthCur = currentNorth(xcurrent,ycurrent,curr_hour+1);
            currentEastCur = currentEast(xcurrent,ycurrent,curr_hour+1);
            current_vector = [currentNorthCur; currentEastCur];
            
            % Velocity vector of the vessel
            Sog_vector = [sog*cos(deg2rad(cog)); sog*sin(deg2rad(cog))];
            Velocity_vector = Sog_vector - current_vector;
            speed = norm(Velocity_vector);
            speed_data = cat(1,speed_data,speed);
            % Angle between velocity and current direction
            currentDir = atan2d( current_vector(2), current_vector(1));
            VelDir = atan2d( Velocity_vector(2), Velocity_vector(1));
            CurVsVelAnglre = VelDir- currentDir;
            % magnitude of the current
            currentSpeed = norm(current_vector);
            
            % Messured wind speed and direction relative to the vessel
            curMessuredRelWindDir = mean(messuredRelWindDir(m-avrager:m+avrager));
            curMessuredRelWindSpeed = mean(messuredRelWindSpeed(m-avrager:m+avrager));
            
            wave_vector = [ForecastWaveSize_data(end)*cos(deg2rad(curWaveDir));...
                ForecastWaveSize_data(end)*sin(deg2rad(curWaveDir))];
            wind_vector = [ForcastWindSpeed*cos(rad2deg(curWindDir));...
                ForcastWindSpeed*sin(rad2deg(curWindDir))];
            
            wave_current_vector =  current_vector + wave_vector;
            disturbance_vector = current_vector + wave_vector + wind_vector;
            %currentDir = rad2deg(acos(dot(Sog_vector,wave_current_vector)/(norm(Sog_vector)*norm(wave_current_vector))));
            
            % Save current data
            cog_data = cat(1, cog_data,cog);
            psi_data = cat(1, psi_data,psi);
            sog_data = cat(1, sog_data,sog);
            relWaveDir_data = cat(1, relWaveDir_data, ssa(ssa(curWaveDir - psi, 'deg') - 180 , 'deg'));
            relWindDir_data = cat(1, relWindDir_data, ssa(ssa(curWindDir - psi, 'deg') - 180 , 'deg'));
            messuredRelWindDir_data = cat(1, messuredRelWindDir_data, curMessuredRelWindDir);
            messuredRelWindSpeed_data = cat(1, messuredRelWindSpeed_data, curMessuredRelWindSpeed);
            ForcastWindSpeed_data = cat(1, ForcastWindSpeed_data, ForcastWindSpeed);
            CurrentDir_data = cat(1, CurrentDir_data, ssa(ssa(currentDir - psi,'deg'), 'deg'));
            CurrentSpeed_data = cat(1, CurrentSpeed_data, currentSpeed);
            
            if ~mod(gps_data.utc_time(m),3600) || first
                str = sprintf('| Day: %d  | Hour: %d \t|', ...
                    (floor(curr_hour/24)+1) + gps_data.utc_day(1)-1, (mod(curr_hour,24)));
                disp(str)
                first = false;
            end
        end

    end
    disp('Run Success')
end
%%
CorrData = [sog_data, abs(relWaveDir_data) abs(relWindDir_data)  ForcastWindSpeed_data ...
    abs(CurrentDir_data) CurrentSpeed_data ForecastWaveFreq_data ForecastWaveSize_data];
corrCoefs = corrcoef(CorrData);
    
nninputs =  double([relWaveDir_data relWindDir_data  ForcastWindSpeed_data ...
    CurrentDir_data CurrentSpeed_data ForecastWaveFreq_data ForecastWaveSize_data])';
%%
disp('Plotting Data')
table1 = [];table2 = [];table3 = [];
for i = 1: length(ForecastWaveSize_data)
    if ForecastWaveSize_data(i) < 2
        table1 = cat(1,table1,[relWaveDir_data(i) sog_data(i)]);
    elseif ForecastWaveSize_data(i) < 2.5
        table2 = cat(1,table2,[relWaveDir_data(i) sog_data(i)]);
    else
        table3 = cat(1,table3,[relWaveDir_data(i) sog_data(i)]);
    end
end
figure;
scatter(table1(:,1), table1(:,2))
hold on 
scatter(table2(:,1), table2(:,2))
scatter(table3(:,1), table3(:,2))
legend('Wave Size < 2', '2 < Wave Size < 3', 'Wave Size > 3')
xlabel 'Relative wave direction',ylabel 'sog';
hold off

%% 
% figure;
% scatter3((relWaveDir_data),ForecastWaveFreq_data,sog_data)
% xlabel 'Relative wave direction',ylabel 'Wave period',zlabel 'SOG';

table1 = [];table2 = [];table3 = [];
for i = 1: length(ForecastWaveFreq_data)
    if ForecastWaveFreq_data(i) < 6.5
        table1 = cat(1,table1,[relWaveDir_data(i) sog_data(i)]);
    elseif ForecastWaveFreq_data(i) < 8
        table2 = cat(1,table2,[relWaveDir_data(i) sog_data(i)]);
    else
        table3 = cat(1,table3,[relWaveDir_data(i) sog_data(i)]);
    end
end
figure;
scatter(table1(:,1), table1(:,2))
hold on 
scatter(table2(:,1), table2(:,2))
scatter(table3(:,1), table3(:,2))
legend('Period < 6.5', '7< Period < 8', 'Period > 8')
xlabel 'Relative wave direction',ylabel 'sog';
hold off
%%
% figure;
% scatter3(relWaveDir_data,relWindDir_data, sog_data)
%xlabel 'Relative wave direction',ylabel 'Relative Wind Angle',zlabel 'SOG';
table1 = [];table2 = [];table3 = [];
for i = 1: length(ForecastWaveSize_data)
    if ForecastWaveSize_data(i) < 2
        table1 = cat(1,table1,[ForecastWaveFreq_data(i) sog_data(i)]);
    elseif ForecastWaveSize_data(i) < 3
        table2 = cat(1,table2,[ForecastWaveFreq_data(i) sog_data(i)]);
    else
        table3 = cat(1,table3,[ForecastWaveFreq_data(i) sog_data(i)]);
    end
end
figure;
scatter(table1(:,1), table1(:,2))
hold on 
scatter(table2(:,1), table2(:,2))
scatter(table3(:,1), table3(:,2))
legend('Wave Size < 2', '2 < Wave Size < 3', 'Wave Size > 3')
xlabel 'Wave period',ylabel 'sog';
hold off
%%
table1 = [];table2 = [];table3 = [];
for i = 1: length(ForecastWaveSize_data)
    if ForecastWaveFreq_data(i) < 6.5
        table1 = cat(1,table1,[ForecastWaveSize_data(i) sog_data(i)]);
    elseif ForecastWaveFreq_data(i) < 8
        table2 = cat(1,table2,[ForecastWaveSize_data(i) sog_data(i)]);
    else
        table3 = cat(1,table3,[ForecastWaveSize_data(i) sog_data(i)]);
    end
end
figure;
scatter(table1(:,1), table1(:,2))
hold on 
scatter(table2(:,1), table2(:,2))
scatter(table3(:,1), table3(:,2))
legend('Wave Period < 6.5', '6.5 < Wave Period < 8', 'Wave Period > 8')
xlabel 'Wave Size',ylabel 'sog';
hold off
%%
% figure
% scatter3(ForcastWindSpeed_data,(relWindDir_data), sog_data)
% xlabel 'Wind Speed',ylabel 'Relative Wind Angle',zlabel 'SOG';
table1 = [];table2 = [];table3 = [];
for i = 1: length(ForcastWindSpeed_data)
    if ForcastWindSpeed_data(i) < 3
        table1 = cat(1,table1,[relWindDir_data(i) sog_data(i)]);
    elseif ForcastWindSpeed_data(i) < 6
        table2 = cat(1,table2,[relWindDir_data(i) sog_data(i)]);
    else
        table3 = cat(1,table3,[relWindDir_data(i) sog_data(i)]);
    end
end
figure;
scatter(table1(:,1), table1(:,2))
hold on 
scatter(table2(:,1), table2(:,2))
scatter(table3(:,1), table3(:,2))
legend('Wind Speed < 3', '3 < Wind Speed < 6', 'Wind Speed > 6')
xlabel 'Relative wind direction',ylabel 'sog';
hold off
%%
% figure
% scatter3(messuredRelWindSpeed_data,(messuredRelWindDir_data), sog_data)
% xlabel 'Wind Speed',ylabel 'Relative Wind Angle',zlabel 'SOG'
table1 = [];table2 = [];table3 = [];
for i = 1: length(messuredRelWindSpeed_data)
    if messuredRelWindSpeed_data(i) < 3
        table1 = cat(1,table1,[messuredRelWindDir_data(i) sog_data(i)]);
    elseif messuredRelWindSpeed_data(i) < 6
        table2 = cat(1,table2,[messuredRelWindDir_data(i) sog_data(i)]);
    else
        table3 = cat(1,table3,[messuredRelWindDir_data(i) sog_data(i)]);
    end
end
figure;
scatter(table1(:,1), table1(:,2))
hold on 
scatter(table2(:,1), table2(:,2))
scatter(table3(:,1), table3(:,2))
legend('Wind Speed < 3', '3 < Wind Speed < 6', 'Wind Speed > 6')
xlabel 'Measured Relative wind direction',ylabel 'sog';
hold off
%%
% figure
% scatter3((CurrentDir_data),CurrentSpeed_data, sog_data)
% xlabel 'CurDir',ylabel 'CurSpeed',zlabel 'SOG';
table1 = [];table2 = [];table3 = [];
for i = 1: length(CurrentSpeed_data)
    if CurrentSpeed_data(i) < 0.15
        table1 = cat(1,table1,[CurrentDir_data(i) sog_data(i)]);
    elseif CurrentSpeed_data(i) < 0.3
        table2 = cat(1,table2,[CurrentDir_data(i) sog_data(i)]);
    else
        table3 = cat(1,table3,[CurrentDir_data(i) sog_data(i)]);
    end
end
figure;
scatter(table1(:,1), table1(:,2))
hold on 
scatter(table2(:,1), table2(:,2))
scatter(table3(:,1), table3(:,2))
legend('Curent speed < 0.15', '0.15< Curent speed <0.3', 'Curent speed > 0.3')
xlabel 'Relative Current angle',ylabel 'sog';
hold off
%%
figure
yvalues = {'Sog','relWaveDir','relWindDir','ForcastWindSpeed',...
    'CurrentDir', 'CurrentSpeed', 'ForecastWaveFreq', 'ForecastWaveSize'};
xvalues = {'Sog','relWaveDir','relWindDir','ForcastWindSpeed',...
    'CurrentDir', 'CurrentSpeed', 'ForecastWaveFreq', 'ForecastWaveSize'};
h = heatmap(xvalues,yvalues,corrCoefs);
h.Title = 'Covariance Matrix';
%%
figure;
count = 0;
for i = 1 : length(sog_data)
    if ForecastWaveFreq_data(i) < 6 && ForecastWaveSize_data(i) > 4 ...
            && messuredRelWindSpeed_data(i) > 3 && abs(relWindDir_data(i)) > 120 ...
            && CurrentSpeed_data(i) < 0.2
        plot(count,sog_data(i), 'o')
        count = count +1;
        hold on
    end
end
ylabel 'SOG' ; xlabel 'Sample'; title 'Speed at desired environment'
hold off
% %%
% disp('Doing Neural')
% [net,perform, netError, netTrainState] = neuralNet(nninputs, double(sog_data)');
% for i = 1:10
%     [temp_net, temp_perform, temp_netError, temp_netTrainState] =...
%         neuralNet(nninputs,double(sog_data)');
%     if temp_perform < perform
%         net = temp_net; perform = temp_perform;
%         netError = temp_netError; netTrainState = temp_netTrainState;
%     end
% end
% disp(num2str(perform))
% figure, ploterrhist(netError)
% %%
% for i = 1: length(sog_data)
%     if sog_data(i)> 0.8
%         x = net(nninputs(:,i));
%         disp([num2str(sog_data(i)) num2str(x)])
%     end
% end

%%
table1 = [];table2 = [];table3 = [];
for i = 1: length(ForecastWaveFreq_data)
    if sog_data(i) > 0.8
        table1 = cat(1,table1,[CurrentDir_data(i) CurrentSpeed_data(i)]);
    elseif ForecastWaveFreq_data(i) < 8
        table2 = cat(1,table2,[relWaveDir_data(i) sog_data(i)]);
    else
        table3 = cat(1,table3,[relWaveDir_data(i) sog_data(i)]);
    end
end
figure;
scatter(table1(:,1), table1(:,2))
hold on 
%scatter(table2(:,1), table2(:,2))
%scatter(table3(:,1), table3(:,2))
%legend('Period < 6.5', '7< Period < 8', 'Period > 8')
xlabel 'Relative wave direction',ylabel 'freq';
hold off
%%
disp('Done')
% 
% 
% figure; scatter3(speed_data, CurrentDir_data, sog_data)
% figure; scatter3(CurrentSpeed_data, CurrentDir_data, speed_data)
% figure; scatter3(ForecastWaveSize_data, ForecastWaveFreq_data, speed_data)
% figure; scatter3(ForecastWaveSize_data, relWaveDir_data, speed_data)


