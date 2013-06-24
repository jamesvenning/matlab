classdef measurement
%MEASUREMENT Describe an experimental measurement.
%   The measurement class contains descriptive information about data
%   obtained experimentally.

	properties				% For example:
		name = '';			% 'Ambient Temperature'
		symbol = '';		% 'T_o'
		units = '';			% 'K'
		value = [];			% 293.15
	end
	
	properties (Dependent)
		print				% 'Ambient Temperature, T_o: 293.15 K'
		describe			% 'Ambient Temperature, T_o [K]'
	end

	methods
		%
		% Constructor
		%
		function m = measurement( name, symbol, units, value )
			if nargin>0, m.name = name; end
			if nargin>1, m.symbol = symbol; end
			if nargin>2, m.units = units; end
			if nargin>3, m.value = value; end
		end
		
		%
		% Object set methods
		%
		function obj = set.name( obj, val )
			if ischar(val),		obj.name = val;
			else				error('NAME property must be a string.');
			end
		end

		function obj = set.symbol( obj, val )
			if ischar(val),		obj.symbol = val;
			else				error('SYMBOL property must be a string.');
			end
		end
		
		function obj = set.units( obj, val )
			if ischar(val),		obj.units = val;
			else				error('UNITS property must be a string.');
			end
		end
		
		function obj = set.value( obj, val )
			% For flexibility, no restrictions are placed on the data type
			% of the measurement value
			obj.value = val;
		end
		
		%
		% Object get methods
		%
		function val = get.print( obj )
			% Print everything known about the measurement (useful for
			% debugging)
			% FORMAT: (name)(, symbol)(: value (units))
			val = obj.name;
			if ~isempty( obj.symbol )
				val = [val ', ' obj.symbol];
			end
			if ~isempty( obj.value )
				if numel(obj.value) == 1
					val = [val ': ' num2str(obj.value)];
				else
					val = [val ': <matrix>'];
				end
				if ~isempty( obj.units )
					val = [val ' ' obj.units];
				end
			end
		end
		
		function val = get.describe( obj )
			% Describe the measurement (useful for labeling axes)
			% FORMAT: (name)(, symbol)( [units])
			val = obj.name;
			if ~isempty( obj.symbol )
				val = [val ', ' obj.symbol];
			end
			if ~isempty( obj.units )
					val = [val ' [' obj.units ']'];
			end
		end
	end
	
end