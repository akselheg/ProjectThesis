function PlotMraData(varargin)
%PLOTMRADATA Summary of this function goes here
%   Detailed explanation goes here
legends = [];

figure;
for i = 1:3:length(varargin)
    time = varargin{i};
    timestamp = time - time(1);
    % Add interpolation. Maybe ask about this.
    plot(timestamp, varargin{i+1});
    legends = cat(2,legends,varargin{i+2});
    hold on;
end
tit = legends(1);
for i = 2 : length(legends)
    tit = tit + ' vs. ' + legends(i);
end
tit = 'Plot of ' + tit;
title(tit)
legend(legends)
xlabel('time')
ylabel('value')
hold off;