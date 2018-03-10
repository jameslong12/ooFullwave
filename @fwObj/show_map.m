function show_map(obj, map_name)

%  Method to show map of choice
%
%  Calling:
%           obj.show_map(map_name)
%
%  Parameters:
%           map_name            - Name of map to display ('cmap')
%
%  James Long, 03/10/2018

if ~exist('map_name','var'), map_name = 'cmap'; end

switch map_name
    case {'cmap', 'c'}
        map = obj.field_maps.cmap';
    case {'rhomap', 'rho'}
        map = obj.field_maps.rhomap';
    case {'attenmap', 'atten'}
        map = obj.field_maps.attenmap';
    case {'boveramap', 'bovera'}
        map = obj.field_maps.boveramap';
    otherwise
        error('Invalid map name.')
end

imagesc(obj.grid_vars.y_axis, obj.grid_vars.z_axis, map)
xlabel('y (mm)'); ylabel('z (mm)'); title(map_name);
axis image
colormap jet
colorbar

end