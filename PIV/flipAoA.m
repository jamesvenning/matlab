function [ fs, dout ] = flipAoA( fs, d )
%FLIPAOA Invert the angle of attack (+/-) on a set of PIV mat files.
%	This function inverts the Y-axis on a set of PIV mat files, effectively
%	switching the sign (+/-) on the angle of attack. It also flips all
%	matrices top to bottom to maintain correct orientation of the data.


% Check inputs
if ~exist( 'fs', 'var' )
	[fs d] = uigetfile( '.mat', 'MultiSelect', 'on' );
end

if ischar(fs), fs={fs}; end

% Create output directory if it doesn't exist
dout = fullfile( d, 'flipped' );
if ~exist( dout, 'dir' ), mkdir(dout); end

% Process each mat file
nFiles = length(fs);
for n=1:nFiles
	% Load the input file
	ff = fullfile( d, fs{n} );
	a = load( ff );
	
	% Load a list of all the variables
	vars = fieldnames(a);
	
	% Step through each variable
	nVars = length(vars);
	for i=1:nVars
		var = vars{i};
		
		% Skip this variable if isn't a measurement object
		if ~strcmpi( class(a.(var)), 'measurement' ), continue; end
		
		% Skip this variable if it isn't a matrix
		if any( size(a.(var).value) < 2 ), continue; end
		
		% Flip the matrix top to bottom
		a.(var).value = flipdim( a.(var).value, 1 );
		
	end
	
	% Invert the y-axis
	a.Y.value = fliplr( -a.Y.value );
	a.Vm.value = -a.Vm.value;
	
	% Timestamp for flipping
	stamp = [ datestr( now, 31 ) '. Flipped top to bottom.' ];
	if isfield( a, 'timestamp' )
		a.timestamp.value{end+1} = stamp;
	else
		a.timestamp = measurement( 'Timestamp History', '', '', {stamp} );
	end
	
	% Save the output file
	fout = fullfile( dout, fs{n} );
	save( fout, '-struct', 'a' );
	
end