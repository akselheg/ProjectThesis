clc, clearvars, close all;
addpath('./Mausund221241/');
gpsFix = load('GpsFix.mat');
gpsData = gpsFix.GpsFix;
RelativeWind = load('RelativeWind.mat');
windData = RelativeWind.RelativeWind;
rmpath('./Mausund221241/');
size(windData.angle)
size(gpsData.cog)
gpsData.timestamp = gpsData.timestamp - gpsData.timestamp(1);
windData.timestamp = windData.timestamp - windData.timestamp(1);
windDataAngles = interp1(windData.timestamp, windData.angle,gpsData.timestamp);
windDataSpeed = interp1(windData.timestamp, windData.speed,gpsData.timestamp);
for i = 1 : length(windDataAngles)
    if windDataAngles(i) > 180
        %windDataAngles(i) = windDataAngles(i) - 360;
    end
end
scatter3(windDataAngles(1:10:end),windDataSpeed(1:10:end),gpsData.sog(1:10:end))