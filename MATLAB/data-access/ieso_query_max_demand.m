function [ max_demand_timeseries ] = ieso_query_max_demand( ...
     start_datetime, end_datetime, num_max )
%IESO_QUERY_MAX_DEMAND Query for max daily IESO demand in a time range.
%   Parameters:
%   start_datetime, String in the format of %Y-%m-%d %T. 
%   end_datetime, String in the format of %Y-%m-%d %T.
%   num_max, Number of maximum daily values to select per year.

%%
% Grab database credentials
schema = 'ontario';
[host, port, username, password] = db_cred(schema);

%%
%Set base preferences with setdbprefs.
setdbprefs('DataReturnFormat', 'cellarray');
setdbprefs('NullNumberRead', 'NaN');
setdbprefs('NullStringRead', 'null');
setdbprefs('FetchInBatches','no');

%%
% Add MySQL driver to classpath
javaclasspath('lib/mysql-connector-java-5.1.27-bin.jar');

%Make connection to database.  Note that the password has been omitted.
%Using JDBC driver.
conn = database(schema, username, password, 'Vendor',...
    'MYSQL', 'Server', host, 'PortNumber', port);

%%
% Run query
curs = exec(conn, ['select * from '...
    '(select max(total_ontario) as daily_max, '...
    'concat(date_format(demand_datetime_dst, ''%d-%b-%Y''), '' 00:00:00'') as datenum ' ...
    'from ontario.zonal_demand '...
    'where demand_datetime_dst >= '''...
    start_datetime...
    ''' and demand_datetime_dst <= '''...
    end_datetime...
    ''' group by date_format(demand_datetime_dst, ''%d-%b-%Y'') ' ...
    'order by daily_max desc) x ' ...
    'limit ' ...
    num2str(num_max)]);

curs = fetch(curs);
sql_results = curs.Data;
close(curs);
close(conn)
clear curs conn;

%Append data to output variable
max_demand_timeseries = timeseries(cell2mat(sql_results(:,1)), sql_results(:,2), ...
    'Name', 'Ontario Demand');
max_demand_timeseries.DataInfo.Units = 'MW';

end