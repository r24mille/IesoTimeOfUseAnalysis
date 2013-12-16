function plot_mean_daily_par_by_week( start_datetime, end_datetime )
%PLOT_DAILY_PAR Plots the mean daily PAR by week for a time range.
%   Parameters:
%   start_datetime, String in the format of %y-%m-%d %T. 
%   end_datetime, String in the format of %y-%m-%d %T.

%%
% Retrieve matrix of datenums and PAR values
demand_ts = ieso_query_demand(start_datetime, end_datetime);
daily_par_ts = par_by_day(demand_ts);
mean_daily_par_by_week_ts = mean_daily_par_by_week(daily_par_ts);

%%
% Plot the results
figure('Name', 'Mean Daily PAR by Week');
hold on;
mean_daily_par_axes = gca;
title(mean_daily_par_axes, 'Mean Daily PAR by Week', 'FontWeight', 'bold');
ylabel(mean_daily_par_axes, 'Mean Peak-to-Average Ratio (PAR)');
xlabel(mean_daily_par_axes, 'Date Grouped by Week');

x_datenums = datenum(mean_daily_par_by_week_ts.TimeInfo.StartDate) + mean_daily_par_by_week_ts.Time;
mean_daily_par_plot = plot(mean_daily_par_axes, x_datenums, mean_daily_par_by_week_ts.Data, ...
    'Color', 'b');
datetick(mean_daily_par_axes, 'x');

% Find x values for plotting the fit based on xlim
axesLimits = xlim(mean_daily_par_axes);
linear_xplot = linspace(axesLimits(1), axesLimits(2));

% Prepare for plotting residuals
set(mean_daily_par_axes,'position',[0.1300    0.5811    0.7750    0.3439]);
residmean_daily_par_axes = axes('position', [0.1300    0.1100    0.7750    0.3439], ...
    'parent', gcf);

fitResults = polyfit(x_datenums, mean_daily_par_by_week_ts.Data, 1);
% Evaluate polynomial
yplot = polyval(fitResults, linear_xplot);

% Calculate and save residuals - evaluate using original xdata
Yfit = polyval(fitResults, x_datenums);
resid = mean_daily_par_by_week_ts.Data - Yfit(:);

% Plot the fit
fitLine = plot(mean_daily_par_axes, linear_xplot, yplot, ...
    'Color','r');
% Create legend
legend(mean_daily_par_axes, 'Mean Daily PAR', 'Linear Trend');

% Set new line in proper position
% Get the axes children
hChildren = get(mean_daily_par_axes,'Children');
% Remove the new line
hChildren(hChildren==fitLine) = [];
% Get the index to the associatedLine
lineIndex = find(hChildren==mean_daily_par_plot);
% Reorder lines so the new line appears with associated data
hNewChildren = [hChildren(1:lineIndex-1);fitLine;hChildren(lineIndex:end)];
% Set the children:
set(mean_daily_par_axes,'Children',hNewChildren);

% Plot residuals in a bar plot
residPlot = bar(residmean_daily_par_axes, x_datenums, resid);
datetick('x');
% Set colors to match fit lines
set(residPlot(1), 'facecolor', 'r', 'edgecolor', 'r');
% Set residual plot axis title
set(get(residmean_daily_par_axes, 'title'),'string','Residuals');
hold off;
end