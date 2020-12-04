%% Clear workspace
clc; clearvars; close all;

%% Data That can be downladed from neptus that are relevant
% AbsoluteWind,Depth,DesiredHeading,DesiredPath,DesiredSpeed,DesiredZ,GpsFix,RelativeWind,RemoteSensorInfo,EstimatedState,EulerAngles
% GpsFix,RelativeWind,EulerAngles

% Data to be saved for plots
lon_data = [];
lat_data = [];
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
Vr_data = [];
VrDir_data = [];
CurrentDirVrDir_data = [];
relWaveDirVrDir_data = [];
relWindDirVrDir_data = [];
CurrentDircog_data = [];
relWaveDircog_data = [];
relWindDircog_data = [];
VcDir_data = [];
xmax = 0; ymax = 0; ymin = inf; xmin = inf;
avrager = 6*60; % average over x min
for i = 1:6
    disp('Loading new data')
    %% load data
    if i == 1
        path = './Mausund200701_181204/';
        addpath(path);
        gpsFix = load('GpsFix.mat');
        RelativeWind = load('RelativeWind.mat');
        EulerAngles = load('EulerAngles.mat');
        rmpath(path)
        load('weatherData_2020-7-1_2020-7-2.mat')
        load('currentweatherData_2020-7-1_2020-7-3.mat')
        disp('Done loading data')
    end
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
    if i == 3
        path = './Mausund200703_080820/';
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
%     if i == 4
%         path = './Mausund200703_215938/';
%         addpath(path);
%         gpsFix = load('GpsFix.mat');
%         RelativeWind = load('RelativeWind.mat');
%         EulerAngles = load('EulerAngles.mat');
%         load('currentweatherData_2020-7-4_2020-7-5.mat')
%         rmpath(path)
%         disp('Done loading data')
%     end
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
    for m = (10*120) : length(gps_data.sog) - (10*120)
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
            if x > xmax; xmax = x; end
            if y > ymax; ymax = y; end
            if x < xmin; xmin = x; end
            if y < ymin; ymin = y; end
            lon_data = cat(1,lon_data, lon);
            lat_data = cat(1,lat_data, lat);
            
         
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
            Vc = [currentNorthCur; currentEastCur];
            
            % Velocity vector of the vessel
            Vg = [sog*cos(deg2rad(cog)); sog*sin(deg2rad(cog))];
            Vr = Vg - Vc;
            % Angle between velocity and current direction
            VcDir = atan2d( Vc(2), Vc(1));
            VrDir = atan2d( Vr(2), Vr(1));
            VcDir_data = cat(1,VcDir_data, VcDir);
            CurVsVelAnglre = VrDir- VcDir;
            VrDir_data = cat(1,VrDir_data,VrDir);
            % magnitude of the current
            currentSpeed = norm(Vc);
            VrSpeed = norm(Vr);
           
            % Messured wind speed and direction relative to the vessel
            curMessuredRelWindDir = mean(messuredRelWindDir(m-avrager:m+avrager));
            curMessuredRelWindSpeed = mean(messuredRelWindSpeed(m-avrager:m+avrager));
            
            wave_vector = [ForecastWaveSize_data(end)*cos(deg2rad(curWaveDir));...
                ForecastWaveSize_data(end)*sin(deg2rad(curWaveDir))];
            wind_vector = [ForcastWindSpeed*cos(rad2deg(curWindDir));...
                ForcastWindSpeed*sin(rad2deg(curWindDir))];
            
            wave_current_vector =  Vc + wave_vector;
            disturbance_vector = Vc + wave_vector + wind_vector;
            %currentDir = rad2deg(acos(dot(Sog_vector,wave_current_vector)/(norm(Sog_vector)*norm(wave_current_vector))));
            
            % Save current data
            Vr_data = cat(1, Vr_data, VrSpeed);
            cog_data = cat(1, cog_data,cog);
            psi_data = cat(1, psi_data,psi);
            sog_data = cat(1, sog_data,sog);
            relWaveDir_data = cat(1, relWaveDir_data, ssa(ssa(psi- curWaveDir, 'deg') - 180 , 'deg'));
            relWindDir_data = cat(1, relWindDir_data, ssa(ssa(psi - curWindDir, 'deg') - 180 , 'deg'));
            relWaveDirVrDir_data = cat(1, relWaveDirVrDir_data, ssa(ssa(VrDir- curWaveDir, 'deg') - 180 , 'deg'));
            relWindDirVrDir_data = cat(1, relWindDirVrDir_data, ssa(ssa(VrDir - curWindDir, 'deg') - 180 , 'deg'));
            messuredRelWindDir_data = cat(1, messuredRelWindDir_data, curMessuredRelWindDir);
            messuredRelWindSpeed_data = cat(1, messuredRelWindSpeed_data, curMessuredRelWindSpeed);
            ForcastWindSpeed_data = cat(1, ForcastWindSpeed_data, ForcastWindSpeed);
            CurrentDir_data = cat(1, CurrentDir_data, ssa(ssa(psi - VcDir,'deg') - 180, 'deg'));
            CurrentDirVrDir_data = cat(1, CurrentDirVrDir_data, ssa(ssa(VrDir - VcDir,'deg'), 'deg'));
            CurrentSpeed_data = cat(1, CurrentSpeed_data, currentSpeed);
            CurrentDircog_data = cat(1, CurrentDircog_data, ssa(ssa(cog - VcDir,'deg'), 'deg'));
            relWaveDircog_data = cat(1, relWaveDircog_data, ssa(ssa(cog- curWaveDir, 'deg') - 180 , 'deg'));
            relWindDircog_data = cat(1, relWindDircog_data, ssa(ssa(cog - curWindDir, 'deg') - 180 , 'deg'));
            if ~mod(gps_data.utc_time(m),3600) || first
                str = sprintf('| Day: %d  | Hour: %d \t|', ...
                    (floor(curr_hour/24)+1) + gps_data.utc_day(1)-1, (mod(curr_hour,24)));
                disp(str)
                first = false;
            end
        end

    end
    disp('Run Success')
    figure(1)
    plot(lon_data,lat_data)
    hold on
    lon_data = [];
    lat_data = [];
end
%% Data That can be downladed from neptus that are relevant
% AbsoluteWind,Depth,DesiredHeading,DesiredPath,DesiredSpeed,DesiredZ,GpsFix,RelativeWind,RemoteSensorInfo,EstimatedState,EulerAngles
% GpsFix,RelativeWind,EulerAngles

% Data to be saved for plots
test_cog_data = [];
test_sog_data = [];
test_psi_data = [];
test_ForecastWaveSize_data = [];
test_messuredRelWindDir_data = [];
test_messuredRelWindSpeed_data = [];
test_relWaveDir_data = [];
test_relWindDir_data = [];
test_ForecastWaveFreq_data = [];
test_ForcastWindSpeed_data = [];
test_CurrentDir_data = [];
test_CurrentSpeed_data = [];
test_speed_data = [];
test_Vr_data = [];
test_VrDir_data = [];
test_CurrentDirVrDir_data = [];
test_relWaveDirVrDir_data = [];
test_relWindDirVrDir_data = [];
test_CurrentDircog_data = [];
test_relWaveDircog_data = [];
test_relWindDircog_data = [];
test_VcDir_data = [];

avrager = 6*60; % average over x min

disp('Loading new data')
%% load data
path = './Mausund200709_53748/';
addpath(path);
gpsFix = load('GpsFix.mat');
RelativeWind = load('RelativeWind.mat');
EulerAngles = load('EulerAngles.mat');
rmpath(path)
load('weatherData_2020-7-9_2020-7-9.mat')
load('currentweatherData_2020-7-9_2020-7-9.mat')
disp('Done loading data')

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
for m = (10*120) : length(gps_data.sog) - (10*120)
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
            test_ForecastWaveSize_data = cat(1, test_ForecastWaveSize_data, ForecastWaveSize_data(end));
        else
            test_ForecastWaveSize_data = cat(1, test_ForecastWaveSize_data, waveSize(x, y, curr_hour + 1));
        end

        % Wave frequency at given time and position
        test_ForecastWaveFreq_data = cat(1,test_ForecastWaveFreq_data, waveHZ(x,y,curr_hour+1));
        if waveHZ(x,y,curr_hour+1) < 0.1 
            disp([num2str(waveHZ(x,y,curr_hour+1)) num2str(lat) num2str(lon)])
        end
        % Current vector at given time and position
        currentNorthCur = currentNorth(xcurrent,ycurrent,curr_hour+1);
        currentEastCur = currentEast(xcurrent,ycurrent,curr_hour+1);
        Vc = [currentNorthCur; currentEastCur];

        % Velocity vector of the vessel
        Vg = [sog*cos(deg2rad(cog)); sog*sin(deg2rad(cog))];
        Vr = Vg - Vc;
        % Angle between velocity and current direction
        VcDir = atan2d( Vc(2), Vc(1));
        VrDir = atan2d( Vr(2), Vr(1));
        test_VcDir_data = cat(1,test_VcDir_data, VcDir);
        CurVsVelAnglre = VrDir- VcDir;
        test_VrDir_data = cat(1,test_VrDir_data,VrDir);
        % magnitude of the current
        currentSpeed = norm(Vc);
        VrSpeed = norm(Vr);

        % Messured wind speed and direction relative to the vessel
        curMessuredRelWindDir = mean(messuredRelWindDir(m-avrager:m+avrager));
        curMessuredRelWindSpeed = mean(messuredRelWindSpeed(m-avrager:m+avrager));

        wave_vector = [ForecastWaveSize_data(end)*cos(deg2rad(curWaveDir));...
            ForecastWaveSize_data(end)*sin(deg2rad(curWaveDir))];
        wind_vector = [ForcastWindSpeed*cos(rad2deg(curWindDir));...
            ForcastWindSpeed*sin(rad2deg(curWindDir))];

        wave_current_vector =  Vc + wave_vector;
        disturbance_vector = Vc + wave_vector + wind_vector;
        %currentDir = rad2deg(acos(dot(Sog_vector,wave_current_vector)/(norm(Sog_vector)*norm(wave_current_vector))));

        % Save current data
        test_Vr_data = cat(1, test_Vr_data, VrSpeed);
        test_cog_data = cat(1, test_cog_data,cog);
        test_psi_data = cat(1, test_psi_data,psi);
        test_sog_data = cat(1, test_sog_data,sog);
        test_relWaveDir_data = cat(1, test_relWaveDir_data, ssa(ssa(psi- curWaveDir, 'deg') - 180 , 'deg'));
        test_relWindDir_data = cat(1, test_relWindDir_data, ssa(ssa(psi - curWindDir, 'deg') - 180 , 'deg'));
        test_relWaveDirVrDir_data = cat(1,test_relWaveDirVrDir_data, ssa(ssa(VrDir- curWaveDir, 'deg') - 180 , 'deg'));
        test_relWindDirVrDir_data = cat(1, test_relWindDirVrDir_data, ssa(ssa(VrDir - curWindDir, 'deg') - 180 , 'deg'));
        test_messuredRelWindDir_data = cat(1, test_messuredRelWindDir_data, curMessuredRelWindDir);
        test_messuredRelWindSpeed_data = cat(1, test_messuredRelWindSpeed_data, curMessuredRelWindSpeed);
        test_ForcastWindSpeed_data = cat(1, test_ForcastWindSpeed_data, ForcastWindSpeed);
        test_CurrentDir_data = cat(1, test_CurrentDir_data, ssa(ssa(psi - VcDir,'deg') - 180, 'deg'));
        test_CurrentDirVrDir_data = cat(1, test_CurrentDirVrDir_data, ssa(ssa(VrDir - VcDir,'deg'), 'deg'));
        test_CurrentSpeed_data = cat(1, test_CurrentSpeed_data, currentSpeed);
        test_CurrentDircog_data = cat(1, test_CurrentDircog_data, ssa(ssa(cog - VcDir,'deg'), 'deg'));
        test_relWaveDircog_data = cat(1, test_relWaveDircog_data, ssa(ssa(cog- curWaveDir, 'deg') - 180 , 'deg'));
        test_relWindDircog_data = cat(1, test_relWindDircog_data, ssa(ssa(cog - curWindDir, 'deg') - 180 , 'deg'));;
        if ~mod(gps_data.utc_time(m),3600) || first
            str = sprintf('| Day: %d  | Hour: %d \t|', ...
                (floor(curr_hour/24)+1) + gps_data.utc_day(1)-1, (mod(curr_hour,24)));
            disp(str)
            first = false;
        end
    end

end
disp('Run Success')

%%
disp('Plotting Data')
table1 = [];table2 = [];table3 = [];
for i = 1: length(ForecastWaveSize_data)
    if ForecastWaveSize_data(i) < 1.2
        table1 = cat(1,table1,[relWaveDircog_data(i) sog_data(i)]);
    elseif ForecastWaveSize_data(i) < 1.6
        table2 = cat(1,table2,[relWaveDircog_data(i) sog_data(i)]);
    else
        table3 = cat(1,table3,[relWaveDircog_data(i) sog_data(i)]);
    end
end
figure;
scatter(table1(:,1), table1(:,2))
hold on 
scatter(table2(:,1), table2(:,2))
scatter(table3(:,1), table3(:,2))
legend('Wave Size < 2', '2 < Wave Size < 3', 'Wave Size > 3')
xlabel 'Relative wave direction',ylabel '|Vr|';
hold off

%% 
% figure;
% scatter3((relWaveDir_data),ForecastWaveFreq_data,Vr_data)
% xlabel 'Relative wave direction',ylabel 'Wave period',zlabel 'SOG';

table1 = [];table2 = [];table3 = [];
for i = 1: length(ForecastWaveFreq_data)
    if ForecastWaveFreq_data(i) < 6.5
        table1 = cat(1,table1,[relWaveDircog_data(i) sog_data(i)]);
    elseif ForecastWaveFreq_data(i) < 8
        table2 = cat(1,table2,[relWaveDircog_data(i) sog_data(i)]);
    else
        table3 = cat(1,table3,[relWaveDircog_data(i) sog_data(i)]);
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
    if ForecastWaveSize_data(i) < 1.2
        table1 = cat(1,table1,[ForecastWaveFreq_data(i) sog_data(i)]);
    elseif ForecastWaveSize_data(i) < 1.6
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
legend('Wave Size < 1.2', '1.2 < Wave Size < 1.6', 'Wave Size > 1.6')
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
        table1 = cat(1,table1,[relWindDircog_data(i) sog_data(i)]);
    elseif ForcastWindSpeed_data(i) < 6
        table2 = cat(1,table2,[relWindDircog_data(i) sog_data(i)]);
    else
        table3 = cat(1,table3,[relWindDircog_data(i) sog_data(i)]);
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
figure;
scatter(ssa(cog_data-VrDir_data,'deg'), Vr_data);
%%
% figure
% scatter3((CurrentDir_data),CurrentSpeed_data, sog_data)
% xlabel 'CurDir',ylabel 'CurSpeed',zlabel 'SOG';
table1 = [];table2 = [];table3 = [];
for i = 1: length(CurrentSpeed_data)
    if CurrentSpeed_data(i) < 0.15
        table1 = cat(1,table1,[CurrentDircog_data(i) sog_data(i)]);
    elseif CurrentSpeed_data(i) < 0.3
        table2 = cat(1,table2,[CurrentDircog_data(i) sog_data(i)]);
    else
        table3 = cat(1,table3,[CurrentDircog_data(i) sog_data(i)]);
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
figure;
count = 0;
for i = 1 : length(sog_data)
    if ForecastWaveFreq_data(i) < 6.5 && ForecastWaveSize_data(i) > 3.5 ...
            && ForcastWindSpeed_data(i) > 6 && abs(relWindDircog_data(i)) > 120 ...
            && CurrentSpeed_data(i) < 0.25
        plot(count,sog_data(i), 'o')
        count = count +1;
        hold on
    end
end
ylabel 'SOG' ; xlabel 'Sample'; title 'Speed at desired environment'
hold off
%%
CorrData = [sog_data abs(relWaveDircog_data) abs(relWindDircog_data)  ForcastWindSpeed_data ...
    abs(CurrentDircog_data) CurrentSpeed_data ForecastWaveFreq_data ForecastWaveSize_data];
corrCoefs = corrcoef(CorrData);
    
nninputs =  double([abs(relWaveDircog_data) abs(relWindDircog_data) ForcastWindSpeed_data ...
     abs(CurrentDircog_data) CurrentSpeed_data ForecastWaveFreq_data ... 
     ForecastWaveSize_data])';
test_nninputs =  double([abs(test_relWaveDircog_data)  abs(test_relWindDircog_data) test_ForcastWindSpeed_data ...
    abs(test_CurrentDircog_data) test_CurrentSpeed_data test_ForecastWaveFreq_data ... 
    test_ForecastWaveSize_data])';

disp('Doing Neural')
best = 1;
best_perfomance = inf;

performance = inf;
for nh = 1:1
    for i = 1:10
        [temp_net, temp_perform, temp_netError, temp_netTrainState] =...
            neuralNet(nninputs,double(sog_data)', nh);
        if temp_perform < performance
            net = temp_net; performance = temp_perform;
            netError = temp_netError; netTrainState = temp_netTrainState;
        end
    end
    disp(['Performance: ' num2str(performance)])
    temp_perf = perform(net, double(test_sog_data), net(test_nninputs));
    if best_perfomance > temp_perf
        best_perfomance = temp_perf;
        best = nh;
    end
    disp(['Best: ' num2str(best_perfomance)])
end
disp(['Performance: ' num2str(performance)])
figure, ploterrhist(netError)
    %figure, plotperform(tr)
    %figure, plottrainstate(tr)
    %figure, ploterrhist(e)
    figure, plotregression(double(sog_data)', net(nninputs))
%%
figure
yvalues = {'Sog','relWaveDir','relWindDir','ForcastWindSpeed',...
    'CurrentDir', 'CurrentSpeed', 'ForecastWaveFreq', 'ForecastWaveSize'};
xvalues = {'Sog','relWaveDir','relWindDir','ForcastWindSpeed',...
    'CurrentDir', 'CurrentSpeed', 'ForecastWaveFreq', 'ForecastWaveSize'};
h = heatmap(xvalues,yvalues,corrCoefs);
h.Title = 'Covariance Matrix';
%%
% for i = 1: length(sog_data)
%     if Vr_data(i)> 0.8
%         x = net(nninputs(:,i));
%         disp([num2str(Vr_data(i)) '  ' num2str(x) '  ' num2str(Vr_data(i) - x)])
%     end
% end


%%
pause(0.5)
y = net(test_nninputs);
e = gsubtract(double(test_sog_data),y);
figure, ploterrhist(e)
figure, plotregression(double(test_sog_data),y)
%%
for i = 1: length(test_sog_data)
    if test_sog_data(i)> 0.8
        x = net(nninputs(:,i));
        disp([num2str(test_sog_data(i)) '  ' num2str(x) '  ' num2str(test_sog_data(i) - x)])
    end
end

%%
table1 = [];table2 = [];table3 = [];
for i = 1: length(ForecastWaveFreq_data)
    if sog_data(i) > 0.8
        table1 = cat(1,table1,[CurrentDircog_data(i) CurrentSpeed_data(i)]);
    elseif ForecastWaveFreq_data(i) < 8
        table2 = cat(1,table2,[relWaveDircog_data(i) sog_data(i)]);
    else
        table3 = cat(1,table3,[relWaveDircog_data(i) sog_data(i)]);
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


