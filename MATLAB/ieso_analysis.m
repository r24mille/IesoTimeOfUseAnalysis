%%
% Add folders to path since this project is growing quite a bit.
addpath('config', 'data-access', 'lib', 'par');

%%
% Uncomment lines below to see average daily load curve by TOU season
% start_year = 2003;
% end_year = 2011;
% season = 'winter';
% plot_hourly_tou(start_year, end_year, season);

%%
% Uncomment lines below to see evolution of peak-to-average ratio over time
% range.
start_datetime = '2002-05-01 00:00:00';
end_datetime = '2012-02-09 23:59:59';
%plot_daily_par(start_datetime, end_datetime);