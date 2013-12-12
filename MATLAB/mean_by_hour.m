function [ mean_by_hour ] = mean_by_hour( reading_ts )
%MEAN_BY_HOUR Groups reading by hour and finds mean
%   First count how many readings there are per hour. Second, sums the
%   readings by hour. Finally, determine mean consumption by hour.

%%
% Sum values by hour
num_events_by_hour = accumarray(hour(reading_ts.TimeInfo.Time)+1, 1);
sums_by_hour = accumarray(hour(reading_ts.TimeInfo.Time)+1, reading_ts.Data);

%%
% Get mean value (ie. divide by number of days in sample)
daily_fraction = 1./num_events_by_hour;
mean_by_hour = sums_by_hour.*(daily_fraction);
clear daily_fraction num_events_by_hour sums_by_hour;
end