function [ h ] = plotStaticPressure( varargin )
%PLOTSTATICPRESSURE Generate a plot of selected static surface pressure
%contours.


% Program defaults
c1		= 0.059;					% Blockage height [m]

%% Process inputs

% Get list of countours to plot
if ~isempty(varargin) && iscell(varargin{1})
	fs = varargin{1};
else
	fs = uigetfile( '.mat', 'MultiSelect', 'on' );
	if ischar(fs), fs={fs}; end
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
	
	xc(:,n) = a.xc.value;
	Cp(:,n) = a.Cp.value;
	
end

%% Generate the plot

% Plot all loaded spectra
figure; plot( xc, Cp );

% Format axes
grid on;
set( gca, ...
	'xlim', [0 1], ...
	'xdir', 'reverse', ...
	'ydir', 'reverse' ...
	);

xlabel(a.xc.describe); ylabel(a.Cp.describe);

% Generate legend
legend( num2str(Stf','%.2f'), 'location', 'southeast' );
