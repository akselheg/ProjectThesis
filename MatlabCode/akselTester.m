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
cog_data = [];
sog_data = [];
wind_data = [];
wave_data = [];
wave_size_data = [];
wind_angle_data = [];
x = 0;
y = 0;
%% Run 
for i = gps_start_time + 1 :gps_end_time - 1
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
    for min = index:120:index+7200-120
        lat = rad2deg(gps_data.lat(min));
        lon = rad2deg(gps_data.lon(min));
        cog = rad2deg(mean(gps_data.cog(min-10:min+10)));
        psi = rad2deg(mean(EulerAngles.psi(min-100:min+100)));
        sog = mean(gps_data.sog(min-100:min+100));
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
        windangle = mean(windDataAngles(min-10:min+10));

        if waveSize(x,y,i+1) < 10 && waveSize(x,y,i+1) > 0.01
            cog_data = cat(1,cog_data,cog);
            sog_data = cat(1,sog_data,sog);
            wave_data = cat(1,wave_data,ssa(psi-wave_dir, 'deg'));
            wave_size_data = cat(1,wave_size_data,waveSize(x,y,i+1));
            %wind_data = cat(1,wind_data, windangle);
            wind_angle_data = cat(1,wind_angle_data, windangle);
        end
%         
%             figure(1);
%             scatter3(ssa(psi-wave_dir, 'deg'), waveSize(x,y,i+1), sog)
%             hold on
%             figure(2)
%             scatter3(ssa(psi-wave_dir,'deg'), windangle, sog)
%             hold on
%         end
    end
    disp(['| Day: ', num2str(floor(i/24)+1),'   | Hour: ', num2str(mod(i,24)), '  |  WaveSize: ', num2str(waveSize(x,y,i+1)),...
            '  |  WaveDir: ', num2str(wave_dir), '  |  Cog: ', num2str(psi), ...
               '  |  sog: ', num2str(sog), '  |', 'rel: ', num2str(ssa(psi-wave_dir,'deg')), '  |' ])
    
%     waveSize(x-1:x+1,y-1:y+1,i+1)
%     waveDir(x-1:x+1,y-1:y+1,i+1)
end
figure(1)
scatter3(wave_data,wave_size_data,sog_data)
xlabel 'Wavedir',ylabel 'waveSize',zlabel 'sog';
figure(2)
scatter3(wave_data,wind_angle_data, sog_data)
xlabel 'Wavedir',ylabel 'windangle',zlabel 'sog';
