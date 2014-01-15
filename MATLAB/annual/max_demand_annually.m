function [ max_demands_ts ] = max_demand_annually( ...
    start_year, end_year, num_max)
%MAX_DEMAND_ANNUALLY Summary of this function goes here
%   Detailed explanation goes here

%%
num_years = end_year - start_year;
max_demands_ts = timeseries(['Top ', num2str(num_max), ' Daily Peaks Annually']);

% Query for max demands annually and append them to a cumulative timeseries
for i=0:(num_years - 1)
    start_datetime = [num2str(start_year + i), '-05-01 00:00:00'];
    end_datetime = [num2str(start_year + i + 1), '-04-30 23:59:59'];
    max_demands_annual_ts = ...
        ieso_query_max_demand( start_datetime, end_datetime, num_max );
    
    max_demands_ts = append(max_demands_ts, max_demands_annual_ts);
end

% Set name again since append overwrites name
max_demands_ts.Name = ['Top ', num2str(num_max), ' Daily Peaks Annually'];
end

