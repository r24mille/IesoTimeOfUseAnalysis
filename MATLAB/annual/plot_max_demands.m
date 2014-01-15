function plot_max_demands( max_demands_ts, plot_title )
%PLOT_MAX_DEMANDS Plots the max daily peaks grouped by year

%%
% Plot the results
figure('Name', plot_title);
hold on;
dail_par_axes = gca;
title(dail_par_axes, plot_title, 'FontWeight', 'bold');
ylabel(dail_par_axes, 'Electricity Demand (MW)');
xlabel(dail_par_axes, 'Date');

x_datenums = datenum(max_demands_ts.TimeInfo.StartDate) + max_demands_ts.Time;
scatter(x_datenums, max_demands_ts.Data, '*');
datetick(dail_par_axes, 'x');

% Find x values for plotting the fit based on xlim
axesLimits = xlim(dail_par_axes);
xplot = linspace(axesLimits(1), axesLimits(2));

fitResults = polyfit(x_datenums, max_demands_ts.Data, 1);
% Evaluate polynomial
yplot = polyval(fitResults, xplot);
% Plot the fit
plot(dail_par_axes, xplot, yplot, 'Color', 'r');

% Build legend
legend(dail_par_axes, 'Electricity Demand', 'Linear Trend');
hold off;
end