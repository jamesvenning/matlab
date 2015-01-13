function addToPath()
% This function adds the parent folder to the user's path

% Where am I located relative to the user?
fullpath = mfilename('fullpath');   % Gets the full path and file name of this file
location = fileparts(fullpath);     % Cuts the file name off, leaving just the path

% Add folder and sub-folders to search path
addpath( genpath(location) );