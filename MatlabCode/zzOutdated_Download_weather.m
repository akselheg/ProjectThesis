clearvars;close all;clc;


startDate = [2020, 07, 03];
endDate = [2020, 07, 04];

startDateString = string(startDate(1)) + "/" + string(startDate(2)) + "/" + string(startDate(3));
endDateString = string(endDate(1)) + "/" + string(endDate(2)) + "/" + string(endDate(3));
numDays = daysact(startDateString, endDateString);
for i = 0:numDays
    date = daysadd(startDateString,i);
    str = datestr(date);
    test = datetime(str);
    %yyyymmdd(datetime(datestr(date),'ConvertFrom','ddmmmyyyy'));
    numberDate = yyyymmdd(datetime(datestr(date)));
    
    previousDate = daysadd(startDateString,i-1); 
    numberPreviousDate = yyyymmdd(datetime(datestr(previousDate)));
    
    windCurrentData =  "https://thredds.met.no/thredds/dodsC/fou-hi/norkyst800m-1h/NorKyst-800m_ZDEPTHS_his.an." + string(numberDate) + "00.nc";
    if i == 0
        waveData = "https://thredds.met.no/thredds/dodsC/fou-hi/mywavewam800mhf/mywavewam800_midtnorge.an." + string(numberPreviousDate) + "18.nc";
        windCurrentInfo = ncinfo(windCurrentData);
        waveInfo = ncinfo(waveData);
        latitudeMapWave = ncread(waveData,'latitude');
        longitudeMapWave = ncread(waveData,'longitude');
        latitudeMapWindCurrent = ncread(windCurrentData,'lat');
        longitudeMapWindCurrent = ncread(windCurrentData,'lon');
        windCurrentDimentions = [size(latitudeMapWindCurrent), 24*(numDays+1)];
        waveDimentions = [size(latitudeMapWave) , 24*(numDays+1) + 18];
        windCurrentDimentions2 = [size(latitudeMapWindCurrent),2, 24*(numDays+1)];
        windEast = zeros(windCurrentDimentions);
        windNorth = zeros(windCurrentDimentions);
        currentEast = zeros(windCurrentDimentions);
        currentNorth = zeros(windCurrentDimentions);
        waveSize = zeros(waveDimentions);
        waveDir = zeros(waveDimentions);
        windDir = zeros(waveDimentions); 
        waveHZ = zeros(waveDimentions); 
        waveSize(:,:,1:18) = ncread(waveData,'mHs', [1 1 7], [inf inf inf]);
        waveDir(:,:,1:18) = ncread(waveData,'thq', [1 1 7], [inf inf inf]); % I believe thq is total wave dir
        windDir(:,:,1:18) = ncread(waveData,'dd', [1 1 7], [inf inf inf]);
        waveHZ(:,:,1:18) = ncread(waveData,'tp', [1 1 7], [inf inf inf]);
        
    end
    waveData = "https://thredds.met.no/thredds/dodsC/fou-hi/mywavewam800mhf/mywavewam800_midtnorge.an." + string(numberDate) + "18.nc";

    windEast(:,:,24*i+1:24*i+24) = double(ncread(windCurrentData,'Uwind'));
    
    windNorth(:,:,24*i+1:24*i+24) = ncread(windCurrentData,'Vwind');
    
    currentNorth(:,:,24*i+1:24*i+24) = ncread(windCurrentData,'v_northward',[1 1 1 1],[inf inf 1 inf]);
    
    currentEast(:,:,24*i+1:24*i+24) = ncread(windCurrentData,'u_eastward',[1 1 1 1],[inf inf 1 inf]);
    
    waveSize(:,:,24*i+7:24*i+30) = ncread(waveData,'mHs');
    
    waveDir(:,:,24*i+19:24*i+42) = ncread(waveData,'thq');  % I believe thq is total wave dir 
    windDir(:,:,24*i+19:24*i+42) = ncread(waveData,'dd');
    waveHZ(:,:,24*i+19:24*i+42) = ncread(waveData,'tp');
end
%%

startDateSaveFormat = string(startDate(1)) + "-" + string(startDate(2)) + "-" + string(startDate(3));
endDateSaveFormat =  string(endDate(1)) + "-" + string(endDate(2)) + "-" + string(endDate(3));
savename = "weatherData_"+ startDateSaveFormat + "_" + endDateSaveFormat + ".mat"; 
save(savename,'waveHZ','windEast','windNorth','currentNorth', 'currentEast', 'waveSize','waveDir', 'latitudeMapWave', 'longitudeMapWave', 'latitudeMapWindCurrent', 'longitudeMapWindCurrent','windDir', 'windCurrentInfo', 'waveInfo','-v7.3');


