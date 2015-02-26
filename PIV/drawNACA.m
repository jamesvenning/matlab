function drawNACA( series, varargin )
%DRAWNACA Draw a NACA series airfoil in the currently active figure. The
%input must be in the form of a string, i.e. drawNACA('0015').
%	drawNACA( '####', a, b ) - chord line from point a to point b
%	drawNACA( '####', angle ) - GLE at 0 with specified angle of attack,
%		assumes a normalized image


if nargin == 3
	a = varargin{1};
	b = varargin{2};

elseif nargin == 2
	H = varargin{1};
	a = [0,0];	b = -8/1.2*[cosd(H),sind(H)];
	
	clear H;

else
	a = [0,0];	b = [1,0];
		
end

% Split the series into its components
m = str2num( series(1) )/100;			% Maximum camber
p = str2num( series(2) )/10;			% Location of maximum camber
t = str2num( series(3:4) )/100;			% Thickness

% Generate axis along chord with more points near the nose
x = logspace( 0, 3, 101 );
x = (x-min(x))/range(x);

% Mean camber line
if ( m == 0 )
	yc = 0;

else
	k = ( x <= p );
	yc(k) = m/p^2 * x(k) .* ( 2*p - x(k) );
	
	k = ( x > p );
	yc(k) = m/(1-p)^2 * ( 1 - x(k) ) .* ( 1 + x(k) - 2*p );

end

% Half-thickness
yt = t/0.2 * ( 0.2969*sqrt(x) - 0.1260*x - 0.3516*x.^2 + 0.2843*x.^3 - 0.1015*x.^4 );

% Upper and lower surface lines
y1 = yc + yt;
y2 = yc - yt;

% Close the loop
x = [ x fliplr(x) ];
y = [ y1 fliplr(y2) ];

% Coordinate transformation
s = sqrt( (b(1)-a(1))^2 + (b(2)-a(2))^2 );
q = atan2( b(2)-a(2), b(1)-a(1) );
[x y] = scale( x, y, s );
[x y] = rotate( x, y, q );
[x y] = translate( x, y, a );

% Guarantee the airfoil is on top of all other data
z = 0.1*ones(size(x));

% Draw the airfoil
hold on;
fill3( x, y, z, 'k' );
hold off;


% Subfunctions
function [x2 y2] = scale( x1, y1, s )
	x2 = s*x1;
	y2 = s*y1;

function [x2 y2] = rotate( x1, y1, q )
	x2 = cos(q)*x1 - sin(q)*y1;
	y2 = sin(q)*x1 + cos(q)*y1;
	
function [x2 y2] = translate( x1, y1, a )
	x2 = a(1) + x1;
	y2 = a(2) + y1;