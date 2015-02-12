function [ eps_t ] = blockageCorrFactor( airfoil, AoA, height )
% Returns the blockage correction factor for a given geometry and angle of
% attack.

% Obtain airfoil parameters
[ xc closed unused H yc chord ] = getTapLocations( airfoil );

% Obtain wind tunnel parameters (assuming model span is the span of the
% wind tunnel)
if ~exist('height','var')
    height = 24;		% [inches]
end

% Re-scale data
xc = xc*chord;
yc = yc*chord;

% Separate data into upper and lower surfaces
I	= find( xc == max(xc), 1, 'first' );
xcu	= xc(1:I);
xcl	= fliplr(xc(I+1:end));
ycu	= yc(1:I);
ycl	= fliplr(yc(I+1:end));

% Interpolate between taps for smoother profile
x	= (0:.025:1)*chord;
yu	= spline(xcu,ycu,x);
yl	= spline(xcl,ycl,x);

% Recombine into single profile (overwrites original x/c and y/c)
xc = [x fliplr(x(2:end))];
yc = [yu fliplr(yl(2:end))];

% Apply rotation
xc2 = cosd(AoA)*xc - sind(AoA)*yc;
yc2 = sind(AoA)*xc + cosd(AoA)*yc;

% Blockage height
bH = range( yc2 );

% Blockage correction factor
eps_t = bH/(4*height);