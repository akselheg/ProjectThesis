clc;close all; clearvars;

data1 = load('GpsFix.mat');
data1 = data1.GpsFix;
data2 = load('Salinity.mat');
data2 = data2.Salinity;

PlotMraData(data1.timestamp, data1.cog, "Cog",...
    data1.timestamp, data1.sog , "Sog", ...
    data2.timestamp, data2.value, 'Salinity');