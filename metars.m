function [T P] = metars( station, time )
%METARS Get atmospheric temperature and pressure.
%	[T P] = METARS( STATION, TIME ) returns the temperature, T, and
%	pressure, P, at the weather station, STATION, at time, TIME.
%	
%	STATION should be a four letter ICAO station identifier, such as
%	'KOSU'. If no STATION is specified, 'KOSU' is assumed. TIME should be a
%	6 digit date/time string of the form 'ddHHMM', such as '251453',
%	meaning the 25th day, 14th hour, and 53rd minute. If no TIME is
%	specified, the most recent measurements are returned.

if ~exist( 'station', 'var' )
	station = 'KOSU';
end

% alpha = isstrprop( varargin, 'alpha' );
% if any(alpha)
% 	station = varargin{alpha};
% else
%	station = 'KOSU';
% end
% 
% num = isstrprop( varargin, 'digit' );
% if any(num), time = varargin{num}; end

%%
% Get the ADDS html page
url = 'http://www.aviationweather.gov/adds/metars/';
params = { 'station_ids', station, ...
	'chk_metars', 'on' ...
	'hoursStr', 'past 36 hours' };
html = urlread( url, 'get', params );

% Extract the METARS strings
expr = [ '>(' station ' [ A-Z0-9/]+)<' ];
strs = regexpi( html, expr, 'tokens' );
strs = cellfun( @(c) c, strs );		% Remove nested cell arrays

%%
% Select the METARS closest to the requested time
if exist('time','var')
	expr = ' (\d+)Z ';		% ex: find ' 251453Z ', keep '251453'
	tstamps = regexpi( strs, expr, 'tokens', 'once' );
	tstamps = cellfun( @(c) c, tstamps );		% Remove nested cell arrays
	tstamps = cell2mat( tstamps' );
	
	dt = datenum( time, 'ddHHMM' ) - datenum( tstamps, 'ddHHMM' );
	[~,k] = min( abs(dt) );
	
	ref = strs{k};
	
else
	% If no time is requested, take the most recent
	ref = strs{1};
	
end

%%
% Temperature [K]
expr = ' (\d+)/\d+ ';		% ex: find ' 20/16 ', keep '20'
T = regexpi( ref, expr, 'tokens', 'once' );
T = str2double( T{1} );
T = T + 273.15;

% Pressure [Pa]
expr =  ' A(\d+) ';			% ex: find ' A2990 ', keep '2990'
P = regexpi( ref, expr, 'tokens', 'once' );
P = str2double( P{1} )/100;
P = 3386 * P;