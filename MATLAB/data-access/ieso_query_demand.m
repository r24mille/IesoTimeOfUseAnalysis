function [ demand_timeseries ] = ieso_query_demand(...
     start_datetime, end_datetime )
%IESO_QUERY_DEMAND Query for IESO hourly demand in a time range.
%   Parameters:
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

%Make connection to database.  Note that the password has been omitted.
%Using JDBC driver.
conn = database(schema, username, password, 'Vendor',...
    'MYSQL', 'Server', host, 'PortNumber', port);

%%
% Run query, GROUP BY picks one of the values for switch from DST to
% standard time in Fall. Necessary because duplicates are not allowed in
% timeseries.
curs = exec(conn, ['select '...
    'total_ontario, date_format(demand_datetime_dst, ''%d-%b-%Y %T'') reading_datetime '...
    'from zonal_demand '...
    'where demand_datetime_dst >= '''...
    start_datetime...
    ''' and demand_datetime_dst <= '''...
    end_datetime...
    ''' group by date_format(demand_datetime_dst, ''%d-%b-%Y %H:%m:%s'') '... 
    'order by demand_datetime_dst asc']);

curs = fetch(curs);
sql_results = curs.Data;
close(curs);
close(conn)
clear curs conn;

%Append data to output variable
demand_timeseries = timeseries(cell2mat(sql_results(:,1)), sql_results(:,2), ...
    'Name', 'Ontario Demand');
demand_timeseries.DataInfo.Units = 'MW';

end