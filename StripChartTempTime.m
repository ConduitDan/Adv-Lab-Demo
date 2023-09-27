
July 16, 2023 Seth Fraden
% The provided code is a MATLAB function called "StripChartTempTime.m" that interfaces with an Arduino board 
% to read temperature data from a serial port. It continuously updates a strip chart with 
% temperature plotted against time, while also storing the temperature and time values in an array. 
% After a specified number of serial reads, the temperature data is written to a file.

% It should be possible to modify both the Arduino acquisition and Matlab display functions to
% record and display multiple thermistors.

% The Matlab function "plotTemperatureData.m" plots the data in the file

% 
% Here's a concise description of what the code does:
% 
% Clears any open serial ports to ensure a clean connection.
% Sets the serial port and baud rate to communicate with the Arduino.
% Opens the serial port for communication.
% Sets the parameters for the strip chart, including its length and y-axis range.
% Creates the figure and axes for the strip chart and initializes the line plot.
% Reads the initial temperature and time values from the Arduino serial port.
% Initializes the arrays for storing temperature and time.
% Defines the parameters for writing temperature data to the file.
% Creates a file with a unique filename based on the timestamp.
% Writes the file header.
% Enters a loop to continuously update the strip chart.
% Reads temperature and time data from the Arduino serial port.
% Updates the strip chart with the new data.
% Displays the temperature and time values in the MATLAB command window.
% Stores the temperature and time values in the tempArray array.
% Checks if it's time to write the data to the file based on the tempArrayLength.
% Writes the tempArray to the file and appends it.
% Closes the file and the serial port.


% Works with the Arduino code: "ThermistorTimeSerialOutForMatlab.ino"

% // Reads voltage from voltage divider with thermistor as one leg. Averages numMeasurements times.
% // Thermistor is in leg next to ground and the voltage is read by "analogPin"
% // The thermistor is a Epcos, R/T 1008 with R_25 = 2000 ohms. B-parameter equation given in code.
% // Outputs temperature (C) and elapsed time (s)
% // Example serial line output:
% //              Temperature (C): 27.73, Time (s): 645.06



function StripChartTempTime()

    % close all serial ports
     fclose(instrfindall);
    
    % Set the serial port and baud rate
    serialPort = '/dev/cu.usbmodem141101';  % Replace with serial port listed in Arduino IDE
    baudRate = 9600;  % Make sure it matches the Arduino code
    
    % Open the serial port
    s = serial(serialPort, 'BaudRate', baudRate);
    fopen(s);
    
    % Set the strip chart parameters
    plotLength = 100;  % Length of the strip chart
    yRange = [15, 40];  % Y-axis range
    
    % Create the figure and axes for the strip chart
    fig = figure('Name', 'Strip Chart');
    ax = axes('Parent', fig);
    linePlot = line('Parent', ax, 'XData', [], 'YData', []);
    xlabel('Time [s]');
    ylabel('Temperature [^{\circ}C]');
    title('Gel temperature vs. time');
    grid on;
    
    % Initialize the variables
    
     % Read the data from the Arduino serial port
        data = fscanf(s);
        
        % Extract numbers (2 x 1 double) using str2double
        tokens = split(data);
        numbers = str2double(tokens(~isnan(str2double(tokens))));
        temperatureNow = numbers(1);
        timeNow = numbers(2);
       
        
    time = zeros(1, plotLength);
    temperature = zeros(1, plotLength);
    
    time(:) = timeNow;
    temperature(:) = temperatureNow;
    
    tempArrayLength = 10;  % Number of serial reads before writing to file
    tempArrayCounter = 0;  % Counter for serial reads
    
    pause(2)
     
    % Create a file to save the data in the current director
    
    % Generate a timestamp for the filename
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    
    % Create the file name with timestamp
    fileName = ['temperature_data_', timestamp, '.txt'];
    
    % Create the file for writing in the current directory
    fileID = fopen(fileName, 'w');
    
    % Write the file header
    fprintf(fileID, 'Temperature\tTime\n');
    
    % To specify a different directory for writing the file, 
    %    provide the full file path when opening the file.
    
    % fileName = '/path/to/directory/temperature_data.txt';
    % fileID = fopen(fileName, 'w');
    
    % Replace "/path/to/directory" with the 
    %  actual directory path where you want to save the file. 
    
 % Write the string to the Arduino
%     str = 'Cool';
%     fprintf(s, '%s\n', str);
    
    
    % Start the loop to continuously update the strip chart
    while ishandle(fig)
      
        % Read the data from the Arduino serial port
        data = fscanf(s);
       
        
        % Extract numbers (2 x 1 double) using str2double
        tokens = split(data);
        numbers = str2double(tokens(~isnan(str2double(tokens))));
        temperatureNow = numbers(1);
        timeNow = numbers(2);
        pwmNow = numbers(3);
        
        
        % Shift the time and temperature arrays
        time = [time(2:end), timeNow];
        temperature = [temperature(2:end), temperatureNow];
        
        % Update the strip chart data
        set(linePlot, 'XData', time, 'YData', temperature);
        
        % Set the x-axis limits
        xlim(ax, [time(1), time(end)]);
        
        % Set the y-axis limits. Autoscale.
        ylim(ax, [min(temperature) - 0.1, max(temperature) + 0.1]);
        
        % Update the plot
        drawnow;
        
        % Display the extracted numbers
        disp(['Temp: ', num2str(temperatureNow), ' (C) ', 'Time: ', num2str(timeNow), ' (s)  PWM: ' ,num2str(pwmNow)]);
    
        % Store the data in tempArray
        tempArrayCounter = tempArrayCounter + 1;
        tempArray(tempArrayCounter, :) = [temperatureNow, timeNow];
        
        % Check if it's time to write to file
        if tempArrayCounter == tempArrayLength
            % Write tempArray to the file and append it
            dlmwrite(fileName, tempArray, '-append');
            
            % Reset the tempArrayCounter and tempArray
            tempArrayCounter = 0;
            %this is a temp change
            tempArray = [];
        end
    
    
    end
    
    % Close the file
    fclose(fileID);
    
    % Close the serial port
    fclose(s);
    delete(s);
