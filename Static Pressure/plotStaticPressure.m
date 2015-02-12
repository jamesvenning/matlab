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
    
    s = regexpi( fs{n}, 'aa(?<ff>[0-9]+)', 'names' );
	aa(n) = str2double(s.ff);
    
    s = regexpi( fs{n}, 're(?<ff>[0-9]+)', 'names' );
	re(n) = str2double(s.ff);

end

% Sort file set by ascending frequency
[ff i] = sort(ff);
fs = fs(i);

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
	
	xc(:,n) = a.xc.value;
	Cp(:,n) = a.Cp.value;
    Cl(n) = a.Cl.value;
    Cd(n) = a.Cd.value;
	
end

%% Generate primary plot ( Cp vs x/c )

% Determine varying parameter

[~,I]=sort([sum(abs(diff(aa))>0),sum(abs(diff(re))),sum(abs(diff(ff)))],'descend');

if I(1)==1
    xx = aa;
    xl = 'Angle of Attack [\circ]';
elseif I(2)==1
    xx = re;
    xl = 'Reynolds Number';
else
	xx = Stf;
    xl = 'Strohal Number';
end

% Plot all loaded contours
figure; plot( xc, Cp );

% Format axes
grid on;
set( gca, ...
	'xlim', [0 1], ...
	'xdir', 'normal', ...
	'ydir', 'reverse' ...
	);

xlabel(a.xc.describe); ylabel(a.Cp.describe);

% Generate legend
if any(ff==0)
    legend( num2str(xx','%.2f'), 'location', 'southeast' );
else
    legend( num2str(xx','%g'), 'location', 'southeast' );
end

%% Generate secondary plots ( Lift and Drag vs ? )

% Lift
figure; plot( xx, Cl )
grid on;
xlabel(xl); ylabel('Coefficient of Lift');

% Drag
figure; plot( xx, Cd )
grid on;
xlabel(xl); ylabel('Coefficient of Drag');