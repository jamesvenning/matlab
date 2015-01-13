function [c,h] = niceContourf( x,y,z, v )
%NICECONTOURF A wrapper function for contourf that uses a cool colormap
%with a color break at zero.


% Pass the arguments through to contourf
[c,h] = contourf( x,y,z, v );

% Load and apply the custom colormap
load('cool_range_custom');
map = CreateCustomMap( [v(1) v(end)], trange, brange );
colormap(map); caxis([v(1) v(end)]);