function [ fsout, dout ] = averagePIV( fs, d )
%AVERAGEPIV Average a set of PIV files.
%	Mean velocity is averaged using  A* = ?( N·A )/?( N )  and RMS velocity
%	is averaged using  A* = ?[ ?( (N-1)·A² )/?( N )]  where (·) is
%	element-wise multiplication.


% Check inputs
if ~exist( 'fs', 'var' )
	[fs d] = uigetfile( '.mat', 'MultiSelect', 'on' );
end

if ischar(fs), fs={fs}; end

% Create output directory if it doesn't exist
dout = fullfile( d, 'averaged' );
if ~exist( dout, 'dir' ), mkdir(dout); end

% Extract configuration from each filename
runs = regexprep( fs, '\.mat', '' );
conf = regexprep( runs, '_[0-9]{2}$', '' );

% Each case has a unique configuration
cases = unique(conf);

% Average all runs of each case
nCases = length(cases);
for n=1:nCases
	
	% Which runs for this case?
	subRuns = strcmpi( cases{n}, conf );
	subfs = fs(subRuns);

	% Load each run
	nSubRuns = length(subfs);
	for m=1:nSubRuns
		a(m) = load( fullfile(d,subfs{m}) );
	end
	
	% Initialize the output by copying all of the first-run inputs
	b = a(1);
	
	%
	Um = a(1).N.value .* a(1).Um.value;
	Vm = a(1).N.value .* a(1).Vm.value;
	Wm = a(1).N.value .* a(1).Wm.value;
	Urms = (a(1).N.value-1) .* (a(1).Urms.value).^2;
	Vrms = (a(1).N.value-1) .* (a(1).Vrms.value).^2;
	Wrms = (a(1).N.value-1) .* (a(1).Wrms.value).^2;
	N = a(1).N.value;
	
	%
	for m=2:nSubRuns
		Um = Um + a(m).N.value .* a(m).Um.value;
		Vm = Vm + a(m).N.value .* a(m).Vm.value;
		Wm = Wm + a(m).N.value .* a(m).Wm.value;
		Urms = Urms + (a(m).N.value-1) .* (a(m).Urms.value).^2;
		Vrms = Vrms + (a(m).N.value-1) .* (a(m).Vrms.value).^2;
		Wrms = Wrms + (a(m).N.value-1) .* (a(m).Wrms.value).^2;
		N = N + a(m).N.value;
	end
	
	%
	b.Um.value = Um./N;
	b.Vm.value = Vm./N;
	b.Wm.value = Wm./N;
	b.Urms.value = sqrt(Urms./N);
	b.Vrms.value = sqrt(Vrms./N);
	b.Wrms.value = sqrt(Wrms./N);
	
	clear Um Vm Wm Urms Vrms Wrms N
	
	% Timestamp for averaging
	stamp = [ datestr( now, 31 ) '. Averaged using ' nSubRuns ' runs.' ];
	if isfield( a, 'timestamp' )
		b.timestamp.value{end+1} = stamp;
	else
		b.timestamp = measurement( 'Timestamp History','','', {stamp} );
	end
	
	% Save the output file
	fsout{n} = [cases{n} '.mat'];
	fout = fullfile( dout, fsout{n} );
	save( fout, '-struct', 'b' );
	
end