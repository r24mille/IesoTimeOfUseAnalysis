function [ ont_holidays ] = ontario_holidays( start_datenum, end_datenum )
%ONTARIO_HOLIDAYS Returns a vector of datenums for each of the 
%statutory holidays in Ontario between (inclusive) the date range provided.
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

% Create empty vector
temp_holidays = [];
ont_holidays = [];

% Vector of years
start_year = year(start_datenum);
end_year = year(end_datenum);

% Get all holidays for years in consideration
year_iter = start_year;
while year_iter <= end_year
    temp_holidays = [temp_holidays 
        ontario_holidays_for_year(year_iter)];
    year_iter = year_iter + 1;
end

% Trim off holidays that do not fall in range
for i=1:length(temp_holidays)
    if temp_holidays(i) >= start_datenum && temp_holidays(i) <= end_datenum
        ont_holidays = [ont_holidays temp_holidays(i)];
    end
end

