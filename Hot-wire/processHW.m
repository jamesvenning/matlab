function [] = processHW( fs, d )
%


%%
% Check the inputs
if ~exist( 'fs', 'var' )
	[fs d] = uigetfile( '.txt', 'MultiSelect', 'on' );
end

if ischar(fs), fs={fs}; end

% Load the calibration file
calFile = fullfile( d, '..\calibration.mat' );
if ~exist( calFile, 'file' )
	error( 'You must run calibrateHW first!' );
else
	cal = load( calFile );
	clear calFile
end

%%
% Remove the ambient.txt file if it was selected
fs( strcmpi(fs,'ambient.txt') ) = [];

% Determine how many files (i.e. coordinates) were selected
nFiles = length(fs);

% Preallocate matrices
Um		= zeros( 1, nFiles );
Urms	= zeros( 1, nFiles );
X		= zeros( 1, nFiles );
Y		= zeros( 1, nFiles );
%PSD	= zeros( ?, nFiles );
%f		= zeros( ?, nFiles );
Po		= zeros( 1, nFiles );
Pinf	= zeros( 1, nFiles );

% Create a low-pass filter
[b a] = butter( 5, 0.9 );		% 5th-order butterworth with Nyquist cutoff

%%
% Loop through each file/coordinate
for n=1:nFiles
	% Load the data
	ff = fullfile( d, fs{n} );
	data = load( ff );
	
	% Get the time series, sampling period, and block size
	t		= data(:,1);
	dt		= t(2)-t(1);
	t0		= abs( t - dt*( 0:length(t)-1 )' );		% Find the time jumps
	blkSz	= find( t0>1e-10, 1, 'first' )-1;		% Block size
	nBlk	= length(t)/blkSz;						% Number of blocks
	
	clear t t0
	
% 	% Low-pass filter the data
% 	for j=1:nBlk
% 		% Filter just one block at a time
% 		l1 = blkSz*(j-1)+1;
% 		l2 = blkSz*j;
% 		
% 		data(l1:l2,2:end) = filtfilt( b, a, data(l1:l2,2:end) );
% 	end
	
	clear l1 l2
	
	% Deal out the data
	v_HW	= data(:,2);
	v_Po	= data(:,3);
	v_Pinf	= data(:,4);
	
	clear ff data
	
	% Convert hot-wire voltage to velocity
	U		= cal.eq( cal.coef, v_HW );			% Black box approach
	Um(n)	= mean( U );
	Urms(n)	= std( U );
	
	clear v_HW
	
	% Calculate spectra from velocity
	[PSD(:,n) f(:,n)] = calPSD( U-Um(n), blkSz, 1/dt, 'hann', 0, [0 0] );
	
	clear U
	
	% Convert stagnation/freestream voltages to pressures
	Po(n)		= in2pa( mean( 4.2610*v_Po - 1.1344 ) );		% [Pa]
	Pinf(n)		= in2pa( mean( 2.0834*v_Pinf - 0.3619 ) );		% [Pa]
	
	clear v_Po v_Pinf
	
	% Get (x,y) coordinates in the format 'x[x]_y[y].txt'
	expr = ['x(?<x>[0-9\.\-]+)' ...		% Find 'x#.#' and return '#.#'
		'_' ...
		'y(?<y>[0-9\.\-]+)' ...			% Find 'y#.#' and return '#.#'
		'.txt'];
	s = regexpi( fs{n}, expr, 'names' );
	X(n) = str2double( s.x );
	Y(n) = str2double( s.y );
end

% Do a whole-test average of pressures
Po		= mean( Po );
Pinf	= mean( Pinf );

%%
% Load the ambient conditions
ff = fullfile( d, 'ambient.txt' );
data = load(ff);
Tamb = f2k( mean(data(:,1)) );			% [K]
Tinf = f2k( mean(data(:,2)) );			% [K]
Pamb = mbar2pa( mean(data(:,3)) );		% [Pa]

%%
% Make sure values are properly ordered (x then y)
[~,i]	= sortrows([X' Y']);
X		= X(i);				Y		= Y(i);
Um		= Um(i);			Urms	= Urms(i);
PSD		= PSD(:,i);			f		= f(:,i);

% Prepare outputs
out.X		= measurement( 'Streamwise Coordinate', 'x', 'mm', X );
out.Y		= measurement( 'Vertical Coordinate', 'y', 'mm', Y );

out.Um		= measurement( 'Streamwise Velocity', 'u', 'm/s', Um );
out.Urms	= measurement( 'RMS of Streamwise Velocity', 'u_{rms}', 'm/s', Urms );

out.PSD		= measurement( 'PSD', '', '', PSD );
out.f		= measurement( 'Frequency', 'f', 'Hz', f );
out.fs		= measurement( 'Sampling Frequency', 'f_s', 'Hz', 1/dt );

out.Po		= measurement( 'Stagnation Pressure', 'p_o', 'Pa', Po );
out.Pinf	= measurement( 'Freestream Pressure', '-p_\infty', 'Pa', Pinf );
out.Pamb	= measurement( 'Ambient Pressure', 'p_{amb}', 'Pa', Pamb );

out.Tinf	= measurement( 'Stagnation Temperature', 'T_\infty', 'K', Tinf );
out.Tamb	= measurement( 'Ambient Temperature', 'T_{amb}', 'K', Tamb );

out.source	= measurement( 'Source Location', '', '', d );

% Timestamp for acquisition and processing
out.timestamp = measurement( 'Timestamp History' );

day = regexpi( d, '[0-9]{8}[\\a-z]', 'match', 'once' );		% Extract the day from the folder tree
acqdate = [ day(1:4) '-' day(5:6) '-' day(7:8) ' 12:00:00' ];
out.timestamp.value{1} = [ acqdate '. Acquired using hot-wire at ' num2str(1/dt) ' Hz.' ];

procdate = datestr( now, 31 );
out.timestamp.value{2} = [ procdate '. Spectra calculated using ' num2str(nBlk) ' blocks of ' num2str(blkSz) '.' ];

% Save the results
ff = [ d(1:end-1) '.mat' ];			% Output file matches test case
save( ff, '-struct', 'out' );