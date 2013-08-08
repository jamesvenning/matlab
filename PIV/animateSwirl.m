function [] = animateSwirl( fs, d )
%ANIMATESWIRL


% Check inputs
if ~exist( 'fs', 'var' )
	[fs d] = uigetfile( '.mat', 'MultiSelect', 'on' );
end

if ischar(fs), fs={fs}; end

%% Load each file and calculate the swirling strength
for n=1:length(fs)
	
	a = load( fullfile(d,fs{n}) );
	
	% Extract the frequency
	s = regexpi( fs{n}, 'ff(?<ff>[0-9]+)', 'names' );
	ff(n) = str2double( s.ff );
	
	% Extract the phase
	s = regexpi( fs{n}, 'pa(?<pa>[0-9]+)', 'names' );
	if isempty(s)
		pa(n) = 0;
	else
		pa(n) = str2double( s.pa );
	end
	
	% 
	if n==1, [x y]=meshgrid(a.X.value,a.Y.value); end
	u = a.Um.value;
	v = a.Vm.value;
	
	% Condition the matrices
	u( isnan(u) | isinf(u) ) = 0;
	v( isnan(v) | isinf(v) ) = 0;
	
	% Calculate the swirling strength
	[~,L1] = VortexID(x,y,u,v);
	
	% Apply a simple smoothing filter and store
	L(:,:,n) = filter2( ones(3)/9, L1 );
	
end

%% Order the stack by frequency, then by phase
[~,i] = sortrows([ ff' pa' ]);
ff = ff(i);
pa = pa(i);
L = L(:,:,i);

%% Create an animated GIF for each frequency
uff = unique( ff );

for n=1:length(uff)
	
	fset = find( ff == uff(n) );
	
	% First frame
	fh = figure(n); ah = axes;
	pcolor( x, y, L(:,:,fset(1)) ); shading interp; axis image;
	c = colorbar; set(get(c,'ylabel'),'string','L [Hz]');
	xlabel( a.X.describe ); ylabel( a.Y.describe ); caxis([0 2]);
	title([ 'f_F = ' num2str(uff(n)) ' Hz' ]);
	
	drawNACA( '0015', 15 );
	
	set(fh,'color','w');
	set(fh,'renderer','zbuffer');
	
	annoPhase( pa(fset(1)) );
	
	frame = getframe(fh);
	[im,map] = rgb2ind(frame.cdata,256,'nodither');
	
	% Remaining frames
	for k=2:length(fset)
		
		clf(fh); ah = axes;
		pcolor( x, y, L(:,:,fset(k)) ); shading interp; axis image;
		c = colorbar; set(get(c,'ylabel'),'string','L [Hz]');
		xlabel( a.X.describe ); ylabel( a.Y.describe ); caxis([0 2]);
		title([ 'f_F = ' num2str(uff(n)) ' Hz' ]);
		
		drawNACA( '0015', 15 );
		
		annoPhase( pa(fset(k)) );
		
		frame = getframe(fh);
		im(:,:,1,k) = rgb2ind(frame.cdata,map,'nodither');

	end
	
	fout = fullfile( d, [ num2str(uff(n)) 'hz.gif' ] );
	imwrite(im,map,fout,'DelayTime',0.5,'LoopCount',Inf);
	
end