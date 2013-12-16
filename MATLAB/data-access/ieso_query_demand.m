function [ demand_timeseries ] = ieso_query_demand(...
     start_datetime, end_datetime )
%IESO_QUERY_DEMAND Query for IESO hourly demand in a time range.
%   Parameters:
%   start_datetime, String in the format of %y-%m-%d %T. 
%   end_datetime, String in the format of %y-%m-%d %T.

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
% Run query
curs = exec(conn, ['select '...
    'ontario, date_format(timestamp, ''%d-%b-%Y %T'') reading_datetime '...
    'from Hourly_Demand '...
    'where timestamp >= '''...
    start_datetime...
    ''' and timestamp <= '''...
    end_datetime...
    ''' order by timestamp asc']);

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