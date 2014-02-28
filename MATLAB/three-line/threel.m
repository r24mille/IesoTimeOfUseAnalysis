function [points, slopes] = threel(X, pct)
%THREEL Three-line model
%
%   Parameters:
%   X, a 2xN matrix of energy and temperature values. mod(length, 24) == 0.
%   pct, percentile.

%%
% Set up initial variables
optimal_section1_x= 0; 
optimal_section1_y = 0;
optimal_section2_x = 0;
optimal_section2_y = 0;
optimal_slope1=0;
optimal_slope2=0;
optimal_slope3 = 0;

optimal_section1=0;
optimal_section2=0;

%%
% Calibrate the search space for line segment temperatures
min_number_section2_temperatures = 5;
max_number_section2_temperatures = 10;

% Ensure matrix does not contain character values and that data is
% comprised of 24-hour days.
if ~ischar(X) && mod(length(X(1,:)), 24) == 0
    % Split matrix into vectors of energy and temperature values
    demands = X(1,:);
    temperatures = X(2,:);
    
    % Round termpartures to nearest integer values
    integer_temperatures = round(temperatures);
    
    % Extract sorted range of temperature values
    temperature_range = zeros(max(integer_temperatures) - min(integer_temperatures) + 1, 1);
    percentile_temperature_range = zeros(max(integer_temperatures) - min(integer_temperatures) + 1, 1);
    
    % temperature_range and percentile_temperature_range are redefined to
    % contain only temperatures with 20+ samples
    number_bins = 0;
    for j=min(integer_temperatures):max(integer_temperatures)
        % Include all temperature bins with at least 20 data points
        if (length(demands(logical(integer_temperatures==j)))>20)
            number_bins = number_bins+1;
            temperature_range(number_bins,1) = j;
            percentile_temperature_range(number_bins,1) = prctile(demands(logical(integer_temperatures==j)),pct);
        end
    end
    temperature_range = temperature_range(1:number_bins,1);
    percentile_temperature_range = percentile_temperature_range(1:number_bins,1);
    
    
    max_temperature_section1 = max(temperature_range) - 15; % originally 20
    min_temperature_section1 = max_temperature_section1 - 10; % originally 10
    min_RMSE = 1000; % calibrate minimum root mean squared error
    %for section1=10:20
    for section1=min_temperature_section1:max_temperature_section1
        % Checks that temperature_range contains section1.
        if any(temperature_range==section1)
            temperature_range_section1 = temperature_range(logical(temperature_range<=section1));
            percentile_temperature_range_section1 = percentile_temperature_range(logical(temperature_range<=section1));
            temperature_range_section1 = [ones(size(temperature_range_section1)) temperature_range_section1];
            CS1 = (temperature_range_section1'*temperature_range_section1) \ (temperature_range_section1'*percentile_temperature_range_section1);
            PLS1 = CS1(1)+CS1(2).*temperature_range_section1(:,2);
            RMSE_S1 = sqrt(sum((PLS1 - percentile_temperature_range_section1) .^ 2)/size(temperature_range_section1,1));
            
            for section2=min_number_section2_temperatures:max_number_section2_temperatures
                temperature_range_section2 = temperature_range(logical(temperature_range>=section1));
                temperature_range_section2 = temperature_range_section2(1:section2);
                percentile_temperature_range_section2 = percentile_temperature_range(logical(temperature_range>=section1));
                percentile_temperature_range_section2 = percentile_temperature_range_section2(1:section2);
                temperature_range_section2 = [ones(size(temperature_range_section2)) temperature_range_section2];
                CS2 = (temperature_range_section2'*temperature_range_section2) \ (temperature_range_section2'*percentile_temperature_range_section2);
                PLS2 = CS2(1)+CS2(2).*temperature_range_section2(:,2);
                RMSE_S2 = sqrt(sum((PLS2 - percentile_temperature_range_section2) .^ 2)/size(temperature_range_section2,1));

                temperature_range_section3 = temperature_range(logical(temperature_range>=temperature_range_section2(end)));
                percentile_tempearture_range_section3 = percentile_temperature_range(logical(temperature_range>=temperature_range_section2(end)));
                temperature_range_section3 = [ones(size(temperature_range_section3)) temperature_range_section3];
                CS3 = (temperature_range_section3'*temperature_range_section3) \ (temperature_range_section3'*percentile_tempearture_range_section3);
                PLS3 = CS3(1)+CS3(2).*temperature_range_section3(:,2);
                RMSE_S3 = sqrt(sum((PLS3 - percentile_tempearture_range_section3) .^ 2)/size(temperature_range_section3,1));

                RMSE = RMSE_S1 + RMSE_S2 + RMSE_S3;
                if(RMSE < min_RMSE)
                    min_RMSE = RMSE;
                    optimal_section1 = section1;
                    optimal_section2 = section2;
                end
            end
            
        end  
    end

    temperature_range_section1 = temperature_range(logical(temperature_range<=optimal_section1));
    percentile_temperature_range_section1 = percentile_temperature_range(logical(temperature_range<=optimal_section1));
    temperature_range_section1 = [ones(size(temperature_range_section1)) temperature_range_section1];
    CS1 = (temperature_range_section1'*temperature_range_section1) \ (temperature_range_section1'*percentile_temperature_range_section1);
    PLS1 = CS1(1)+CS1(2).*temperature_range_section1(:,2);
    temperature_range_section2 = temperature_range(logical(temperature_range>=optimal_section1));
    temperature_range_section2 = temperature_range_section2(1:optimal_section2);
    percentile_temperature_range_section2 = percentile_temperature_range(logical(temperature_range>=optimal_section1));
    percentile_temperature_range_section2 = percentile_temperature_range_section2(1:optimal_section2);
    temperature_range_section2 = [ones(size(temperature_range_section2)) temperature_range_section2];
    CS2 = (temperature_range_section2'*temperature_range_section2) \ (temperature_range_section2'*percentile_temperature_range_section2);
    PLS2 = CS2(1)+CS2(2).*temperature_range_section2(:,2);
    if(length(temperature_range_section2)>0)
        temperature_range_section3=temperature_range(logical(temperature_range>=temperature_range_section2(end)));
        percentile_tempearture_range_section3=percentile_temperature_range(logical(temperature_range>=temperature_range_section2(end)));
        temperature_range_section3=[ones(size(temperature_range_section3)) temperature_range_section3];
        CS3=(temperature_range_section3'*temperature_range_section3) \ (temperature_range_section3'*percentile_tempearture_range_section3);
        PLS3=CS3(1)+CS3(2).*temperature_range_section3(:,2);
    end
    optimal_section2 = optimal_section2+optimal_section1-1;

    TcpA = optimal_section1;
    LcpA1 = CS1(1)+TcpA*CS1(2);
    LcpA2 = CS2(1)+TcpA*CS2(2);
    LcpA = (LcpA1+LcpA2)/2;

    TcpB = optimal_section2;
    LcpB2 = CS2(1)+TcpB*CS2(2);
    LcpB3 = CS3(1)+TcpB*CS3(2);
    LcpB = (LcpB2+LcpB3)/2;

    searchSpace1 = zeros(9,2);
    searchSpace2 = zeros(9,2);

    deltaT = 0.5;
    deltaL1 = abs(LcpA1-LcpA2)/4;
    deltaL2 = abs(LcpB2-LcpB3)/4;

    searchSpace1(1,1)=TcpA-deltaT; searchSpace1(1,2)=LcpA+deltaL1;
    searchSpace1(2,1)=TcpA; searchSpace1(2,2)=LcpA+deltaL1;
    searchSpace1(3,1)=TcpA+deltaT; searchSpace1(3,2)=LcpA+deltaL1;
    searchSpace1(4,1)=TcpA-deltaT; searchSpace1(4,2)=LcpA;
    searchSpace1(5,1)=TcpA; searchSpace1(5,2)=LcpA;
    searchSpace1(6,1)=TcpA+deltaT; searchSpace1(6,2)=LcpA;
    searchSpace1(7,1)=TcpA-deltaT; searchSpace1(7,2)=LcpA-deltaL1;
    searchSpace1(8,1)=TcpA; searchSpace1(8,2)=LcpA-deltaL1;
    searchSpace1(9,1)=TcpA+deltaT; searchSpace1(9,2)=LcpA-deltaL1;

    searchSpace2(1,1)=TcpB-deltaT; searchSpace2(1,2)=LcpB+deltaL1;
    searchSpace2(2,1)=TcpB; searchSpace2(2,2)=LcpB+deltaL1;
    searchSpace2(3,1)=TcpB+deltaT; searchSpace2(3,2)=LcpB+deltaL1;
    searchSpace2(4,1)=TcpB-deltaT; searchSpace2(4,2)=LcpB;
    searchSpace2(5,1)=TcpB; searchSpace2(5,2)=LcpB;
    searchSpace2(6,1)=TcpB+deltaT; searchSpace2(6,2)=LcpB;
    searchSpace2(7,1)=TcpB-deltaT; searchSpace2(7,2)=LcpB-deltaL1;
    searchSpace2(8,1)=TcpB; searchSpace2(8,2)=LcpB-deltaL1;
    searchSpace2(9,1)=TcpB+deltaT; searchSpace2(9,2)=LcpB-deltaL1;

    x1S1=temperature_range(1); y1S1=CS1(1)+CS1(2)*temperature_range(1);
    x2S3=temperature_range(end); y2S3=CS3(1)+CS3(2)*temperature_range(end);
    min_RMSE=1000;
    for section1=1:9
        x2S1=searchSpace1(section1,1); y2S1=searchSpace1(section1,2);
        mS1=(y2S1-y1S1)/(x2S1-x1S1);
        CS1(1)=y1S1-mS1*x1S1;
        CS1(2)=mS1;
        PLS1=CS1(1)+CS1(2).*temperature_range_section1(:,2);
        RMSE_S1 = sqrt(sum((PLS1 - percentile_temperature_range_section1) .^ 2)/size(temperature_range_section1,1));
        for section2=1:9
            x1S2=searchSpace1(section1,1); y1S2=searchSpace1(section1,2); x2S2=searchSpace2(section2,1); y2S2=searchSpace2(section2,2);
            mS2=(y2S2-y1S2)/(x2S2-x1S2);
            CS2(1)=y1S2-mS2*x1S2;
            CS2(2)=mS2;
            PLS2=CS2(1)+CS2(2).*temperature_range_section2(:,2);
            RMSE_S2 = sqrt(sum((PLS2 - percentile_temperature_range_section2) .^ 2)/size(temperature_range_section2,1));

            x1S3=searchSpace2(section2,1); y1S3=searchSpace2(section2,2); 
            mS3=(y2S3-y1S3)/(x2S3-x1S3);
            CS3(1)=y1S3-mS3*x1S3;
            CS3(2)=mS3;
            PLS3=CS3(1)+CS3(2).*temperature_range_section3(:,2);
            RMSE_S3 = sqrt(sum((PLS3 - percentile_tempearture_range_section3) .^ 2)/size(temperature_range_section3,1));

            RMSE = RMSE_S1 + RMSE_S2 + RMSE_S3;
            if(RMSE < min_RMSE)
                min_RMSE = RMSE;
                optimal_section1_x=x1S2;
                optimal_section2_x=x2S2;
                optimal_section2_y=y2S2;
                optimal_section1_y=y1S2;

                optimal_slope1=mS1;
                optimal_slope2=mS2;
                optimal_slope3=mS3;
            end
        end
    end
end

points =[optimal_section1_x,optimal_section1_y,optimal_section2_x,optimal_section2_y];
slopes = [optimal_slope1,optimal_slope2,optimal_slope3];
end