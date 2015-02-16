function [ Cp Cl Cd Cm ] = calcCpCl( xc, H, P, Pinf, Q, close, yc, aoa )
% Calculates Cp and Cl given the tap locations and pressure information.


if ~exist( 'close', 'var' ), close = false; end

if ~exist( 'aoa', 'var' ), aoa = 15; end

% How many samples are there?
nSamp = size(P,1);

% Replicate Pinf and/or Q if only one value is provided
if numel(Pinf)==1, Pinf = repmat(Pinf,nSamp,1); end
if numel(Q)==1, Q = repmat(Q,nSamp,1); end

% Calculate Cp
for n = 1:nSamp
  	Cp(n,:) = ( P(n,:) + Pinf(n) )/Q(n);
end

% Find last pressure tab
I	= find( xc==max(xc), 1, 'first' );

% Re-order data for easy integration
xc	= [ -fliplr( xc(1:I) )	fliplr( xc((I+1):end) ) ];
H	= [ fliplr( H(1:I) )	fliplr( H((I+1):end) ) ];
Cp	= [ fliplr( Cp(:,1:I ))	fliplr( Cp(:,(I+1):end) ) ];

% Close the Cp curve
if close
	Cp(:,end+1)	= Cp(:,1);
	xc(end+1)	= -xc(1);
	yc(end+1)	= yc(1);
    H(end+1)	= H(1);
end

% Calculate panel lengths
ds	= sqrt( diff(xc).^2 + diff(yc).^2 );
s	= cumsum( [0 ds] );

% Lift and drag
Ht	= H + aoa*pi/180;
Cl	= -trapz( s, Cp.*repmat(sin(Ht),nSamp,1), 2 );
Cd	= trapz( s, Cp.*repmat(cos(Ht),nSamp,1), 2 );

% Coefficient of moment, defined such that GLE nose up is positive
Cm	= -trapz( s, ( Cp .* repmat(yc,nSamp,1) .* repmat(cos(H),nSamp,1) ), 2 ) ...
		+ trapz( s, ( Cp .* repmat(0.25-abs(xc),nSamp,1) .* repmat(sin(H),nSamp,1) ), 2 );

% Re-order Cp back to standard
Cp	= [ fliplr(Cp(:,1:I))	fliplr(Cp(:,(I+1):end)) ];