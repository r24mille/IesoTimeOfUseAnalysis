function plot_daily_par( start_datetime, end_datetime )
%PLOT_DAILY_PAR Plots the daily peak-to-average ratio for a time range
%   Parameters:
%   start_datetime, String in the format of %y-%m-%d %T. 
%   end_datetime, String in the format of %y-%m-%d %T.

%%
% Retrieve matrix of datenums and PAR values
daily_pars = par_by_day(start_datetime, end_datetime);

%%
% Plot the results
hold on;
title('Change in Daily PAR Over Time', 'FontWeight', 'bold');
ylabel('Peak-to-Average Ratio (PAR)');
xlabel('Day of Year');

plot(daily_pars(:,1), daily_pars(:,2), ...
    'Color', 'b');
datetick('x');

% Find x values for plotting the fit based on xlim
lin_xplot = linspace(min(daily_pars(:,1)), max(daily_pars(:,1)));

fit_res = polyfit(daily_pars(:,1), daily_pars(:,2), 1);
% Evaluate polynomial
lin_yplot = polyval(fit_res, lin_xplot);
% Plot the fit
plot(lin_xplot, lin_yplot, ...
    'Color', 'r');

% Build legend
legend('Peak-to-Average Ratio', 'Linear Trend');
hold off;
end

