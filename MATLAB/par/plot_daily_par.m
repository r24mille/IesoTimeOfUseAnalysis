function plot_daily_par( start_datetime, end_datetime )
%PLOT_DAILY_PAR Plots the daily peak-to-average ratio for a time range
%   Parameters:
%   start_datetime, String in the format of %y-%m-%d %T. 
%   end_datetime, String in the format of %y-%m-%d %T.

%%
% Retrieve matrix of datenums and PAR values
demand_ts = ieso_query_demand(start_datetime, end_datetime);
daily_par_ts = par_by_day(demand_ts);

%%
% Plot the results
hold on;
title('Change in Daily PAR Over Time', 'FontWeight', 'bold');
ylabel('Peak-to-Average Ratio (PAR)');
xlabel('Date');

plot((datenum(daily_par_ts.TimeInfo.StartDate) + daily_par_ts.Time), ...
    daily_par_ts.Data, 'Color', 'b');
datetick('x');

% Find x values for plotting the fit based on xlim
axesLimits = xlim(gca);
xplot = linspace(axesLimits(1), axesLimits(2));

fitResults = polyfit((datenum(daily_par_ts.TimeInfo.StartDate) + daily_par_ts.Time), ...
    daily_par_ts.Data, 1);
% Evaluate polynomial
yplot = polyval(fitResults, xplot);
% Plot the fit
plot(xplot, yplot, 'Color', 'r');

% Build legend
legend('Peak-to-Average Ratio', 'Linear Trend');
hold off;
end

