function [ Cp Cl ] = calcCpCl( xc, P, Pinf, Q, close )
% Calculates Cp and Cl given the tap locations and pressure information.


if ~exist( 'close', 'var' ), close = false; end

% Calculate Cp
nSets = size(P,1);
for n = 1:nSets
% 	Cp(n,:) = ( P(n,:) + Pinf(n) )/Q(n);
	Cp(n,:) = ( P(n,:) + Pinf )/Q;
end

% Close the Cp curve
if close
	Cp(:,end+1) = Cp(:,1);
	xc(end+1) = xc(1);
end

% Integrate Cp to get Cl
Cl = -trapz( xc, Cp' );