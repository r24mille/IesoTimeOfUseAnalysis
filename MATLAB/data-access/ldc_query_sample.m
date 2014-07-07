function [ y_readings, rounded_temps, tou_periods, tou_billings ] = ...
    ldc_query_sample( )
%LDC_QUERY_SAMPLE Queries the r24mille_anova_sample table. 
%   Though this table has been named prior the the ANOVA analysis, it's
%   actually suitable as an cleaned 2D array of MeterID x hour readings.

%%
% Grab database credentials
schema = 'essex_annotated';
[host, port, username, password] = db_cred(schema);

%%
%Set base preferences with setdbprefs.
setdbprefs('DataReturnFormat', 'numeric');
setdbprefs('NullNumberRead', 'NaN');
setdbprefs('NullStringRead', 'null');
setdbprefs('FetchInBatches','yes');
setdbprefs('FetchBatchSize','100');

%Make connection to database.  Note that the password has been omitted.
%Using JDBC driver.
conn = database(schema, username, password, 'Vendor',...
    'MYSQL', 'Server', host, 'PortNumber', port);

%%
% Run query
curs = exec(conn, ['select Reading, rounded_temp_celsius, '...
    'tou_period_id, tou_billing_active '...
    'from r24mille_anova_sample '...
    'order by MeterID, observation_period_hour asc']);
curs = fetch(curs);
sql_results = single(curs.Data);
close(curs);
close(conn);

%%
% Parse results array into ANOVA variable vectors
y_readings = sql_results(:,1);
rounded_temps = sql_results(:,2);
tou_periods = sql_results(:,3);
tou_billings = sql_results(:,4);

%%
% Clear temporary variables
clear curs conn sql_results;
end

