%%
% Add folders to path since this project is growing quite a bit.
addpath('annual', 'config', 'data-access', 'lib', 'par', 'util');

%%
% Uncomment lines below to see average daily load curve by TOU season
% start_year = 2003;
% end_year = 2011;
% season = 'winter';
% plot_hourly_tou(start_year, end_year, season);

%%
% Uncomment lines below to see evolution of peak-to-average ratio over time
% range.
% start_datetime = '2002-05-01 00:00:00';
% end_datetime = '2011-04-30 23:59:59';
% plot_mean_daily_par_by_week(start_datetime, end_datetime);

start_datetime = '2002-05-01 00:00:00';
end_datetime = '2011-04-30 23:59:59';
demand_ts = ieso_query_demand(start_datetime, end_datetime);
par_ts = par_by_weekend_holiday(demand_ts);

% Trim timeseries to only have top 10 PAR values annually
num_max = 10;
annual_def = 'tou_season';
max_pars_ts = max_pars_annually(par_ts, num_max, annual_def);

% Plot results
plot_title = ['Top ', num2str(num_max), ' Peak-to-Average Ratios Annually (Weekends & Holidays)'];
plot_max_pars(max_pars_ts, plot_title);


%% 
% Query for max demands annually and plot
start_year = 2002;
end_year = 2011;
num_max = 10;
max_demands_ts = max_demand_annually(start_year, end_year, num_max);

% Plot results
plot_title = ['Top ', num2str(num_max), ' Daily Peaks Annually'];
plot_max_demands(max_demands_ts, plot_title);