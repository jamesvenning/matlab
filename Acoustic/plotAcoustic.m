function [ h ] = plotAcoustic( fs, d, varargin )
%PLOTACOUSTIC Generate a plot of selected acoustic spectra.

% Program defaults
c1		= 0.0509;					% Blockage height [m]
sep		= 10;						% Separation between spectra [dB]
offset	= 0;						% Offset of spectra [dB]
annoX	= 0.03;						% X location of St annotations

%% Process inputs

% Request inputs if none are given
if ~exist( 'fs', 'var' )
	[fs d] = uigetfile( '.mat', 'MultiSelect', 'on' );
end
if ischar(fs), fs={fs}; end

% Look for additional plotting flags
if any( strcmpi(varargin,'separation') )
	% Override the seperation between spectra
	i = find( strcmpi(varargin,'separation') );
	if isnumeric(varargin{i+1}),	sep = varargin{i+1};
	else							error('Separation flag must be followed by numeric value.');
	end
end
if any( strcmpi(varargin,'offset') )
	% Override the offset
	i = find( strcmpi(varargin,'offset') );
	if isnumeric(varargin{i+1}),	offset = varargin{i+1};
	else							error('Offset flag must be followed by numeric value.');
	end
end

%% Reorganize files and determine non-dimensionalization

% Determine the excitation Strouhal number of each case
for n=1:length(fs)
	
	s = regexpi( fs{n}, 'ff(?<ff>[0-9]+)', 'names' );
	ff(n) = str2double(s.ff);

end

% Sort file set by ascending frequency
[ff i] = sort(ff);
fs = fs(i);

% Determine baseline non-dimensionalization factor (length over velocity)
bl = load( fs{ff==0} );
l_v = c1/manometer( bl.Tinf.value, bl.Po.value, bl.Pinf.value, bl.Pamb.value );

% Non-dimentionalize the excitation frequencies
Stf = ff*l_v;

%% Load the relevant data

for n=1:length(fs)
	
	a = load( fs{n} );
	
	St(:,n) = a.f.value*l_v;
	dB(:,n) = a.PSD.value + (1-n)*sep + offset;
	
end

%% Generate the plot

% Plot all loaded spectra
figure; semilogx( St, dB );

% Annotate each spectrum with corresponding Strouhal number
for n=1:length(fs)
	
	[~,i] = min( abs( St(:,n) - annoX ) );
	annoY = dB(i,n);
	
	text( annoX, annoY, num2str(Stf(n),'%.2f'), ...
		'background', 'white', ...
		'horizontalalign', 'center' ...
		);
	
end

% Annotate y-axis separation
xx = [1.8 2.2 2.2 1.8]*1e-2;
yy = floor(annoY/10)*10 - [10 10 20 20];
hold on; plot( xx, yy, '-k', 'linewidth', 2 );
text( 2.5e-2, mean(yy), [num2str(sep) ' dB'], ...
	'background', 'white' ...
	);

% Format axes
grid on;
set( gca, ...
	'xlim', [0.02 2], ...
	'ytick', -400:sep:200, ...
	'yticklabel', [] ...
	);

xlabel('Strouhal Number, St'); ylabel('SPL [dB]');