function [] = animateSwirl( fs, d )
%ANIMATESWIRL


% Check inputs
if ~exist( 'fs', 'var' )
	[fs d] = uigetfile( '.mat', 'MultiSelect', 'on' );
end

if ischar(fs), fs={fs}; end

%% Process the filenames
for n=1:length(fs)
	
	% Extract the frequency
	s = regexpi( fs{n}, 'ff(?<ff>[0-9]+)', 'names' );
	if isempty(s),		ff(n) = 0;
	else				ff(n) = str2double( s.ff );
	end
	
	% Extract the phase
	s = regexpi( fs{n}, 'pa(?<pa>[0-9]+)', 'names' );
	if isempty(s),		pa(n) = 0;
	else				pa(n) = str2double( s.pa );
	end
	
end

% Order the files by frequency, then by phase
[~,i] = sortrows([ ff' pa' ]);
ff = ff(i);
pa = pa(i);
fs = fs(i);

%% Create an animated GIF for each frequency
uff = unique( ff );

for n=1:length(uff)
	
	fset = find( ff == uff(n) );
	
	% FIRST FRAME
	a = load( fullfile( d, fs{fset(1)} ) );
	
	% 
	[x y]=meshgrid(a.X.value,a.Y.value);
	u = a.Um.value;		v = a.Vm.value;
	
	% Apply a simple smoothing filter
	u = filter2( ones(3)/9, u );
	v = filter2( ones(3)/9, v );
	
	% Condition the matrices
	u( isnan(u) | isinf(u) ) = 0;
	v( isnan(v) | isinf(v) ) = 0;
	
	% Calculate the swirling strength
	[~,L1] = VortexID(x,y,u,v);
	
	% Plot the swirling strength
	fh = figure; ah = axes;
	pcolor( x, y, L1 ); shading interp; axis image;
	c = colorbar; caxis([0 2]);
	
	% Label everything
	set(get(c,'ylabel'),'string','L [Hz]');
	xlabel( a.X.describe ); ylabel( a.Y.describe );
	title([ 'f_F = ' num2str(uff(n)) ' Hz' ]);

	drawNACA( '0015', 15 );
	
	set(fh,'color','w');
	set(fh,'renderer','zbuffer');
	
	annoPhase( pa(fset(1)) );
	
	frame = getframe(fh);
	[im,map] = rgb2ind(frame.cdata,256,'nodither');
	
	% REMAINING FRAMES
	for k=2:length(fset)
		
		a = load( fullfile( d, fs{fset(k)} ) );
		
		% 
		u = a.Um.value;		v = a.Vm.value;
		
		% Apply a simple smoothing filter
		u = filter2( ones(3)/9, u );
		v = filter2( ones(3)/9, v );
		
		% Condition the matrices
		u( isnan(u) | isinf(u) ) = 0;
		v( isnan(v) | isinf(v) ) = 0;
		
		% Calculate the swirling strength
		[~,L1] = VortexID(x,y,u,v);
		
		% Plot the swirling strength
		clf(fh); ah = axes;
		pcolor( x, y, L1 ); shading interp; axis image;
		c = colorbar; caxis([0 2]);
		
		% Label everything
		set(get(c,'ylabel'),'string','L [Hz]');
		xlabel( a.X.describe ); ylabel( a.Y.describe );
		title([ 'f_F = ' num2str(uff(n)) ' Hz' ]);
		
		drawNACA( '0015', 15 );
		
		annoPhase( pa(fset(k)) );
		
		frame = getframe(fh);
		im(:,:,1,k) = rgb2ind(frame.cdata,map,'nodither');

	end
	
	fout = fullfile( d, [ num2str(uff(n)) 'hz.gif' ] );
	imwrite(im,map,fout,'DelayTime',0.5,'LoopCount',Inf);
	
end