function [ Cm ] = calcCm( xc, yc, H, Cp, close )
% Calculates the coefficient of moment. Note that xc, yc, and H should be
% in the airfoil reference frame and thus NOT transformed. This function
% will be merged with calcCpCl in the future.


% How many samples are there?
nSamp = size(Cp,1);

% 
I	= find( xc==max(xc), 1, 'first');

% Re-order data for easy integration
xc	= [ -fliplr(xc(1:I))	fliplr(xc((I+1):end)) ];
yc	= [ fliplr(yc(1:I))		fliplr(yc((I+1):end)) ];
H	= [ fliplr(H(1:I))		fliplr(H((I+1):end)) ];
Cp	= [ fliplr(Cp(:,1:I))	fliplr(Cp(:,(I+1):end)) ];

if close
	xc(end+1)	= -xc(1);
	yc(end+1)	= yc(1);
    H(end+1)	= H(1);
end

% Coefficient of moment, defined such that ALE nose up is positive
Cm	= trapz( xc, ( Cp .* repmat(yc,nSamp,1) .* repmat(cos(H),nSamp,1) ), 2 ) ...
		+ trapz( xc(1:I), ( Cp(:,1:I) .* repmat((0.25-xc(1:I)),nSamp,1) .* repmat(sin(H(1:I)),nSamp,1) ), 2 ) ...
		+ trapz( xc(I:end), ( Cp(:,I:end) .* repmat((xc(I:end)-0.25),nSamp,1) .* repmat(sin(H(I:end)),nSamp,1) ), 2 );