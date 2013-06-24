function bulkAcoustic()

% Get the list of data-containing directories to be processed
ds = uigetdir2();

nDirs = length(ds);
for k=1:nDirs
	% Include all coordinates
	fs = dir( fullfile( ds{k}, '*.txt' ) );
	fs = {fs.name}';
	
	processAcoustic( fs, [ds{k} '\'] );		% Directory needs trailing slash
end