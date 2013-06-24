function [ ah ] = annoPhase( angle )
%ANNOPHASE Annotate phase angle.


% Create and position the subplot
ah = axes;
set( ah, 'Position', [0.1 0.1 0.1 0.1] );

% Create the clock face
lh1 = plot( ah, cosd(0:15:360), sind(0:15:360), '-k' );
set( lh1, 'LineWidth', 3 );

% Create the clock hand
hold on;
lh2 = plot( ah, [0 0.8*cosd(90-angle)], [0 0.8*sind(90-angle)], '-k' );
set( lh2, 'LineWidth', 3 );

% 
axis equal; axis off;
xlim([-1.1 1.1]); ylim([-1.1 1.1]);