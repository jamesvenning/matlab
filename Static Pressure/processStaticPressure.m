function processStaticPressure( airfoil, dataFolder )
% Processes static pressure data taken using the Scanivalve system.


% Declare program parameters
cpFolder = '\\gdtl-nas\LST\RFoA\Experiments\Static Pressure';
resFolder = '\\gdtl-nas\LST\RFoA\Experiments\Results';

%% Check the inputs
if ~exist( 'airfoil', 'var' )
	airfoil = input( 'Which airfoil did you test with? ', 's' );
end

if ~exist( 'dataFolder', 'var' )
	dayFolder = uigetdir( cpFolder, 'Select the data containing folder' );
end

%% Declare constants and load tap locations
k		= 1.05;			% Tunnel calibration constant, see Little 2010 p.33
[xc cc]	= getTapLocations( airfoil );

%% Begin main program
allFiles = dir( fullfile(dayFolder,'*.txt') );
allFiles = {allFiles.name}';

% Extract folder ancestry from path
dd		= regexpi( dayFolder, '\', 'split' );
day		= dd{end};			% Extract day
proj	= dd{end-1};		% Extract name of project

clear dd dayIndex

% Create output directory if it doesn't exist
dout = fullfile( resFolder, proj, day );
if ~exist(dout,'dir'), mkdir(dout); end

% Process each text file
nFiles = length(allFiles);
for n=1:nFiles
	% Extract name of specific run/case
	run		= regexprep( allFiles{n}, '.txt', '' );
	
	% Load raw data from txt file
	data	= load( fullfile(dayFolder,allFiles{n} ));

	% Deal out the data
	Tinf	= f2k( data(:,1) );				% Stagnation temperature, [K]
	Tamb	= f2k( data(:,2) );				% Ambient temperature, [K]
	Pamb	= mbar2pa( data(:,3) );			% Ambient pressure, [Pa]
	Po		= in2pa( data(:,4) );			% Stagnation pressure, [Pa]
	Pinf	= in2pa( data(:,5) );			% Freestream pressure, [Pa]
	P		= psi2pa( data(:,6:end) );		% Static surface pressure, [Pa]

	Q		= k*( Po + Pinf );				% Dynamic pressure, [Pa]

	N		= size(P,1);					% Number of samples

	clear data

	% Remove pressure data from open/unused transducers
	ci = [ 26:32, 43:48 ];
	P(:,ci) = [];
	
	clear ci

	% Calculate Cp and Cl
	[Cp Cl]	= calcCpCl( xc, P, Pinf, Q, cc );
	
	clear Q P

	% Perform column-wise statistics
	Cp_rms	= std( Cp, 0, 1 );
	Cl_rms	= std( Cl );
	Cp		= mean( Cp, 1 );
	Cl		= mean( Cl );
	Tinf	= mean( Tinf );
	Tamb	= mean( Tamb );
	Pamb	= mean( Pamb );
	Po		= mean( Po );
	Pinf	= mean( Pinf );

	% Close the Cp curve
	xc1 = xc;
	if cc, xc1(end+1) = xc1(1); end

	% Prepare outputs
	out.xc		= measurement( 'Chordwise Location', '|x/c|', '', xc1 );
	out.Cp		= measurement( 'Pressure Coefficient', 'C_p', '', Cp );
	out.Cp_rms	= measurement( 'RMS of Pressure Coefficient', 'C_{p,rms}', '', Cp_rms );

	out.Cl		= measurement( 'Lift Coefficient', 'C_L', '', Cl );
	out.Cl_rms	= measurement( 'RMS of Lift Coefficient', 'C_{L,rms}', '', Cl_rms );

	out.Tamb	= measurement( 'Ambient Temperature', 'T_{amb}', 'K', Tamb );
	out.Pamb	= measurement( 'Ambient Pressure', 'p_{amb}', 'Pa', Pamb );

	out.Tinf	= measurement( 'Freestream Temperature', 'T_\infty', 'K', Tinf );
	out.Pinf	= measurement( 'Freestream Pressure', '-p_\infty', 'Pa', Pinf );
	out.Po		= measurement( 'Stagnation Pressure', 'p_o', 'Pa', Po );

	out.source	= measurement( 'Source Location', '', '', dayFolder );

 	clear xc1 Cp Cp_rms Cl Cl_rms Tamb Pamb Tinf Po Pinf

	% Timestamp for acquisition and averaging
	out.timestamp = measurement( 'Timestamp History' );

	acqdate = [ day(1:4) '-' day(5:6) '-' day(7:8) ' 12:00:00' ];
	out.timestamp.value{1} = [ acqdate '. Acquired using static pressure transducers.' ];

	avgdate = datestr( now, 31 );
	out.timestamp.value{2} = [ avgdate '. Ensemble averaged using ' num2str(N) ' samples.' ];

 	clear acqdate avgdate N

	% Save the output file
 	fout = fullfile( dout, [run '.mat'] );
	save( fout, '-struct', 'out' );

	clear fout run
end