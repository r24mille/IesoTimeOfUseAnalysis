%%
% Add folders to path.
addpath('config', 'data-access', 'lib', 'three-line');
ac_setpoints_annually = [];
baseload_annually = [];
start_year = 2003;
end_year = 2013;


zone_name = 'West';
location_id = 13;
% zone_name = 'Southwest';
% location_id = 2;
% zone_name = 'Bruce';
% location_id = 7;
% zone_name = 'Niagara';
% location_id = 6;
% zone_name = 'Toronto';
% location_id = 1;
% zone_name = 'East';
% location_id = 3;

%%% Problematic %%%
% zone_name = 'Ottawa';
% location_id = 5;

% zone_name = 'Essa';
% location_id = 8;
% zone_name = 'Northeast';
% location_id = 9;
% zone_name = 'Northwest';
% location_id = 10;

% Create figure
plot_title = [zone_name ' Zone: Three-Line Model (' ...
    num2str(start_year) '-' num2str(end_year) ')'];
figure('Name', plot_title);
hold on;

grid on;
three_line_axes = gca;
title(three_line_axes, plot_title, 'FontWeight', 'bold', 'FontSize', 14);
ylabel(three_line_axes, 'Electricity Demand (MW)');
xlabel(three_line_axes, 'Outdoor Temperature (Celsius)');
% axis([-35 40 3500 12500]); % Toronto
% axis([-35 40 1000 6000]); % Southwest
axis([-35 40 0 5000]); % West, Bruce, Niagara, East, Essa, Northeast

for year=start_year:end_year
    %%
    % Set start/end and details about location to get demand and temperature
    % timeseries.
    
    % Calendar year
    start_datetime = strcat(num2str(year), '-01-01 00:00:00');
    end_datetime = strcat(num2str(year), '-12-31 23:59:59');
    
    [ demand_ts, temperature_ts ] = ieso_query_zonal_demand_temp(... 
        lower(zone_name), location_id, start_datetime, end_datetime);
    
    %%
    % Parse data with the three-line model
    X = [demand_ts.Data'; temperature_ts.Data'];

    [tenth_pct_points, tenth_pct_slopes] = threel(X,10);
    [median_fit_points, median_fit_slopes] = threel(X,50);
    [ninetieth_pct_points, ninetieth_pct_slopes] = threel(X,90);
    
    % Track median summer temperature
    summer_temps = [];
    summer_tou_start = datenum(strcat(num2str(year), '-06-20 00:00:00'));
    summer_tou_end = datenum(strcat(num2str(year), '-09-20 23:59:59'));
    summer_temp_ts = getsampleusingtime(temperature_ts, summer_tou_start, summer_tou_end);
    mean_summer_temp = mean(summer_temp_ts.Data);

    % If slow of second segment is greater than last segment,
    % then use the first point as the AC setpoint.
    if(ninetieth_pct_slopes(2) > ninetieth_pct_slopes(3))
        ac = ninetieth_pct_points(1);
    else
        % The point that _should_ be used as the AC setpoint
        ac = ninetieth_pct_points(3);
    end
    ac_setpoints_annually = [ac_setpoints_annually; [year ac mean_summer_temp]];
    
    % Use the lower of the two 10th percentile points as baseload
    baseload = min(tenth_pct_points(2),tenth_pct_points(4));
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
%     plot(three_line_axes, median_fit_xvals, median_fit_yvals, '-mo', ...
%         'MarkerSize', 3, 'MarkerFaceColor', [0.59 0.24 0.17], ...
%         'MarkerEdgeColor', [0.44 0.09 0.02], ...
%         'Color', [0.59 0.24 0.17], 'LineWidth', 1);
    plot(three_line_axes, ninetieth_pct_xvals, ninetieth_pct_yvals, '-mo', ...
        'MarkerSize', 3, 'MarkerFaceColor', [0.19 0.22 0.60], ...
        'MarkerEdgeColor', [0.04 0.07 0.45], ...
        'Color', [0.19 0.22 0.60], 'LineWidth', 1);
end

% legend(three_line_axes, '10th Percentile', 'Median Fit', '90th Percentile', ...
%     'Location', 'NorthWest');
legend(three_line_axes, '10th Percentile', '90th Percentile', ...
    'Location', 'NorthWest');
hold off;

%%
% Plot AC setpoint as a function of year
setpoint_title = [zone_name ' Zone: Outdoor Temperature at which Air Conditioning is Used'];
figure('Name', setpoint_title, 'Position', [100, 100, 700, 400]);
hold on;
grid on;
[ac_setpoint_axes, ac_handle_1, ac_handle_2] = plotyy(ac_setpoints_annually(:,1), ac_setpoints_annually(:,2), ...
        ac_setpoints_annually(:,1), ac_setpoints_annually(:,3));
title(setpoint_title, 'FontWeight', 'bold', 'FontSize', 14);

set(get(ac_setpoint_axes(1),'Ylabel'),'String', 'AC Setpoint Temperature (Celsius)');
set(ac_setpoint_axes(1), 'YColor', [0.04 0.07 0.45]);
set(ac_handle_1, 'LineStyle', '-', ...
    'Marker', 'o', ...
    'MarkerSize', 3, ...
    'MarkerFaceColor', [0.19 0.22 0.60], ...
    'MarkerEdgeColor', [0.04 0.07 0.45], ...
    'Color', [0.19 0.22 0.60], ...
    'LineWidth', 1);
set(get(ac_setpoint_axes(2),'Ylabel'),'String','Mean Summer Temperature (Celsius)');
set(ac_setpoint_axes(2), 'YColor', [0.85 0.51 0]);
set(ac_handle_2, 'LineStyle', '-', ...
    'Marker', 'o', ...
    'MarkerSize', 3, ...
    'MarkerFaceColor', [1 0.66 0.12], ...
    'MarkerEdgeColor', [0.85 0.51 0], ...
    'Color', [1 0.66 0.12], ...
    'LineWidth', 1);
xlabel('Year');
linkaxes(ac_setpoint_axes, 'y');

% All other zones
% set(ac_setpoint_axes,'XTick', [2003:1:2013], ...
%     'XLim', [2003 2013], ...
%     'YTick', [12:1:25], ...
%     'YLim', [12 25]);

% Bruce, Northeast, Northwest
set(ac_setpoint_axes,'XTick', [2003:1:2013], ...
    'XLim', [2003 2013], ...
    'YTick', [5:1:25], ...
    'YLim', [5 25]);

legend([ac_handle_1; ac_handle_2], 'AC Setpoint', 'Mean Summer Temp', ...
    'Location', 'SouthWest');
hold off;

%%
% Plot baseload as a function of year
baseline_title = [zone_name ' Zone: Baseload Over Time'];
figure('Name', baseline_title, 'Position', [100, 100, 700, 400]);
hold on;
grid on;
baseload_axes = gca;
title(baseload_axes, baseline_title, 'FontWeight', 'bold', 'FontSize', 14);
ylabel(baseload_axes, 'Demand (MW)');
xlabel(baseload_axes, 'Year');
% axis([2003 2013 3500 4500]); % Toronto
% axis([2003 2013 2000 3000]); % Southwest
axis([2003 2013 1000 2000]); % West
% axis([2003 2013 0 1000]); % Bruce, East, Essa, Niagara, Northwest
% axis([2003 2013 500 1500]); % Northeast
plot(baseload_annually(:,1), baseload_annually(:,2), '-mo', ...
        'MarkerSize', 3, 'MarkerFaceColor', [0.17 0.61 0.22], ...
        'MarkerEdgeColor', [0.02 0.46 0.07], ...
        'Color', [0.17 0.61 0.22], 'LineWidth', 1);
legend(baseload_axes, 'Baseload Demand', ...
    'Location', 'NorthWest');
hold off;