close all; clearvars;clc;
x = -200*pi:pi*20:200*pi;
y = x;

hold on

[X, Y] = meshgrid(x,y);

[xCurrent,yCurrent] = xyCurrent(X,Y);
figure(3)
quiver(X,Y,xCurrent,yCurrent);
