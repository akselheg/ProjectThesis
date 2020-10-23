function [current_components, current_time] = get_current_components(GpsData, id)
    % Extract the current for each location recorded in the Gps data
    % structure. The current is returned as a set of vectors. One for each
    % direction (North and East) with a corresponging time vector.
    
    RAD2DEG = 180/pi;
    save_directory = pwd;
    base_path = "https://thredds.met.no/thredds/dodsC/fou-hi/norkyst800m-1h/NorKyst-800m_ZDEPTHS_his.an.202007";
    samples_per_hour = 4;
    GPS_sample_time = round(10.^2*(GpsData.timestamp_secondsSince01_01_1970_(2,:)-GpsData.timestamp_secondsSince01_01_1970_(1,:)))/10.^2;
    
    ds_factor = (3600/(samples_per_hour*GPS_sample_time));
    
    % Check if data already exists
    if exist([save_directory '/' id '.mat']) == 2
        load([id '.mat']);
        current_components = result.current_components;
        current_time = result.current_time;
    else
        % Start with downsampling 
        day = downsample(GpsData.utc_day, ds_factor);
        unique_days = unique(day);
        seconds = downsample(GpsData.utc_time_s_, ds_factor);
        latitude = downsample(GpsData.lat_rad_, ds_factor);
        longitude = downsample(GpsData.lon_rad_, ds_factor);

        % Check if dataset covers several days
        urls = [];
        
        if length(unique_days) ~= 1
            % Generate a list of all urls
            for i=1:length(unique_days)
                date = unique_days(i);
                if date >= 10
                    urls = [urls; base_path + num2str(date) + '00.nc'];
                else
                    urls = [urls; base_path + '0' + num2str(date) + '00.nc'];
                end
            end
        else
            date = unique_days;
            if date >= 10
                urls = [base_path + num2str(date) + '00.nc'];
            else
                urls = [base_path + '0' + num2str(date) + '00.nc'];
            end
        end

        current_components = [];
        current_time = [];
        % For each day
        for i=1:length(unique_days)
            disp(['Day: ', num2str(i)])
            date = unique_days(i);

            % Extract data for given day
            day_mask = day == date;
            seconds_day = seconds(day_mask);
            hour_in_day = floor(seconds_day/3600);
            unique_hour_in_day = unique(hour_in_day);
            latitude_day = latitude(day_mask)*RAD2DEG;
            longitude_day = longitude(day_mask)*RAD2DEG;

            current_time = [current_time; hour_in_day];
            for h=1:length(unique_hour_in_day)
                hour = unique_hour_in_day(h);
                disp(['Hour: ', num2str(hour)])
                
                % Load map of current at a given hour
                current_at_hour_north = ncread(urls(i),'v_northward',[1 1 1 hour+1],[inf inf 1 1]);
                current_at_hour_east = ncread(urls(i),'u_eastward',[1 1 1 hour+1],[inf inf 1 1]);
                current_latitude_map = ncread(urls(i),'lat');
                current_longitude_map = ncread(urls(i),'lon');

                % Find all GPS measurments corresponging to that hour
                gps_latitude_at_hour = latitude_day(hour_in_day == hour);
                gps_longitude_at_hour = longitude_day(hour_in_day == hour);

                current_results_at_hour = zeros(length(gps_latitude_at_hour),2);
                for j=1:length(gps_latitude_at_hour)
                    error_map = sqrt((current_latitude_map-gps_latitude_at_hour(j)).^2 + ((current_longitude_map-gps_longitude_at_hour(j)).^2));
                    [row_index,col_index] = find(error_map==min(error_map,[],'all'));

                    current_results_at_hour(j,1) = current_at_hour_north(row_index,col_index);
                    current_results_at_hour(j,2) = current_at_hour_east(row_index,col_index);
                end
                current_components = [current_components; current_results_at_hour]
            end
        end
        result = struct;
        result.current_components = current_components;
        result.current_time = current_time;
        save(id,'result')
    end
end