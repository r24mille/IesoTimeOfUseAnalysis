function [ daily_par_ts ] = par_by_day( demand_ts )
%PAR_BY_DAY Finds the daily peak-to-average ratio (PAR) for a timeseries.
%   Returns the daily peak-to-average ratio (PAR) of a timeseries. Also
%   known as "crest factor."
%
%   Parameters:
%   demand_ts, Timeseries object of hourly demand.
%
%   Returns:
%   daily_pars_ts, Timeseries object of daily PAR values.

%%
% Loop over days in timeseries
num_days = ceil(demand_ts.TimeInfo.End - demand_ts.TimeInfo.Start);
daily_pars = zeros(num_days, 2);
for i = 0:(num_days - 1)
    starttime = addtodate(datenum(demand_ts.TimeInfo.StartDate), i, 'day');
    endtime = addtodate(starttime, 86399, 'second'); % 1 day - 1 second
    daily_ts = getsampleusingtime(demand_ts, starttime, endtime);
    par = abs(max(daily_ts.Data)) / rms(daily_ts.Data);
    clear daily_ts;
    
    % Place results in matrix, skip outliers (eg. Blackout ~Aug 14, 2003)
    if par < 1.28
        daily_pars(i+1, 1) = par;
        daily_pars(i+1, 2) = starttime;
    else
        disp(['Outlier PAR=', num2str(par), ' on ', datestr(starttime), '.'])
    end
end

% Remove rows left as zeros, which were outliers
daily_pars(all(daily_pars==0,2),:) = [];

% Translate matrix to timeseries
daily_par_ts = timeseries(daily_pars(:,1), datestr(daily_pars(:,2)), ...
    'Name', 'Daily PAR');
end

