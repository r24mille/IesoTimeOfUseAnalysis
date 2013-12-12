function [ daily_pars ] = par_by_day( start_datetime, end_datetime )
%PAR_BY_DAY Finds the daily peak-to-average ratio (PAR) for a timeseries.
%   Returns the daily peak-to-average ratio (PAR) of a timeseries. Also
%   known as "crest factor."
%
%   Parameters:
%   start_datetime, String in the format of %y-%m-%d %T. 
%   end_datetime, String in the format of %y-%m-%d %T.
%
%   Returns:
%   daily_pars, nx2 matrix where first column is datenum and the second 
%               column is the PAR for that datenum.

%%
% Query database
reading_ts = ieso_query_readings(start_datetime, end_datetime);

%%
% Loop over days in timeseries
num_days = ceil(reading_ts.TimeInfo.End - reading_ts.TimeInfo.Start);
daily_pars = zeros(num_days, 2);
for i = 0:(num_days - 1)
    starttime = addtodate(datenum(reading_ts.TimeInfo.StartDate), i, 'day');
    endtime = addtodate(starttime, 86399, 'second'); % 1 day - 1 second
    daily_ts = getsampleusingtime(reading_ts, starttime, endtime);
    daily_ts_vec = daily_ts.Data;
    par = abs(max(daily_ts_vec)) / rms(daily_ts_vec);
    
    % Place results in matrix, skip outliers (eg. Blackout ~Aug 14, 2003)
    if par < 1.28
        daily_pars(i+1, 1) = starttime;
        daily_pars(i+1, 2) = par;
    end
end

% Remove rows left as zeros, which were outliers
daily_pars(all(daily_pars==0,2),:) = [];
end

