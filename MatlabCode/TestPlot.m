clc; close all; clearvars;
% AbsoluteWind,Depth,DesiredHeading,DesiredPath,DesiredSpeed,DesiredZ,GpsFix,RelativeWind,RemoteSensorInfo,EstimatedState,EulerAngles
% addpath("./Mausund181204")
% data1 = load('GpsFix.mat');
% data1 = data1.GpsFix;
% data2 = load('DesiredSpeed.mat');
% data2 = data2.DesiredSpeed;
% data3 = load('RelativeWind.mat');
% data3 = data3.RelativeWind;
% 
% PlotMraData(data1.timestamp, data1.sog , "Sog", ...
%     data2.timestamp, data2.value, 'DesiredSpeed');
% 
% PlotMraData(data1.timestamp, data1.sog , "Sog", ...
%     data3.timestamp, deg2rad(data3.angle), 'angle');
% 
% PlotMraData(data1.timestamp, data1.sog , "Sog", ...
%     data3.timestamp, data3.speed, 'speed');
% 
% rmpath("./Mausund181204")
addpath("./Mausund221241")
data1 = load('GpsFix.mat');
data1 = data1.GpsFix;
data2 = load('DesiredHeading.mat');
data2 = data2.DesiredHeading;
data3 = load('RelativeWind.mat');
data3 = data3.RelativeWind;

PlotMraData(data1.timestamp, data1.cog , "cog", ...
    data2.timestamp, data2.value, 'DesiredSpeed');

PlotMraData(data1.timestamp, data1.sog , "Sog", ...
    data3.timestamp, deg2rad(data3.angle), 'angle');

PlotMraData(data1.timestamp, data1.sog , "Sog", ...
    data3.timestamp, data3.speed, 'speed');