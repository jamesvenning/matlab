function processPIV( Tamb, Pamb, type, varargin )
%PROCESSPIV


% Program defaults
pivFolder	= '\\gdtl-nas\LST\RFoA\Experiments\PIV';
resFolder	= '\\gdtl-nas\LST\RFoA\Experiments\Results';
finalForm	= 'PostProc';	% Folder name of final processing step
group		= false;		% Group like configurations?
condThresh	= -1;			% Conditional threshold (-1 to disable)
lim			= -1;			% Maximum number of images (-1 to disable)


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
	dlgPrompt = { 'Ambient temperature [�F]', 'Ambient pressure [mbar]' };
	dlgTitle = 'Ambient Conditions';
	dlgAnswer = inputdlg( dlgPrompt, dlgTitle );
	
	Tamb = str2double( dlgAnswer{1} );
	Pamb = str2double( dlgAnswer{2} );
	
	clear dlgPrompt dlgTitle dlgAnswer
end

% Look for additional processing flags
if any( strcmpi(varargin,'results') )
	% Override the output folder
	i = find( strcmpi(varargin,'results') );
	if ischar(varargin{i+1}),		resFolder = varargin{i+1};
	else							error('Results flag must be followed by path string.');
	end
end
if any( strcmpi(varargin,'finalform') )
	% Override the final process folder
	i = find( strcmpi(varargin,'finalform') );
	if ischar(varargin{i+1}),		finalForm = varargin{i+1};
	else							error('Final flag must be followed by string.');
	end
end
if any( strcmpi(varargin,'group') )
	% Group like configurations together
	i = find( strcmpi(varargin,'group') );
	if islogical(varargin{i+1}),	group = varargin{i+1};
	else							error('Group flag must be followed by boolean.');
	end
end
if any( strcmpi(varargin,'conditional') )
	% Use a conditional ensemble average
	i = find( strcmpi(varargin,'conditional') );
	if isnumeric(varargin{i+1}),	condThresh = varargin{i+1};
	else							error('Conditional flag must be followed by numeric threshold.');
	end
end
if any( strcmpi(varargin,'limit') )
	% Limit the maximum number of images
	i = find( strcmpi(varargin,'limit') );
	if isnumeric(varargin{i+1}),	lim = varargin{i+1};
	else							error('Limit flag must be followed by numeric threshold.');
	end
end

clear i

% Convert ambient conditions to SI units
Tamb = f2k(Tamb);			% Convert temperature from �F to K
Pamb = mbar2pa(Pamb);		% Convert pressure from mbar to Pa


%% Begin main program

dayFolder = uigetdir(pivFolder,'Select the DAY FOLDER');

clc;
fprintf( 'Processing PIV folder: "%s"\n\n', dayFolder );

% Find 'PostProc' folder paths
fprintf( 'Searching for "%s" folders...', finalForm );
subdirs = genpath( dayFolder );								% Get recursive subdirectories
subdirs = regexpi( subdirs, pathsep, 'split' );				% Reformat into cell array
keep = ~cellfun(@isempty,regexpi(subdirs,[finalForm '$']));	% Tag each path that ends in 'PostProc'
pp = subdirs(keep);											% Keep tagged paths

clear subdirs keep

J = length(pp);
fprintf( ' %g found.\n\n', J );

% Process each PostProc folder
for j=1:J
	% Extract folder ancestry from path
	dd = regexpi( pp{j}, filesep, 'split' );

	% Figure out which ancestor is the day
	dayIndex = length( find( dayFolder == filesep ) ) + 1;

	proj	= dd{dayIndex-1};		% Extract name of project
	day		= dd{dayIndex};			% Extract day
	run		= dd{dayIndex+1};		% Extract name of specific run/case
	
	clear dd dayIndex
	
	fprintf( 'Processing run %g of %g: "%s"\n', j, J, run );
	
	if group
		% Skip this run if it's a repeat configuration (already loaded)
		if regexp( run, '_[0-9]{2}$' )
			fprintf( 'Already processed.\n\n' );
			continue;
		end
		
		% Select VC7 files from grouped PostProc folders
		i=0; fs=[]; src=[];
		while (j+i)<=J && ~isempty(strfind(pp{j+i},run))
			dlist = dir( fullfile( pp{j+i}, '*.VC7' ) );
			fs = [ fs; strcat( pp{j+i}, filesep, {dlist.name}' ) ];
			src{i+1} = pp{j+i};
			i = i+1;
		end
		
		if length(src)==1, src=src{1}; end
		
		fprintf( 'Found %g "VC7" files in %g folders.\n', length(fs), i );
	else
		% Select VC7 files from this PostProc folder
		dlist = dir( fullfile( pp{j}, '*.VC7') );
		fs = strcat( pp{j}, filesep, {dlist.name}' );
		src = pp{j};
		
		fprintf( 'Found %g "VC7" files.\n', length(fs) );
	end
	
	clear i dlist
	
	% Load all selected files
	[ X,Y,Z, U,V,W ] = loadVC7( fs, type );
	nLoaded = size( U, 3 );
	
 	% Remove any bad images
 	bad = findBadImages( U, V );
 	U = U(:,:,~bad);	V = V(:,:,~bad);	W = W(:,:,~bad);
	
	clear bad
	
	% Select similar images for conditional averaging
	if condThresh>0
		sim = findSimilarImages( U, V, condThresh, 1 );
		U = U(:,:,sim);		V = V(:,:,sim);		W = W(:,:,sim);
		
		clear sim
	end
	
	% Reduce set to specified maximum
	if lim>0 && lim<=size(U,3)
		fprintf( 'Downsampling to %g images...', lim );
		U = U(:,:,1:lim);	V = V(:,:,1:lim);	W = W(:,:,1:lim);
		fprintf( ' success.\n' );
	end
		
	nUsed = size( U, 3 );
	fprintf( 'Using %g of %g images available.\n', nUsed, nLoaded );
	
	% Calculate mean/std profiles for each component
	fprintf( 'Calculating mean and standard deviation...' );
	[N,Um,Urms] = nzstats( U, 3 );
	[~,Vm,Vrms] = nzstats( V, 3 );
	[~,Wm,Wrms] = nzstats( W, 3 );
	fprintf( ' success.\n' );
	
	clear U V W

	% Remove locations for which there were no vectors
	Um( Um == 0 ) = NaN;		Urms( Urms == 0 ) = NaN;
	Vm( Vm == 0 ) = NaN;		Vrms( Vrms == 0 ) = NaN;
	Wm( Wm == 0 ) = NaN;		Wrms( Wrms == 0 ) = NaN;
	
	% Prepare outputs
	fprintf( 'Preparing output file...' );
	
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
	
	out.N		= measurement( 'Number of Samples', 'N', '', N );
	out.type	= measurement( 'PIV Type', '', '', type );
	out.source	= measurement( 'Source Location', '', '', src );
	
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
	out.timestamp.value{2} = [ avgdate '. Ensemble averaged using ' num2str(nUsed) ' of ' num2str(nLoaded) ' images.' ];

	clear acqdate acqtype avgdate nImgs
	
	fprintf( ' success.\n' );
	
	% Export average of each run
	dout = fullfile( resFolder, proj, day );
	if ~exist(dout,'dir'), mkdir(dout); end
	fout = fullfile( dout, [run '.mat'] );
	save( fout, '-struct', 'out' );
	fprintf( 'Processed PIV data exported: "%s"\n', fout );
	
	clear proj day run fs N out dout fout

	fprintf('\n');
end

fprintf('PIV processing complete!\n');
beep;