function [ X,Y,Z, U,V,W ] = loadVC7( fs, pivtype, frame )
% Load a set of VC7 files
% NOTE: This version of loadVC7 uses transformations specific to the
% low-speed wind tunnel.


fprintf( 'Loading VC7 data...' );

% Allow for single file input as string
if ischar(fs), fs={fs}; end

% Use the first frame if none specified
if nargin<3, frame=1; end

%% Load the first image and preallocate matrices

nFiles = length(fs);

% Get first file
imx = readimx( fs{1} );

h = figure;			% Create temporary home for showimx vector plot
if rem(pivtype,2)==0
	% 2D PIV
	vec = showimx( imx.Frames{frame} );
	x1 = vec.X;
	x2 = vec.Y;
	u1 = vec.U;
	u2 = vec.V;
	
	if nFiles>1
		u1(:,:,nFiles) = zeros( size(u1) );
		u2(:,:,nFiles) = zeros( size(u2) );
	end
	
else
	% 3D PIV
	vec = showimx( imx.Frames{frame} );
	x1 = vec.X;
	x2 = vec.Y;
	x3 = vec.Z;
	u1 = vec.U;
	u2 = vec.V;
	u3 = vec.W;
	
	if nFiles>1
		u1(:,:,nFiles) = zeros( size(u1) );
		u2(:,:,nFiles) = zeros( size(u2) );
		u3(:,:,nFiles) = zeros( size(u3) );
	end
	
end
close(h);			% Close showimx vector plot

clear imx h

%% Load the remaining images

for i=2:nFiles
	% Get current file
    imx = readimx( fs{i} );
	
	h = figure;		% Create temporary home for showimx vector plot
	if rem(pivtype,2)==0
		% 2D PIV
		vec = showimx( imx.Frames{frame} );
		u1(:,:,i) = vec.U;
		u2(:,:,i) = vec.V;

	else
		% 3D PIV
		vec = showimx( imx.Frames{frame} );
		u1(:,:,i) = vec.U;
		u2(:,:,i) = vec.V;
		u3(:,:,i) = vec.W;

	end
	close(h);		% Close showimx vector plot
	
	clear imx h
end

%% Perform coordinate transformation
% (x1,x2,x3) and (u1,u2,u3) are relative to the calibration plate
% (X,Y,Z) and (U,V,W) are relative to physical tunnel

switch pivtype
	case 0			% Spanwise, 2D
	
	case 1			% Spanwise, 3D

	case 2			% Streamwise, 2D
		X = fliplr( -x1(:,1)' );
		Y = fliplr( x2(1,:) );
		Z = 0;
		
		U = flipdim( flipdim( -u1, 1 ), 2 );
		V = flipdim( flipdim( u2, 1 ), 2 );
		W = zeros( size(u1) );

	case 3			% Streamwise, 3D
		X = fliplr( x1(:,1)' );
		Y = fliplr( x2(1,:) );
		Z = x3(1,1);
		
		U = flipdim( flipdim( -u1, 1 ), 2 );
		V = flipdim( flipdim( u2, 1 ), 2 );
		W = u3;

end

clear pivtype x1 x2 x3 u1 u2 u3

U = permute( U, [2 1 3] );
V = permute( V, [2 1 3] );
W = permute( W, [2 1 3] );

%% Done!

fprintf( ' successfully loaded %g files.\n', nFiles );