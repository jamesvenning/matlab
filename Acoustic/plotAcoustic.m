function [ h ] = plotAcoustic( varargin )
%PLOTACOUSTIC Generate a plot of selected acoustic spectra.

% Program defaults
c1		= 0.059;					% Blockage height [m]
sep		= 10;						% Separation between spectra [dB]
offset	= 0;						% Offset of spectra [dB]
dy		= 10;						% Y-axis grid increment [dB]
annoX	= 0.03;						% X location of St annotations
underlay= false;					% Underlay cases with the baseline?
order	= [];						% Specific ordering of spectra

%% Process inputs

% Get list of spectra to plot
if ~isempty(varargin) && iscell(varargin{1})
	fs = varargin{1};
else
	fs = uigetfile( '.mat', 'MultiSelect', 'on' );
	if ischar(fs), fs={fs}; end
end

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
if any( strcmpi(varargin,'grid') )
	% Override the grid size
	i = find( strcmpi(varargin,'grid') );
	if isnumeric(varargin{i+1}),	dy = varargin{i+1};
	else							error('Grid flag must be followed by numeric value.');
	end
end
if any( strcmpi(varargin,'baselineUnderlay') )
	% Underlay every case with the baseline
	i = find( strcmpi(varargin,'baselineUnderlay') );
	if islogical(varargin{i+1}),	underlay = varargin{i+1};
	else							error('Baseline underlay flag must be followed by boolean value.');
	end
end
if any( strcmpi(varargin,'order') )
	% Specify spectra order
	i = find( strcmpi(varargin,'order') );
	if isnumeric(varargin{i+1}),	order = varargin{i+1};
	else							error('Order flag must be followed by numeric value.');
	end
end

%% Reorganize files and determine non-dimensionalization

% Determine the excitation Strouhal number of each case
for n=1:length(fs)
	
	s = regexpi( fs{n}, 'ff(?<ff>[0-9]+)', 'names' );
	ff(n) = str2double(s.ff);

end

if ~isempty(order)
	% Sort according to manual input
	fs = fs(order);
else
	% Otherwise, sort by ascending frequency
	[ff i] = sort(ff);
	fs = fs(i);
end

% Determine baseline non-dimensionalization factor (length over velocity)
if any(ff==0)
	bl = load( fs{find(ff==0,1,'first')} );		% Use the first, if more than one
	l_v = c1/manometer( bl.Tinf.value, bl.Po.value, bl.Pinf.value, bl.Pamb.value );
else
	l_v = 1;
end

% Non-dimentionalize the excitation frequencies
Stf = ff*l_v;

%% Load the relevant data

for n=1:length(fs)
	
	a = load( fs{n} );
	
	St(:,n) = a.f.value*l_v;
	dB(:,n) = a.PSD.value + (1-n)*sep + offset;
	
end

%% Generate the plot

figure;

% Plot a bunch of baselines
if underlay
	if ~exist('bl','var')
		
		warning('No baseline provided, skipping underlay.');
		
	else

		for n=1:length(fs),	dB_bl(:,n) = bl.PSD.value + (1-n)*sep + offset;
		end

		h = semilogx( St, dB_bl, ...
			'color', [0.5 0.5 0.5], ...
			'handlevisibility', 'off' ...		% Hide from legend
			);
		hold on;
	
	end
end

% Plot all loaded spectra
semilogx( St, dB );

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
yy = round(annoY/dy)*dy - dy*[1 1 2 2];
hold on; plot( xx, yy, '-k', 'linewidth', 2 );
text( 2.5e-2, mean(yy), [num2str(dy) ' dB'], ...
	'background', 'white' ...
	);

% Format axes
grid on;
set( gca, ...
	'xlim', [0.02 2], ...
	'ytick', -400:dy:200, ...
	'yticklabel', [] ...
	);

xlabel('Strouhal Number, St'); ylabel('SPL [dB]');