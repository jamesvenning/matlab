function [ coef ] = calcCoefs( tap, P, Pinf, Q )
%CALCCOEFS Summary of this function goes here
%   Detailed explanation goes here


% How many samples are there?
[ nSamples, nTaps ] = size(P);


%% Convert variables to matrix form

% Freestream pressure
if numel(Pinf)==1	
	% Singular, replicate rows and columns
	Pinf = repmat( Pinf, nSamples, nTaps );
elseif length(Pinf)==nSamples
	% Column vector, replicate columns
	Pinf = repmat( Pinf, 1, nTaps );
else
	error('Length of Pinf must equal the number of samples or one.')
end

% Dynamic pressure
if numel(Q)==1
	% Singular, replicate rows and columns
	Q = repmat( Q, nSamples, nTaps );
elseif length(Q)==nSamples
	% Column vector, replicate columns
	Q = repmat( Q, 1, nTaps );
else
	error('Length of Q must equal the number of samples or one.')
end

% x/c
if length(tap.xc)==nTaps
	% Row vector, replicate rows
	xc = repmat( tap.xc, nSamples, 1 );
else
	error('Length of xc must equal the number of taps.')
end

% y/c
if length(tap.yc)==nTaps
	% Row vector, replicate rows
	yc = repmat( tap.yc, nSamples, 1 );
else
	error('Length of yc must equal the number of taps.')
end

% Surface-normal angle
if length(tap.H)==nTaps
	% Row vector, replicate rows
	H = repmat( tap.H, nSamples, 1 );
else
	error('Length of H must equal the number of taps.')
end

%
Ht = H - aoa*(pi/180);


%% Calculate aerodynamic coefficients

% Coefficient of pressure
coef.pressure = ( P + Pinf )./ Q;

% Coefficient of lift
coef.lift = -trapz( s, coef.pressure.*sin(Ht), 2 );

% Coefficient of drag
coef.drag = -trapz( s, coef.pressure.*cos(Ht), 2 );

% Coefficient of moment, such that GLE nose-up is positive
coef.moment = -trapz( s, coef.pressure.*yc.*cos(H), 2 ) ...
				+ trapz( s, coef.pressure.*(0.25-abs(xc)).*sin(H), 2 );