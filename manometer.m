function [ V, Re ] = manometer( Tinf, Po, Pinf, Pamb )
%MANOMETER Calculates velocity from temperature and pressure data. Inputs
%must be in SI units.


if nargin==0
	% Import values from workspace if none are provided
	Tinf	= evalin( 'base', 'Tinf.value' );
	Po		= evalin( 'base', 'Po.value' );
	Pinf	= evalin( 'base', 'Pinf.value' );
	Pamb	= evalin( 'base', 'Pamb.value' );
end

k	= 1.05;			% Tunnel calibration constant, see Little 2010 p.33
c	= 0.2032;		% Airfoil chord length [m]
mu	= 1.8e-5;		% Dynamic viscosity of air [N-s/m2]

Q	= k*( Po + Pinf );		% Dynamic pressure [Pa]
P	= Pamb - Pinf;			% Static pressure [Pa]
rho = P/(287*Tinf);			% Density of air [kg/m3]

V	= sqrt( 2*Q/rho );		% Velocity [m/s]
Re	= rho*V*c/mu;			% Reynolds number