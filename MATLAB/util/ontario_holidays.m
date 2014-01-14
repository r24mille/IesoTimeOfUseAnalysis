function [ ontario_holidays ] = ontario_holidays( year )
%IS_ONTARIO_HOLIDAY Summary of this function goes here
%   Ontario holidays retrieved from 
%   https://www.labour.gov.on.ca/english/es/pubs/guide/publicholidays.php
%     New Year's Day - January 1
%     Family Day - 3rd Monday of February
%     Good Friday - Find only holidays() from Finance Toolbox between 
%                   March 11 (earliest possible Easter) and April 25
%                   (latest possible Easter). Conveniently there are no
%                   U.S. holidays between these two dates.
%     Victoria Day - Last Monday before May 25
%     Canada Day - July 1
%     Labour Day - 1st Monday in September
%     Thanksgiving Day - 2nd Monday in October
%     Christmas Day - December 25
%     Boxing Day - December 26

%%
year = 2012;

% Year as string for convenience
year_str = num2str(year);

% New Year`s Day
new_years_datenum = datenum(['Jan-01-', year_str]);

% Family Day
feb_cal = calendar(year,2);
if feb_cal(1,2) > 0
    family_day_number = feb_cal(3,2);
else
    family_day_number = feb_cal(4,2);
end
family_day_datenum = datenum(['Feb-',num2str(family_day_number),'-',year_str]);

% Good Friday
easter_range_start_datestr = ['Mar-11-', year_str];
easter_range_end_datestr = ['Apr-25-', year_str];
good_friday_datenum = holidays(easter_range_start_datestr, easter_range_end_datestr);

% Victoria Day
may_25_datenum = datenum(['May-25-', year_str]);
if weekday(may_25_datenum) == 2
    victoria_day_datenum = addtodate(may_25_datenum, -7, 'day');
elseif weekday(may_25_datenum) == 1
    victoria_day_datenum = addtodate(may_25_datenum, -6, 'day');
else
    days_after_mon = weekday(may_25_datenum) - 2;
    victoria_day_datenum = addtodate(may_25_datenum, (0-days_after_mon), 'day');
end

% Canada Day
canada_day_datenum = datenum(['July-01-', year_str]);

% Labour Day
sep_cal = calendar(year,9);
if sep_cal(1,2) > 0
    labour_day_number = sep_cal(1,2);
else
    labour_day_number = sep_cal(2,2);
end
labour_day_datenum = datenum(['Sep-',num2str(labour_day_number),'-',year_str]);

% Thanksgiving
oct_cal = calendar(year,10);
if oct_cal(1,2) > 0
    thanksgiving_day_number = oct_cal(2,2);
else
    thanksgiving_day_number = oct_cal(3,2);
end
thanksgiving_day_datenum = datenum(['Oct-',num2str(thanksgiving_day_number),'-',year_str]);

% Christmas Day
christmas_datenum = datenum(['Dec-25-', year_str]);

% Boxing Day
boxing_day_datenum = datenum(['Dec-26-', year_str]);

ontario_holidays = [new_years_datenum
    family_day_datenum
    good_friday_datenum
    victoria_day_datenum
    canada_day_datenum
    labour_day_datenum
    thanksgiving_day_datenum
    christmas_datenum
    boxing_day_datenum];

for i=1:length(ontario_holidays)
    datestr(ontario_holidays(i))
end
end

