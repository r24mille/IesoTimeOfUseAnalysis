%%
% Add folders to path since this project is growing quite a bit.
addpath('anova', 'config', 'data-access', 'lib', 'util');

%%
% Split database results into relevant vectors
[y_readings, rounded_temps, tou_periods, tou_billings] = ldc_query_sample();

%%
% Perform ANOVA analysis
p = anovan(y_readings, {rounded_temps tou_periods tou_billings})