%%
% Add folders to path.
addpath('config', 'data-access', 'lib', 'three-line');

%%
% Set start/end and details about location to get demand and temperature
% timeseries.
start_datetime = '2004-01-01 00:00:00';
end_datetime = '2004-12-31 23:59:59';
zone_col = 'toronto'; % Zone column name
location_id = 1; % Toronto
[ demand_ts, temperature_ts ] = ieso_query_zonal_demand_temp(... 
    zone_col, location_id, start_datetime, end_datetime);

%%
% Build energy/temperature vectors only for those days with 24-hours in a
% day.
datenum_index = datenum(demand_ts.TimeInfo.StartDate)
datenum_ts_end = addtodate(datenum_index, 1, 'year')
while datenum_index < datenum_ts_end
    daily_end = addtodate(datenum_index, 86399, 'second') % 1 day - 1 second
    daily_demand_ts = getsampleusingtime(demand_ts, datenum_index, daily_end);
    daily_demand_ts.Data.length
    daily_temp_ts = getsampleusingtime(temperature_ts, datenum_index, daily_end);
    daily_temp_ts.Data.length
    
    datenum_index = addtodate(datenum_index, 1, 'day');
end

%%
% Parse data with the three-line model
X = [demand_ts.Data'; temperature_ts.Data'];

[point1,slope1] = threel(X,10);
[point2,slope2] = threel(X,90);

baseload = min(point1(2),point1(4))
actload = min(point2(2),point2(4)) - baseload
heatgrad = slope2(1)

if(slope2(2)>slope2(3))
    coolgrad = slope2(2)
    ac = point2(1)
else
    coolgrad = slope2(3)
    ac = point2(3)
end