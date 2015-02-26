function drawVR7( varargin )
%DRAWNACA Draw a VR7 airfoil in the currently active figure.
%	drawVR7( a, b ) - chord line from point a to point b
%	drawVR7( angle ) - GLE at 0 with specified angle of attack,
%		assumes a normalized image


if nargin == 2
	a = varargin{1};
	b = varargin{2};

elseif nargin == 1
	H = -varargin{1};
	a = [0,0];
    b = [cosd(H),sind(H)];
    
    clear H

else
	a = [0,0];	b = [1,0];
		
end

% Coordinates
x = .01*[ 0	0.5	1	2	3	4	5	6	7	8.5	10.2	12	14	16	18	20	22.5	25.5	29	33	37	41	45	49	53	57	61	65	69	73	77	81	84.5	88	91	93.5	95.5	98	100	98	95.5	93.5	91	88	84.5	81	77	73	69	65	61	57	53	49	45	41	37	33	29	25.5	22.5	20	18	16	14	12	10.2	8.5	7	6	5	4	3	2	1	0.5	0 ];
y = .01*[ 0	-0.575	-0.81	-1.09	-1.29	-1.445	-1.585	-1.71	-1.805	-1.985	-2.145	-2.285	-2.41	-2.51	-2.6	-2.66	-2.73	-2.8	-2.85	-2.89	-2.9	-2.85	-2.75	-2.6	-2.4	-2.2	-1.99	-1.79	-1.58	-1.38	-1.17	-0.97	-0.791	-0.613	-0.459	-0.332	-0.23	-0.102	0	0.331	0.745	1.078	1.49	1.99	2.57	3.15	3.81	4.47	5.14	5.8	6.46	7.1	7.67	8.16	8.56	8.87	9.05	9.14	9.09	8.92	8.67	8.38	8.08	7.75	7.37	6.91	6.45	5.93	5.41	5.025	4.605	4.15	3.615	2.98	2.18	1.65	0 ];

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