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
addOptional(p,'zd',0.5)                         % 50% acoustic impedance

p.parse(varargin{:})
var_struct = p.Results;
assignments = extract_struct(var_struct);
for i = 1:length(assignments)
    eval(assignments{i})
end

if length(zd) == 1; zd = zd*ones(size(pos,2)); end
if length(zd) ~= size(pos,2); error('Size of zd and pos must match.'); end

%%% Place points in map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for idx = 1:size(pos,2)
    if abs(pos(idx,1)) > obj.input_vars.wY/2; error('Specified lateral position outside field range.'); end
    if pos(idx,2) > obj.input_vars.wZ || pos(idx,2) < 0; error('Specified axial position outside field range.'); end
    [~,iy] = min(abs(obj.grid_vars.y_axis-pos(idx,1)));
    [~,iz] = min(abs(obj.grid_vars.z_axis-pos(idx,2)));
    obj.field_maps.cmap(iy-1:iy+1,iz-1:iz+1) = zd(idx)*obj.field_maps(iy,iz);
end

