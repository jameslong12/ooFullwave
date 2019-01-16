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
c0 = obj.input_vars.c0;
rho = obj.input_vars.rho;
[cwall, rhowall, attenwall, betawall] = img2fieldFlatten(wall_name,dY,dZ,c0,rho);

if size(cwall,1) < obj.grid_vars.nY; error('Simulation width exceeds wall width.'); end
if size(cwall,2) > obj.grid_vars.nZ; error('Wall depth exceeds simulation depth.'); end

nY = obj.grid_vars.nY;
nW = size(cwall,1);
pad = round((nW-nY)/2);
offset = round(offset/obj.grid_vars.dY);
wall_select = (pad+1:pad+nY)+offset;

if any(wall_select < 1) || any(wall_select > nW); error('Offset exceeds wall width.'); end
cwall = cwall(wall_select,:); obj.field_maps.cmap(:,1:size(cwall,2)) = cwall;
rhowall = rhowall(wall_select,:); obj.field_maps.rhomap(:,1:size(cwall,2)) = rhowall;
attenwall = attenwall(wall_select,:); obj.field_maps.attenmap(:,1:size(cwall,2)) = attenwall;
betawall = betawall(wall_select,:); obj.field_maps.betamap(:,1:size(cwall,2)) = betawall;
end