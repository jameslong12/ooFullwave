function obj = make_points(obj, varargin)

%  Function to add point targets to map
%
%  Calling:
%           obj.make_points('pos',15,'zd',0.05)
%
%  Optional parameters:
%
%  James Long, 12/17/2018

%%% Use inputParser to set optional parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%
p = inputParser;
addOptional(p,'pos',[0 obj.input_vars.wZ/2])    % Laterally centered, half depth
addOptional(p,'zd',0.5)                         % 50% impedance

p.parse(varargin{:})
var_struct = p.Results;
assignments = extract_struct(var_struct);
for i = 1:length(assignments)
    eval(assignments{i})
end

%%% Place points in map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for idx = 1:size(pos,2)
    [~,iy] = min(abs(obj.grid_vars.y_axis-pos(idx,1)));
    [~,iz] = min(abs(obj.grid_vars.z_axis-pos(idx,2)));
end

