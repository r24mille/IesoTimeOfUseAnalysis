%%
% Add folders to path.
addpath('config', 'data-access', 'lib', 'three-line');
ac_range = [];
baseload_range = [];

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
for year=2010:2013
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
    [fiftieth_pct_points, fiftieth_pct_slopes] = threel(X,50);
    [ninetieth_pct_points, ninetieth_pct_slopes] = threel(X,90);

    baseload = min(tenth_pct_points(2),tenth_pct_points(4));
    actload = min(ninetieth_pct_points(2),ninetieth_pct_points(4)) - baseload;
    heatgrad = ninetieth_pct_slopes(1);

    if(ninetieth_pct_slopes(2)>ninetieth_pct_slopes(3))
        coolgrad = ninetieth_pct_slopes(2);
        ac = ninetieth_pct_points(1)
    else
        coolgrad = ninetieth_pct_slopes(3);
        ac = ninetieth_pct_points(3)
    end
    ac_range = [ac_range ac];
    baseload_range = [baseload_range baseload];

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

    % Fiftieth percentil line
%     fiftieth_pct_xvals = ...
%         [min(temperature_ts.Data') fiftieth_pct_points(1) fiftieth_pct_points(3) max(temperature_ts.Data')];
% 
%     fiftieth_pct_start_pnt = fiftieth_pct_points(2) - ...
%         fiftieth_pct_slopes(1)*(fiftieth_pct_points(1)-min(temperature_ts.Data'));
%     fiftieth_pct_end_pnt = fiftieth_pct_points(4) + ...
%         fiftieth_pct_slopes(3)*(max(temperature_ts.Data')-fiftieth_pct_points(3));
%     fiftieth_pct_yvals = [fiftieth_pct_start_pnt fiftieth_pct_points(2) fiftieth_pct_points(4) fiftieth_pct_end_pnt];

    % Ninetieth percentil line
    ninetieth_pct_xvals = ...
        [min(temperature_ts.Data') ninetieth_pct_points(1) ninetieth_pct_points(3) max(temperature_ts.Data')];

    ninetieth_pct_start_pnt = ninetieth_pct_points(2) - ...
        ninetieth_pct_slopes(1)*(ninetieth_pct_points(1)-min(temperature_ts.Data'));
    ninetieth_pct_end_pnt = ninetieth_pct_points(4) + ...
        ninetieth_pct_slopes(3)*(max(temperature_ts.Data')-ninetieth_pct_points(3));
    ninetieth_pct_yvals = [ninetieth_pct_start_pnt ninetieth_pct_points(2) ninetieth_pct_points(4) ninetieth_pct_end_pnt];
    
    

    scatter(temperature_ts.Data', demand_ts.Data', 10, ...
        'x', 'MarkerEdgeColor', [0.25 0.25 0.25], 'MarkerFaceColor', [0.25 0.25 0.25]);
    plot(three_line_axes, tenth_pct_xvals, tenth_pct_yvals, '-mo', ...
        'MarkerSize', 6, 'MarkerFaceColor', [0.17 0.61 0.22], ...
        'Color', [0.17 0.61 0.22], 'LineWidth', 2);
%     plot(three_line_axes, fiftieth_pct_xvals, fiftieth_pct_yvals, '-mo', ...
%         'MarkerSize', 6, 'MarkerFaceColor', [0.59 0.24 0.17], ...
%         'Color', [0.59 0.24 0.17], 'LineWidth', 2);
    plot(three_line_axes, ninetieth_pct_xvals, ninetieth_pct_yvals, '-mo', ...
        'MarkerSize', 6, 'MarkerFaceColor', [0.19 0.22 0.60], ...
        'Color', [0.19 0.22 0.60], 'LineWidth', 2);
    
 
end

legend(three_line_axes, 'Temperature Observations', '10th Percentile', '90th Percentile', ...
    'Location', 'NorthWest');
hold off;