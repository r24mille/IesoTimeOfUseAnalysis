function [ weekend_holiday_par_ts ] = par_by_weekend_holiday( demand_ts )
%PAR_BY_WEEKDAY Finds the daily peak-to-average ratio (PAR) for a 
%   timeseries only for non-holiday weekdays. Returns the daily 
%   peak-to-average ratio (PAR) of a timeseries, also known as "crest 
%   factor." 
%
%   Parameters:
%   demand_ts, Timeseries object of hourly demand.
%
%   Returns:
%   weekday_par_ts, Timeseries object of daily PAR values for non-holiday 
%                  weekdays.

%%
% Find Ontario holidays for date range of timeseries
ont_holidays = ontario_holidays(datenum(demand_ts.TimeInfo.StartDate), ...
    datenum(demand_ts.TimeInfo.StartDate) + demand_ts.TimeInfo.End);

%%
% Loop over days in timeseries
num_days = ceil(demand_ts.TimeInfo.End - demand_ts.TimeInfo.Start);
daily_pars = zeros(num_days, 2);
for i = 0:(num_days - 1)
    starttime = addtodate(datenum(demand_ts.TimeInfo.StartDate), i, 'day');
    % Check that starttime is not weekend or holiday
    if any(ont_holidays == floor(starttime)) || ...
            weekday(floor(starttime)) == 1 || ... 
            weekday(floor(starttime)) == 7
        % starttime is holiday or weeekend, continue
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
    else
        % disp(['Skipped Weekend, ', datestr(floor(starttime)), '.'])
    end
end

% Remove rows left as zeros
daily_pars(all(daily_pars==0,2),:) = [];

% Translate matrix to timeseries
weekend_holiday_par_ts = timeseries(daily_pars(:,1), datestr(daily_pars(:,2)), ...
    'Name', 'Daily PAR (Weekends & Holidays)');
end

