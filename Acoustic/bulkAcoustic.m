function bulkAcoustic( gain )

if ~exist( 'gain', 'var' )
	% If no gain is specified, just assume the standard value
	gain = 10.0e-3;		% [V/Pa]
end

% Get the list of data-containing directories to be processed
ds = uigetdir2();

nDirs = length(ds);
for k=1:nDirs
	% Include all coordinates
	fs = dir( fullfile( ds{k}, '*.txt' ) );
	fs = {fs.name}';
	
	processAcoustic( fs, [ds{k} '\'], gain );		% Directory needs trailing slash
end