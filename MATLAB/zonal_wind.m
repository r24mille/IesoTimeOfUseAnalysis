%%
% Add folders to path.
addpath('config', 'data-access', 'lib', 'three-line');

for year=2004:2013
    %%
    % Set start/end and details about location to get demand and temperature
    % timeseries.
    start_datetime = strcat(num2str(year), '-01-01 00:00:00');
    end_datetime = strcat(num2str(year), '-12-31 23:59:59');
    zone_col = 'toronto'; % Zone column name
    location_id = 1; % Toronto
    [ demand_ts, wind_ts ] = ieso_query_zonal_demand_wind(... 
        zone_col, location_id, start_datetime, end_datetime);
    
    figure('Name', ['Wind vs. Demand (', num2str(year), ')']);
    hold on;
    ylabel('Demand in Toronto Zone (MW)');
    xlabel('Wind Speed (km/h)');
    scatter(wind_ts.Data, demand_ts.Data, 'x');
    hold off;
end