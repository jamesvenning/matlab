function processPIV( Tamb, Pamb, type, varargin )
%PROCESSPIV


% Declare program parameters
pivFolder = '\\gdtl-nas\LST\RFoA\Experiments\PIV';
resFolder = '\\gdtl-nas\LST\RFoA\Experiments\Results';


%% Process inputs

% Request inputs if none are given
if nargin<3
	% Request type
	qAnswer = questdlg( 'What type of PIV did you perform?', ...
		'PIV Type', ...
		'1: Spanwise 3D', '2: Streamwise 2D', '3: Streamwise 3D', ...
		'2: Streamwise 2D' );

	type = str2double( qAnswer(1) );
	
	clear qAnswer
end
if nargin<2
	% Request ambient conditions
	dlgPrompt = { 'Ambient temperature [°F]', 'Ambient pressure [mbar]' };
	dlgTitle = 'Ambient Conditions';
	dlgAnswer = inputdlg( dlgPrompt, dlgTitle );
	
	Tamb = str2double( dlgAnswer{1} );
	Pamb = str2double( dlgAnswer{2} );
	
	clear dlgPrompt dlgTitle dlgAnswer
end

% Look for additional processing flags
if any( strcmpi(varargin,'conditional') )
	conditionalAverage = true;
end

% Convert ambient conditions to SI units
Tamb = f2k(Tamb);			% Convert temperature from °F to K
Pamb = mbar2pa(Pamb);		% Convert pressure from mbar to Pa


%% Begin main program

dayFolder = uigetdir(pivFolder,'Select the DAY FOLDER');

% Find PostProc folder paths
subdirs = genpath( dayFolder );								% Get recursive subdirectories
subdirs = regexpi( subdirs, ';', 'split' );					% Reformat into cell array
keep = ~cellfun(@isempty,regexpi(subdirs,'PostProc$'));		% Tag each path that ends in 'PostProc'
pp = subdirs(keep);											% Keep tagged paths

clear subdirs keep

% Process each PostProc folder
J = length(pp);
for j=1:J
	% Extract folder ancestry from path
	dd = regexpi( pp{j}, '\', 'split' );

	% Figure out which ancestor is the day
	dayIndex = length( find( dayFolder == '\' ) ) + 1;

	proj	= dd{dayIndex-1};		% Extract name of project
	day		= dd{dayIndex};			% Extract day
	run		= dd{dayIndex+1};		% Extract name of specific run/case
	
	clear dd dayIndex

	% Remove iteration from run
	conf = regexprep( run, '_[0-9]{2}$', '' );

	% Select all VC7 files in PostProc folder
	fs = dir( fullfile( pp{j}, '*.vc7' ) );
	fs = {fs.name}';
	
	% Load all selected files
	[ X,Y,Z, U,V,W ] = loadVC7( pp{j}, fs, type );
	nImgs = size( U, 3 );
	
 	% Remove any bad images
 	bad = findBadImages( U, V );
 	U = U(:,:,~bad);	V = V(:,:,~bad);	W = W(:,:,~bad);
	
	clear bad
	
	% Select similar images for conditional averaging
	if exist('conditionalAverage','var')
		sim = findSimilarImages( U, V, 0.8, 1 );
		U = U(:,:,sim);		V = V(:,:,sim);		W = W(:,:,sim);
		
		clear sim
	end
	
	% Calculate mean/std profiles for each component
	[N,Um,Urms] = nzstats( U, 3 );
	[~,Vm,Vrms] = nzstats( V, 3 );
	[~,Wm,Wrms] = nzstats( W, 3 );
	
	clear U V W

	% Remove locations for which there were no vectors
	Um( Um == 0 ) = NaN;		Urms( Urms == 0 ) = NaN;
	Vm( Vm == 0 ) = NaN;		Vrms( Vrms == 0 ) = NaN;
	Wm( Wm == 0 ) = NaN;		Wrms( Wrms == 0 ) = NaN;
	
	% Prepare outputs
	out.X		= measurement( 'Streamwise Coordinate', 'x', 'mm', X );
	out.Y		= measurement( 'Vertical Coordinate', 'y', 'mm', Y );
	out.Z		= measurement( 'Spanwise Coordinate', 'z', 'mm', Z );
	
	out.Um		= measurement( 'Streamwise Velocity', 'u', 'm/s', Um );
	out.Vm		= measurement( 'Vertical Velocity', 'v', 'm/s', Vm );
	out.Wm		= measurement( 'Spanwise Velocity', 'w', 'm/s', Wm );
	
	out.Urms	= measurement( 'RMS of Streamwise Velocity', 'u_{rms}', 'm/s', Urms );
	out.Vrms	= measurement( 'RMS of Vertical Velocity', 'v_{rms}', 'm/s', Vrms );
	out.Wrms	= measurement( 'RMS of Spanwise Velocity', 'w_{rms}', 'm/s', Wrms );
	
	out.Tamb	= measurement( 'Ambient Temperature', 'T_{amb}', 'K', Tamb );
	out.Pamb	= measurement( 'Ambient Pressure', 'p_{amb}', 'Pa', Pamb );
	
	out.N		= measurement( 'Number of Images', 'N', '', N );
	out.type	= measurement( 'PIV Type', '', '', type );
	out.source	= measurement( 'Source Location', '', '', pp{j} );
	
	clear X Y Z Um Vm Wm Urms Vrms Wrms N
	
	% Timestamp for acquisition and averaging
	out.timestamp = measurement( 'Timestamp History' );

	acqdate = [ day(1:4) '-' day(5:6) '-' day(7:8) ' 12:00:00' ];
	switch type
		case 0, acqtype = 'spanwise 2D PIV';
		case 1, acqtype = 'spanwise 3D PIV';
		case 2, acqtype = 'streamwise 2D PIV';
		case 3, acqtype = 'streamwise 3D PIV';
	end
	out.timestamp.value{1} = [ acqdate '. Acquired using ' acqtype '.' ];

	avgdate = datestr( now, 31 );
	out.timestamp.value{2} = [ avgdate '. Ensemble averaged using ' num2str(nImgs) ' images.' ];

	clear acqdate acqtype avgdate nImgs
	
	% Export average of each run
	dout = fullfile( resFolder, proj, day );
	if ~exist(dout,'dir'), mkdir(dout); end
	fout = fullfile( dout, [run '.mat'] );
	save( fout, '-struct', 'out' );
	fprintf( '\tVelocity component averages exported: %s\n', fout );
	
	clear proj day run conf fs N out dout fout

	fprintf('\n');
end

fprintf('PIV processing complete!\n');
beep;