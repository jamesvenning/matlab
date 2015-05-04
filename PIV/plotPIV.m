function [ h ] = plotPIV( varargin )
%PLOTPIV plots a colormap of the listed quantities for each selected MAT
%file.
%	Valid quantities: 'u','v','vort','tke'


% Which quantities should be plotted?
if nargin<1,	plist = {'u','v'};
else			plist = varargin;
end
nPlots = length(plist);

% Which data should they be plotted for?
[fs,d] = uigetfile( '.mat', 'MultiSelect', 'on' );
if ischar(fs), fs={fs}; end

% Loop through each file
nFiles = length(fs);
for n=1:nFiles
	
	ff = fullfile( d, fs{n} );
	load( ff );
	
	% One figure per file
	h(n) = figure;
	
	% Loop through each quantity
	for m=1:nPlots
		
		% One subfigure per quantity
		subplot( nPlots, 1, m );
		
		switch lower(plist{m})
			case {'u','um'}
				pcolor( X.value, Y.value, Um.value ); 
				title( Um.name );
				
			case {'v','vm'}
				pcolor( X.value, Y.value, Vm.value );
				title( Vm.name );
				
			case {'urms'}
				pcolor( X.value, Y.value, Urms.value );
				title( Urms.name );
				
			case {'vrms'}
				pcolor( X.value, Y.value, Vrms.value );
				title( Vrms.name );
				
			case {'vort'}
				pcolor( X.value, Y.value, curl(X.value,Y.value,Um.value,Vm.value) );
				title( 'Vorticity' );
				
			case {'tke'}
				% For another time
		
		end
		
		shading interp;
		colorbar;
		ylabel( Y.describe );
		
	end
		
end