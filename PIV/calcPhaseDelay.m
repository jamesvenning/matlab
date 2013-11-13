function [ delays ] = calcPhaseDelay( frequency, phases )
% Outputs PIV reference times in milliseconds


actDelay = 22.3e-3;     % Delay between trigger and plasma formation [ms]
minDelay = 0.4;         % Minimum delay time [ms]

% Calculate the delay times
delays = actDelay + phases/360 * 1000/frequency;

% Add one period to delays less than the minimum
delays( delays<minDelay ) = delays( delays<minDelay ) + 1000/frequency;

% Round to the nearest microsecond
delays = round( 1000*delays )/1000;