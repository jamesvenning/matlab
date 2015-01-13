% This is a one-off code to process the PSD of a microphone voltage trace.
clear all; close all; clc;

% Acquisition parameters
samples		= 8192;
blocks		= 50;
freq		= 80e3;

% Select the data containing folder
dataFolder = uigetdir( 'Select the folder containing acoustic data' );

allFiles = dir( fullfile(dataFolder,'*.txt') );
allFiles = {allFiles.name}';

nFiles = length(allFiles);
for n=1:nFiles
	fid		= fopen( fullfile(dataFolder,allFiles{n}) );
	data	= textscan( fid, '%f', ...
		'HeaderLines', 22, ...
		'CollectOutput', 1 );
	fclose( fid );

	% Deal out the data
	data	= data{1};
	v		= data(:,1);
	
	vf		= v - mean(v);
	
	% Calculate the PSD
	[PSD Hz] = calPSD( vf, samples, freq, 'hann', 0, [0,0] );
	
	% Plot the PSD
	figure; loglog( Hz, PSD );
	xlim([20 20000]); ylim(10.^[-12 -2]);
	xlabel('Hz'); ylabel('V');
	title( allFiles{n} );
end