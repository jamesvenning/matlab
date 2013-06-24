function [ Cp Cl ] = calcCpCl( xc, P, Pinf, Q, close )
% Calculates Cp and Cl given the tap locations and pressure information.


if ~exist( 'close', 'var' ), close = false; end

% Arrage the data so each row corresponds to a pressure tap
P = reshape( P, length(xc), [] );

% Calculate Cp
nSets = length(Pinf);
for n = 1:nSets
	Cp(:,n) = ( P(:,n) + Pinf(n) )/Q(n);
end

% Close the Cp curve
if close
	Cp(end+1,:) = Cp(1,:);
	xc(end+1) = xc(1);
end

% Integrate Cp to get Cl
Cl = -trapz( xc, Cp );