function processSinglePIV( Tamb, Pamb, type )
%PROCESSSINGLEPIV


% Declare program parameters
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

% Convert ambient conditions to SI units
Tamb = f2k(Tamb);			% Convert temperature from °F to K
Pamb = mbar2pa(Pamb);		% Convert pressure from mbar to Pa


%% Begin main program

[fs d] = uigetfile( '.vc7', 'MultiSelect','on' );
if ischar(fs), fs={fs}; end

% Extract folder ancestry from path
dd = regexpi( d, '\', 'split' );

% Figure out which ancestor is the day
dayIndex = length(dd) - 4;		% NOTE: THIS METHOD IS NOT ROBUST

proj	= dd{dayIndex-1};		% Extract name of project
day		= dd{dayIndex};			% Extract day
run		= dd{dayIndex+1};		% Extract name of specific run/case

clear dd dayIndex
	
% Process each file
J = length(fs);
for j=1:J
	% Identify the image being processed
	image = regexp( fs{j}, '\d+', 'match', 'once' );
		
	% Load single selected file
	[ X,Y,Z, U,V,W ] = loadVC7( d, fs{j}, type );
		
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
	
	clear X Y Z Um Vm Wm Urms Vrms Wrms N
	
	% Export average of each run
	dout = fullfile( resFolder, proj, day, 'Instantaneous Samples' );
	if ~exist(dout,'dir'), mkdir(dout); end
	fout = fullfile( dout, [run '_' image '.mat'] );
	save( fout, '-struct', 'out' );
	fprintf( '\tVelocity component averages exported: %s\n', fout );
	
	clear image N out dout fout

	fprintf('\n');
end

fprintf('PIV processing complete!\n');
beep;