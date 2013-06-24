function [] = calibrateHW( ds )
% Creates a hot-wire calibration curve using a least-squares application of
% King's Law


% Check the inputs
if ~exist( 'ds', 'var' )
	ds = uigetdir2();
end

if ischar(ds), ds={ds}; end

% Declare constants
k = 1.05;		% Tunnel calibration constant, see Little 2010 p.33

% Preallocate matrices
nFiles	= length(ds);
Vm		= zeros( 1, nFiles );
Vrms	= zeros( 1, nFiles );
Um		= zeros( 1, nFiles );
Urms	= zeros( 1, nFiles );

% Loop through each file
for n=1:nFiles
	% Load the ambient conditions
	ff = fullfile( ds{n}, 'ambient.txt' );
	data = load( ff );
	Tinf = f2k( data(2) );			% [K]
	Pamb = mbar2pa( data(3) );		% [Pa]
	
	% Load the velocity and pressure data
	ff = fullfile( ds{n}, 'x0.000000_y0.000000.txt' );
	data = load( ff );
	
	% Deal out the data
	v_HW	= data(:,2);
	v_Po	= data(:,3);
	v_Pinf	= data(:,4);
	
	% Convert pressure measurements
	Po		= in2pa( 4.2610*v_Po - 1.1344 );		% [Pa]
	Pinf	= in2pa( 2.0834*v_Pinf - 0.3619 );		% [Pa]
	
 	% Calculate density
 	rho = (Pamb-Pinf)/287/Tinf;
	
	% Calculate velocity
	Q		= k*( Po + Pinf );
	U		= sqrt( 2*Q./rho );
	
	% Store the mean and rms values
	Vm(n)	= mean( v_HW );
	Vrms(n) = std( v_HW );
	
	Um(n)	= mean( U );
	Urms(n) = std( U );
end

% Perform least-squares fit of King's Law to data
eq		= @(c,x) c(1)+c(2)*x.^c(3);
coef	= lsqcurvefit( eq, [1 1 1], Vm, Um );

% Plot the results for reference
figure;
errorbar( Vm, Um, Urms, '+k' ); hold on;
herrorbar( Vm, Um, Vrms, '+k' );
plot( Vm, eq(coef,Vm), '-k' ); hold off;
xlabel( 'Voltage, V [V]' ); ylabel( 'Velocity, U [m/s]' );

% Save the calibration
fout = fullfile( ds{1}, '..\calibration.mat' );
save( fout, 'Vm','Vrms', 'Um','Urms', 'eq','coef' );