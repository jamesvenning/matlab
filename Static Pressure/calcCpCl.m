function [ Cp Cl ] = calcCpCl( xc, P, Pinf, Q, close )
% Calculates Cp and Cl given the tap locations and pressure information.


if ~exist( 'close', 'var' ), close = false; end

% How many samples are there?
nSamp = size(P,1);

% Replicate Pinf and/or Q if only one value is provided
if numel(Pinf)==1, Pinf = repmat(Pinf,nSamp,1); end
if numel(Q)==1, Q = repmat(Q,nSamp,1); end

% Calculate Cp
for n = 1:nSamp
  	Cp(n,:) = ( P(n,:) + Pinf(n) )/Q(n);
end

% Close the Cp curve
if close
	Cp(:,end+1) = Cp(:,1);
	xc(end+1) = xc(1);
end

% Integrate Cp to get Cl
Cl = -trapz( xc, Cp' );