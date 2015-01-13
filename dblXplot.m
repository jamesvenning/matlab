function [H] = dblXplot( type, conv, varargin )

%dblXplot is a function to plot curves in a figure with two X axes, one on
%top, and the other on the bottom. The input arguments are the type of plot
%('loglog','linlin','linlog','loglin'), the relation between the two axes
%(use Xc in the expression to be the given horizontal coordinate) for
%example: 'Xc*15/500', and pairs of X and Y vectors. The function will
%return a vector of axis handles: the first to the data axis, the second to
%the axis that has the top axis on it.
%
%Handles = dblXplot('loglin','Xc*0.45 + 10',X1,Y1,X2,Y2,...);
%


%parsing the inputs
if nargin < 4
	fprintf(2,'\nError: Too few input arguments\n\n');
	return
	
elseif mod(length(varargin),2) ~= 0
	fprintf(2,'\nError: X and Y vectors must be entered in pairs\n\n');
	return
end

if ~ischar(type) || ~ischar(conv)
	fprintf(2,'\nError: The plot type, and conversion between X-coordinates must both be strings\n\n');
	return
	
elseif length(type) ~= 6
	fprintf(2,'\nError: The plot type must be ''loglog'', ''linlin'', ''loglin'', or ''linlog''\n\n');
	return
end

Xtyp = type(1:3); Ytyp = type(4:6);

if ~(strcmp(Xtyp,'log') || strcmp(Xtyp,'lin')) || ~(strcmp(Ytyp,'log') || strcmp(Ytyp,'lin'))
	fprintf(2,'\nError: The plot type must be ''loglog'', ''linlin'', ''loglin'', or ''linlog''\n\n');
	return
end

Np = length(varargin)/2;
X = cell(1,Np);
Y = X;

for k = 1:Np
	X{k} = varargin{2*k - 1};
	Y{k} = varargin{2*k};
	
	if ~isnumeric(X{k}) || ~isnumeric(Y{k})
		fprintf(2,'\nError: X and Y input pairs must be numeric vectors\n\n');
		return
		
	elseif length(X{k}) ~= length(Y{k})
		fprintf(2,'\nError: X and Y input pairs must be vectors of the same length\n\n');
		return
	end
end


%plotting the vectors
ff = figure; set(gcf,'color','white');
H = axes();
hold on
for k = 1:Np
	plot(X{k},Y{k});
end
hold off
set(H,'xscale',Xtyp,'yscale',Ytyp);


%adding the secondary axis
pos = get(H,'position');
Xc = get(H,'xlim'); Ylm = get(H,'ylim');

try
	Xlm = eval(conv);
catch
	fprintf(2,'\nError: The conversion expression entered is not a correct MATLAB expression\n\n');
	close(ff);
	return	
end

set(H,'box','off');
H2 = axes('position',pos);
set(H2,'box','off','xaxislocation','top','color','none');
set(H2,'yaxislocation','right');
set(H2,'xlim',Xlm,'ylim',Ylm);
set(H2,'xscale',Xtyp,'yticklabel',[]);

H(2) = H2;