function [ h ] = plotPIV( fs, d )


if ~exist( 'fs', 'var' )
	[fs d] = uigetfile( '.mat', 'MultiSelect', 'on' );
end

if ischar(fs), fs={fs}; end

nFiles = length(fs);
for n=1:nFiles
	ff = fullfile( d, fs{n} );
	load( ff );
	
	h(n) = figure;
	
	subplot(2,1,1); axis equal;
		pcolor( X.value, Y.value, Um.value ); shading interp;
		%hold on; drawNACA( '0015', [1 0], [0 0] );
		c = colorbar; set( get(c,'ylabel'), 'string', Um.symbol );
		ylabel( Y.describe );
		title( Um.name );
	
	subplot(2,1,2); axis equal;
		pcolor( X.value, Y.value, Vm.value ); shading interp;
		%hold on; drawNACA( '0015', [1 0], [0 0] );
		c = colorbar; set( get(c,'ylabel'), 'string', Vm.symbol );
		xlabel( X.describe ); ylabel( Y.describe );
		title( Vm.name );
end