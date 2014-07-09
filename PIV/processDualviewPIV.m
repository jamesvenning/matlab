function processDualviewPIV( Tamb, Pamb, varargin )
%PROCESSPIV


%% Declare program defaults

% PIV (input) base folder
pivFolder = '\\gdtl-nas\LST\RFoA\Experiments\PIV';

% Results (output) base folder
resFolder = '\\gdtl-nas\LST\RFoA\Experiments\Results';

% Group like configurations?
group = false;

% Threshold for conditional averaging
condThresh = -1;

% Splice line on the x-axis
splice = 0;


%% Process inputs

% Request inputs if none are given
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
if any( strcmpi(varargin,'results') )
	% Override the output folder
	i = find( strcmpi(varargin,'results') );
	if ischar(varargin{i+1}),		resFolder = varargin{i+1};
	else							error('Results flag must be followed by path string.');
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
if any( strcmpi(varargin,'splice') )
	% Override the splice line
	i = find( strcmpi(varargin,'splice') );
	if isnumeric(varargin{i+1}),	splice = varargin{i+1};
	else							error('Splice flag must be followed by numeric x value');
	end
end

clear i

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
	
% 	if group
% 		% Skip this run if it's a repeat configuration (already loaded)
% 		if regexp( run, '_[0-9]{2}$' ), continue; end
% 		
% 		% Select VC7 files from grouped PostProc folders
% 		i=0; fs=[]; src=[];
% 		while (j+i)<=J && ~isempty(strfind(pp{j+i},run))
% 			dlist = dir( fullfile( pp{j+i}, '*.vc7' ) );
% 			fs = [ fs; strcat( pp{j+i}, '\', {dlist.name}' ) ];
% 			src{i+1} = pp{j+i};
% 			i = i+1;
% 		end
% 		
% 		if length(src)==1, src=src{1}; end
% 	else
		% Select VC7 files from this PostProc folder
		dlist = dir( fullfile( pp{j}, '*.vc7') );
		fs = strcat( pp{j}, '\', {dlist.name}' );
		src = pp{j};
% 	end
	
	clear i dlist
	
	% Load all selected files
	[ a.X,a.Y,a.Z, a.U,a.V,a.W ] = loadVC7( fs, 1 );
	[ b.X,b.Y,b.Z, b.U,b.V,b.W ] = loadVC7( fs, 2 );
	nLoaded = size( a.U, 3 );
	
	% Fix the grid of image 2, this assumes that both images have the same
	% spatial resolution!
	b.X = b.X + ???;
	b.Y = b.Y + ???;
	
	% Generate a common grid, this assumes that image 1 is SW of image 2
	X = a.X(1):(a.X(2)-a.X(1)):b.X(end);
	Y = a.Y(1):(a.Y(2)-a.Y(1)):b.Y(end);
	[a.X b.Y] = meshgrid(a.X,a.Y);
	[b.X b.Y] = meshgrid(b.X,b.Y);
	[c.X c.Y] = meshgrid(X,Y);			% Don't overwrite X,Y
	[U V] = deal( zeros(size(X)) );
	
	%
	U = interp2( a.X,a.Y, a.U, c.X,c.Y, 'cubic', 0 );
	V = interp2( a.X,a.Y, a.V, c.X,c.Y, 'cubic', 0 );
	
	%
	U = U + interp2( b.X,b.Y, b.U, c.X,c.Y, 'cubic', 0 );
	V = V + interp2( b.X,b.Y, b.V, c.X,c.Y, 'cubic', 0 );
	
	clear a b
	
%  	% Remove any bad images
%  	bad = findBadImages( U, V );
%  	U = U(:,:,~bad);	V = V(:,:,~bad);	W = W(:,:,~bad);
% 	
% 	clear bad
	
% 	% Select similar images for conditional averaging
% 	if condThresh>0
% 		sim = findSimilarImages( U, V, condThresh, 1 );
% 		U = U(:,:,sim);		V = V(:,:,sim);		W = W(:,:,sim);
% 		
% 		clear sim
% 	end
	
	nUsed = size( U, 3 );
	
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
	
	out.N		= measurement( 'Number of Samples', 'N', '', N );
	out.type	= measurement( 'PIV Type', '', '', 2 );
	out.source	= measurement( 'Source Location', '', '', src );
	
	clear X Y Z Um Vm Wm Urms Vrms Wrms N
	
	% Timestamp for acquisition and averaging
	out.timestamp = measurement( 'Timestamp History' );

	acqdate = [ day(1:4) '-' day(5:6) '-' day(7:8) ' 12:00:00' ];
	acqtype = 'streamwise 2D PIV';
	out.timestamp.value{1} = [ acqdate '. Acquired using ' acqtype '.' ];

	avgdate = datestr( now, 31 );
	out.timestamp.value{2} = [ avgdate '. Ensemble averaged using ' num2str(nUsed) ' of ' num2str(nLoaded) ' images.' ];

	clear acqdate acqtype avgdate nImgs
	
	% Export average of each run
	dout = fullfile( resFolder, proj, day );
	if ~exist(dout,'dir'), mkdir(dout); end
	fout = fullfile( dout, [run '.mat'] );
	save( fout, '-struct', 'out' );
	fprintf( '\tVelocity component averages exported: %s\n', fout );
	
	clear proj day run fs N out dout fout

	fprintf('\n');
end

fprintf('PIV processing complete!\n');
beep;