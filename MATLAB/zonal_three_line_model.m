%%
% Add folders to path.
addpath('config', 'data-access', 'lib', 'three-line');
ac_setpoints_annually = [];
baseload_annually = [];

plot_title = ['Electricity Demand vs. Temperature in Toronto Zone'];
% Create figure
figure('Name', plot_title);
hold on;

grid on;
three_line_axes = gca;
title(three_line_axes, plot_title, 'FontWeight', 'bold', 'FontSize', 14);
ylabel(three_line_axes, 'Electricity Demand (MW)');
xlabel(three_line_axes, 'Outdoor Temperature (Celsius)');
axis([-25 40 3000 12500]); % Toronto
%axis([-25 40 2000 6000]); % Southwest

for year=2003:2013
    %%
    % Set start/end and details about location to get demand and temperature
    % timeseries.
    
    % Calendar year
    start_datetime = strcat(num2str(year), '-01-01 00:00:00');
    end_datetime = strcat(num2str(year), '-12-31 23:59:59');
    
    zone_col = 'toronto'; % Zone column name
    location_id = 1; % Toronto
    %zone_col = 'southwest'; % Zone column name
    %location_id = 2; % Kitchener
    [ demand_ts, temperature_ts ] = ieso_query_zonal_demand_temp(... 
        zone_col, location_id, start_datetime, end_datetime);

    %%
    % Parse data with the three-line model
    X = [demand_ts.Data'; temperature_ts.Data'];

    [tenth_pct_points, tenth_pct_slopes] = threel(X,10);
    [median_fit_points, median_fit_slopes] = threel(X,50);
    [ninetieth_pct_points, ninetieth_pct_slopes] = threel(X,90);

    baseload = min(tenth_pct_points(2),tenth_pct_points(4));
    actload = min(ninetieth_pct_points(2),ninetieth_pct_points(4)) - baseload;
    heatgrad = ninetieth_pct_slopes(1);

    % Build a matrix of AC setpoints and baseload setpoints as a function
    % of year
    if(ninetieth_pct_slopes(2)>ninetieth_pct_slopes(3))
        ac = ninetieth_pct_points(1);
    else
        ac = ninetieth_pct_points(3);
    end
    ac_setpoints_annually = [ac_setpoints_annually; [year ac]];
    
    if(tenth_pct_slopes(2)>tenth_pct_slopes(3))
        baseload = tenth_pct_points(2);
    else
        baseload = tenth_pct_points(4);
    end
    
    baseload_annually = [baseload_annually; [year baseload]];

    %%
    % Find coordinates of the three-line model

    % Tenth percentile line
    tenth_pct_xvals = ...
        [min(temperature_ts.Data') tenth_pct_points(1) tenth_pct_points(3) max(temperature_ts.Data')];

    tenth_pct_start_pnt = tenth_pct_points(2) - ...
        tenth_pct_slopes(1)*(tenth_pct_points(1)-min(temperature_ts.Data'));
    tenth_pct_end_pnt = tenth_pct_points(4) + ...
        tenth_pct_slopes(3)*(max(temperature_ts.Data')-tenth_pct_points(3));
    tenth_pct_yvals = [tenth_pct_start_pnt tenth_pct_points(2) tenth_pct_points(4) tenth_pct_end_pnt];

    % Median fit line
    median_fit_xvals = ...
        [min(temperature_ts.Data') median_fit_points(1) median_fit_points(3) max(temperature_ts.Data')];

    median_fit_start_pnt = median_fit_points(2) - ...
        median_fit_slopes(1)*(median_fit_points(1)-min(temperature_ts.Data'));
    median_fit_end_pnt = median_fit_points(4) + ...
        median_fit_slopes(3)*(max(temperature_ts.Data')-median_fit_points(3));
    median_fit_yvals = [median_fit_start_pnt median_fit_points(2) median_fit_points(4) median_fit_end_pnt];

    % Ninetieth percentil line
    ninetieth_pct_xvals = ...
        [min(temperature_ts.Data') ninetieth_pct_points(1) ninetieth_pct_points(3) max(temperature_ts.Data')];

    ninetieth_pct_start_pnt = ninetieth_pct_points(2) - ...
        ninetieth_pct_slopes(1)*(ninetieth_pct_points(1)-min(temperature_ts.Data'));
    ninetieth_pct_end_pnt = ninetieth_pct_points(4) + ...
        ninetieth_pct_slopes(3)*(max(temperature_ts.Data')-ninetieth_pct_points(3));
    ninetieth_pct_yvals = [ninetieth_pct_start_pnt ninetieth_pct_points(2) ninetieth_pct_points(4) ninetieth_pct_end_pnt];
    
    % scatter(temperature_ts.Data', demand_ts.Data', 10, ...
    %     'x', 'MarkerEdgeColor', [0.5 0.5 0.5], 'MarkerFaceColor', [0.5 0.5 0.5]);
    plot(three_line_axes, tenth_pct_xvals, tenth_pct_yvals, '-mo', ...
        'MarkerSize', 3, 'MarkerFaceColor', [0.17 0.61 0.22], ...
        'MarkerEdgeColor', [0.02 0.46 0.07], ...
        'Color', [0.17 0.61 0.22], 'LineWidth', 1);
    plot(three_line_axes, median_fit_xvals, median_fit_yvals, '-mo', ...
        'MarkerSize', 3, 'MarkerFaceColor', [0.59 0.24 0.17], ...
        'MarkerEdgeColor', [0.44 0.09 0.02], ...
        'Color', [0.59 0.24 0.17], 'LineWidth', 1);
    plot(three_line_axes, ninetieth_pct_xvals, ninetieth_pct_yvals, '-mo', ...
        'MarkerSize', 3, 'MarkerFaceColor', [0.19 0.22 0.60], ...
        'MarkerEdgeColor', [0.04 0.07 0.45], ...
        'Color', [0.19 0.22 0.60], 'LineWidth', 1);
end

legend(three_line_axes, '10th Percentile', 'Median Fit', '90th Percentile', ...
    'Location', 'NorthWest');
hold off;

%%
% Plot AC setpoint as a function of year
figure('Name', 'Air Conditioning setpoint as a function of year');
hold on;
ac_setpoint_axes = gca;
title(ac_setpoint_axes, plot_title, 'FontWeight', 'bold', 'FontSize', 14);
ylabel(ac_setpoint_axes, 'Temperature (degrees Celsius)');
xlabel(ac_setpoint_axes, 'Year');
axis([2003 2013 12 20]);
plot(ac_setpoints_annually(:,1), ac_setpoints_annually(:,2), '-mo', ...
        'MarkerSize', 3, 'MarkerFaceColor', [0.19 0.22 0.60], ...
        'MarkerEdgeColor', [0.04 0.07 0.45], ...
        'Color', [0.19 0.22 0.60], 'LineWidth', 1);
legend(ac_setpoint_axes, 'A/C Setpoint', ...
    'Location', 'NorthWest');
hold off;

%%
% Plot baseload as a function of year
figure('Name', 'Baseload as a function of year');
hold on;
hold on;
ac_setpoint_axes = gca;
title(ac_setpoint_axes, plot_title, 'FontWeight', 'bold', 'FontSize', 14);
ylabel(ac_setpoint_axes, 'Demand (MW)');
xlabel(ac_setpoint_axes, 'Year');

plot(baseload_annually(:,1), baseload_annually(:,2), '-mo', ...
        'MarkerSize', 3, 'MarkerFaceColor', [0.17 0.61 0.22], ...
        'MarkerEdgeColor', [0.02 0.46 0.07], ...
        'Color', [0.17 0.61 0.22], 'LineWidth', 1);
legend(ac_setpoint_axes, 'Baseload Demand', ...
    'Location', 'NorthWest');
hold off;