function plot_daily_par( daily_par_ts, plot_title )
%PLOT_DAILY_PAR Plots the daily peak-to-average ratio for a time range
%   Parameters:
%   start_datetime, String in the format of %y-%m-%d %T. 
%   end_datetime, String in the format of %y-%m-%d %T.
%%
% Plot the results
figure('Name', plot_title);
hold on;
dail_par_axes = gca;
title(dail_par_axes, plot_title, 'FontWeight', 'bold');
ylabel(dail_par_axes, 'Peak-to-Average Ratio (PAR)');
xlabel(dail_par_axes, 'Date');

x_datenums = datenum(daily_par_ts.TimeInfo.StartDate) + daily_par_ts.Time;
plot(dail_par_axes, x_datenums, daily_par_ts.Data, 'Color', 'b');
datetick(dail_par_axes, 'x');

% Find x values for plotting the fit based on xlim
axesLimits = xlim(dail_par_axes);
xplot = linspace(axesLimits(1), axesLimits(2));

fitResults = polyfit(x_datenums, daily_par_ts.Data, 1);
% Evaluate polynomial
yplot = polyval(fitResults, xplot);
% Plot the fit
plot(dail_par_axes, xplot, yplot, 'Color', 'r');

% Build legend
legend(dail_par_axes, 'Peak-to-Average Ratio', 'Linear Trend');
hold off;
end