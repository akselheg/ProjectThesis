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
windAnglesSmooth = [];
SogSmooth = [];
windSpeedSmooth = [];
sample = 5;
for i = sample + 1 : length(windDataAngles) - sample
    windAnglesSmooth = cat(1,windAnglesSmooth, mean(windDataAngles(i-sample:i+sample)));
    SogSmooth = cat(1,SogSmooth, mean(gpsData.sog(i-sample:i+sample)));
    windSpeedSmooth = cat(1,windSpeedSmooth, mean(windDataSpeed(i-sample:i+sample)));
end
figure;
plot(SogSmooth)
for i = 1 : length(windDataAngles)
    if windDataAngles(i) > 180
        %windDataAngles(i) = windDataAngles(i) - 360;
    end
end
%scatter3(windDataAngles(1:10:end),windDataSpeed(1:10:end),gpsData.sog(1:10:end))