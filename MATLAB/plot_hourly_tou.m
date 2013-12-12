function plot_hourly_tou( start_year, end_year, season )
%MEAN_BY_HOUR Groups reading by hour and finds mean
%   First count how many readings there are per hour. Second, sums the
%   readings by hour. Finally, determine mean consumption by hour.
%
%   Parameters:
%   start_year - Integer starting year of query (inclusive)
%   end_year - Integer ending year of query (inclusive)
%   season - String of time-of-use season must match 'summer' or 'winter'
%%

%%
% Prep some settings for the query and plot;
line_colors = colormap(lines(end_year - start_year + 1));
xrng = 0:23;

if strcmp(season, 'summer') == 1
    legend_labels = start_year:end_year;
    legend_labels = substring(num2str(legend_labels'), 3, 2);
    start_month_part = '-05-01';
    end_month_part = '-09-30';
    figure_title = 'Mean Daily Load Curve During Summer (May 1 - Sep 30)';
elseif strcmp(season, 'winter') == 1
    % Labels for a two years are a bit more complicated
    legend_labels = cell(end_year-start_year,1)
    for i=start_year:end_year
        from_str = num2str(i);
        from_str = from_str(3:4);
        to_str = num2str(i+1);
        to_str = to_str(3:4);
        legend_labels{i-start_year+1, 1} = strcat('''', from_str, '-''', to_str); 
    end
    start_month_part = '-05-01';
    end_month_part = '-09-30';
    figure_title = 'Mean Daily Load Curve During Winter (Nov 1 - Apr 30)';
end

%%
% Loop over years and find May 1 - September 30 (IESO summer time-of-use
% schedule) for each year
hold on;
for i = start_year:end_year
    % Query for timeseries
    if strcmp(season, 'summer') == 1
        start_datetime = strcat(num2str(i), start_month_part, ' 00:00:00');
        end_datetime = strcat(num2str(i), end_month_part, ' 23:59:59');
    elseif strcmp(season, 'winter') == 1
        start_datetime = strcat(num2str(i), start_month_part, ' 00:00:00');
        end_datetime = strcat(num2str(i+1), end_month_part, ' 23:59:59');
    end
    reading_ts = ieso_query_readings(start_datetime, end_datetime, ...
        schema, username, password, host, port);

    % Find mean consumption by hour
    mean_readings = mean_by_hour(reading_ts);
    clear reading_ts;
    plot(xrng, mean_readings, ...
        'Color', line_colors((i - start_year + 1),:), ...
        'LineWidth', 2);
end

title(figure_title, 'FontWeight', 'bold');

% Formatting y-axis
ylabel('Ontario Demand (MW)');
yrng = get(gca, 'YTick');
set(gca, 'YTickLabel', sprintf('%u|', yrng));

% Formatting x-axis
xlabel('Hour of Day');
set(gca, 'XTick', 0:3:24);
set(gca, 'XTickLabel', sprintf('%02u:00|',xrng(1:3:end)));

legend(legend_labels);
hold off;
end