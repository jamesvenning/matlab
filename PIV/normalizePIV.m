function [ fs, dout ] = normalizePIV( fs, d )
%NORMALIZEPIV Normalize a set of PIV mat files.


% Check inputs
if ~exist( 'fs', 'var' )
	[fs d] = uigetfile( '.mat', 'MultiSelect', 'on' );
end

if ischar(fs), fs={fs}; end

% Translation and normalization parameters
if exist( fullfile(d,'origin.m'), 'file' )
	% Load the parameters from a script if available
	run( fullfile(d,'origin.m') );
	if ~( exist('Xo','var') && exist('Yo','var') && exist('Zo','var') && exist('D','var') )
		error('Not all parameters defined in origin script.');
	end
else
	% Otherwise ask user for parameters
	
	% Save parameters to script for future use
	sprintf( [	'Xo	= %d;		% Trailing edge X coordinate [mm]\n'
				'Yo	= %d;		% Trailing edge Y coordinate [mm]\n'
				'Zo	= %d;		% Trailing edge Z coordinate [mm]\n'
				'D	= %d;		% Airfoil thickness [mm]' ], ...
				Xo, Yo, Zo, D );
end

% Create output directory if it doesn't exist
dout = fullfile( d, 'normed' );
if ~exist( dout, 'dir' ), mkdir(dout); end

% Process each mat file
nFiles = length(fs);
for n=1:nFiles
	% Load the input file
	ff = fullfile( d, fs{n} );
	a = load( ff );
	
 	% Get the freestream velocity
	sample = a.Um.value(end-2:end,:);			% USE THIS ONE FOR ATE
% 	sample = a.Um.value(10:70,10:30);			% USE THIS ONE FOR ALE
	Uinf = nanmean( sample(:) );
	
	% Perform a coordinate shift
	a.X.value = a.X.value - Xo;
	a.Y.value = a.Y.value - Yo;
	a.Z.value = a.Z.value - Zo;	
		
	% Load a list of all the variables
	vars = fieldnames(a);
	
	% Step through each variable
	nVars = length(vars);
	for i=1:nVars
		var = vars{i};
		
		% Skip this variable if isn't a measurement object
		if ~strcmpi( class(a.(var)), 'measurement' ), continue; end
		
		% Normalize each variable by
		% 1. dividing the variable by the appropriate quantity
		% 2. updating the symbol
		% 3. updating the units (unitless)
		switch lower( a.(var).units )
			case 'mm'
				% Normalize 'mm' quantities by airfoil thickness
				a.(var).value	= a.(var).value / D;
				a.(var).symbol	= [ a.(var).symbol '/D' ];
				a.(var).units	= '';

			case 'm/s'
				% Normalize 'm/s' quantities by freestream velocity
				a.(var).value	= a.(var).value / Uinf;
				a.(var).symbol	= [ a.(var).symbol '/u_\infty' ];
				a.(var).units	= '';
				
			otherwise
				% Do nothing

		end
		
	end
	
	% Include D and Uinf
	a.D		= measurement( 'Airfoil Thickness', 'D', 'mm', D );
	a.Uinf	= measurement( 'Freestream Velocity', 'u_\infty', 'm/s', Uinf );
	
	% Timestamp for normalization
	stamp = [ datestr( now, 31 ) '. Normalized using D=' num2str(D) ' mm and Uinf=' num2str(Uinf) ' m/s.' ];
	if isfield( a, 'timestamp' )
		a.timestamp.value{end+1} = stamp;
	else
		a.timestamp = measurement( 'Timestamp History','','', {stamp} );
	end
	
	% Save the output file
	fout = fullfile( dout, fs{n} );
	save( fout, '-struct', 'a' );
	
end