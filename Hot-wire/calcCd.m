function [] = calcCd(fs,d)

% Check the inputs
if ~exist( 'fs', 'var' )
	[fs d] = uigetfile( '*1.mat', 'MultiSelect', 'on' );
end

if ischar(fs), fs={fs}; 
end

% Constants
R = 287;

%Preallocate matrices
nFiles = length(fs);
re = zeros(1,nFiles);
Cd = zeros(1,nFiles);

% Loop through each file
for n = 1:nFiles
    % Load the data
   	ff	= fullfile( d, fs{n} );
 	data = load( ff );
    
    % Calculate coefficient of drag
    yd = data.Y.value./30.5; % dimensionless vertical position
    Ufree = sqrt(2*(data.Po.value+data.Pinf.value)*R*data.To.value/(data.Pamb.value-data.Pinf.value));
    Unorm = data.Um.value/Ufree; % dimensionless velocity
    Cd(n) = trapz(yd,(Unorm).*(1-Unorm));
        
    % Find Re value for plotting
	expr = ['_re(?<re>[0-9\-]+)'];				
	s = regexpi(fs{n}, expr, 'names' );
    re(n) = str2num(s.re);
end





    



