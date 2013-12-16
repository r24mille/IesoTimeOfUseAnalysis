function [ mean_daily_par_by_week_ts ] = ...
    mean_daily_par_by_week( daily_par_ts )
%MEAN_DAILY_PAR_BY_WEEK Create a weekly timeseries of mean daily PAR values
%   Parameters:
%   daily_par_ts, A timeseries object of daily PAR values. See par_by_day
%   function.

%%
% Loop over ts to create a matrix of mean daily PAR values by week
num_weeks = ceil(ceil(daily_par_ts.TimeInfo.End - daily_par_ts.TimeInfo.Start) / 7);
mean_daily_pars_mat = zeros(num_weeks, 2);
for i = 0:(num_weeks - 1)
    starttime = addtodate(datenum(daily_par_ts.TimeInfo.StartDate), (i*7), 'day');
    endtime = addtodate(starttime, 604799, 'second'); % 1 week - 1 second
    daily_par_for_week_ts = getsampleusingtime(daily_par_ts, starttime, endtime);
    mean_daily_par = mean(daily_par_for_week_ts);
    % clear daily_par_for_week_ts;
    
    % Place results in matrix
    mean_daily_pars_mat(i+1, 1) = mean_daily_par;
    mean_daily_pars_mat(i+1, 2) = starttime;
end

%%
% Translate weekly matrix to timeseries
mean_daily_par_by_week_ts = timeseries(mean_daily_pars_mat(:,1), ... 
    datestr(mean_daily_pars_mat(:,2)), 'Name', 'Mean Daily PAR by Week');
end

