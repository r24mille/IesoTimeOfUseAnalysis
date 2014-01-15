function [ max_pars_ts ] = max_pars_annually( daily_par_ts, num_max, ...
    annual_def )
%MAX_PARS_ANNUALLY Finds the daily peak-to-average ratio (PAR) for a timeseries.
%   Returns the daily peak-to-average ratio (PAR) of a timeseries. Also
%   known as "crest factor."
%
%   Parameters:
%   daily_par_ts, Timeseries of daily PAR values
%   num_max, The number of maximum PAR values to select in each year (eg.
%            num_max=10 would mean "top 10 PAR values annually")
%   annual_def, Key term which controls the definition of annual cycle:
%                  'tou_season' = May 1st - April 30th
%                  'calendar' = January 1st - December 31st
%
%   Returns:
%   max_pars_ts, Timeseries object of maximum PAR values for each year.

%%
% Loop over days in timeseries
max_pars_ts = timeseries(['Top ', num2str(num_max), ' PARs Annually']);
start_year = year(datenum(daily_par_ts.TimeInfo.StartDate));
end_year = year(datenum(daily_par_ts.TimeInfo.StartDate) + daily_par_ts.TimeInfo.End);
num_years = end_year + 1 - start_year;

% If annual cycle is by TOU season, end the outer for loop one iteration
% earlier since TOU season is May of current year into April of next year.
if strcmp(annual_def, 'tou_season')
    outer_loop_end = (num_years - 2);
else
    outer_loop_end = (num_years - 1);
end

for i = 0:outer_loop_end
    % Conditionally switch between annual cycle defined by TOU season or
    % calendar year.
    if strcmp(annual_def, 'tou_season')
        loop_start_year_str = num2str(start_year + i);
        loop_end_year_str = num2str(start_year + i + 1);
        annual_ts = getsampleusingtime(daily_par_ts, ...
            datenum(['01-May-', loop_start_year_str, ' 00:00:00']), ...
            datenum(['30-Apr-', loop_end_year_str, ' 23:59:59']));
    else
        loop_year_str = num2str(start_year + i);
        annual_ts = getsampleusingtime(daily_par_ts, ...
            datenum(['01-Jan-', loop_year_str, ' 00:00:00']), ...
            datenum(['31-Dec-', loop_year_str, ' 23:59:59']));
    end
    
    % Sort timeseries data to fine the top # of PARs in the year
    sorted_annual_data = sort(annual_ts.Data(:), 'descend');
    max_pars = sorted_annual_data(1:num_max);
    lower_bound = max_pars(num_max);
    
    % Iterate through annual_ts checking if data is greater than the lower
    % bound found above. This preserves timestamp of original data.
    max_par_sample_indeces = [];
    for j=1:length(annual_ts.Data)
        if annual_ts.getsamples(j).Data >= lower_bound
            % disp(['Adding element #', num2str(j), ' PAR=', num2str(annual_ts.getsamples(j).Data)]);
            max_par_sample_indeces = [max_par_sample_indeces j];
        end
    end
    
    % Merge the top PAR values from this annual_ts with other years' top
    % PAR values.
    max_par_annual_ts = annual_ts.getsamples(max_par_sample_indeces);
    max_pars_ts = append(max_pars_ts, max_par_annual_ts);
end

% Set name again since append overwrites name
max_pars_ts.Name = ['Top ', num2str(num_max), ' PARs Annually'];
end

