function obj = add_wall(obj, wall_name, offset)

%  Function to create transducer related fields. Call parameters
%  keywords-style.
%
%  Calling:
%           obj.make_speckle('nscat',15,'csr',0.05,'nC',0)
%
%  Parameters:
%           sc_params       - Structure of scatterer parameters
%                               nscat:      Scatterers per resolution cell (15)
%                               csr:        Scatterer impedance contrast (0.05)
%                               nC:         Number of cysts (0)
%                               rC:         Vector of cyst radii (m), length
%                                           equal to nC
%                               cC:         Matrix of cyst center locations
%                                           in [y,z] (m), length equal to nC
%                               zC:         Vector of cyst impedance
%                                           contrast, length equal to nC
%
%  James Long, 12/10/2018 (Code partially from Nick Bottenus)

dY = obj.grid_vars.dY;
dZ = obj.grid_vars.dZ;
c0 = obj.input_vars.c0;
rho = obj.input_vars.rho;
[cwall, rhowall, awall, boverawall] = img2fieldFlatten(wall_name,dY,dZ,c0,rho);

if size(cwall,1) < obj.grid_vars.nY; error('Simulation width exceeds wall width.'); end
if size(cwall,2) > obj.grid_vars.nZ; error('Wall depth exceeds simulation depth.'); end

nY = obj.grid_vars.nY;
nW = size(cwall,1);
pad = round((nW-nY)/2);
wall_select = pad+1:pad+nY;

cwall = cwall(wall_select,:); obj.field_maps.cmap(:,1:size(cwall,2)) = cwall;
rhowall = rhowall(wall_select,:); obj.field_maps.rhomap(:,1:size(cwall,2)) = rhowall;
awall = awall(wall_select,:); obj.field_maps.amap(:,1:size(cwall,2)) = awall;
boverawall = boverawall(wall_select,:); obj.field_maps.boveramap(:,1:size(cwall,2)) = boverawall;
end