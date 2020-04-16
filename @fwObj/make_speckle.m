function obj = make_speckle(obj, varargin)

%  Function to add scatterers and optional cyst(s) to map
%
%  Calling:
%           obj.make_speckle('nscat',15,'csr',0.05,'nC',0)
%
%  Optional parameters:
%           nscat:      Scatterers per resolution cell (15)
%           csr:        Scatterer impedance contrast (0.05)
%           nC:         Number of cysts (0)
%           rC:         Vector of cyst radii (m), length equal to nC
%           cC:         Matrix of cyst center locations in [y,z] (m), length equal to nC
%           zC:         Vector of cyst impedance contrast, length equal to nC
%           offset:     Axial offset of scatterers and wall in lambda (5)
%
%  James Long, 12/17/2018 (Code partially from Nick Bottenus)

%%% Use inputParser to set optional parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%
p = inputParser;
addOptional(p,'nC',0)
addOptional(p,'csr',0.05)
addOptional(p,'nscat',25)
addParameter(p,'rC',[])
addParameter(p,'cC',[])
addParameter(p,'zC',[])
addParameter(p,'offset',5);

p.parse(varargin{:})
var_struct = p.Results;
assignments = extract_struct(var_struct);
for i = 1:length(assignments)
    eval(assignments{i})
end

%%% Calculate resolution cell using input variables %%%%%%%%%%%%%%%%%%%%%%%
res_cell = rescell2d(obj.input_vars.c0, obj.input_vars.omega0, obj.input_vars.wZ/2,...
    obj.input_vars.wY, obj.input_vars.ncycles, obj.grid_vars.dY,...
    obj.grid_vars.dZ);

%%% Randomly place scatterers according to density %%%%%%%%%%%%%%%%%%%%%%%%
scat_density = nscat/res_cell;
cscatmap = rand(obj.grid_vars.nY, obj.grid_vars.nZ)-0.5;
cscatmap(abs(cscatmap) > scat_density) = 0;
cscatmap = cscatmap/scat_density;

%%% Create lesions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nC
    if size(cC,1) ~= nC || length(rC) ~= nC || length(zC) ~= nC
        error('cC, rC, and zC must match nC.')
    end
    for idx = 1:nC
        [z_int, y_int] = meshgrid(obj.grid_vars.z_axis, obj.grid_vars.y_axis);
        lesion_mask = (y_int-cC(idx,1)).^2+(z_int-cC(idx,2)).^2 < rC(idx).^2;
        cscatmap(lesion_mask) = zC(idx)*cscatmap(lesion_mask);
    end
end

%%% Superimpose original cmap and cscatmap %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obj.field_maps.cmap = obj.field_maps.cmap+cscatmap*csr.*obj.field_maps.cmap;

%%% Axial offset %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
z_standoff = obj.input_vars.c0/obj.input_vars.f0*offset/2;
n_shift = find(obj.grid_vars.z_axis>=z_standoff,1);
obj.field_maps.cmap(:,1:n_shift) = obj.input_vars.c0;
obj.field_maps.rhomap(:,1:n_shift) = obj.input_vars.rho;
obj.field_maps.attenmap(:,1:n_shift) = obj.input_vars.atten;
if(obj.input_vars.v==1)
    obj.field_maps.boveramap(:,1:n_shift) = obj.input_vars.boveramap;
elseif(obj.input_var.v==2)
    obj.field_maps.Bmap(:,1:n_shift) = obj.input_vars.B;
end

end