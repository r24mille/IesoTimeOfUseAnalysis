%%
% Add folders to path.
addpath('config', 'data-access', 'lib', 'three-line');

for year=2004:2012
    %%
    % Set start/end and details about location to get demand and temperature
    % timeseries.
    
    % Calendar year
    %start_datetime = strcat(num2str(year), '-01-01 00:00:00');
    %end_datetime = strcat(num2str(year), '-12-31 23:59:59');
    %plot_title = ['Electricity Demand vs. Temperature in Toronto Zone (', num2str(year), ')'];
    
    % Summer Time-of-Use months
    %start_datetime = strcat(num2str(year), '-05-01 00:00:00');
    %end_datetime = strcat(num2str(year), '-10-31 23:59:59');
    %plot_title = ['Electricity Demand vs. Temperature in Toronto Zone (Summer Time-of-Use ', num2str(year), ')'];
    
    % Winter Time-of-Use months (lower for loop end year by 1)
    start_datetime = strcat(num2str(year), '-11-01 00:00:00');
    end_datetime = strcat(num2str(year+1), '-04-30 23:59:59');
    plot_title = ['Electricity Demand vs. Temperature in Toronto Zone (Winter Time-of-Use ', num2str(year),'-', num2str(year+1),')'];
    
    zone_col = 'toronto'; % Zone column name
    location_id = 1; % Toronto
    [ demand_ts, temperature_ts ] = ieso_query_zonal_demand_temp(... 
        zone_col, location_id, start_datetime, end_datetime);

    %%
    % Build energy/temperature vectors only for those days with 24-hours in a
    % day.
    pristine_demand_data = [];
    pristine_temperature_data = [];
    datenum_index = datenum(demand_ts.TimeInfo.StartDate);
    datenum_ts_end = addtodate(datenum_index, 1, 'year');
    while datenum_index < datenum_ts_end
        daily_end = addtodate(datenum_index, 86399, 'second'); % 1 day - 1 second
        daily_demand_ts = getsampleusingtime(demand_ts, datenum_index, daily_end);

        if length(daily_demand_ts.Data) ~= 24
            % disp([datestr(datenum_index), ' demand ts length ', num2str(length(daily_demand_ts.Data))])
        else
            pristine_demand_data = [pristine_demand_data daily_demand_ts.Data'];
        end

        daily_temp_ts = getsampleusingtime(temperature_ts, datenum_index, daily_end);

        if length(daily_temp_ts.Data) ~= 24
            % disp([datestr(datenum_index), ' temp ts length ', num2str(length(daily_temp_ts.Data))])
        else
            pristine_temperature_data = [pristine_temperature_data daily_temp_ts.Data'];
        end

        datenum_index = addtodate(datenum_index, 1, 'day');
    end

    %%
    % Parse data with the three-line model
    X = [pristine_demand_data; pristine_temperature_data];

    [tenth_pct_points, tenth_pct_slopes] = threel(X,10);
    [fiftieth_pct_points, fiftieth_pct_slopes] = threel(X,50);
    [ninetieth_pct_points, ninetieth_pct_slopes] = threel(X,90);

    baseload = min(tenth_pct_points(2),tenth_pct_points(4));
    actload = min(ninetieth_pct_points(2),ninetieth_pct_points(4)) - baseload;
    heatgrad = ninetieth_pct_slopes(1);

    if(ninetieth_pct_slopes(2)>ninetieth_pct_slopes(3))
        coolgrad = ninetieth_pct_slopes(2);
        ac = ninetieth_pct_points(1);
    else
        coolgrad = ninetieth_pct_slopes(3);
        ac = ninetieth_pct_points(3);
    end

    %%
    % Find coordinates of the three-line model

    % Tenth percentile line
    tenth_pct_xvals = ...
        [min(pristine_temperature_data) tenth_pct_points(1) tenth_pct_points(3) max(pristine_temperature_data)];

    tenth_pct_start_pnt = tenth_pct_points(2) - ...
        tenth_pct_slopes(1)*(tenth_pct_points(1)-min(pristine_temperature_data));
    tenth_pct_end_pnt = tenth_pct_points(4) + ...
        tenth_pct_slopes(3)*(max(pristine_temperature_data)-tenth_pct_points(3));
    tenth_pct_yvals = [tenth_pct_start_pnt tenth_pct_points(2) tenth_pct_points(4) tenth_pct_end_pnt];

    % Fiftieth percentil line
    fiftieth_pct_xvals = ...
        [min(pristine_temperature_data) fiftieth_pct_points(1) fiftieth_pct_points(3) max(pristine_temperature_data)];

    fiftieth_pct_start_pnt = fiftieth_pct_points(2) - ...
        fiftieth_pct_slopes(1)*(fiftieth_pct_points(1)-min(pristine_temperature_data));
    fiftieth_pct_end_pnt = fiftieth_pct_points(4) + ...
        fiftieth_pct_slopes(3)*(max(pristine_temperature_data)-fiftieth_pct_points(3));
    fiftieth_pct_yvals = [fiftieth_pct_start_pnt fiftieth_pct_points(2) fiftieth_pct_points(4) fiftieth_pct_end_pnt];

    % Ninetieth percentil line
    ninetieth_pct_xvals = ...
        [min(pristine_temperature_data) ninetieth_pct_points(1) ninetieth_pct_points(3) max(pristine_temperature_data)];

    ninetieth_pct_start_pnt = ninetieth_pct_points(2) - ...
        ninetieth_pct_slopes(1)*(ninetieth_pct_points(1)-min(pristine_temperature_data));
    ninetieth_pct_end_pnt = ninetieth_pct_points(4) + ...
        ninetieth_pct_slopes(3)*(max(pristine_temperature_data)-ninetieth_pct_points(3));
    ninetieth_pct_yvals = [ninetieth_pct_start_pnt ninetieth_pct_points(2) ninetieth_pct_points(4) ninetieth_pct_end_pnt];

    % Create figure
    figure('Name', plot_title);
    hold on;

    grid on;
    three_line_axes = gca;
    title(three_line_axes, plot_title, 'FontWeight', 'bold', 'FontSize', 14);
    ylabel(three_line_axes, 'Electricity Demand (MW)');
    xlabel(three_line_axes, 'Outdoor Temperature (Celsius)');
    axis([-25 40 3000 12500]);

    scatter(pristine_temperature_data, pristine_demand_data, 10, ...
        'x', 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0 0]);
    plot(three_line_axes, tenth_pct_xvals, tenth_pct_yvals, '-mo', ...
        'MarkerSize', 6, 'MarkerFaceColor', [0.17 0.61 0.22], ...
        'Color', [0.17 0.61 0.22], 'LineWidth', 2);
    plot(three_line_axes, fiftieth_pct_xvals, fiftieth_pct_yvals, '-mo', ...
        'MarkerSize', 6, 'MarkerFaceColor', [0.59 0.24 0.17], ...
        'Color', [0.59 0.24 0.17], 'LineWidth', 2);
    plot(three_line_axes, ninetieth_pct_xvals, ninetieth_pct_yvals, '-mo', ...
        'MarkerSize', 6, 'MarkerFaceColor', [0.19 0.22 0.60], ...
        'Color', [0.19 0.22 0.60], 'LineWidth', 2);

    legend(three_line_axes, 'Temperature Occurrence', '10th Percentile', ...
        'Median Data', '90th Percentile', 'Location', 'NorthWest');
    hold off;
end