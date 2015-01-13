% Place this file in your default working directory.
% Windows:	C:/Users/<user>/Documents/MATLAB
% Linux:	/home/<user>/Documents/MATLAB

% Define commonly used parameters
setenv( 'matpref_expFolder', '/home/clifford.69/network/lst on gdtl-nas/RFoA/Experiments' );

% Add local readimx binaries
addpath( genpath('/home/clifford.69/Documents/MATLAB/readimx') );

% Move to the common codes folder and add everything to the path
cd '/home/clifford.69/network/lst on gdtl-nas/Common/Code/MATLAB'
addToPath;