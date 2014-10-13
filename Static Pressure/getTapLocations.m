function [ xc closed unused ] = getTapLocations( airfoil )
% Returns the normalized tap locations for the specified airfoil.


switch lower(airfoil)
	case { 'a1', 'naca0015-smooth' }
		chord	= 8;
		xc		= [0 0.04 0.08 0.12 0.16 0.32 0.48 0.64 0.8 1.2 1.6 2.4 3.2 4 4.8 5.6 6.4 7.2 8 7.2 6.4 5.6 4.8 4 3.2 1.6 1.2 0.8 0.64 0.48 0.32 0.16 0.12 0.08 0.04]/chord;
		closed	= true;
		unused	= [ 26:32, 43:48 ];

	case { 'a2', 'naca0015-recess' }
		chord	= 8;
		xc		= [0 0.04 0.08 0.12 0.16 0.32 0.48 0.64 0.8 1.2 1.6 2.4 3.2 4 4.8 5.6 6.4 7.2 8 7.2 6.4 5.6 4.8 4 3.2 1.6 1.2 0.85 0.64 0.48 0.32 0.16 0.12 0.08 0.04]/chord;
		closed	= false;
		unused	= [ 26:32, 43:48 ];

	case { 'a3', 'boeing-vr7' }
		chord	= 7.96;
		xc		= [0.00 0.08 0.13 0.21 0.31 0.47 0.66 0.78 1.09 1.55 2.26 3.21 4.81 5.46 6.44 7.25 7.60 7.60 7.25 6.45 5.49 4.85 3.88 3.24 2.28 1.58 1.08 0.75 0.65 0.44 0.30 0.13 0.05 0.02]/chord;
		closed	= true;
		unused	= [ 26:32, 42:48 ];

end