function [ xc close ] = getTapLocations( airfoil )
% Returns the normalized tap locations for the specified airfoil.


switch lower(airfoil)
	case 'a1'
		c = 8;
		xc = [0 0.04 0.08 0.12 0.16 0.32 0.48 0.64 0.8 1.2 1.6 2.4 3.2 4 4.8 5.6 6.4 7.2 8 7.2 6.4 5.6 4.8 4 3.2 1.6 1.2 0.8 0.64 0.48 0.32 0.16 0.12 0.08 0.04]/c;
		close = true;

	case 'a2'
		c = 8;
		xc = [0 0.04 0.08 0.12 0.16 0.32 0.48 0.64 0.8 1.2 1.6 2.4 3.2 4 4.8 5.6 6.4 7.2 8 7.2 6.4 5.6 4.8 4 3.2 1.6 1.2 0.85 0.64 0.48 0.32 0.16 0.12 0.08 0.04]/c;
		close = false;

end