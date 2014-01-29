function [ demand_timeseries, wind_timeseries ] = ... 
    ieso_query_zonal_demand_wind( zone_col, location_id, ... 
    start_datetime, end_datetime)
%IESO_QUERY_ZONAL_DEMAND_WIND Query for a timeseries of IESO zonal demand
%during a timerange. Also returns the matching timeseries for a location,
%intended to be a representative city in the zone. Both timeseries include
%only measurements that are common to both timeseries (though wind
%may have 4-5 hourly measurements missing each year).
%
%   Parameters:
%   zone_col, Column name from zonal_demand (ie. zone name)
%   location_id, Integer representing the location PK from weathertables.
%   start_datetime, String in the format of %Y-%m-%d %T. 
%   end_datetime, String in the format of %Y-%m-%d %T.


%%
% Grab database credentials
schema = 'ontario';
[host, port, username, password] = db_cred(schema);

%%
%Set base preferences with setdbprefs.
setdbprefs('DataReturnFormat', 'cellarray');
setdbprefs('NullNumberRead', 'NaN');
setdbprefs('NullStringRead', 'null');

%%
% Add MySQL driver to classpath
javaclasspath('lib/mysql-connector-java-5.1.27-bin.jar');

%Make connection to database.  Note that the password has been omitted.
%Using JDBC driver.
conn = database(schema, username, password, 'Vendor',...
    'MYSQL', 'Server', host, 'PortNumber', port);

%%
% Run query to grab a time range of results where both a zonal demand and
% temperature observation exist.
curs = exec(conn, ['select '...
    'date_format(wo.observation_datetime_standard, ''%d-%b-%Y %T'') observation_datetime, '... 
    'wo.windspeed_metric, zd.' ...
    zone_col ... 
    ' '...
    'from weathertables.wunderground_observation wo  '...
    'inner join ontario.zonal_demand zd on zd.demand_datetime_standard = wo.observation_datetime_standard '...
    'where wo.location_id = '...
    num2str(location_id) ...
    ' and wo.windspeed_metric > 0 '...
    'and observation_datetime_standard >= '''...
    start_datetime...
    ''' and observation_datetime_standard <= '''...
    end_datetime...
    ''' order by wo.observation_datetime_standard asc']);

curs = fetch(curs);
sql_results = curs.Data;
close(curs);
close(conn)
clear curs conn;

%Append data to output variables
wind_timeseries = timeseries(cell2mat(sql_results(:,2)), sql_results(:,1), ...
    'Name', 'Wind Speed for Location');
wind_timeseries.DataInfo.Units = 'km/h';
demand_timeseries = timeseries(cell2mat(sql_results(:,3)), sql_results(:,1), ...
    'Name', 'Electricity Demand for Zone');
demand_timeseries.DataInfo.Units = 'MW';

end

