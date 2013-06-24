function [] = scaleXY( xscale, yscale, fh )
%SCALEXY Rescale the X and Y axes of a figure.


if ~exist ('fh', 'var' )
	% If no figure handle is provided, use the current figure
	fh = gcf;
end

if strcmpi( fh, 'all' )
	% If all figures are wanted, get a list
	fh = findall( 0, 'Type', 'Object' );
end

%%
% Loop through all figures
nFigs = length(fh);
for f=1:nFigs
	
	lh = findall( fh(f), 'Type', 'Line' );
	
	% Loop through all lines
	nLines = length(lh);
	for l=1:nLines
		
		% Get the current x/y data
		x = get( lh(l), 'XData' );
		y = get( lh(l), 'YData' );
		
		% Set the new x/y data
		set( lh(l), 'XData', x*xscale );
		set( lh(l), 'YData', y*yscale );
		
	end
	
end