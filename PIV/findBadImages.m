function [ bad ] = findBadImages( U, V )
%FINDBADIMAGES


fprintf( 'Detecting bad images...' );

N = size(U,3);

bad = false(1,N);

% Some vectors will be missing from all images due to mask usage, laser
% constraints, and physical obstructions. Let's consider only those within
% the region of interest.
RoI = ( sum(U,3)~=0 & sum(V,3)~=0 );

for n=1:N
	u = U(:,:,n);
	v = V(:,:,n);
	
	% Check for at least 70% non-zero vectors
	coverage = sum( u(RoI)~=0 ) / numel( u(RoI) );
	if coverage<0.7
		bad(n) = true;
		continue;
	end
	
% 	% Check for a mean vertical velocity of at most 10 m/s
% 	vm = mean( v( RoI & v~=0 ) );
% 	if abs(vm)>10
% 		bad(n) = true;
% 		continue;
% 	end
% 	
% 	% Check for a mean freestream velocity of at least 10 m/s
% 	um = mean( u( RoI & u~=0 ) );
% 	if abs(um)<10
% 		bad(n) = true;
% 		continue;
% 	end
	
end

fprintf( ' %g images removed.\n', sum(bad) );