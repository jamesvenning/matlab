function [ similar ] = findSimilarImages( U, V, thresh, k )
%FINDSIMILARIMAGES


fprintf( 'Detecting images with correlation > %g...', thresh );

%
if nargin<3, thresh = 0.8; end
if nargin<4, k = 1; end

% Reshape each image into a single column
U = permute(U,[2 1 3]);		U = reshape(U,[],size(U,3),1);
V = permute(V,[2 1 3]);		V = reshape(V,[],size(V,3),1);
Q = [U; V];

% Remove rows of all zeros (masked areas, etc.)
Q( sum(abs(Q))==0, : ) = [];

% Calculate the correlation coefficient between each column
cc = corrcoef( Q );

% Sort each 'correlation set' by best overall correlation
ccTotals = sum( cc, 2 );
[~,i] = sort(ccTotals,'descend');

% Keep the kth-best correlated set (defaults to first)
i = i(k);
ccSubset = cc(i,:);

% Sort by correlation value (useful when reducing set)
[ccSubset j] = sort(ccSubset,'descend');

% Downselect based on correlation threshold
keep = ( ccSubset > thresh );
similar = j(keep);

fprintf( ' downselected %g images.\n', sum(keep) );