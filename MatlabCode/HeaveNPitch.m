clearvars; close all; clc;
%% load data
path = './Mausund200701_221241/';
addpath(path);
gpsFix = load('GpsFix.mat');
gpsFix = gpsFix.GpsFix;
RelativeWind = load('RelativeWind.mat');
EulerAngles = load('EulerAngles.mat');
EulerAngles = EulerAngles.EulerAngles;
Heave = load('./Mausund200701_221241/Heave.mat');
Heave = Heave.Heave;
heave = Heave.value;
rmpath(path);

time = Heave.timestamp - Heave.timestamp(1);
pitch = interp1(EulerAngles.timestamp, ssa(EulerAngles.phi,'deg' ), Heave.timestamp);
counter = 0;
counter1 =0;
avrager = 240*6;
for m = (10*120) : length(time) - (10*120)
    counter1 = counter1 +1; 
    round(time(m),1)
        if ~mod(round(time(m),1),avrager)
            counter = counter +1 ;
        end
end
%%
Fs = 4;
T = 1/Fs;
L = 960;
testsample = pitch(121:121+L - 1);
Y = fft(testsample);
Y(1) = 0;
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs * (0:(L/2))/L;
figure;
plot(f,P1);
[mp, i] = max(P1);
hz= 2*pi*f(i);
%%
Fs = 4;
T = 1/Fs;
L = 960;
testsample = heave(121:121+L - 1);
Y = fft(testsample);
Y(1) = 0;
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs * (0:(L/2))/L;
figure;
plot(f,P1);
[mp, i] = max(P1);
hz2 = 2*pi*f(i);