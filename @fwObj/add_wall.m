function obj = add_wall(obj, wall_name, offset)

%  Function to add abdominal wall.
%
%  Calling:
%           obj.add_wall('r75hi')
%
%  Parameters:
%           wall_name           - String of wall name
%           offset              - Lateral offset from center (m)
%
%  James Long, 01/16/2019

if ~exist('offset','var'); offset=0; end

dY = obj.grid_vars.dY;
dZ = obj.grid_vars.dZ;
[cwall, rhowall, attenwall, Bwall] = img2fieldFlatten(wall_name,dY,dZ);

if size(cwall,1) < obj.grid_vars.nY; error('Simulation width exceeds wall width.'); end
if size(cwall,2) > obj.grid_vars.nZ; error('Wall depth exceeds simulation depth.'); end

% Offset %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nY = obj.grid_vars.nY;
nW = size(cwall,1);
pad = round((nW-nY)/2);
offset = round(offset/obj.grid_vars.dY);
wall_select = (pad+1:pad+nY)+offset;

if any(wall_select < 1) || any(wall_select > nW); error('Offset exceeds wall width.'); end
cwall = cwall(wall_select,:); 
rhowall = rhowall(wall_select,:); 
attenwall = attenwall(wall_select,:); 
Bwall = Bwall(wall_select,:); 

% Apply Gaussian blur %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cwall = imgaussfilt(cwall,obj.input_vars.ppw/12);
rhowall = imgaussfilt(rhowall,obj.input_vars.ppw/12);
attenwall = imgaussfilt(attenwall,obj.input_vars.ppw/12);
Bwall = imgaussfilt(Bwall,obj.input_vars.ppw/12);

% Add to field_maps structure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj.field_maps.cmap(:,1:size(cwall,2)) = cwall;
obj.field_maps.rhomap(:,1:size(cwall,2)) = rhowall;
obj.field_maps.attenmap(:,1:size(cwall,2)) = attenwall;
obj.field_maps.Bmap(:,1:size(cwall,2)) = Bwall;

end