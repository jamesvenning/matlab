function [ xc Cp_m Cl_m Cp_rms Cl_rms ] = processStaticPressure( airfoil, dataFolder )
% Processes static pressure data taken using the Scanivalve system.

%% Check the inputs
if ~exist( 'airfoil', 'var' )
	airfoil = input( 'Which airfoil did you test with? ', 's' );
end

if ~exist( 'dataFolder', 'var' )
	dataFolder = uigetdir( 'Select the data containing folder' );
end

%% Declare constants and load tap locations
in2pa	= 249.1;		% Inches of water to Pascals [Pa/in.H2O]
psi2pa	= 6895;			% PSI to Pascals [Pa/psi]
k		= 1.05;			% Tunnel calibration constant, see Little 2010 p.33
[xc cc]	= getTapLocations( airfoil );

%%
allFiles = dir( fullfile(dataFolder,'*.txt') );
allFiles = {allFiles.name}';

nFiles = length(allFiles);
for n=1:nFiles
	% Load raw data from txt file
	txtFile	= fullfile( dataFolder, allFiles{n} );
	data	= load( txtFile );

	% Deal out the data
	P		= psi2pa*data(:,1);					% [Pa]
	Po		= in2pa*nonzeros( data(:,2) );		% [Pa]
	Pinf	= in2pa*nonzeros( data(:,3) );		% [Pa]
	To		= nonzeros( data(:,4) );			% [K]
	Tamb	= nonzeros( data(:,5) );			% [K]
	Pamb	= nonzeros( data(:,6) );			% [Pa]

	Q = k*( Po + Pinf );		% Dynamic pressure, [Pa]

	% Calculate Cp and Cl
	[Cp Cl]	= calcCpCl( xc, P, Pinf, Q, cc );

	% Perform row-wise statistics
	Cp_m(:,n)	= mean( Cp, 2 );		Cp_rms(:,n)	= std( Cp, 0, 2 );
	Cl_m(n)		= mean( Cl, 2 );		Cl_rms(n)	= std( Cl, 0, 2 );
end

% Close the Cp curve
if cc
	xc(end+1) = xc(1);
end